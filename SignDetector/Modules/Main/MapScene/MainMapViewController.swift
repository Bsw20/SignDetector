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
    //MARK: - Controls
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
        view.addSubview(mapView)
        view.addSubview(videoModeView)
        
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        videoModeView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
        }
        
        
        
    }
}
