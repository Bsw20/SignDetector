//
//  OTPTextField.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 26.04.2021.
//

import Foundation
import UIKit

class OTPTextField: UITextField {
    weak var previousTextField: OTPTextField?
    weak var nextTextField: OTPTextField?
    
    override func deleteBackward() {
        if text == "" {
            previousTextField?.text = ""
        }
        text = ""
        previousTextField?.becomeFirstResponder()
    }
}
