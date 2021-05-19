//
//  String + Extension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 27.04.2021.
//

import Foundation
import UIKit

extension String {
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let frame = (self as NSString).size(withAttributes: fontAttributes)
        
        let textpreSize = CGSize(width: frame.width, height: .greatestFiniteMagnitude)
        
        let size = self.boundingRect(with: textpreSize,
                                     options: .usesLineFragmentOrigin,
                                     attributes: fontAttributes,
                                     context: nil)
        return CGSize(width: size.width, height: ceil(size.height))
    }
    
    func replace(_ index: Int, _ newChar: Character) -> String {
        var chars = Array(self)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    
}
