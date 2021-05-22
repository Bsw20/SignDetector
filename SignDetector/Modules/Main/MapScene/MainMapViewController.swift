//
//  MainMapViewController.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 02.05.2021.
//

import Foundation
import UIKit
import YandexMapsMobile
import SnapKit
import AVFoundation
import CoreLocation

class MainMapViewController: UIViewController {
    //MARK: - Variables
    struct SlideUpViewConstants {
        static var shared = SlideUpViewConstants()
        var isHidden: Bool = true
        var shownY: CGFloat = UIScreen.main.bounds.height - (150 + 49 + 70)
        var hiddenY: CGFloat = UIScreen.main.bounds.height
    }
    private var panGesture = UIPanGestureRecognizer()
    private var timer: Timer?
    private var session: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var input: AVCaptureDeviceInput!
    private var output: AVCapturePhotoOutput!
    private var socket: Socket!
    var locationManager: CLLocationManager = CLLocationManager()
//    let dragableViewWidth: CGFloat = 100 * UIScreen.main.scale
//    dragableView.frame = CGRect(x: topInset,
//                                y: topInset,
//                                width: dragableViewWidth,
//                                height: dragableViewWidth * 0.5625)
    private var dragableViewSize: CGSize = CGSize(width: 100 * UIScreen.main.scale, height: 100 * UIScreen.main.scale * 0.5625)
    
