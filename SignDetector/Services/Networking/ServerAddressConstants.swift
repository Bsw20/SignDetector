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
    static let MAIN_SERVER_ADDRESS = "http://92.63.105.87:8080"
    static let SOCKET_ADDRESS = "ws://92.63.105.87:8080"
    
    //MARK: - Auth
    static let SENDSMS_ADDRESS = MAIN_SERVER_ADDRESS + "/smsSend"
    static let REGISTER_ADDRESS = MAIN_SERVER_ADDRESS + "/register"
    static let LOGIN_ADDRESS = MAIN_SERVER_ADDRESS + "/login"
    static let CHANGENAME_ADDRESS = MAIN_SERVER_ADDRESS + "/user/changeName"
    
    //MARK: - Main
    static let GETUSERINFO_ADDRESS = MAIN_SERVER_ADDRESS + "/user/getProfile"
    static let ADDSIGN_ADDRESS = MAIN_SERVER_ADDRESS + "/sign/addSign"
    static let UPLOAD_IMAGE_ADDRESS = MAIN_SERVER_ADDRESS + "/file/upload"
    static let ADD_SIGN_WITH_PHOTO_ADDRESS = MAIN_SERVER_ADDRESS + "/sign/addInfo"
    
}
