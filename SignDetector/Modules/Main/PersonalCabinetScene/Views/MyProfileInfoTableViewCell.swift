//
//  MyProfileInfoTableViewCell.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 27.04.2021.
//

import Foundation
import UIKit

class MyProfileInfoTableViewCell: UITableViewCell {
    //MARK: - Varibles
    public static var reuseId = "MyProfileInfoTableViewCell"
    //MARK: - Controls
    private var topLabel = UILabel(text: "НОМЕР ТЕЛЕФОНА",
                                   font: UIFont.sfUIMedium(with: 12),
                                        textColor: #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
    
    private var bottomLabel = UILabel(text: "+7 (912) 992 53 84",
                                   font: UIFont.sfUIMedium(with: 18),
                                   textColor: .black)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(topText: String, bottomText: String) {
        topLabel.text = topText
        bottomLabel.text = bottomText
    }
}
//Height 80

//MARK: - Constraints
extension MyProfileInfoTableViewCell {
    private func setupConstraints() {
        addSubview(topLabel)
        addSubview(bottomLabel)
        
        topLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
        }
        
        bottomLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom).offset(6)
        }
        
        let topLabelHeight = "string".sizeOfString(usingFont: UIFont.sfUIMedium(with: 12)).height
        NSLayoutConstraint.activate([
            topLabel.heightAnchor.constraint(equalToConstant: topLabelHeight)
        ])
        
        let bottomLabelHeight = "string".sizeOfString(usingFont: UIFont.sfUIMedium(with: 18)).height
        NSLayoutConstraint.activate([
            bottomLabel.heightAnchor.constraint(equalToConstant: bottomLabelHeight)
        ])
        
    }
}
