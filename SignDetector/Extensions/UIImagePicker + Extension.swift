//
//  UIImagePicker + Extension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 21.05.2021.
//

import Foundation
import UIKit


extension UIImagePickerController
{
    override open var shouldAutorotate: Bool {
            return true
    }
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
            return .landscape
    }
}
