//
//  APIError.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 06.05.2021.
//

import Foundation
import UIKit

struct APIErrorFabrics {
    static func serverError(code: Int?) -> APIError{
        return APIError(message: "Ошибка сервера.", code: code)
    }
    
    static func coreDataError() -> APIError {
        return APIError(message: "Ошибка CoreData.")
    }
}

class APIError: Error {
    public init(message: String, code: Int? = nil) {
        self.message = message
        self.code = code
    }
    var message: String
    var code: Int?
    
    var description: String {
        return "\(message)" + (code == nil ? "" : "\nКод: \(code)")
    }
}
