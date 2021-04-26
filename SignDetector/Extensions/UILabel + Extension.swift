//
//  UILabel + Extension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 26.04.2021.
//

import Foundation
import UIKit

extension UILabel {
    convenience init( text: String,
                      fontSize: CGFloat,
                      textColor: UIColor = .baseGrayTextColor(),
                      textAlignment: NSTextAlignment = .center,
                      numberOfLines: Int = 1) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        self.textColor = textColor
        self.font = UIFont.sfUIMedium(with: fontSize)
        self.text = text
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
    }
}
