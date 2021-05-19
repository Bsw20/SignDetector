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
import CoreData

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
//        CoreDataManager.shared
        
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
            if APIManager.isAuthorized() {
                CoreDataManager.shared.startSendingDataToServer()
            }
            
        default:
            isConnected = false
        }
            
    }
    
    var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
}

