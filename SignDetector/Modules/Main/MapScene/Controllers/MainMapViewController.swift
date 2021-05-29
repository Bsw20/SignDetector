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
    internal var session: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    internal var input: AVCaptureDeviceInput!
    internal var output: AVCapturePhotoOutput!
    internal var socket: Socket!
    var locationManager: CLLocationManager = CLLocationManager()

    private var dragableViewSize: CGSize = CGSize(width: 100 * UIScreen.main.scale, height: 100 * UIScreen.main.scale * 0.5625)
    
    private let addLocationPointImageView = UIImageView(image: #imageLiteral(resourceName: "AddNewLocationVector"))
    
    
    private var searchManager: YMKSearchManager?
    private var searchSession: YMKSearchSession?
    
    internal var pointsDict: [YMKPoint : (Int, YMKPlacemarkMapObject, SignModel)] = [:]
    
    
    internal var signsForFilter: [String] = SignsJSONHolder.shared.getKeys()
    
    
    private var jobPosition: JobPosition = .user {
        didSet {
            editSlideUpView.configure(isEditingEnable: jobPosition == .manager)
        }
    }
    
    private var needToShowNavBar: Bool = false
    //MARK: Map
    private var mapCompletelyUpdated: Bool = false
    internal var previousRegion: CGRect? = nil
    internal var clustersCollection: YMKClusterizedPlacemarkCollection!
    internal let FONT_SIZE: CGFloat = 15
    internal let MARGIN_SIZE: CGFloat = 3
    internal let STROKE_SIZE: CGFloat = 3
    
    //MARK: - Controls
    //MARK: Clusters
    internal var firstClusterView = SignsClusterView(isHidden: true)
    internal var secondClusterView = SignsClusterView(isHidden: true)
    internal var thirdClusterView = SignsClusterView(isHidden: true)
    internal var fourthClusterView = SignsClusterView(isHidden: true)
    
    //MARK: Other
    internal var editSlideUpView: EditSignView = EditSignView()
    
    private var addLocationView: NewLocationView = {
       let view = NewLocationView()
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    internal var dragableView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .clear
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 6
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()
    
    internal var mapView: YMKMapView = {
       let mapView = YMKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.mapWindow.map.isRotateGesturesEnabled = false
        return mapView
    }()
    
    internal var titleView = MapTitleView()
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSession()
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .all
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needToShowNavBar {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            needToShowNavBar = false
        }
    }
    
    //MARK: - Funcs

    internal func showSlideUpView() {
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
    
    internal func hideSlideUpView() {
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
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        guard let camera = AVCaptureDevice.default(for: AVMediaType.video) else { return }

        do {
            input = try AVCaptureDeviceInput(device: camera) } catch { return }
            output = AVCapturePhotoOutput()
            
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
                    self.previewLayer.connection?.videoOrientation = .landscapeRight
                } else {
                    self.previewLayer.connection?.videoOrientation = .portrait
                }
            }
        
            dragableView.layer.addSublayer(previewLayer!)
            previewLayer.frame = CGRect(x: 0, y: 0, width: dragableViewSize.width, height: dragableViewSize.height)
            if UDManager.isCameraWorkOnStart() {
                session.startRunning()
                dragableView.isHidden = false
            }
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

        let mapKit = YMKMapKit.sharedInstance()
        let userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)

        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingEnabled = true
        userLocationLayer.setObjectListenerWith(self)
        
       
        mapView.mapWindow.map.move(with:
            YMKCameraPosition(target: YMKPoint(latitude: 55.751244, longitude: 37.618423), zoom: 14, azimuth: 0, tilt: 0))

        
        
        videoModeView.customDelegate = self
    }
    
    

    //MARK: - Objc func
    @objc private func updateMap() {
        previousRegion = nil
        let map = mapView.mapWindow.map
        print("\(map.visibleRegion.bottomLeft.latitude) \(map.visibleRegion.bottomLeft.longitude)")
        
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
    
    
    @objc private func draggedView(gesture:UIPanGestureRecognizer){
        let location = gesture.location(in: self.view)
        let draggedView = gesture.view
        draggedView?.center = location
        let topInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.size.height
        let screenSize = UIScreen.main.bounds
        
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
                    let newWidth = (self.dragableViewSize.width / 2)
                    self.dragableView.center.x =  newWidth + topInset
                    
                    let newHeight = (self.dragableViewSize.height / 2)
                    self.dragableView.center.y = newHeight + topInset
                }, completion: nil)
            }
        }
    }
    
    
    
    @objc private func timerCalled() {
        print("TIMER CALLED \(timer?.timeInterval)")
        capturePhoto()
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
        dismiss(animated: true, completion: nil)
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
        
        dragableView.frame = CGRect(x: topInset, y: topInset, width: dragableViewSize.width, height: dragableViewSize.height)
        
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
    }
}
