//
//  SignInViewController.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 26.04.2021.
//

import Foundation
import UIKit
import MaterialComponents
import SnapKit

class SignInViewController: UIViewController {
    //MARK: - Variables
    private let maxPhoneCount = 11
    private let regex = try! NSRegularExpression(pattern: "[\\+\\s-\\(\\)]", options: .caseInsensitive)
    private let screenSize = UIScreen.main.bounds

    //MARK: - Controls
    private var signInLabel = UILabel(text: "Вход",
                                      font: UIFont.sfUISemibold(with: 32),
                                      textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
                                      textAlignment: .left)
    private var phoneNumberLabel = UILabel(text: "НОМЕР ТЕЛЕФОНА",
                                        fontSize: 12,
                                        textColor: .baseGrayTextColor(),
                                        textAlignment: .left)
    private var nextButton = UIButton.getLittleRoundButton(text: "ДАЛЕЕ",
                                                           isEnabled: true)
    private var descriptionLabel =  UILabel(text: "Мы отправим вам SMS с кодом для авторизации",
                                            fontSize: 16,
                                            textColor: .baseGrayTextColor(),
                                            textAlignment: .left,
                                            numberOfLines: 2)
    
    private var phoneTextField: MDCUnderlinedTextField = {
        let tf = MDCUnderlinedTextField()
        tf.font = UIFont.sfUIMedium(with: 18)
//        let tf = MDCOutlinedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: false)
        //        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    
    //MARK: - Funcs
    private func configure() {
        phoneTextField.delegate = self
        phoneTextField.keyboardType = .numberPad
        phoneTextField.addTarget(self, action: #selector(textFieldDidChanged), for: UIControl.Event.editingChanged)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    private func setupUI() {
//        phoneTextField.placeholderLabel.text = "+7 912 992 53 84"
        view.backgroundColor = .mainBackground()
//        navigationController?.navigationBar.barTintColor = UIColor.green
//        let navigationBar = navigationController?.navigationBar
//        let navigationBarAppearence = UINavigationBarAppearance()
//        navigationBarAppearence.shadowColor = .clear
//        navigationBarAppearence.shadowImage = UIImage()
//        navigationBar?.scrollEdgeAppearance = navigationBarAppearence
        
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.isTranslucent = false
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //MARK: - Objc funcs
    @objc private func nextButtonTapped() {
        print("tapped")
        if let text = phoneTextField.text {
            AuthService.shared.sendSms(login: text) { [weak self] result in
                switch result {
                
                case .success(let result):
                    self?.navigationController?.push(OTPViewController(authModel: .init(type: result, login: text)))
                case .failure(let error):
                    UIApplication.showAlert(title: "Ошибка!", message: error.description)
                }
            }
        }

    }
    @objc private func textFieldDidChanged() {
        if let isEmpty = phoneTextField.text?.isEmpty {
            nextButton.isEnabled = !isEmpty
        }
    }
}

//MARK: - TextFieldDelegate
extension SignInViewController: UITextFieldDelegate {
    private func formatPhoneNumber(phoneNumber: String, shouldRemoveLastDigit: Bool) -> String {
        guard !(shouldRemoveLastDigit && phoneNumber.count <= 2) else { return "+" }
        let range = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: [], range: range, withTemplate: "")

        if number.count > maxPhoneCount {
            let maxIndex = number.index(number.startIndex, offsetBy: maxPhoneCount)
            number = String(number[number.startIndex..<maxIndex])
        }
        if shouldRemoveLastDigit {
            let maxIndex = number.index(number.startIndex, offsetBy: number.count - 1)
            number = String(number[number.startIndex..<maxIndex])
        }

        let maxIndex = number.index(number.startIndex, offsetBy: number.count)
        let regRange = number.startIndex..<maxIndex

        if number.count < 7 {
            let pattern = "(\\d)(\\d{3})(\\d+)"
            number = number.replacingOccurrences(of: pattern, with: "$1 ($2) $3", options: .regularExpression, range: regRange)
        } else {
            let pattern = "(\\d)(\\d{3})(\\d{3})(\\d{2})(\\d+)"
            number = number.replacingOccurrences(of: pattern, with: "$1 ($2) $3-$4-$5", options: .regularExpression, range: regRange)
        }
        return "+" + number
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text ?? "").count + string.count - range.length
        if textField == phoneTextField {
            var changeString: String = string
            if textField.text?.count == 0 && string == "8"{
                changeString = "7"
            }
            let fullString = (textField.text ?? "") + changeString
            textField.text = formatPhoneNumber(phoneNumber: fullString, shouldRemoveLastDigit: range.length == 1)
            return false
        }
        return false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        phoneTextField.resignFirstResponder()
        return true
    }
    

}

//MARK: - Constraints
extension SignInViewController {
    private func setupConstraints() {
        let defaultLeadingOffset = screenSize.width * 0.064
        view.addSubview(signInLabel)
        view.addSubview(phoneTextField)
        view.addSubview(phoneNumberLabel)
        view.addSubview(nextButton)
        view.addSubview(descriptionLabel)
        
        signInLabel.snp.makeConstraints { (make) in
//            make.centerX.centerY.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(screenSize.height * 0.2)
            make.left.equalToSuperview().offset(defaultLeadingOffset)
            
        }
        phoneNumberLabel.snp.makeConstraints { (make) in
            make.top.equalTo(signInLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(defaultLeadingOffset)
        }
        
        phoneTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLeadingOffset)
            make.top.equalTo(phoneNumberLabel.snp.bottom).offset(12)
            make.width.equalToSuperview().multipliedBy(0.872)
//            make.height.equalTo(80)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phoneTextField.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(defaultLeadingOffset)
            make.width.equalToSuperview().multipliedBy(0.7)
            
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLeadingOffset)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            make.height.equalTo(screenSize.height * 0.06896)
            make.width.equalTo(screenSize.width * 0.29)
        }
        
    }
    
}


//MARK: - SwiftUI
import SwiftUI

struct SignInVCProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        let tabBarVC = SignInViewController()
        
        func makeUIViewController(context: Context) -> some SignInViewController {
            return tabBarVC
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}



