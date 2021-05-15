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
    private var panGesture = UIPanGestureRecognizer()
    private var timer: Timer?
    private var session: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var input: AVCaptureDeviceInput!
    private var output: AVCapturePhotoOutput!
    private var socket: Socket!
    var locationManager: CLLocationManager = CLLocationManager()
    
    private let addLocationPointImageView = UIImageView(image: #imageLiteral(resourceName: "AddNewLocationVector"))
    
    
    var searchManager: YMKSearchManager?
    var searchSession: YMKSearchSession?
    
    
    
    //MARK: - Controls
    //MARK: Clusters
    private var firstClusterView = SignsClusterView()
    private var secondClusterView = SignsClusterView()
    private var thirdClusterView = SignsClusterView()
    private var fourthClusterView = SignsClusterView()
    
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
//        iv.backgroundColor = .red
        
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
        let point = YMKPoint(latitude: 55.751244, longitude: 37.618423)
        mapView.mapWindow.map.mapObjects.addPlacemark(with: point, image: UIImage(named: "1_1")!)
//        mapView.mapWindow.focusRect
//        let userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)
//           userLocationLayer.setVisibleWithOn(true)
//           userLocationLayer.isHeadingEnabled = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSession()
    }
    
    //MARK: - Funcs
    private func setupSession() {
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
            
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer.connection?.videoOrientation = .portrait
            dragableView.layer.addSublayer(previewLayer!)
            previewLayer.frame = CGRect(x: 0, y: 0, width: screenSize.width * 0.3573, height: screenSize.height * 0.235)
        if APIManager.isCameraWorkOnStart() {
            session.startRunning()
            dragableView.isHidden = false
        }
//            session.startRunning()
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
        addLocationView.customDelegate = self
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        
        socket = Socket.shared
        socket.customDelegate = self
        let panGesture = UIPanGestureRecognizer(target: self, action:#selector(draggedView(gesture:)))
        dragableView.addGestureRecognizer(panGesture)
        mapView.mapWindow.addSizeChangedListener(with: self)
        mapView.mapWindow.map.addCameraListener(with: self)
//        lat: 55.751244, long: 37.618423
        mapView.mapWindow.map.move(with:
            YMKCameraPosition(target: YMKPoint(latitude: 55.751244, longitude: 37.618423), zoom: 14, azimuth: 0, tilt: 0))
        
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
        
        videoModeView.customDelegate = self
    }
    
    private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                     kCVPixelBufferWidthKey as String: 160,
                                     kCVPixelBufferHeightKey as String: 160,
                                     ]
        settings.previewPhotoFormat = previewFormat as [String : Any]
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
    @objc private func filterButtonTapped() {
        print("filter button tapped")
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
        
        if gesture.state == .ended {
            if self.dragableView.frame.midX >= self.view.layer.frame.width / 2 && self.dragableView.frame.midY >= self.view.layer.frame.height/2 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
//                    self.dragableView.center.x = self.view.layer.frame.width - 40
                    let newWidth = self.view.layer.frame.width - UIScreen.main.bounds.width * (0.3573 / 2)
                    self.dragableView.center.x =  newWidth - defaultOffset
                    let newHeight = self.view.layer.frame.height - UIScreen.main.bounds.height * (0.235/2)
                    self.dragableView.center.y = newHeight - defaultOffset
                    
                }, completion: nil)
            }else if self.dragableView.frame.midX >= self.view.layer.frame.width / 2 && self.dragableView.frame.midY < self.view.layer.frame.height/2 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    
                    self.dragableView.center.x = self.view.layer.frame.width - UIScreen.main.bounds.width * (0.3573/2) - defaultOffset
                    self.dragableView.center.y = topInset +  UIScreen.main.bounds.height * (0.235/2) + topViewHeight + videoModeViewHeight
                }, completion: nil)

                
            }else if self.dragableView.frame.midX < self.view.layer.frame.width / 2 && self.dragableView.frame.midY >= self.view.layer.frame.height/2  {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    
                    self.dragableView.center.x = UIScreen.main.bounds.width * (0.3573/2) + defaultOffset
                    self.dragableView.center.y = self.view.layer.frame.height - UIScreen.main.bounds.height * (0.235/2) - defaultOffset
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    
                    self.dragableView.center.x = UIScreen.main.bounds.width * (0.3573/2) + defaultOffset
                    self.dragableView.center.y = topInset + UIScreen.main.bounds.height * (0.235/2) + topViewHeight + videoModeViewHeight
                }, completion: nil)
            }
        }
    }
    
    
    
    @objc private func timerCalled() {
        print("TIMER CALLED \(timer?.timeInterval)")
        capturePhoto()
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

        if socket != nil {
//            print(".... \(topLeft.latitude) \(topLeft.longitude) \(bottomRight.latitude) \(bottomRight.longitude) \(middlePoint.latitude) \(middlePoint.longitude) \(radius)")
            socket.sendCurrentCoordinates(radius: radius, lat: middlePoint.latitude, long: middlePoint.longitude, filter: [])
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }

        print("SIIIIZE")
        print(image.size)
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - SocketManagerDelegate
extension MainMapViewController: SocketManagerDelegate {
    func onSignsReceived(socket: Socket, model: ClusterModel, clusterNumber: Int) {
        print(#function)
//        let mapObjects = mapView.mapWindow.map.mapObjects
        getClusterViewWith(index: clusterNumber).configure(count: model.size)
//        mapObjects.clear()
//        for searchResult in response.collection.children {
//            if let point = searchResult.obj?.geometry.first?.point {
//                let placemark = mapObjects.addPlacemark(with: point)
//                placemark.setIconWith(UIImage(named: "SearchResult")!)
//            }
//        }
//        for sign in model.signs {
////            let point = YMKPoint(latitude: sign.lat, longitude: sign.lon)
////            mapView.mapWindow.map.mapObjects.addPlacemark(with: point, image: UIImage(named: "1_1")!)
//        }

    }
    
    func didConnect(socket: Socket) {
        print("did connect ViewController")
//        createTimer()
        socket.sendCurrentCoordinates(radius: 500, lat: 55.751244, long: 37.618423, filter: [])
    }
    
    func didDisconnect(socket: Socket) {
        print("did disconnect ViewController")
    }
    
    func onMessageReceived(socket: Socket, message: String) {
        print("did receive message")
    }
    
    
}

//MARK: - AVCapturePhotoCaptureDelegate
extension MainMapViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("IMAGE CAPTURED")
        print(socket == nil)
        print(photo.fileDataRepresentation())
        guard socket != nil, let photoData = photo.fileDataRepresentation() else { return }
        print("HERE")
        socket.sendImage(image: photoData) { result in
            print("IMAGE SEND WITH SOCKET")
            print(self.locationManager.heading?.magneticHeading)
        }
//        socket.sendImage { <#Result<Void, Error>#> in
//            <#code#>
//        }
//        if socket != nil {
//            guard let
//            socket.sendImage(completion: <#T##(Result<Void, Error>) -> Void#>)
//        }
    }
}

