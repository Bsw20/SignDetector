//
//  AuthService.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 06.05.2021.
//

import Foundation
import UIKit
import Alamofire
import SwiftyBeaver

struct AuthService {
    struct AuthModel {
        internal init(type: AuthService.AuthType, login: String, smsCode: String) {
            self.type = type
            self.login = login
            if login.prefix(1) == "7" {
                self.login = login.replace(0, "8")
            }
            self.smsCode = smsCode
        }
        
        var type: AuthType
        var login: String
        var smsCode: String
    }
    
    struct SignInModel {
        var login: String
        var smsCode: String
        
        var representation: [String: Any] {
            var rep: [String: Any] = ["login": login]
            rep["smsCode"] = smsCode
            return rep
        }
    }
    
    struct SignUpModel {
        var login: String
        var smsCode: String
        
        var representation: [String: Any] {
            var rep: [String: Any] = ["login": login]
            rep["smsCode"] = smsCode
            rep["name"] = ""
            return rep
        }
    }
    
    typealias AuthType = NetworkingGlobalModels.AuthType
    
    public static var shared = AuthService()
    private var headers: HTTPHeaders {
        get {
            return ["Content-Type":"application/json"]
        }
    }
    
    func sendSms(login: String, completion: @escaping (Result<AuthType, APIError>) -> Void) {
        let url = ServerAddressConstants.SENDSMS_ADDRESS
        
        let userData: [String: Any] = ["login": login.prefix(1) == "7" ? login.replace(0, "8") : login]
        DispatchQueue.global(qos: .userInitiated).async {
            AF.request(url,
                       method: .post,
                       parameters: userData,
                       encoding: JSONEncoding.default,
                       headers: self.headers)
                .validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    switch response.result {
                    
                    case .success(let data):
                        if let message = (data as? [String: Any])?["message"] as? String {
                            if message == "registered" {
                                completion(.success(.registered))
                            } else {
                                completion(.success(.notRegistered))
                            }
                            return
                        }
                        completion(.failure(APIErrorFabrics.serverError(code: nil)))
                    case .failure(let error):
                        SwiftyBeaver.error(error.localizedDescription)
                        completion(.failure(APIErrorFabrics.serverError(code: error.responseCode)))
                    }
                }
        }
    }
    
    func auth(model: AuthModel, completion: @escaping (Result<Void, APIError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let url = model.type == .registered ? ServerAddressConstants.LOGIN_ADDRESS: ServerAddressConstants.REGISTER_ADDRESS
            print("URL + \(url)")
            let userData: [String: Any] = model.type == .registered ?
                SignInModel(login: model.login, smsCode: model.smsCode).representation
                :
                SignUpModel(login: model.login, smsCode: model.smsCode).representation
            print(userData)
            print(model)
            
            AF.request(url,
                       method: .post,
                       parameters: userData,
                       encoding: JSONEncoding.default,
                       headers: self.headers)
                .validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    print(response.response)
                    
                     switch response.result {
                    
                    case .success(let data):
                        if let token = (data as? [String: Any])?["token"] as? String, let hasName = (data as? [String: Any])?["hasName"] as? Bool{
                            APIManager.setToken(token: token)
                            UDManager.setNeedToSetNameStatus(status: !hasName)
                            completion(.success(Void()))
                            return
                        }
                        let error = APIErrorFabrics.serverError(code: nil)
                        SwiftyBeaver.error(error.message)
                        completion(.failure(error))
                    case .failure(let error):
                        SwiftyBeaver.error(error.localizedDescription)
                        completion(.failure(APIErrorFabrics.serverError(code: error.responseCode)))
                    }
                }
        }
    }
    
    func changeName(name: String,  completion: @escaping (Result<Void, APIError>) -> Void) {
        let url = ServerAddressConstants.CHANGENAME_ADDRESS
        
        let userData: [String: Any] = ["name": name]
        var currentHeaders = self.headers
        currentHeaders["Authorization"] = APIManager.getToken()
        
        DispatchQueue.global(qos: .userInitiated).async {
            AF.request(url,
                       method: .post,
                       parameters: userData,
                       encoding: JSONEncoding.default,
                       headers: currentHeaders)
                .validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    switch response.result {
                    
                    case .success(_):
                        UDManager.setNeedToSetNameStatus(status: false)
                        completion(.success(Void()))
                    case .failure(let error):
                        SwiftyBeaver.error(error.localizedDescription)
                        completion(.failure(APIErrorFabrics.serverError(code: error.responseCode)))
                    }
                }
        }
    }
}
