//
//  UDManager.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 29.05.2021.
//

import Foundation
import UIKit

struct UDManager {
    static func needToSetName() -> Bool {
        return (UserDefaults.standard.bool(forKey: "needToSetName") as? Bool) ?? true
    }

    static func setNeedToSetNameStatus(status: Bool) {
        UserDefaults.standard.set(status, forKey: "needToSetName")
    }

    private static let cameraWorkOnStartKey = "isCameraWorkOnStart"
    
    static func isCameraWorkOnStart() -> Bool {
        return UserDefaults.standard.bool(forKey: cameraWorkOnStartKey)
    }
    
    static func setIsCameraWorkOnStart(shouldWork: Bool) {
        UserDefaults.standard.set(shouldWork, forKey: cameraWorkOnStartKey)
    }
    
    private static let showConfirmedSignsKey = "showConfirmedSignsKey"
    
    static var showConfirmedSignsOnMap: Bool {
        get {
            if UserDefaults.standard.object(forKey: showConfirmedSignsKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: showConfirmedSignsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: showConfirmedSignsKey)
        }
    }
    
    private static let showUnconfirmedSignsKey = "showUnconfirmedSignsKey"
    
    static var showUnconfirmedSignsOnMap: Bool {
        get {
            if UserDefaults.standard.object(forKey: showUnconfirmedSignsKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: showUnconfirmedSignsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: showUnconfirmedSignsKey)
        }
    }
}
