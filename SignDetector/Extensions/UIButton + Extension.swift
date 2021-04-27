//
//  UIButton + Extension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 26.04.2021.
//

import Foundation
import UIKit

extension UIButton {
    static func getLittleRoundButton(text: String?,
                                     backgroundColor: UIColor = .baseOrange(), disabledBackgroundColor: UIColor = .baseOrangeWithOpacity(),
                                     textColor: UIColor = .white,
                                     image: UIImage? = nil,
                                     font: UIFont? = UIFont.sfUISemibold(with: 14),
                                     isEnabled: Bool = true) -> UIButton {
        let button = StateSensitiveButton(type: .system)
        button.setupColors(enabledColor: backgroundColor, disabledColor: disabledBackgroundColor)
        button.setTitle(text, for: .normal)
        button.setImage(image, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel?.font = font
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.isEnabled = isEnabled
        return button
    }
}
private class StateSensitiveButton: UIButton {
    //MARK: - Variables
    private var enabledColor: UIColor = .baseOrange()
    private var disabledColor: UIColor = .baseOrangeWithOpacity()
    
    override open var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? enabledColor : disabledColor
        }
    }
    
    //MARK: - Functions
    public func setupColors(enabledColor: UIColor = .baseOrange(), disabledColor: UIColor = .baseOrangeWithOpacity()) {
        self.enabledColor = enabledColor
        self.disabledColor = disabledColor
    }
}

