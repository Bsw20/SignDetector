//
//  SceneDelegate.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 18.03.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
//        window?.rootViewController = UINavigationController(rootViewController: SignInViewController())
//        window?.rootViewController = PersonalCabinetViewController()
//        window?.rootViewController = UINavigationController(rootViewController: SettingsViewController())
//        window?.rootViewController = SettingsViewController()
//        window?.rootViewController = UINavigationController(rootViewController: MainMapViewController())
//        window?.rootViewController = MainTabBarController()
        window?.makeKeyAndVisible()
        
        if APIManager.isAuthorized() {
            if UDManager.needToSetName() {
                window?.rootViewController = UINavigationController(rootViewController: PersonalDataViewController())
            } else {
                window?.rootViewController = MainTabBarController()
            }
        } else {
            startSignIn()
        }
        
        SignsJSONHolder.build()
    }
    
    func startSignIn() {
        let signInVC = SignInViewController()
        window?.rootViewController = UINavigationController(rootViewController: signInVC)
    }
    
    func setRootController(controller: UIViewController) {
        window?.rootViewController = controller
    }
}


extension SceneDelegate {
    public static func shared() -> SceneDelegate {
        
        let sceneDelegate = UIApplication.shared.connectedScenes
                .first!.delegate as! SceneDelegate
        return sceneDelegate
    }
}
