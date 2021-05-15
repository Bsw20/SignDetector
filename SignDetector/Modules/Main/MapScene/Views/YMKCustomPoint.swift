//
//  YMKCustomPoint.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 15.05.2021.
//

import Foundation
import UIKit
import YandexMapsMobile

class YMKCustomPoint: YMKPoint {
    var clusterNumber: Int?
//    init() {
//        super.init(latitude: <#T##Double#>, longitude: <#T##Double#>)
//    }
//    override init(latitude: Double, longitude: Double) {
//        
//    }
    
    public func setClusterNumber(clusterNumber: Int) {
        self.clusterNumber = clusterNumber
    }
}