    private let addLocationPointImageView = UIImageView(image: #imageLiteral(resourceName: "AddNewLocationVector"))
    
    
    private var searchManager: YMKSearchManager?
    private var searchSession: YMKSearchSession?
    
    private var pointsDict: [YMKPoint : (Int, YMKPlacemarkMapObject, SignModel)] = [:]
    
    
    private var signsForFilter: [String] = LocalManager.shared.getKeys()
    
    
    private var jobPosition: JobPosition = .user {
        didSet {
            editSlideUpView.configure(isEditingEnable: jobPosition == .manager)
        }
    }
    
    private var needToShowNavBar: Bool = false
    //MARK: Map
    private var mapCompletelyUpdated: Bool = false
    private var previousRegion: CGRect? = nil
    private var clustersCollection: YMKClusterizedPlacemarkCollection!
    private let FONT_SIZE: CGFloat = 15
    private let MARGIN_SIZE: CGFloat = 3
    private let STROKE_SIZE: CGFloat = 3
    
    //MARK: - Controls
    //MARK: Clusters
    private var firstClusterView = SignsClusterView(isHidden: true)
    private var secondClusterView = SignsClusterView(isHidden: true)
    private var thirdClusterView = SignsClusterView(isHidden: true)
    private var fourthClusterView = SignsClusterView(isHidden: true)
    
    //MARK: Other
    private var editSlideUpView: EditSignView = EditSignView()
    
    private var addLocationView: NewLocationView = {
       let view = NewLocationView()
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    private var dragableView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .clear
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 6
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()
    
    private var mapView: YMKMapView = {
       let mapView = YMKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.mapWindow.map.isRotateGesturesEnabled = false
        return mapView
    }()
    
    private var titleView = MapTitleView()
    private var videoModeView: VideoModeView = {
       let view = VideoModeView()
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    
    //MARK: - Variables
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupUI()
        setupConstraints()
//        let point = YMKPoint(latitude: 55.751244, longitude: 37.618423)
//        point.
//        let point = YMKCustomPoint(
        
//        let p = YMKPoint(
//        mapView.mapWindow.map.mapObjects.addPlacemark(with: point, image: UIImage(named: "1_1")!)
//        mapView.mapWindow.focusRect
//        let userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)
//           userLocationLayer.setVisibleWithOn(true)
//           userLocationLayer.isHeadingEnabled = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needToShowNavBar {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            needToShowNavBar = false
        }
        
    }
    
    //MARK: - Funcs

    private func showSlideUpView() {
        if !editSlideUpView.isShown {
            
            UIView.animate(withDuration: 0.1) {[weak self] in
                guard let self = self else { return }
//                self.slideUpView.frame.origin.y = 0
                self.editSlideUpView.frame.origin.y = self.editSlideUpView.shownY
//                self.slideUpView.transform = CGAffineTransform(translationX:0, y:0)
            } completion: { (res) in
                self.editSlideUpView.isShown = true
            }

        }
    }
    
    private func hideSlideUpView() {
        if editSlideUpView.isShown {
            UIView.animate(withDuration: 0.35) {
                self.editSlideUpView.frame.origin.y = self.editSlideUpView.hiddenY
//                self.slideUpView.transform = CGAffineTransform(translationX:0, y: UIScreen.main.bounds.height)
            } completion: { (res) in
                self.editSlideUpView.isShown = false
            }
        }
    }
    
    

    
    private func setupSession() {
        let r = mapView.mapWindow.map.visibleRegion
//        YMKRect.init(min: r.topLeft, max: r.bottomRight)
        let screenSize = UIScreen.main.bounds
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        guard let camera = AVCaptureDevice.default(for: AVMediaType.video) else { return }

        do {
            input = try AVCaptureDeviceInput(device: camera) } catch { return }
            output = AVCapturePhotoOutput()
//            let settings = AVCapturePhotoSettings()
//            settings.livePhotoVideoCodecType = .jpeg
//            output.capturePhoto(with: settings, delegate: s)
//            output.preparedPhotoSettingsArray = [ AVVideoCodecKey: AVVideoCodecType.jpeg ]
            
            guard session.canAddInput(input)
                    && session.canAddOutput(output) else { return }
            
            session.addInput(input)
            session.addOutput(output)
        if let videoConnection = output.connection(with: .video) {
            videoConnection.videoOrientation = .landscapeRight
        }
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.previewLayer.connection?.videoOrientation = .portrait
            if let orientation = windowInterfaceOrientation {
                if orientation.isLandscape {
                    // activate landscape changes
                    self.previewLayer.connection?.videoOrientation = .landscapeRight
                } else {
                    // activate portrait changes
                    self.previewLayer.connection?.videoOrientation = .portrait
                }
            }
        
            dragableView.layer.addSublayer(previewLayer!)
            previewLayer.frame = CGRect(x: 0, y: 0, width: dragableViewSize.width, height: dragableViewSize.height)
            if APIManager.isCameraWorkOnStart() {
                session.startRunning()
                dragableView.isHidden = false
            }
//            session.startRunning()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
            let topInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.size.height
            
            if windowInterfaceOrientation.isLandscape {
                // activate landscape changes
                self.previewLayer.connection?.videoOrientation = .landscapeRight

            } else {
                // activate portrait changes
                self.previewLayer.connection?.videoOrientation = .portrait
            }
            let newWidth = (self.dragableViewSize.width / 2)
            self.dragableView.center.x =  newWidth + topInset

            let newHeight = (self.dragableViewSize.height / 2)
            self.dragableView.center.y = newHeight + topInset
            self.addLocationView.layoutIfNeeded()
//            let tabBarHeight: CGFloat = 49
//            let newWidth = self.view.layer.frame.width - (self.dragableViewSize.width / 2)
//            self.dragableView.center.x =  newWidth - topInset
//            let newHeight = self.view.layer.frame.height - (self.dragableViewSize.height / 2)
//            self.dragableView.center.y = newHeight - tabBarHeight
        })
    }
    
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
    }

    private func setupUI() {
        navigationItem.titleView = titleView
        view.backgroundColor = .white
        let rightButton = UIBarButtonItem(image: UIImage(named: "newMoreVector"),
                                          style: .plain, target: self,
                                          action: nil)
        
        navigationItem.rightBarButtonItem = rightButton
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "filterVector"),
                                                            style: .plain, target: self,
                                                            action: #selector(filterButtonTapped))
        
        let addPlace = UIAction(title: "Добавить участок") { [weak self]_ in
          print("add place")
            self?.hideSlideUpView()
            self?.addLocationViewLayout()
            
        }
        let takePicture = UIAction(title: "Сделать фотографию") {[weak self] _ in
            guard let self = self else { return }
            print("TAKE A PICTURE")
            let vc = UIImagePickerController()
            vc.sourceType = .camera
            vc.allowsEditing = false
            vc.delegate = self
            self.present(vc, animated: true)
        }
        
