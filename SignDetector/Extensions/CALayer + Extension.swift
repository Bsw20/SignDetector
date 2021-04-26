//
//  CALayer + Extension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 26.04.2021.
//

import Foundation
import UIKit

extension CALayer {
    func animateBorderColor(from startColor: UIColor, to endColor: UIColor, withDuration duration: Double, autoreverses: Bool = false, animationDelegate: CAAnimationDelegate? = nil) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = startColor.cgColor
        animation.toValue = endColor.cgColor
        animation.duration = duration
        animation.autoreverses = autoreverses
        if !autoreverses {
            borderColor = endColor.cgColor
        }
        animation.delegate = animationDelegate
        self.add(animation, forKey: "borderColor")
    }
}
