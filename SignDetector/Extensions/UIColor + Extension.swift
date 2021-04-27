//
//  UIColor + Extension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 26.04.2021.
//

import Foundation
import UIKit

extension UIColor {
    static func mainBackground() -> UIColor {
        return .white
    }
    static func baseGrayTextColor() -> UIColor {
        return #colorLiteral(red: 0.3921568627, green: 0.4235294118, blue: 0.5294117647, alpha: 1)
    }
    static func baseOrange() -> UIColor {
        return #colorLiteral(red: 0.9529411765, green: 0.4392156863, blue: 0.07058823529, alpha: 1)
    }
    static func baseOrangeWithOpacity() -> UIColor {
        return #colorLiteral(red: 0.9529411765, green: 0.4392156863, blue: 0.07058823529, alpha: 0.5)
    }
    
    static func silverLighten() -> UIColor {
        return #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.9725490196, alpha: 1)
    }
}
