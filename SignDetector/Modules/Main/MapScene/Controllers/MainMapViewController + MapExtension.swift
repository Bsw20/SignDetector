//
//  MainMapViewController + MapExtension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 29.05.2021.
//

import Foundation
import UIKit
import YandexMapsMobile
import CoreLocation

//MARK: - Main map delegates
extension MainMapViewController: YMKInertiaMoveListener, YMKMapSizeChangedListener, YMKMapCameraListener {
    class func findCenterPoint(_lo1: CLLocationCoordinate2D, _loc2: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let lon1 = _lo1.longitude * .pi / 180;
        let lon2 = _loc2.longitude * .pi / 180;

        let lat1 = _lo1.latitude * .pi / 180;
        let lat2 = _loc2.latitude * .pi / 180;

        let dLon = lon2 - lon1;

        let x = cos(lat2) * cos(dLon);
        let y = cos(lat2) * sin(dLon);

        let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) );
        let lon3 = lon1 + atan2(y, cos(lat1) + x);
        

        return CLLocationCoordinate2D(latitude: lat3 * 180 / .pi,
                                      longitude: lon3 * 180 / .pi)
    }

    
    private func getMiddlePointIn(region visibleRegion: YMKVisibleRegion) -> CLLocationCoordinate2D  {
        let topLeft = visibleRegion.topLeft
        let bottomRight = visibleRegion.bottomRight

        let middlePoint = MainMapViewController.findCenterPoint(_lo1: CLLocationCoordinate2D(latitude: topLeft.latitude, longitude: topLeft.longitude), _loc2: CLLocationCoordinate2D(latitude: bottomRight.latitude, longitude: bottomRight.longitude))
        
        return middlePoint
    }
    
    private func getRadiusIn(region visibleRegion: YMKVisibleRegion) -> Double {
        let topLeft = visibleRegion.topLeft
        let bottomRight = visibleRegion.bottomRight
        
        let firstLocation = CLLocation(latitude: topLeft.latitude, longitude: topLeft.longitude)
        let secondLocation = CLLocation(latitude: bottomRight.latitude, longitude: bottomRight.longitude)
        
        return firstLocation.distance(from: secondLocation) / 2
    }
    
    func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateReason: YMKCameraUpdateReason, finished: Bool) {
        guard finished else { return}
        print(#function)
        let map = mapView.mapWindow.map
        print("\(map.visibleRegion.bottomLeft.latitude) \(map.visibleRegion.bottomLeft.longitude)")
        
        let visibleRegion = map.visibleRegion
        if socket != nil {
//            print(".... \(topLeft.latitude) \(topLeft.longitude) \(bottomRight.latitude) \(bottomRight.longitude) \(middlePoint.latitude) \(middlePoint.longitude) \(radius)")
            socket.sendCurrentCoordinates(center: mapView.mapWindow.map.cameraPosition.target, topRight: visibleRegion.topRight, topLeft: visibleRegion.topLeft, bottomRight: visibleRegion.bottomRight, bottomLeft: visibleRegion.bottomLeft, filter: signsForFilter)
        }
        
    }
    
    func onMapWindowSizeChanged(with mapWindow: YMKMapWindow, newWidth: Int, newHeight: Int) {
        print(#function)
    }
    
    func onStart(with map: YMKMap, finish finishCameraPosition: YMKCameraPosition) {
        print(#function)
    }
    
    func onCancel(with map: YMKMap, cameraPosition: YMKCameraPosition) {
        print(#function)
    }
    
    func onFinish(with map: YMKMap, cameraPosition: YMKCameraPosition) {
        print(#function)
    }
    
}

//MARK: - YMKUserLocationObjectListener
extension MainMapViewController: YMKUserLocationObjectListener {
    func onObjectAdded(with view: YMKUserLocationView) {
        view.arrow.setIconWith(UIImage(named:"userLocationImage")!)
        
        let pinPlacemark = view.pin.useCompositeIcon()

        pinPlacemark.setIconWithName(
            "pin",
            image: UIImage(named:"userLocationImage")!,
            style:YMKIconStyle(
                anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
                rotationType:YMKRotationType.rotate.rawValue as NSNumber,
                zIndex: 1,
                flat: false,
                visible: true,
                scale: 1,
                tappableArea: nil))

        view.accuracyCircle.fillColor = #colorLiteral(red: 0.168627451, green: 0.1803921569, blue: 0.231372549, alpha: 0.1)
       
    }
    
    func onObjectRemoved(with view: YMKUserLocationView) {}
    
    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {
        print("UPDATE")
    }
}

//MARK: - SocketManagerDelegate
extension MainMapViewController: SocketManagerDelegate {
    func onSignsCountChanged(socket: Socket, newCount: Int) {
        onMainThread {[weak self] in
            self?.titleView.setSignsCount(count: newCount)
        }
    }
    
    func onNewSignReceived(socket: Socket, model: SignModel) {
        if let previousRect = previousRegion {
            let point = CGPoint(x: model.lon, y: model.lat)
            if previousRect.contains(point) {
//                let (slice, remainder) = previousRect.divided(atDistance: previousRect.width * 0.5, from: .minXEdge)
                let centerPoint = CGPoint(x: previousRect.midX, y: previousRect.midY)
                var clusterNumber = 0
                if point.x <= centerPoint.x && point.y <= centerPoint.y {
                    clusterNumber = 1
                } else if point.x > centerPoint.x && point.y <= centerPoint.y {
                    clusterNumber = 2
                } else if point.x <= centerPoint.x && point.y > centerPoint.y {
                    clusterNumber = 3
                } else  if point.x > centerPoint.x && point.y > centerPoint.y{
                    clusterNumber = 4
                }
                print("NUMBER")
                print(clusterNumber)
                addPointsToClusterCollection(clusterNumber: clusterNumber, models: [model])
            }
            
        }
    }
    
    func onSignsReceived(socket: Socket, model: ClusterModel, clusterNumber: Int) {

        let cv = getClusterViewWith(index: clusterNumber)
        cv.configure(count: model.size)
        cv.isHidden = model.size < Globals.clusterMaxSignsCount
        if model.size > Globals.clusterMaxSignsCount {
            deletePointsFromClusterCollection(points: getPointsIn(clusterNumber: clusterNumber))
            deletePointsFromClusterCollection(points: getPointsInInvisibleArea())
            if isAllSectorsClear() {
                print("ALLSECTORSCLEAR")
                previousRegion = nil
            }

        } else {
            let currentRegion = mapView.mapWindow.map.visibleRegion

            if let prRegion = previousRegion {
                if prRegion.contains(currentRegion.asCGRect()) &&  !prRegion.equalTo(currentRegion.asCGRect()) {
                    return
                } else {
//                    deletePointsIn(clusterNumber: clusterNumber)
//                    deletePointsInInvisibleRegion()
                    previousRegion = currentRegion.asCGRect()
                    deletePointsFromClusterCollection(points: getPointsIn(clusterNumber: clusterNumber))
                    deletePointsFromClusterCollection(points: getPointsInInvisibleArea())
                    addPointsToClusterCollection(clusterNumber: clusterNumber, models: model.signs)

                }
            } else {
                previousRegion = currentRegion.asCGRect()
                deletePointsFromClusterCollection(points: getPointsIn(clusterNumber: clusterNumber))
                deletePointsFromClusterCollection(points: getPointsInInvisibleArea())
                addPointsToClusterCollection(clusterNumber: clusterNumber, models: model.signs)
            }

        }

    }
    private func getClusterViewWith(index: Int) -> SignsClusterView {
        switch index {
        case 1:
            return firstClusterView
        case 2:
            return secondClusterView
        case 3:
            return thirdClusterView
        case 4:
            return fourthClusterView
        default:
            fatalError("Unknown view")
        }
    }
    
    private func isAllSectorsClear() -> Bool {
        return !firstClusterView.isHidden &&
            !secondClusterView.isHidden &&
            !thirdClusterView.isHidden &&
            !fourthClusterView.isHidden
    }

    
    func didConnect(socket: Socket) {
        print("did connect ViewController")
        let vr = mapView.mapWindow.map.visibleRegion
        socket.sendCurrentCoordinates(center: mapView.mapWindow.map.cameraPosition.target,
                                      topRight: vr.topRight,
                                      topLeft: vr.topLeft,
                                      bottomRight: vr.bottomRight,
                                      bottomLeft: vr.bottomLeft,
                                      filter: signsForFilter)
    }
    
    func didDisconnect(socket: Socket) {
        print("did disconnect ViewController")
    }
    
    func onMessageReceived(socket: Socket, message: String) {
        print("did receive message")
    }

    private func getPointsIn(clusterNumber: Int) -> [YMKPoint] {
        var points = [YMKPoint]()
        for el in pointsDict.keys {
            if pointsDict[el]?.0 == clusterNumber {
                points.append(el)
            }
        }
        return points
    }
    
    private func getPointsInInvisibleArea() -> [YMKPoint] {
        var points = [YMKPoint]()
        
        for el in pointsDict.keys {
            if !mapView.mapWindow.map.visibleRegion.contains(el) {
                points.append(el)
            }
        }
        
        return points
    }
    
    private func deletePointsIn(clusterNumber: Int) {
        pointsDict.keys.forEach {[weak self] key in
            guard let self = self else { return }
            guard let tup = pointsDict[key] else { return }
            if tup.0 == clusterNumber {
                mapView.mapWindow.map.mapObjects.remove(with: tup.1)
                pointsDict.removeValue(forKey: key)
                print("DELETED POINT IN")
            }
        }
    }
    private func deletePointsInInvisibleRegion() {
        pointsDict.keys.forEach { [weak self] key in
            guard let self = self else { return}
            guard let tup = pointsDict[key] else { return }
            if !mapView.mapWindow.map.visibleRegion.contains(key) {
                mapView.mapWindow.map.mapObjects.remove(with: tup.1)
                pointsDict.removeValue(forKey: key)
                print("DELETE FROM INVISIBLE AREA")
            }
        }
    }
}

//MARK: - YMKClusterizedPlacemarkCollection
extension MainMapViewController: YMKClusterListener, YMKClusterTapListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setIconWith(clusterImage(cluster.size))
        cluster.addClusterTapListener(with: self)
    }
    
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        UIApplication.showAlert(title: "Уведомление", message: String(format: "В это кластере %u знаков", cluster.size))
        return true
    }
    
    internal func addPointsToClusterCollection(clusterNumber: Int, models: [SignModel]) {
        for sign in models {
            let point = YMKPoint(latitude: sign.lat, longitude: sign.lon)
//            let obj = mapView.mapWindow.map.mapObjects.addPlacemark(with: point)
            let obj = clustersCollection.addPlacemark(with: point)

            let signView = YMKCustomPointView(isVerified: sign.correct, image: UIImage(named: sign.type))
            if let viewProvider = YRTViewProvider(uiView: signView) {
                obj.setViewWithView(viewProvider)
                pointsDict[point] = (clusterNumber, obj, sign)
            } else {
//                mapView.mapWindow.map.mapObjects.remove(with: obj)
                clustersCollection.remove(withPlacemark: obj)
            }
        }
        print(pointsDict.count)
        clustersCollection.clusterPlacemarks(withClusterRadius: 60, minZoom: 15)

    }
    
    internal func deletePointsFromClusterCollection(points: [YMKPoint]) {
        for point in points {
            if let el = pointsDict[point] {
                clustersCollection.remove(withPlacemark: el.1)
                pointsDict.removeValue(forKey: point)
            }
        }
        clustersCollection.clusterPlacemarks(withClusterRadius: 60, minZoom: 15)
    }
    
    private func replacePointModel(point: YMKPoint, model: SignModel) {
        if let el = pointsDict[point] {
            deletePointsFromClusterCollection(points: [point])
            addPointsToClusterCollection(clusterNumber: el.0, models: [model])
//            pointsDict.removeValue(forKey: old)
//            pointsDict[new] = el
        }
    }
    
    private func clusterImage(_ clusterSize: UInt) -> UIImage {
        
        let scale = UIScreen.main.scale
        let text = (clusterSize as NSNumber).stringValue
        let font = UIFont.systemFont(ofSize: FONT_SIZE * scale)
        let size = text.size(withAttributes: [NSAttributedString.Key.font: font])
        let textRadius = sqrt(size.height * size.height + size.width * size.width) / 2
        let internalRadius = textRadius + MARGIN_SIZE * scale
        let externalRadius = internalRadius + STROKE_SIZE * scale
        let iconSize = CGSize(width: externalRadius * 2, height: externalRadius * 2)

        UIGraphicsBeginImageContext(iconSize)
        let ctx = UIGraphicsGetCurrentContext()!

        ctx.setFillColor(UIColor.red.cgColor)
        ctx.fillEllipse(in: CGRect(
            origin: .zero,
            size: CGSize(width: 2 * externalRadius, height: 2 * externalRadius)));

        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fillEllipse(in: CGRect(
            origin: CGPoint(x: externalRadius - internalRadius, y: externalRadius - internalRadius),
            size: CGSize(width: 2 * internalRadius, height: 2 * internalRadius)));

        (text as NSString).draw(
            in: CGRect(
                origin: CGPoint(x: externalRadius - size.width / 2, y: externalRadius - size.height / 2),
                size: size),
            withAttributes: [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.black])
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        return image
    }
    
}

//MARK: - Map object tap listener
extension MainMapViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        
        for el in pointsDict.keys {
            if pointsDict[el]?.1 == mapObject {
                if let model = pointsDict[el] {
                    editSlideUpView.configure(signModel: model.2)
                    showSlideUpView()
                    return true
                }
            }
        }
        
        print("NO MODEL")
        hideSlideUpView()
        print(#function)
        return false
    }
    
    
}
