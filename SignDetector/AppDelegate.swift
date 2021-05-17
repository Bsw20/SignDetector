//
//  AppDelegate.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 18.03.2021.
//

import UIKit
import YandexMapsMobile
import SwiftyBeaver
import Connectivity

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let MAPKIT_API_KEY = "d439c349-2ddc-4a0d-8833-9af1d6e6fc1f"
    

    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        YMKMapKit.setApiKey(MAPKIT_API_KEY)
        SwiftyBeaver.addDestination(ConsoleDestination())
        let connectivityChanged: (Connectivity) -> Void = { [weak self] connectivity in
             self?.updateConnectionStatus(connectivity.status)
        }
        
        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
        connectivity.pollingInterval = 7
        connectivity.isPollingEnabled = true
        connectivity.framework = .network

        connectivity.startNotifier()
        return true
    }
    
    //MARK: - Connectivity
    let connectivity = Connectivity()

    
    private(set) var isConnected = false
    
    func updateConnectionStatus(_ status: Connectivity.Status) {

        switch status {
        case .connectedViaCellular, .connectedViaWiFi, .connected:
            isConnected = true
        default:
            isConnected = false
        }
            
    }
}

