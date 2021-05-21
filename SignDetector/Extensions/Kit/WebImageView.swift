//
//  WebImageView.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 21.05.2021.
//


import Foundation
import UIKit
import Kingfisher
import SwiftyBeaver

protocol WebImageViewDelegate: NSObjectProtocol {
    func onSuccess()
    func onError()
}
class WebImageView: UIImageView {
    weak var customDelegate: WebImageViewDelegate?
    
    private var service = UserAPIService.shared
    private var imagePlaceholder: UIImage? {
        didSet {
//            print(self.image)
            if self.image == nil {
                self.image = imagePlaceholder
            }
        }
    }
    
    
    private var currentUrlSring: String?
    private let modifier = AnyModifier { request in
        var r = request
        r.setValue(APIManager.getToken(), forHTTPHeaderField: "Authorization")
        return r
    }
    public var getCurrentUrl: String? {
        print(#function)
        print(currentUrlSring)
        return currentUrlSring
    }
    
    public func resetUrl() {
        self.image = nil
        self.currentUrlSring = nil
    }
    
    public func set(imageURL: String?, placeholder: UIImage? = nil, completion: ( (Result<RetrieveImageResult, KingfisherError>)->())? = nil) {
        self.imagePlaceholder = placeholder
        guard let imageURL = imageURL, let url = URL(string: imageURL) else {
            resetUrl()
            return
        }
        
        kf.indicatorType = .activity
        self.currentUrlSring = imageURL
        kf.setImage(with: url, placeholder: placeholder , options: [.requestModifier(modifier)]) { [weak self] (result) in
            switch result {
            
            case .success(let data):
                self?.customDelegate?.onSuccess()
                break
            case .failure(let error):
                self?.customDelegate?.onError()
                self?.image = placeholder
            }
            completion?(result)
        }
    }
}
