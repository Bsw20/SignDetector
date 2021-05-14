//
//  NewLocationView.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 13.05.2021.
//

import Foundation
import UIKit

protocol NewLocationViewDelegate: NSObjectProtocol {
    func approveButtonTapped()
    func cancelButtonTapped()
}
class NewLocationView: UIView {
    //MARK: - Variables
    weak var customDelegate: NewLocationViewDelegate?
    //MARK: - Controls
    
    private var topLabel = UILabel(text: "НОВЫЙ УЧАСТОК",
                                   font: .sfUISemibold(with: 15),
                                        textColor: .black)
    private var bottomLabel = UILabel(text: "Перетащите на нужную точку",
                                        fontSize: 14,
                                        textColor: #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
    
    private var approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ApproveActionVector"), for: .normal)
        return button
    }()
    
    private var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "CancelActionVector"), for: .normal)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        self.translatesAutoresizingMaskIntoConstraints = false
        configure()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Funcs
    private func configure() {
        approveButton.addTarget(self, action: #selector(approveButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    //MARK: - Objc funcs
    @objc private func approveButtonTapped() {
        customDelegate?.approveButtonTapped()
    }
    @objc private func cancelButtonTapped() {
        customDelegate?.cancelButtonTapped()
    }
}

//MARK: - NewLocationView
extension NewLocationView {
    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds
        let scale = UIScreen.main.scale
//        addSubview(label)
//        addSubview(modeSwitch)
        addSubview(approveButton)
        addSubview(cancelButton)
        addSubview(topLabel)
        addSubview(bottomLabel)
        
        self.snp.makeConstraints { (make) in
            make.height.equalTo(0.0825 * screenSize.height)
            make.width.equalTo(screenSize.width)
        }
        
        approveButton.snp.makeConstraints { make in
            make.width.equalTo(15 * scale)
            make.height.equalTo(11 * scale)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(screenSize.width * 0.07 )
        }
        
        cancelButton.snp.makeConstraints { make in
            make.width.height.equalTo(11.5 * scale)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(screenSize.width * 0.07 )
        }
        
        topLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.left.equalTo(cancelButton.snp.right)
            make.right.equalTo(approveButton.snp.left)
        }
        
        bottomLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.left.equalTo(cancelButton.snp.right)
            make.right.equalTo(approveButton.snp.left)
        }
    }
}