//        rightButton.showsMenuAsPrimaryAction = true
        rightButton.menu = UIMenu(title: "", children: [addPlace, takePicture])
    }
    
    private func configure() {
//        YMKGeometry.init(circle: .init(center: , radius: <#T##Float#>)).boundingBox.
//        mapView.mapWindow.map.visibleRegion.co
//        previousRegion = mapView.mapWindow.map.visibleRegion.asCGRect()
        NotificationCenter.default.addObserver(self, selector: #selector(updateMap), name: .settingsChanged, object: nil)
        UserAPIService.shared.getSignsNumber { number in
            onMainThread {[weak self] in
                self?.titleView.setSignsCount(count: number)
            }
        }
        clustersCollection = mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
        UserAPIService.shared.getUserPosition {[weak self] newPosition in
            self?.jobPosition = newPosition
        }
        editSlideUpView.customDelegate = self
        addLocationView.customDelegate = self
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        
        socket = Socket.shared
        socket.customDelegate = self
        let panGesture = UIPanGestureRecognizer(target: self, action:#selector(draggedView(gesture:)))
        dragableView.addGestureRecognizer(panGesture)
        mapView.mapWindow.addSizeChangedListener(with: self)
        mapView.mapWindow.map.addCameraListener(with: self)
        mapView.mapWindow.map.mapObjects.addTapListener(with: self)
//        lat: 55.751244, long: 37.618423

        
        let scale = UIScreen.main.scale
        
//        let mapKit = YMKMapKit.sharedInstance()
//        let userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)
//        userLocationLayer.setVisibleWithOn(true)
//        userLocationLayer.isHeadingEnabled = true
        let mapKit = YMKMapKit.sharedInstance()
        let userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)

        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingEnabled = true
//        userLocationLayer.setAnchorWithAnchorNormal(
//            CGPoint(x: 0.5 * mapView.frame.size.width * scale, y: 0.5 * mapView.frame.size.height * scale),
//            anchorCourse: CGPoint(x: 0.5 * mapView.frame.size.width * scale, y: 0.83 * mapView.frame.size.height * scale))
        userLocationLayer.setObjectListenerWith(self)
        
       
        mapView.mapWindow.map.move(with:
            YMKCameraPosition(target: YMKPoint(latitude: 55.751244, longitude: 37.618423), zoom: 14, azimuth: 0, tilt: 0))

        
        
        videoModeView.customDelegate = self
    }
    
    private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                     kCVPixelBufferWidthKey as String: 1280,
                                     kCVPixelBufferHeightKey as String: 720,
                                     ]
        settings.previewPhotoFormat = previewFormat as [String : Any]
        print(view.frame.width)
        self.output.capturePhoto(with: settings, delegate: self)
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
    //MARK: - Objc func
    @objc private func updateMap() {
        previousRegion = nil
        let map = mapView.mapWindow.map
        print("\(map.visibleRegion.bottomLeft.latitude) \(map.visibleRegion.bottomLeft.longitude)")
        
        let radius = getRadiusIn(region: map.visibleRegion)

        let middlePoint = getMiddlePointIn(region: map.visibleRegion)
        let visibleRegion = map.visibleRegion
        if socket != nil {
            socket.sendCurrentCoordinates(center: mapView.mapWindow.map.cameraPosition.target, topRight: visibleRegion.topRight, topLeft: visibleRegion.topLeft, bottomRight: visibleRegion.bottomRight, bottomLeft: visibleRegion.bottomLeft, filter: signsForFilter)
        }
        
    }
    
    @objc private func filterButtonTapped() {
        print("filter button tapped")
        let vc = FilteringViewController(signsForFilter: signsForFilter)
        vc.customDelegate = self
        navigationController?.push(vc, animated: true)
    }
    
    @objc private func moreButtonTapped() {
        print("more button tapped")
    }
    
    @objc private func draggedView(gesture:UIPanGestureRecognizer){
        let location = gesture.location(in: self.view)
        let draggedView = gesture.view
        draggedView?.center = location
        let topViewHeight = UIScreen.main.bounds.height * 0.074
        let topInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.size.height
        let defaultOffset = CGFloat(16)
        let screenSize = UIScreen.main.bounds
        let videoModeViewHeight = 0.0825 * screenSize.height
        
        let tabBarHeight: CGFloat = 49
        
        if gesture.state == .ended {
            if self.dragableView.frame.midX >= self.view.layer.frame.width / 2 && self.dragableView.frame.midY >= self.view.layer.frame.height/2 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
//                    self.dragableView.center.x = self.view.layer.frame.width - 40
                    let newWidth = self.view.layer.frame.width - (self.dragableViewSize.width / 2)
                    self.dragableView.center.x =  newWidth - topInset
                    let newHeight = self.view.layer.frame.height - (self.dragableViewSize.height / 2)
                    self.dragableView.center.y = newHeight - tabBarHeight

                }, completion: nil)
            }else if self.dragableView.frame.midX >= self.view.layer.frame.width / 2 && self.dragableView.frame.midY < self.view.layer.frame.height/2 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {

                    let newWidth = self.view.layer.frame.width - (self.dragableViewSize.width / 2)
                    self.dragableView.center.x =  newWidth - topInset
                    
                    let newHeight = (self.dragableViewSize.height / 2)
                    self.dragableView.center.y = newHeight + topInset
                }, completion: nil)


            }else if self.dragableView.frame.midX < self.view.layer.frame.width / 2 && self.dragableView.frame.midY >= self.view.layer.frame.height/2  {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {

//                    self.dragableView.center.x = UIScreen.main.bounds.width * (0.3573/2) + defaultOffset
//                    self.dragableView.center.y = self.view.layer.frame.height - UIScreen.main.bounds.height * (0.235/2) - defaultOffset
                    let newWidth = (self.dragableViewSize.width / 2)
                    self.dragableView.center.x =  newWidth + topInset
                    let newHeight = self.view.layer.frame.height - (self.dragableViewSize.height / 2)
                    self.dragableView.center.y = newHeight - tabBarHeight
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {

//                    self.dragableView.center.x = UIScreen.main.bounds.width * (0.3573/2) + defaultOffset
//                    self.dragableView.center.y = topInset + UIScreen.main.bounds.height * (0.235/2) + topViewHeight + videoModeViewHeight
                    
                    let newWidth = (self.dragableViewSize.width / 2)
                    self.dragableView.center.x =  newWidth + topInset
                    
                    let newHeight = (self.dragableViewSize.height / 2)
                    self.dragableView.center.y = newHeight + topInset
                }, completion: nil)
            }
        }
        