//MARK: - YMKUserLocationObjectListener
extension MainMapViewController: YMKUserLocationObjectListener {
    func onObjectAdded(with view: YMKUserLocationView) {
        view.arrow.setIconWith(UIImage(named:"UserArrow")!)
        
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
        let middlePoint = getMiddlePointIn(region: mapView.mapWindow.map.visibleRegion).toYMKPoint()
        print("\(middlePoint.latitude) \(middlePoint.longitude)")
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
//MARK: - Constraints
extension MainMapViewController {
    private func defaultLayout() {
        videoModeView.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        addLocationView.removeFromSuperview()
        addLocationPointImageView.removeFromSuperview()
    }
    private func addLocationViewLayout() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.videoModeView.isHidden = true
    
        self.view.addSubview(self.addLocationView)
        self.addLocationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        self.view.addSubview(self.addLocationPointImageView)
        self.addLocationPointImageView.snp.makeConstraints {[weak self] make in
            guard let self = self else { return }
            make.centerX.equalToSuperview()
            print(self.addLocationPointImageView.frame.height)
            make.centerY.equalToSuperview().inset(self.addLocationPointImageView.frame.height / 2)
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
        dragableView.frame = CGRect(x: screenSize.width - screenSize.width * 0.3573 - 16, y: topInset + UIScreen.main.bounds.height * 0.074 + 0.0825 * screenSize.height , width: screenSize.width * 0.3573, height: screenSize.height * 0.235)
        
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
