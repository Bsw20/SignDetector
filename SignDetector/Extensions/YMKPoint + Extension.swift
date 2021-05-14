//
//  YMKPoint + Extension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 13.05.2021.
//

import Foundation
import UIKit
import YandexMapsMobile
import CoreLocation

extension YMKPoint {
    public func toCoreLocationPoint() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude,
                                      longitude: self.longitude)
    }
}
