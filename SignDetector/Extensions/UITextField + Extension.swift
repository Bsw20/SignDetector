//
//  UITextField + Extension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 27.04.2021.
//

import Foundation
import UIKit

extension UITextField {
    static func getNormalTextField(placeholder: String) -> UITextField{
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                             attributes:[NSAttributedString.Key.foregroundColor: UIColor.baseGrayTextColor(), NSAttributedString.Key.font: UIFont.sfUIMedium(with: 17)])
        textField.backgroundColor = .silverLighten()
        textField.clipsToBounds = true
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 19, height: textField.frame.height))
        textField.leftViewMode = .always

        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 19, height: textField.frame.height))
        textField.rightViewMode = .always
        
        textField.textColor = .baseGrayTextColor()
        textField.font = UIFont.sfUIMedium(with: 17)
        
        return textField
    }
}
