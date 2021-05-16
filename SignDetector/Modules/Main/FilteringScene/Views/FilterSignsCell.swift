//
//  FilterSignsCell.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 16.05.2021.
//

import Foundation
import UIKit

class FilterSignsCell: UITableViewCell {
    
    //MARK: - Variables
    public static var reuseId = "FilterSignsCell"
    private var signImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 9
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var selectedForEditing: Bool = false {
        didSet {
            if selectedForEditing {
                checkBox.image = UIImage(named: "CheckBoxOnVector")
            } else {
                checkBox.image = UIImage(named: "CheckBoxOffVector")
            }
        }
    }
    //MARK: - Controls
    private var checkBox: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "CheckBoxOffVector"))
        imageView.backgroundColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var leftLabel = UILabel(text: "Все",
                                        fontSize: 16,
                                        textColor: .black,
                                        textAlignment: .left)
    
    //MARK: - Initing
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectedForEditing = false
        signImageView.isHidden = true
    }
    
    //MARK: - funcs
    public func configure(text: String, isSelected: Bool, signImageName: String?) {
        onMainThread {[weak self] in
            self?.signImageView.isHidden = signImageName == nil
            self?.selectedForEditing = isSelected
            self?.leftLabel.text = text
            if let imageName = signImageName {
                self?.signImageView.image = UIImage(named: imageName)
            }
        }
    }
    
    public func configure(isSelected: Bool) {
        selectedForEditing = isSelected
    }
}

//MARK: - Constraints
extension FilterSignsCell {
    private func setupConstraints() {
        addSubview(leftLabel)
        addSubview(checkBox)
        addSubview(signImageView)
        
        checkBox.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.right.equalToSuperview().inset(23)
            make.centerY.equalToSuperview()
        }
        
        signImageView.snp.makeConstraints { make in
            make.width.height.equalTo(32)
//            make.right.equalTo(checkBox.snp.left).inset(10)
            make.centerY.equalToSuperview()
        }
        
        NSLayoutConstraint.activate([
            signImageView.trailingAnchor.constraint(equalTo: checkBox.leadingAnchor, constant: -10)
        ])
        
        leftLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalTo(signImageView.snp.left).inset(5)
            
        }
    }
}

