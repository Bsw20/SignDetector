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

protocol SocketManagerDelegate: NSObjectProtocol {
    func didConnect(socket: Socket)
    func didDisconnect(socket: Socket)
    func onMessageReceived(socket: Socket, message: String)
    
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

        socket.connect()
    }
    public func sendImage(image: Data, completion: @escaping (Result<Void, Error>) -> Void ) {
//        print(model.representation())
//        let img = #imageLiteral(resourceName: "Component 1")
        socket.emit("sendFile", ["buffer" : image]) {
            print("SENDSEND")
            completion(.success(Void()))
        }
    }
}
