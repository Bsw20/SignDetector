//
//  ImagedButton.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 14.05.2021.
//

import Foundation
import UIKit

protocol ImagedButtonDelegate: NSObjectProtocol {
    func buttonTapped(button: ImagedButton)
}

class ImagedButton: UIButton {
    //MARK: - Variables
    weak var customDelegate: ImagedButtonDelegate?
    
    //MARK: - Controls
    private var leftLabel = UILabel(text: "",
                                        fontSize: 18,
                                        textColor: #colorLiteral(red: 0.2431372549, green: 0.262745098, blue: 0.3294117647, alpha: 1),
                                        textAlignment: .left)
    
    private var rightImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.9725490196, alpha: 1)
        return iv
    }()
    //MARK: - Lifecycle
    init(text: String? = nil, image: UIImage? = nil) {
        super.init(frame: .zero)
        if let text = text {
            leftLabel.text = text
        }
        if let image = image {
            rightImageView.image = image
        }
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.9725490196, alpha: 1)
        layer.cornerRadius = 10
        clipsToBounds = true
        addTarget(self, action: #selector(onTap), for: .touchUpInside)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - funcs
    public func configure(text: String?, image: UIImage? = nil) {
        onMainThread {[weak self] in
            guard let self = self else { return }
            self.layer.cornerRadius = 10
            if let image = image {
                self.rightImageView.image = image
            }
            if let text = text {
                self.leftLabel.text = text
            }
        }
    }
    
    //MARK: - Objc funcs
    @objc private func onTap() {
        customDelegate?.buttonTapped(button: self)
    }
}

//MARK: - Constraints
extension ImagedButton {
    private func setupConstraints() {
        addSubview(leftLabel)
        addSubview(rightImageView)
        let scale = UIScreen.main.scale
        
        rightImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(15.75)
            make.width.equalTo(17.5)
            make.height.equalTo(20)
        }
        
        leftLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(14)
            make.right.equalTo(rightImageView.snp.left).inset(5)
        }
        
        
    }
}
