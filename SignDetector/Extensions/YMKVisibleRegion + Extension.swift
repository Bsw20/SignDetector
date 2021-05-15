//
//  YMKVisibleRegion + Extension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 15.05.2021.
//

import Foundation
import YandexMapsMobile

extension YMKVisibleRegion {
    public func contains(_ point: YMKPoint) -> Bool {
        return self.asCGRect().contains(CGPoint(x: point.longitude, y: point.latitude))
      }
      

      public func asCGRect() -> CGRect {
          return CGRect(
              x: self.topLeft.longitude,
              y: self.topLeft.latitude,
              width: self.topRight.longitude - self.topLeft.longitude,
              height: self.bottomLeft.latitude - self.topLeft.latitude
          )
      }
}
