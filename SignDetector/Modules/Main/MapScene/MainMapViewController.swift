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

class MainMapViewController: UIViewController {
    //MARK: - Variables
    private var panGesture = UIPanGestureRecognizer()
    //MARK: - Controls
    private var dragableView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
//        iv.backgroundColor = .clear
        iv.backgroundColor = .red
        
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 6
        iv.clipsToBounds = true
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
        setupUI()
        configure()
        setupConstraints()
    }
    
    //MARK: - Funcs
    private func setupUI() {
        navigationItem.titleView = titleView
        let rightButton = UIBarButtonItem(image: UIImage(named: "newMoreVector"),
                                          style: .plain, target: self,
                                          action: nil)
        
        navigationItem.rightBarButtonItem = rightButton
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "filterVector"),
                                                            style: .plain, target: self,
                                                            action: #selector(filterButtonTapped))
        
        let addPlace = UIAction(title: "Добавить участок") { _ in
          print("add place")
        }
        
//        rightButton.showsMenuAsPrimaryAction = true
        rightButton.menu = UIMenu(title: "", children: [addPlace])
    }
    
    private func configure() {
        
        let panGesture = UIPanGestureRecognizer(target: self, action:#selector(draggedView(gesture:)))
        dragableView.addGestureRecognizer(panGesture)
        
        mapView.mapWindow.map.move(with:
            YMKCameraPosition(target: YMKPoint(latitude: 0, longitude: 0), zoom: 14, azimuth: 0, tilt: 0))
        
        let scale = UIScreen.main.scale
        let mapKit = YMKMapKit.sharedInstance()
        let userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)

        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingEnabled = true
        userLocationLayer.setAnchorWithAnchorNormal(
            CGPoint(x: 0.5 * mapView.frame.size.width * scale, y: 0.5 * mapView.frame.size.height * scale),
            anchorCourse: CGPoint(x: 0.5 * mapView.frame.size.width * scale, y: 0.83 * mapView.frame.size.height * scale))
        userLocationLayer.setObjectListenerWith(self)
        
        videoModeView.customDelegate = self
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
                    self.dragableView.center.y = topInset +  UIScreen.main.bounds.height * (0.235/2) + topViewHeight
                }, completion: nil)

                
            }else if self.dragableView.frame.midX < self.view.layer.frame.width / 2 && self.dragableView.frame.midY >= self.view.layer.frame.height/2  {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    
                    self.dragableView.center.x = UIScreen.main.bounds.width * (0.3573/2) + defaultOffset
                    self.dragableView.center.y = self.view.layer.frame.height - UIScreen.main.bounds.height * (0.235/2) - defaultOffset
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    
                    self.dragableView.center.x = UIScreen.main.bounds.width * (0.3573/2) + defaultOffset
                    self.dragableView.center.y = topInset + UIScreen.main.bounds.height * (0.235/2) + topViewHeight
                }, completion: nil)
            }
        }
    }
}

//MARK: - YMKUserLocationObjectListener
extension MainMapViewController: YMKUserLocationObjectListener {
    func onObjectAdded(with view: YMKUserLocationView) {
        view.arrow.setIconWith(UIImage(named:"UserArrow")!)
        
        let pinPlacemark = view.pin.useCompositeIcon()
        
        pinPlacemark.setIconWithName("icon",
            image: UIImage(named:"Icon")!,
            style:YMKIconStyle(
                anchor: CGPoint(x: 0, y: 0) as NSValue,
                rotationType:YMKRotationType.rotate.rawValue as NSNumber,
                zIndex: 0,
                flat: true,
                visible: true,
                scale: 1.5,
                tappableArea: nil))
        
        pinPlacemark.setIconWithName(
            "pin",
            image: UIImage(named:"SearchResult")!,
            style:YMKIconStyle(
                anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
                rotationType:YMKRotationType.rotate.rawValue as NSNumber,
                zIndex: 1,
                flat: true,
                visible: true,
                scale: 1,
                tappableArea: nil))

        view.accuracyCircle.fillColor = UIColor.blue
    }
    
    func onObjectRemoved(with view: YMKUserLocationView) {}
    
    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}
}

//MARK: - VideoModelViewDelegate
extension MainMapViewController: VideoModelViewDelegate {
    func modeDidChange(isOn: Bool) {
        print("Video mode isOn: \(isOn)")
    }
    
    
}

extension MainMapViewController {
    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds
        view.addSubview(mapView)
        view.addSubview(videoModeView)
        
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        videoModeView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
        }
        
        let topInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.size.height
        
        view.addSubview(dragableView)
        dragableView.frame = CGRect(x: screenSize.width - screenSize.width * 0.3573 - 16, y: topInset + UIScreen.main.bounds.height * 0.074 , width: screenSize.width * 0.3573, height: screenSize.height * 0.235)
        
        
        
    }
}
