//
//  SelectSignCell.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 14.05.2021.
//

import Foundation
import UIKit

class SelectSignCell: UITableViewCell {
    //MARK: - Variables
    public static var reuseId = "SelectSignCell"
    private var signNameLabel = UILabel(text: "",
                                        fontSize: 16,
                                        textColor: .black,
                                        textAlignment: .left)
    private var rightImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8941176471, blue: 0.9098039216, alpha: 1)
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 9
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    //MARK: - Initing
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .gray
        backgroundColor = .white
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - funcs
    public func configure(text: String, image: UIImage? = nil) {
        onMainThread {[weak self] in
            self?.signNameLabel.text = text
            self?.rightImageView.image = image
        }
    }
}

//MARK: - Constraints
extension SelectSignCell {
    private func setupConstraints() {
        addSubview(signNameLabel)
        addSubview(rightImageView)
        
        rightImageView.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(23)
        }
        
        signNameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
//            make.right.equalTo(rightImageView.snp.left)
        }
        
        NSLayoutConstraint.activate([
            signNameLabel.trailingAnchor.constraint(equalTo: rightImageView.leadingAnchor, constant: -5)
        ])
    }
}
