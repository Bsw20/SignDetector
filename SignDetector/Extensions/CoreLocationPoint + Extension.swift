//
//  CoreLocationPoint + Extension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 13.05.2021.
//

import Foundation
import UIKit
import YandexMapsMobile
import CoreLocation

extension CLLocationCoordinate2D {
    public func toYMKPoint() -> YMKPoint {
        return YMKPoint(latitude: self.latitude,
                                      longitude: self.longitude)
    }
}

