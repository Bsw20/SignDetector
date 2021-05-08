//
//  MainTabBarController.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 07.05.2021.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tabBar.isTranslucent = false
        tabBar.tintColor = .mainBackground()
        viewControllers = [
            generateNavigationController(rootViewController: MainMapViewController(), unselectedImage: UIImage(named: "MainMapUnselected")!, selectedImage: UIImage(named: "MainMapSelected")!),
            generateNavigationController(rootViewController: SettingsViewController(),
                                         unselectedImage: UIImage(named: "SettingsVectorUnselected")!, selectedImage: UIImage(named: "SettingsVectorUnselected")!),
            generateNavigationController(rootViewController: PersonalCabinetViewController(), unselectedImage: UIImage(named: "ProfileInfoUnselected")!, selectedImage: UIImage(named: "ProfileInfoSelected")!)
        ]
    }
    private func generateNavigationController(rootViewController: UIViewController, unselectedImage: UIImage, selectedImage: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.image = unselectedImage
        navigationVC.tabBarItem.selectedImage = selectedImage
        navigationVC.navigationBar.barTintColor = .mainBackground()
        navigationVC.navigationBar.isTranslucent = false
        return navigationVC
    }
}