//        if gesture.state == .ended {
//            if self.dragableView.frame.midX >= self.view.layer.frame.width / 2 && self.dragableView.frame.midY >= self.view.layer.frame.height/2 {
//                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
////                    self.dragableView.center.x = self.view.layer.frame.width - 40
//                    let newWidth = self.view.layer.frame.width - UIScreen.main.bounds.width * (0.3573 / 2)
//                    self.dragableView.center.x =  newWidth - defaultOffset
//                    let newHeight = self.view.layer.frame.height - UIScreen.main.bounds.height * (0.235/2)
//                    self.dragableView.center.y = newHeight - defaultOffset
//
//                }, completion: nil)
//            }else if self.dragableView.frame.midX >= self.view.layer.frame.width / 2 && self.dragableView.frame.midY < self.view.layer.frame.height/2 {
//                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
//
//                    self.dragableView.center.x = self.view.layer.frame.width - UIScreen.main.bounds.width * (0.3573/2) - defaultOffset
//                    self.dragableView.center.y = topInset +  UIScreen.main.bounds.height * (0.235/2) + topViewHeight + videoModeViewHeight
//                }, completion: nil)
//
//
//            }else if self.dragableView.frame.midX < self.view.layer.frame.width / 2 && self.dragableView.frame.midY >= self.view.layer.frame.height/2  {
//                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
//
//                    self.dragableView.center.x = UIScreen.main.bounds.width * (0.3573/2) + defaultOffset
//                    self.dragableView.center.y = self.view.layer.frame.height - UIScreen.main.bounds.height * (0.235/2) - defaultOffset
//                }, completion: nil)
//            } else {
//                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
//
//                    self.dragableView.center.x = UIScreen.main.bounds.width * (0.3573/2) + defaultOffset
//                    self.dragableView.center.y = topInset + UIScreen.main.bounds.height * (0.235/2) + topViewHeight + videoModeViewHeight
//                }, completion: nil)
//            }
//        }
    }
    
    
    
    @objc private func timerCalled() {
        print("TIMER CALLED \(timer?.timeInterval)")
        capturePhoto()
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
    
    private func addPointsToClusterCollection(clusterNumber: Int, models: [SignModel]) {
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
    
    private func deletePointsFromClusterCollection(points: [YMKPoint]) {
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
//        guard let model = pointsDict[point] else {
//            print("NO MODEL")
//            hideSlideUpView()
//            return false
//        }
        
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
//MARK: - Main map delegates
extension MainMapViewController: YMKInertiaMoveListener, YMKMapSizeChangedListener, YMKMapCameraListener {
    class func findCenterPoint(_lo1: CLLocationCoordinate2D, _loc2: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        var lon1 = _lo1.longitude * M_PI / 180;
        var lon2 = _loc2.longitude * M_PI / 180;

        var lat1 = _lo1.latitude * M_PI / 180;
        var lat2 = _loc2.latitude * M_PI / 180;

        var dLon = lon2 - lon1;

        var x = cos(lat2) * cos(dLon);
        var y = cos(lat2) * sin(dLon);

        var lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) );
        var lon3 = lon1 + atan2(y, cos(lat1) + x);
        

        return CLLocationCoordinate2D(latitude: lat3 * 180 / M_PI,
                                      longitude: lon3 * 180 / M_PI)
    }

    
    private func getMiddlePointIn(region visibleRegion: YMKVisibleRegion) -> CLLocationCoordinate2D  {
        let topLeft = visibleRegion.topLeft
        let bottomRight = visibleRegion.bottomRight
        
        let firstLocation = CLLocation(latitude: topLeft.latitude, longitude: topLeft.longitude)
        let secondLocation = CLLocation(latitude: bottomRight.latitude, longitude: bottomRight.longitude)
        
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
        
        let radius = getRadiusIn(region: map.visibleRegion)

        let middlePoint = getMiddlePointIn(region: map.visibleRegion)
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

//MARK: - CLLocationManagerDelegate
extension MainMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        print(newHeading.magneticHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let point = locationManager.location?.coordinate
        
        if let point = point, videoModeView.isVideoOn() {
            if !mapView.mapWindow.map.visibleRegion.contains(point.toYMKPoint()) {
                mapView.mapWindow.map.move(with:
                                            YMKCameraPosition(target: YMKPoint(latitude: point.latitude, longitude: point.longitude), zoom: 14, azimuth: 0, tilt: 0))
            }
        }
        

    }
}

//MARK: - Timer
extension MainMapViewController {
    func createTimer() {
      if timer == nil {
        let timer = Timer(timeInterval: 0.5,
          target: self,
          selector: #selector(timerCalled),
          userInfo: nil,
          repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        timer.tolerance = 0.1
        
        self.timer = timer
      }
    }
    
    func cancelTimer() {
      timer?.invalidate()
        print("TIMER INVALIDATED")
      timer = nil
    }
}

//MARK: - UIImagePickerControllerDelegate
extension MainMapViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func makeAddressSearch(point: YMKPoint, zoom: NSNumber?, searchOptions: YMKSearchOptions,  completion: @escaping YMKSearchSessionResponseHandler) {
        if searchManager == nil {
            let mapKit = YMKMapKit.sharedInstance()
            searchManager = YMKSearch.sharedInstance().createSearchManager(with: .online)
        }
        searchSession = searchManager?.submit(with: point, zoom: zoom, searchOptions: searchOptions, responseHandler: completion)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage,
//              let data = image.resized(to: .init(width: 1280, height: 720)).pngData(),
              let resImage = UIImage.resizedImage(image: image, for: .init(width: 640, height: 360)),
              let data = UIImage.removeAlpha(from: resImage).pngData(),
              
//              let data = UIImage(named: "TestPhoto")?.pngData(),
              let latitude = locationManager.location?.coordinate.latitude,
              let longitude = locationManager.location?.coordinate.longitude else {
            dismiss(animated: true, completion: nil)
            print("No image found")
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            UserAPIService.shared.sendImageWithSign(model: .init(fileData: data,
                                                                 latitude: latitude,
                                                                 longitude: longitude,
                                                                 direction: self.locationManager.heading?.magneticHeading ?? 0)) { result in
                switch result {

                case .success():
                    break
                case .failure(_):
                    onMainThread {
                        UIApplication.showAlert(title: "Ошибка!", message: "Не получилось загрузить фотографию, попробуйте позже")
                    }

                }

            }
        }

        print("SIIIIZE")
        print(image.size.width)
        print(image.size.height)
        let newImage = UIImage.resizedImage(image: image, for: .init(width: 1280, height: 720))
        print(newImage?.size.width)
        print(newImage?.size.height)
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - SocketManagerDelegate
extension MainMapViewController: SocketManagerDelegate {

    

    
//    func onSignsReceived(socket: Socket, model: ClusterModel, clusterNumber: Int) {
//
//        let cv = getClusterViewWith(index: clusterNumber)
//        cv.configure(count: model.size)
//        cv.isHidden = model.size < Globals.clusterMaxSignsCount
//        if model.size > Globals.clusterMaxSignsCount {
//            deletePointsFromClusterCollection(points: getPointsIn(clusterNumber: clusterNumber))
//            deletePointsFromClusterCollection(points: getPointsInInvisibleArea())
//            if isAllSectorsClear() {
//                print("ALLSECTORSCLEAR")
//                previousRegion = nil
//            }
//
//        } else {
//            deletePointsFromClusterCollection(points: getPointsIn(clusterNumber: clusterNumber))
//            deletePointsFromClusterCollection(points: getPointsInInvisibleArea())
//            addPointsToClusterCollection(clusterNumber: clusterNumber, models: model.signs)
//
//        }
//
//    }
    
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
    
    private func isAllSectorsClear() -> Bool {
        return !firstClusterView.isHidden &&
            !secondClusterView.isHidden &&
            !thirdClusterView.isHidden &&
            !fourthClusterView.isHidden
    }

//    func onSignsReceived(socket: Socket, model: ClusterModel, clusterNumber: Int) {
//        print(#function)
//        let mapObjects = mapView.mapWindow.map.mapObjects
////        mapObjects.clear()
//        let cv = getClusterViewWith(index: clusterNumber)
//        cv.configure(count: model.size)
//        cv.isHidden = model.size < 100
//        deletePointsIn(clusterNumber: clusterNumber)
//        deletePointsInInvisibleRegion()
//
//        guard model.signs.count > 0 else { return }
//        for sign in model.signs {
//            let point = YMKPoint(latitude: sign.lat, longitude: sign.lon)
//            let obj = mapView.mapWindow.map.mapObjects.addPlacemark(with: point)
//
//            let signView = YMKCustomPointView(isVerified: sign.correct, image: UIImage(named: sign.type))
//            if let viewProvider = YRTViewProvider(uiView: signView) {
//                obj.setViewWithView(viewProvider)
//                pointsDict[point] = (clusterNumber, obj, sign)
//            } else {
//                mapView.mapWindow.map.mapObjects.remove(with: obj)
//            }
//
//        }
//
//    }
    
    func didConnect(socket: Socket) {
        print("did connect ViewController")
//        createTimer()
//        socket.sendCurrentCoordinates(radius: 500, lat: 55.751244, long: 37.618423, filter: [])
//        mapView.mapWindow.map.loca
//        socket.sendCurrentCoordinates(center: mapView.mapWindow.map.cameraPosition.target,
//                                      topRight: YMKPoint(latitude: 55.751244, longitude: 37.618423),
//                                      topLeft: YMKPoint(latitude: 55.751244, longitude: 37.618423),
//                                      bottomRight: YMKPoint(latitude: 55.751244, longitude: 37.618423),
//                                      bottomLeft: YMKPoint(latitude: 55.751244, longitude: 37.618423),
//                                      filter: signsForFilter)
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
    private func getSortedKeys() {
//        let keys = pointsDict.keys.sorted { firstPoint, secondPoint in
//            <#code#>
//        }
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
//        let mapObjects = mapView.mapWindow.map.mapObjects
//        mapObjects.remove(with: YMKPlacemarkMapObject())
//        let keys = pointsDict.keys.sorted { firstPoint, secondPoint in
//            <#code#>
//        }
        pointsDict.keys.forEach {[weak self] key in
            guard let self = self else { return }
            guard let tup = pointsDict[key] else { return }
            if tup.0 == clusterNumber {
                mapView.mapWindow.map.mapObjects.remove(with: tup.1)
                pointsDict.removeValue(forKey: key)
                print("DELETED POINT IN")
            }
        }
//        mapObjects.
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

//MARK: - AVCapturePhotoCaptureDelegate
extension MainMapViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("IMAGE CAPTURED")
        guard socket != nil, let photoData = photo.fileDataRepresentation(),
              let latitude = locationManager.location?.coordinate.latitude,
              let longitude = locationManager.location?.coordinate.longitude else {
            print("DIDN T SEND WITH SOCKET")
            return
            
        }
        print("HERE")
        if isConnectedToInternet() {
            socket.sendImage(image: photoData, lat: latitude, long: longitude, direction: locationManager.heading?.magneticHeading ?? 0) { result in
                print("IMAGE SEND WITH SOCKET")
                print(self.locationManager.heading?.magneticHeading)
            }
        } else {
            print("add sign model")
            CoreDataManager.shared.addSignModel(fileData: photoData,
                                                latitude: latitude,
                                                longitude: longitude,
                                                direction: locationManager.heading?.magneticHeading ?? 0)
        }
    }
}

//MARK: - YMKUserLocationObjectListener
extension MainMapViewController: YMKUserLocationObjectListener {
    func onObjectAdded(with view: YMKUserLocationView) {
        view.arrow.setIconWith(UIImage(named:"userLocationImage")!)
        
        let pinPlacemark = view.pin.useCompositeIcon()

//        pinPlacemark.setIconWithName("icon",
//            image: UIImage(named:"Icon")!,
//            style:YMKIconStyle(
//                anchor: CGPoint(x: 0, y: 0) as NSValue,
//                rotationType:YMKRotationType.rotate.rawValue as NSNumber,
//                zIndex: 0,
//                flat: true,
//                visible: true,
//                scale: 1.5,
//                tappableArea: nil))

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

//MARK: - VideoModelViewDelegate
extension MainMapViewController: VideoModelViewDelegate {
    func modeDidChange(isOn: Bool) {
        print("Video mode isOn: \(isOn)")
        guard session != nil else { return }
        if isOn {
            session.startRunning()
            createTimer()
        } else {
            session.stopRunning()
            cancelTimer()
        }
        dragableView.isHidden = !isOn
    }
    
    
}
//MARK: - NewLocationViewDelegate
extension MainMapViewController: NewLocationViewDelegate {
    func approveButtonTapped() {
        print("approveButtonTapped")
        let middlePoint = mapView.mapWindow.map.cameraPosition.target
        print("\(middlePoint.latitude) \(middlePoint.longitude)")
//        print("\(.latitude) \(mapView.mapWindow.map.cameraPosition.target.longitude)")
        let mapKit = YMKMapKit.sharedInstance()
        searchManager = YMKSearch.sharedInstance().createSearchManager(with: .online)
        
        searchSession = searchManager!.submit(with: middlePoint, zoom: nil, searchOptions: YMKSearchOptions()) { result, error in
            if let error = error {
                UIApplication.showAlert(title: "Ошибка!", message: "Не получилось определить точку, попробуйте позже")
                return
            }
            if let name = result?.collection.children.first?.obj?.name {
                print("jfkalsjdflk\(name)")
                onMainThread {[weak self] in
                    let vc = EditLocationViewController(viewType: .create(model: .init(address: name, latitude: middlePoint.latitude, longitude: middlePoint.longitude)))
                    vc.hidesBottomBarWhenPushed = true
                    vc.customDelegate = self
//                    vc.hide
                    self?.navigationController?.push(vc, animated: true)
                }
            } else {
                UIApplication.showAlert(title: "Ошибка!", message: "Не получилось определить точку, попробуйте позже")
            }
//            let res = result?.collection.children.first?.obj?.name

//            result?.collection.
            print(error)
//        mapView.mapWindow.map.
        }
    }
    
    func cancelButtonTapped() {
        defaultLayout()
    }
}

//MARK: - Filtering delegate
extension MainMapViewController: FilteringViewControllerDelegate {
    func applyButtonTapped(selectedSigns: [String]) {
        signsForFilter = selectedSigns
        hideSlideUpView()
        updateMap()
    }
}

//MARK: - EditLocationViewControllerDelegate
extension MainMapViewController: EditLocationViewControllerDelegate {
    func signWasEdited(controller: EditLocationViewController, oldModel: EditingSignModel, newModel: EditingSignModel) {
        let oldSignModel = SignModel(correct: oldModel.confirmed,
                                     lat: oldModel.latitude,
                                     lon: oldModel.longitude,
                                     type: oldModel.signName!,
                                     uuid: oldModel.uuid,
                                     address: oldModel.address)
        let newSignModel = SignModel(correct: newModel.confirmed,
                                     lat: newModel.latitude,
                                     lon: newModel.longitude,
                                     type: newModel.signName!,
                                     uuid: newModel.uuid,
                                     address: newModel.address)
        for key in pointsDict.keys {
            if pointsDict[key]?.2 == oldSignModel {
                let clusterNumber = pointsDict[key]!.0
                deletePointsFromClusterCollection(points: [key])
                addPointsToClusterCollection(clusterNumber: clusterNumber, models: [newSignModel])
                self.defaultLayout()
                needToShowNavBar = true
                return
            }
        }
        self.defaultLayout()
        needToShowNavBar = true

    }
    
    func backFromEditType() {
//        onMainThread {[weak self] in
//            self?.defaultLayout()
//        }
        print("BACKBACKBACK")
        self.defaultLayout()
        needToShowNavBar = true
    }
    
    func signWasSaved(signId: String) {
        onMainThread {[weak self] in
            self?.defaultLayout()
        }
    }
}

//MARK: - EditSignViewDelegate
extension MainMapViewController: EditSignViewDelegate {
    func editButtonTapped(view: EditSignView, model: SignModel?) {
        print(#function)
        guard let model = model else { return}
        hideSlideUpView()
        let vc = EditLocationViewController(viewType: .edit(model: .init(uuid: model.uuid,
                                                                         address: model.address,
                                                                         latitude: model.lat,
                                                                         longitude: model.lon,
                                                                         confirmed: model.correct,
                                                                         signName: model.type)))
        vc.customDelegate = self
        vc.hidesBottomBarWhenPushed = true
        onMainThread {
            self.navigationController?.push(vc)
        }
    }
    
    
    func closeButtonTapped(view: EditSignView) {
        hideSlideUpView()
    }
    
    
}
//MARK: - Constraints
extension MainMapViewController {
    private func defaultLayout() {

        
        self.videoModeView.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.addLocationView.removeFromSuperview()
        self.addLocationPointImageView.removeFromSuperview()

    }
    private func addLocationViewLayout() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.videoModeView.isHidden = true
    
        self.view.addSubview(self.addLocationView)
        self.addLocationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
        }
        self.view.addSubview(self.addLocationPointImageView)
        self.addLocationPointImageView.snp.makeConstraints {[weak self] make in
            guard let self = self else { return }
            make.centerX.equalToSuperview()
            print("addLocationPoint\(self.addLocationPointImageView.frame.height * UIScreen.main.scale)")
            make.centerY.equalToSuperview().inset(self.addLocationPointImageView.frame.height * UIScreen.main.scale)
        }
    }
    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds
        view.addSubview(mapView)
        view.addSubview(videoModeView)
        
        mapView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
        
        videoModeView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
        }
        
        let topInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.size.height
        
        view.addSubview(dragableView)
//        dragableView.frame = CGRect(x: screenSize.width - screenSize.width * 0.3573 - 16, y: topInset + UIScreen.main.bounds.height * 0.074 + 0.0825 * screenSize.height , width: screenSize.width * 0.3573, height: screenSize.height * 0.235)
        
        dragableView.backgroundColor = .red
//        let dragableViewWidth: CGFloat = 100 * UIScreen.main.scale
//        dragableView.frame = CGRect(x: topInset,
//                                    y: topInset,
//                                    width: dragableViewWidth,
//                                    height: dragableViewWidth * 0.5625)
        dragableView.frame = CGRect(x: topInset, y: topInset, width: dragableViewSize.width, height: dragableViewSize.height)
//        let newWidth = (self.dragableViewSize.width / 2)
//        self.dragableView.center.x =  newWidth + topInset
//
//        let newHeight = (self.dragableViewSize.height / 2)
//        self.dragableView.center.y = newHeight + topInset
        
        view.addSubview(firstClusterView)
        view.addSubview(secondClusterView)
        view.addSubview(thirdClusterView)
        view.addSubview(fourthClusterView)
        
        let defaultWidthOffset = screenSize.width * 0.25
        let defaultHeightOffset = screenSize.height * 0.15
        firstClusterView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(defaultWidthOffset)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(defaultHeightOffset)
        }
        
        secondClusterView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(defaultWidthOffset)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(defaultHeightOffset)
        }
        
        thirdClusterView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(defaultWidthOffset)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(defaultHeightOffset)
        }
        
        fourthClusterView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(defaultWidthOffset)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(defaultHeightOffset)
        }
        
        view.addSubview(editSlideUpView)
        let tabBarHeight: CGFloat = 49
        let slideUpViewHeight: CGFloat = 150
        editSlideUpView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: slideUpViewHeight)
//        print("DLFJI")
//        print(screenSize.height)
//        print(view.safeAreaLayoutGuide.layoutFrame.width)
//        print("lfkjsd")
//        print(view.safeAreaLayoutGuide.layoutFrame.height)
//        firstClusterView.snp.makeConstraints { make in
//            <#code#>
//        }
        
    }
}
