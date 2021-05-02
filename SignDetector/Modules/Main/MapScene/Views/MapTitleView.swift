//
//  MapTitleView.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 02.05.2021.
//

import Foundation
import UIKit

class MapTitleView: UIView {
    //MARK: - Controls
    private var topLabel = UILabel(text: "ГЛАВНАЯ",
                                   font: .sfUISemibold(with: 15),
                                        textColor: .black)
    private var bottomLabel = UILabel(text: "Знаков за сегодня: 0",
                                        fontSize: 14,
                                        textColor: #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
    
    public init() {
        super.init(frame: .zero)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Funcs
    public func setSignsCount(count: Int) {
        DispatchQueue.main.async {[weak self] in
            self?.bottomLabel.text = "Знаков за сегодня: \(count)"
        }
    }
}

//MARK: - Constraints
extension MapTitleView {
    private func setupConstraints() {
        addSubview(topLabel)
        addSubview(bottomLabel)
        
        topLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        bottomLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        
    }
}
