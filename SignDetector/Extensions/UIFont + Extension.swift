//
//  UIFont + Extension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 26.04.2021.
//

import Foundation
import UIKit

extension UIFont {
    static func sfUIMedium(with size: CGFloat) -> UIFont {
        //IF nil fatal error
        return UIFont.init(name: "SFUIDisplay-Regular", size: size)!
    }
    
    static func sfUISemibold(with size: CGFloat) -> UIFont {
        //IF nil fatal error
        return UIFont.init(name: "SFUIDisplay-Semibold", size: size)!
    }
}

