//
//  SignModel.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 12.05.2021.
//

import Foundation
import UIKit


struct SignModel: Decodable, Equatable {
    var correct: Bool
    var lat: Double
    var lon: Double
    var type: String
    var uuid: String
    var address: String
    
    public var representation: [String: Any] {
        var rep: [String: Any] = ["lat": lat]
        rep["lon"] = lon
        rep["type"] = type
        rep["address"] = address
        rep["uuid"] = uuid
        rep["correct"] = correct
        return rep
    }
    
    static func == (lhs: SignModel, rhs: SignModel) -> Bool {
        return
            lhs.correct == rhs.correct &&
            lhs.lat == rhs.lat &&
            lhs.lon == rhs.lon &&
            lhs.type == rhs.type &&
            lhs.uuid == rhs.uuid &&
            lhs.address == rhs.address
            
    }
}
