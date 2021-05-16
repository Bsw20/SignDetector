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
    
    
    private var bodyFormDataHeaders: HTTPHeaders {
        get {
            return ["Content-Type":"multipart form data",
                    "Authorization" : APIManager.getToken()
            ]
        }
    }
    
    struct AddSignModel {
        var uuid: String
        var lat: Double
        var lon: Double
        var name: String
        var address: String
        
        public var representation: [String: Any] {
            var rep: [String: Any] = ["lat": lat]
            rep["lon"] = lon
            rep["name"] = name
            rep["address"] = address
            rep["uuid"] = uuid
            return rep
        }
    }
    
    struct SendImageModel {
        var fileData: Data
        var latitude: Double
        var longitude: Double
        var address: String
        var direction: Double
        
        public var representation: [String: Any] {
            var rep: [String: Any] = ["filedata": fileData]
            rep["lon"] = longitude
            rep["lat"] = latitude
            rep["address"] = address
            rep["direction"] = direction
            return rep
        }
    }
    public func sendImageWithSign(model: SendImageModel, completion: @escaping (Result<Void, APIError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let url = ServerAddressConstants.ADD_IMAGE_WITH_SIGN_ADDRESS
            AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(model.fileData, withName: "filedata")
                multipartFormData.append(("\(model.longitude)").data(using: .utf8, allowLossyConversion: false)!, withName: "lon")
                multipartFormData.append(("\(model.latitude)").data(using: .utf8, allowLossyConversion: false)!, withName: "lat")
                multipartFormData.append(model.address.data(using: .utf8, allowLossyConversion: false)!, withName: "address")
                multipartFormData.append(("\(model.direction)").data(using: .utf8, allowLossyConversion: false)!, withName: "direction")
multipartFormData.append("India".data(using: .utf8, allowLossyConversion: false)!, withName: "location")

            }, to: url, method: .post)
            .validate(statusCode: 200..<300)
            .responseJSON { (result) in
                #warning("RECODE")
                switch result.result {
                
                case .success(let data):
                    onMainThread {
                        completion(.success(Void()))
                    }
                case .failure(let error):
                    SwiftyBeaver.error(error.localizedDescription)
                    onMainThread {
                        completion(.failure(APIErrorFabrics.serverError(code: error.responseCode)))
                    }
                }

            }
        }
    }
    
    public func addSign(model: AddSignModel, completion: @escaping (Result<Void, APIError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let url = ServerAddressConstants.ADDSIGN_ADDRESS
            
            AF.request(url,
                       method: .post,
                       parameters: model.representation,
                       encoding: JSONEncoding.default,
                       headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON(completionHandler: { (response) in
                    
                    switch response.result {
                    case .success(let data):
                        onMainThread {
                            print(data)
                            completion(.success(Void()))
                        }
                    case .failure(let error):
                        SwiftyBeaver.error(error.localizedDescription)
                        onMainThread {
                            completion(.failure(APIErrorFabrics.serverError(code: error.responseCode)))
                        }
                    }
                })
        }
    }
    
    public func getUserInfo(completion: @escaping (Result<PersonalCabinetModel, APIError>) -> Void) {
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
                            if let model = PersonalCabinetModel(data: data) {
                                onMainThread {
                                    completion(.success(model))
                                }
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
}
