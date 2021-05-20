//
//  SocketManager.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 06.05.2021.
//

import Foundation
import UIKit
import SocketIO
import Combine
import SwiftyBeaver
import SwiftyJSON
import YandexMapsMobile

protocol SocketManagerDelegate: NSObjectProtocol {
    func didConnect(socket: Socket)
    func didDisconnect(socket: Socket)
    func onMessageReceived(socket: Socket, message: String)
    func onSignsReceived(socket: Socket, model: ClusterModel, clusterNumber: Int)
    
}
final class Socket: ObservableObject {
    //MARK: - Variables
    private var manager = SocketManager(socketURL: URL(string: ServerAddressConstants.SOCKET_ADDRESS)!, config: [.log(true), .compress, .connectParams(["token": APIManager.getToken()])])
    
    var socket: SocketIOClient!
    
    private static var instance: Socket? = nil
    public static var shared: Socket {
        if let instance = instance {
            return instance
        }
        instance = Socket()
        return instance!
    }
    weak var customDelegate: SocketManagerDelegate?
    
    private init() {
        print("TOKEN")
        print(APIManager.getToken())
        socket = manager.defaultSocket
        socket.disconnect()
        socket.on(clientEvent: .disconnect) { [weak self] (data, ack) in
            print("##disconnected##")
            guard let self = self else { return }
            self.customDelegate?.didDisconnect(socket: self)
        }
        socket.on(clientEvent: .connect) { [weak self](data, ack) in
            print("##connected##")
            guard let self = self else { return }
            self.customDelegate?.didConnect(socket: self)
//            print("connected---------------")
//            self?.sendImage { res in
//                print("SEND FROM .connect")
//            }
        }
        onCluster1()
        onCluster2()
        onCluster3()
        onCluster4()

        socket.connect()
    }
    public func sendImage(image: Data, lat: Double, long: Double, direction: Double, completion: @escaping (Result<Void, Error>) -> Void ) {
//        print(model.representation())
//        let img = #imageLiteral(resourceName: "Component 1")
        socket.emit("sendFile", ["buffer" : image,
                                 "lat": lat,
                                 "lon": long,
                                 "direction": direction

        ]) {
            print("SENDSEND")
            completion(.success(Void()))
        }
    }
    
    public func sendCurrentCoordinates(center: YMKPoint, topRight: YMKPoint, topLeft: YMKPoint, bottomRight: YMKPoint, bottomLeft: YMKPoint, filter: [String] ) {
        print("SLFISDFL ")
        print([
            "leftDown" : [
                "lat": bottomLeft.latitude,
                "lon": bottomLeft.longitude
            ],
            "leftUp" : [
                "lat": topLeft.latitude,
                "lon": topLeft.longitude
            ],
            "rightDown" : [
                "lat": bottomRight.latitude,
                "lon": bottomRight.longitude
            ],
            "rightUp" : [
                "lat": topRight.latitude,
                "lon": topRight.longitude
            ],
            "lat": center.latitude, "lon": center.longitude, "filter" : filter,
        "needConfirmed": APIManager.showConfirmedSignsOnMap,
        "needUnconfirmed": APIManager.showUnconfirmedSignsOnMap
])
        
        socket.emit("getSigns", [
                        "leftDown" : [
                            "lat": bottomLeft.latitude,
                            "lon": bottomLeft.longitude
                        ],
                        "leftUp" : [
                            "lat": topLeft.latitude,
                            "lon": topLeft.longitude
                        ],
                        "rightDown" : [
                            "lat": bottomRight.latitude,
                            "lon": bottomRight.longitude
                        ],
                        "rightUp" : [
                            "lat": topRight.latitude,
                            "lon": topRight.longitude
                        ],
                        "lat": center.latitude, "lon": center.longitude, "filter" : filter,
                    "needConfirmed": APIManager.showConfirmedSignsOnMap,
                    "needUnconfirmed": APIManager.showUnconfirmedSignsOnMap
        ]) {
            print(#function)
            print(APIManager.showConfirmedSignsOnMap)
            print(APIManager.showUnconfirmedSignsOnMap)
            
        }
    }
    
    private func dataToSigns(clusterNumber: Int, data: [Any]) {
        let model = Socket.dataToSignsModel(firstData: data[0])
        if let model = model {
            customDelegate?.onSignsReceived(socket: self, model: model, clusterNumber: clusterNumber)
        }
        
    }
    public func onCluster1() {
        socket.on("cluster1") {[weak self] data, _ in
            self?.dataToSigns(clusterNumber: 1, data: data)
        }
    }
    
    public func onCluster2() {
        socket.on("cluster2") { [weak self] data, _ in
            self?.dataToSigns(clusterNumber: 2, data: data)
        }
    }
    
    public func onCluster3() {
        socket.on("cluster3") { [weak self] data, _ in
            self?.dataToSigns(clusterNumber: 3, data: data)
        }
    }
    
    public func onCluster4() {
        socket.on("cluster4") { [weak self] data, _ in
            self?.dataToSigns(clusterNumber: 4, data: data)
        }
    }
}

//MARK: - Mapping
extension Socket {
    static func dataToSignsModel(firstData: Any) -> ClusterModel? {
        guard let data = firstData as? [String: Any] else {
            SwiftyBeaver.error("Incorrect model, it must be json")
            return nil
        }
        let json = JSON(data)
        
        guard let size = json["size"].int else {
            return nil
            
        }
        var model = ClusterModel(size: size,
                                 signs: [])

        guard let signs = json["signs"].array  else {
            return model
        }
        var array = [SignModel]()
        for jsonObject in signs {
            var el = SignModel(correct: jsonObject["correct"].boolValue,
                               lat: jsonObject["lat"].doubleValue,
                               lon: jsonObject["lon"].doubleValue,
                               type: jsonObject["type"].stringValue,
                               uuid: jsonObject["uuid"].stringValue)
           array.append(el)
        }
        model.signs = array
//        let parseddata = try? JSONDecoder().decode([SignModel].self, from: Data(signs.utf8))
//        if let parsedSigns = parseddata {
//            model.signs = parsedSigns
//        }
        return model
    }
}
