//
//  EditingSignModel.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 14.05.2021.
//

import Foundation
import UIKit

struct EditingSignModel {
    internal init(uuid: String, address: String, latitude: Double, longitude: Double, confirmed: Bool = false,  signName: String) {
        self.uuid = uuid
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.signName = signName
        self.confirmed = confirmed
    }
    
    internal init(address: String, latitude: Double, longitude: Double, confirmed: Bool = false, signName: String? = nil) {
        self.uuid = UUID().uuidString
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.signName = signName
        self.confirmed = confirmed
    }
    
    var uuid: String
    var address: String
    var latitude: Double
    var longitude: Double
    var signName: String?
    var confirmed: Bool
    
}
