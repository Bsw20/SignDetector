//
//  SignModel.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 12.05.2021.
//

import Foundation
import UIKit


struct SignModel: Decodable {
    var correct: Bool
    var lat: Double
    var lon: Double
    var type: String
    var uuid: String
}
