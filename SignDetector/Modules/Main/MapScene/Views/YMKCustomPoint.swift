//
//  YMKCustomPoint.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 15.05.2021.
//

import Foundation
import UIKit
import YandexMapsMobile

class YMKCustomPointView: UIView {
    private(set) var isVerified: Bool
    
    private var imageView: UIImageView = {
        let iv = UIImageView()
//        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    init(isVerified: Bool, image: UIImage?) {
        self.isVerified = isVerified
        super.init(frame: CGRect(x: 0, y: 0, width: 26, height: 26))

        if isVerified {
            backgroundColor = .green
        } else {
            backgroundColor = UIColor.baseRed()
        }
        
        imageView.image = image
        imageView.frame = CGRect(x: 3, y: 3, width: 20, height: 20)
        addSubview(imageView)
        setupUI()
    }
    
    private func setupUI() {
        layer.cornerRadius = 13
        isOpaque = false
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //    init() {
//        super.init(latitude: <#T##Double#>, longitude: <#T##Double#>)
//    }
//    override init(latitude: Double, longitude: Double) {
//        
//    }
    
}
