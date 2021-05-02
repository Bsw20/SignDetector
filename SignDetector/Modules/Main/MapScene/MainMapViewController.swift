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
       let view = YMKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - Variables
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
