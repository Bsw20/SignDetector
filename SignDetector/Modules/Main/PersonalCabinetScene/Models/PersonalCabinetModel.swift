//
//  PersonalCabinetModel.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 27.04.2021.
//

import Foundation
import UIKit

enum JobPosition: String, CaseIterable {
    case manager = "manager"
    case user = "user"
    
    func description() -> String {
        switch self {
        
        case .manager:
            return "Менеджер"
        case .user:
            return "Пользователь"
        }
    }
}
class PersonalCabinetModel {
    internal init(profileImage: UIImage? = nil, phone: String, name: String, signsCount: Int, role: JobPosition, id: String) {
        self.profileImage = profileImage
        self.phone = phone
        self.name = name
        self.signsCount = signsCount
        self.role = role
        self.id = id
    }
    
    var profileImage: UIImage?
    
    var phone: String
    var name: String
    var signsCount: Int
    var role: JobPosition
    var id: String
    
    init?(data: Any) {
        
        guard let json = data as? [String: Any] else { return nil}
        
        guard let intId =  json["id"] as? Int64,
              let name =  json["name"] as? String,
              let phone = json["phone"] as? String,
              let pos = json["role"] as? String,
              let role = JobPosition.init(rawValue: pos),
              let signsCount = json["signsCount"] as? String
        else {
            return nil
        }
        
        self.id = String(intId)
        self.name = name
        self.phone = phone
        self.role = role
        self.signsCount = Int(signsCount) ?? 0
        
        let lblNameInitialize = UILabel()
        lblNameInitialize.frame.size = CGSize(width: 100.0, height: 100.0)
        lblNameInitialize.textColor = .black
        lblNameInitialize.text = String((name.first)!)
        lblNameInitialize.textAlignment = NSTextAlignment.center
        lblNameInitialize.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        lblNameInitialize.layer.cornerRadius = 50.0
        lblNameInitialize.font = lblNameInitialize.font.withSize(50)
        UIGraphicsBeginImageContext(lblNameInitialize.frame.size)
        lblNameInitialize.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.profileImage = newImage
        
    }
    
}
