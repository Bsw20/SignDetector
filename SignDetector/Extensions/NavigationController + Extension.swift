//
//  NavigationController + Extension.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 26.04.2021.
//

import Foundation
import UIKit

extension UINavigationController {
    func setupAsBaseScreen(_ controller: UIViewController, animated: Bool) {
        self.setViewControllers([controller], animated: animated)
    }
    
    func push(_ controller: UIViewController, animated: Bool = true, completion: @escaping() -> () = {}) {
        pushViewController(controller, animated: animated)
        completion()
    }
    
    func presentScreen(_ controller: UIViewController, animated: Bool = true, completion: @escaping() -> () = {}) {
        present(controller, animated: animated, completion: completion)
        completion()
    }
}
