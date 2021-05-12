//
//  ClusterModel.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 12.05.2021.
//

import Foundation
import UIKit

struct ClusterModel: Decodable {
    var size: Int
    
    var signs: [SignModel]
}
