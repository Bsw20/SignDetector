//
//  EditingSignModel.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 14.05.2021.
//

import Foundation
import UIKit

struct EditingSignModel {
    internal init(uuid: String, address: String, latitude: Double, longitude: Double, signName: String) {
        self.uuid = uuid
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.signName = signName
    }
    
    internal init(address: String, latitude: Double, longitude: Double, signName: String? = nil) {
        self.uuid = UUID().uuidString
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.signName = signName
    }
    
    var uuid: String
    var address: String
    var latitude: Double
    var longitude: Double
    var signName: String?
    
}
