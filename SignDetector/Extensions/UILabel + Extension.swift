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
                      fontSize: CGFloat = 12,
                      font: UIFont? = nil,
                      textColor: UIColor = .baseGrayTextColor(),
                      textAlignment: NSTextAlignment = .center,
                      numberOfLines: Int = 1,
                      backgroundColor: UIColor? = nil) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        self.textColor = textColor
        if let font = font {
            self.font = font
        } else {
            self.font = UIFont.sfUIMedium(with: fontSize)
        }
        self.text = text
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
        if let color = backgroundColor {
            self.backgroundColor = color
        }
    }
}
