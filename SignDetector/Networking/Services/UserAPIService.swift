//
//  UserAPIService.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 08.05.2021.
//

import Foundation
import UIKit
import Alamofire
import SwiftyBeaver

struct UserAPIService {
    private init() {}
    public static var shared = UserAPIService()
    
    private var headers: HTTPHeaders {
        get {
            return ["Content-Type":"application/json",
                    "Authorization" : APIManager.getToken()
            ]
        }
    }
    public func getUserInfo(completion: @escaping (Result<Void, APIError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let url = ServerAddressConstants.GETUSERINFO_ADDRESS
            
                AF.request(url,
                           method: .get,
                           encoding: JSONEncoding.default,
                           headers: self.headers)
                    .validate(statusCode: 200..<300)
                    .responseJSON { (response) in
                        switch response.result {
                        
                        case .success(let data):
                            print(data)
//                            if let message = (data as? [String: Any])?["message"] as? String {
//                                if message == "registered" {
//                                    completion(.success(.registered))
//                                } else {
//                                    completion(.success(.notRegistered))
//                                }
//                                return
//                            }
//                            completion(.failure(APIErrorFabrics.serverError(code: nil)))
                        case .failure(let error):
                            SwiftyBeaver.error(error.localizedDescription)
                            completion(.failure(APIErrorFabrics.serverError(code: error.responseCode)))
                        }
                    }
        }
    }
}
