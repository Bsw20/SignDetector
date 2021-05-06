//
//  ServerAddressConstants.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 06.05.2021.
//

import Foundation
import UIKit

struct ServerAddressConstants {
    //MARK: - Server Address
    static var MAIN_SERVER_ADDRESS = "http://92.63.105.87:8080"
    
    //MARK: - Auth
    static var SENDSMS_ADDRESS = MAIN_SERVER_ADDRESS + "/smsSend"
    static var REGISTER_ADDRESS = MAIN_SERVER_ADDRESS + "/register"
    static var LOGIN_ADDRESS = MAIN_SERVER_ADDRESS + "/login"
    static var CHANGENAME_ADDRESS = MAIN_SERVER_ADDRESS + "/user/changeName"
}
