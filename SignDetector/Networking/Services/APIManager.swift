//
//  APIManager.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 06.05.2021.
//

import Foundation
import UIKit
import SwiftyBeaver


struct APIManager {
    static func setToken(token: String) {
        SwiftyBeaver.info("token was updated")
        UserDefaults.standard.set(token, forKey: "userSecret")
    }
    
    static func getToken() -> String {
       return UserDefaults.standard.object(forKey: "userSecret") as? String ?? ""
    }
    
    static func isAuthorized() -> Bool {
        return getToken() !=  ""
    }
    
    static func needToSetName() -> Bool {
        return (UserDefaults.standard.bool(forKey: "needToSetName") as? Bool) ?? true
    }
    
    static func setNeedToSetNameStatus(status: Bool) {
        UserDefaults.standard.set(status, forKey: "needToSetName")
    }
    
    static func logOut() {
        setToken(token: "")
        setNeedToSetNameStatus(status: true)
        SceneDelegate.shared().startSignIn()
        SwiftyBeaver.info("User log out")
    }
}
