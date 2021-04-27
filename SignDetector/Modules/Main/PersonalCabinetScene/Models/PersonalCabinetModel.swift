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
struct PersonalCabinetModel {
    var profileImage: String?
    var phoneNumber: String
    var fio: String
    var detectedSignsCount: Int
    var time: Int
    var position: JobPosition
    
    
}
