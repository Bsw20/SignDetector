//
//  PersonalDataViewController.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 27.04.2021.
//

import Foundation
import UIKit

class PersonalDataViewController: UIViewController {
    //MARK: - Controls
    private var topLabel = UILabel(text: "Данные",
                                      font: UIFont.sfUISemibold(with: 32),
                                      textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
                                      textAlignment: .center)
    private var lastStepLabel = UILabel(text: "Последний шаг перед началом использования",
                                        fontSize: 16,
                                        textColor: .baseGrayTextColor(),
                                        textAlignment: .left,
                                        numberOfLines: 2)
    private var fioLabel = UILabel(text: "ФИО",
                                        fontSize: 12,
                                        textColor: .baseGrayTextColor(),
                                        textAlignment: .center,
                                        numberOfLines: 1)
    
    private lazy var fioTextView: TextFieldView = TextFieldView(placeholder: "Иванов Иван Иванович")
    
    private var nextButton = UIButton.getLittleRoundButton(text: "ГОТОВО",
                                                           isEnabled: false)
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        setupUI()
        setupConstraints()
    }
    
    //MARK: - Funcs
    private func configure() {
        fioTextView.delegate = self
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
    }
    //MARK: - objc funcs
    @objc private func nextButtonTapped() {
        if(!fioTextView.isEmpty()) {
            AuthService.shared.changeName(name: fioTextView.getText()) {[weak self] result in
                switch result {
                
                case .success():
                    self?.navigationController?.setupAsBaseScreen(MainMapViewController(), animated: true)
                case .failure(let error):
                    UIApplication.showAlert(title: "Ошибка!", message: error.message)
                }
            }
        }
    }
}

//MARK: - TextFieldViewDelegate
extension PersonalDataViewController: TextFieldViewDelegate {
    func textDidChange(textFieldView: TextFieldView, newText: String) {
        print(newText)
        nextButton.isEnabled = !fioTextView.isEmpty()
    }
}

//MARK: - Constraints
extension PersonalDataViewController {
    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds
        let defaultLeadingOffset = screenSize.width * 0.064
        
        view.addSubview(topLabel)
        view.addSubview(lastStepLabel)
        view.addSubview(fioLabel)
        view.addSubview(fioTextView)
        view.addSubview(nextButton)
        
        topLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLeadingOffset)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(screenSize.height * 0.02463)
        }
        
        lastStepLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLeadingOffset)
            make.top.equalTo(topLabel.snp.bottom).offset(12)
            make.width.equalToSuperview().multipliedBy(0.6)
        }
        
        fioLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLeadingOffset)
            make.top.equalTo(lastStepLabel.snp.bottom).offset(12)
        }
        
        fioTextView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLeadingOffset)
            make.top.equalTo(fioLabel.snp.bottom).offset(12)
            make.height.equalTo(59)
            make.width.equalTo(screenSize.width * 0.872)
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLeadingOffset)
            make.top.equalTo(fioTextView.snp.bottom).offset(screenSize.height * 0.03)
            make.height.equalTo(screenSize.height * 0.06896)
            make.width.equalTo(screenSize.width * 0.29)
        }
        
        
    }
}

//MARK: - SwiftUI
import SwiftUI

struct PersonalDataVCProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        let tabBarVC = PersonalDataViewController()
        
        func makeUIViewController(context: Context) -> some PersonalDataViewController {
            return tabBarVC
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}


