//
//  LocalManager.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 14.05.2021.
//

import Foundation
import UIKit

class LocalManager {
    struct LocalManagerSignModel {
        var name: String
        var imageName: String?
    }
    public init(){
        initData()
    }
    
    private var keys: [String]?
    private var localSigns: [String: String]?
    
    public var signs: [String: String] {
        if localSigns == nil {
            let jsonData = readLocalFile(forName: "signsNames")!
            parse(jsonData: jsonData)
        }
        return localSigns!
    }
    public static var shared = LocalManager()
    
    public func getKeys() -> [String] {
        initData()
        return keys!
    }
    public func getSignByIndex(index: Int) -> LocalManagerSignModel? {
        initData()
        if index > keys!.count - 1 {
            return nil
        }
        let key = keys![index]
        return .init(name: signs[key]!,
                     imageName: key)
            
    }
    
    public func getIndexBy(name: String) -> Int {
        initData()
        return keys!.firstIndex(of: name) ?? 0
    }
    
    public func getSignNameBy(id: String) -> String? {
        initData()
        return localSigns![id]
    }
    
    private func initData() {
        if keys == nil || localSigns == nil {
            let jsonData = readLocalFile(forName: "signsNames")!
            parse(jsonData: jsonData)
        }
    }
    
    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    private func parse(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode([String:String].self,
                                                       from: jsonData)
            
            print(decodedData.count)
            self.localSigns = decodedData
            keys = decodedData.keys.sorted{$0 < $1}
        } catch {
            fatalError("Файловая система была некорректно изменена, signs json incorrect")
        }
    }
    
    
}
