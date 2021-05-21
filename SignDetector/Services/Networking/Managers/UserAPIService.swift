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
        var direction: Double
        
        public var representation: [String: Any] {
            var rep: [String: Any] = ["filedata": fileData]
            rep["lon"] = longitude
            rep["lat"] = latitude
            rep["direction"] = direction
            return rep
        }
    }
    public func sendImageWithSign(model: SendImageModel, completion: @escaping (Result<Void, APIError>) -> Void) {
        let url = ServerAddressConstants.UPLOAD_IMAGE_ADDRESS
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            "Authorization" : APIManager.getToken()
                ]
        AF.upload(multipartFormData: { (multiPart) in
            multiPart.append(model.fileData, withName: "filedata", fileName: "image.png", mimeType: "image/jpeg")
        }, to: url, headers: headers)
        .validate(statusCode: 200..<300)
        .responseJSON { (result) in

            switch result.result {
            
            case .success(let data):
                print(data)
                if let data = data as? [String:String], let fileId = data["id"] {
                    print(fileId)
                    uploadSignInfo(model: .init(fileId: fileId,
                                                latitude: model.latitude,
                                                longitude: model.longitude,
                                                direction: model.direction)) { result in
                        completion(result)
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
    
    struct SignInfoModel {
        var fileId: String
        var latitude: Double
        var longitude: Double
        var direction: Double
        
        public var representation: [String: Any] {
            var rep: [String: Any] = ["id": fileId]
            rep["lon"] = longitude
            rep["lat"] = latitude
            rep["direction"] = direction
            return rep
        }
    }
    private func uploadSignInfo(model: SignInfoModel, completion: @escaping (Result<Void, APIError>) -> Void) {
        let url = ServerAddressConstants.ADD_SIGN_WITH_PHOTO_ADDRESS
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
    
    public func getUserPosition(completion: @escaping (JobPosition) -> Void) {
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
                            if let json = data as? [String: Any],
                               let pos = json["role"] as? String,
                               let role = JobPosition.init(rawValue: pos) {
                                completion(role)
                                return
                            }
                            
                            let error = APIErrorFabrics.serverError(code: nil)
                            SwiftyBeaver.error(error.message)
//                            completion(.failure(error))
                            completion(.user)
                            
                        case .failure(let error):
                            SwiftyBeaver.error(error.localizedDescription)
                            completion(.user)
                        }
                }
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
    
    public func deleteUser(login: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let url = ServerAddressConstants.MAIN_SERVER_ADDRESS + "/deleteUser"
            
            AF.request(url,
                       method: .post,
                       parameters: ["login" : login],
                       encoding: JSONEncoding.default,
                       headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON(completionHandler: { (response) in
                    
                    switch response.result {
                    case .success(let data):
                        onMainThread {
                            APIManager.logOut()
                            SwiftyBeaver.info("User \(login) deleted")
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
}
