//
//  OTPViewController.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 26.04.2021.
//

import Foundation
import UIKit
import SnapKit

class OTPViewController: UIViewController {
    
    //MARK: - Variables
    //MARK: - Controls
    private lazy var numbersView: OTPStackView = OTPStackView()
    private var signInLabel = UILabel(text: "Вход",
                                        fontSize: 32,
                                        textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
                                        textAlignment: .left)
    private var smsCodeLabel = UILabel(text: "КОД ИЗ СМС",
                                        fontSize: 12,
                                        textColor: .baseGrayTextColor(),
                                        textAlignment: .center)
    private var notificationLabel = UILabel(text: "Если код не пришел, вернитесь на предыдущий шаг и попробуйте еще раз",
                                        fontSize: 16,
                                        textColor: .baseGrayTextColor(),
                                        textAlignment: .center,
                                        numberOfLines: 0)

    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainBackground()
        setupConstraints()
        
        numbersView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: false)
        //        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: false)
        //        navigationItem.setHidesBackButton(true, animated: false)
    }
}


//MARK: - OTPDelegate
//ma token ["token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MCwiaWF0IjoxNjEyMDEzNzIwfQ.xppDQuayBeLYIhH7oNkLiednNrqJkoDoM8Oz1ZUzcf0"]
extension OTPViewController: OTPDelegate {
    func animationWithCorrectCodeFinished() {
        print("auth finished")
    }
    
    
    func didChangeValidity(isValid: Bool) {
//        numbersView.finishEnterAnimation(colorForAnimation: .green, isCorrectCode: true)
        if isValid {
            let isCorrectCode = numbersView.getOTP() == "111111"
            if isCorrectCode {
                numbersView.finishEnterAnimation(colorForAnimation: .green, isCorrectCode: isCorrectCode)
            } else {
                numbersView.finishEnterAnimation(colorForAnimation: .red, isCorrectCode: isCorrectCode)
            }
        }
//        if isValid {
//            switch authType {
//
//            case .signIn(data: var data):
//                data.smsCode = numbersView.getOTP()
//                authService.signIn(signInModel: data) { (result) in
//                    switch result {
//                    case .success():
//                        print("----------------")
//                        print(result)
//                        self.authDelegate?.authFinished()
//                    case .failure(_):
//                        break
//                    }
//                }
//
//            case .signUp(data: var data):
////                ["token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsImlhdCI6MTYxMjA5NjQ2NH0.sfXLi1rDR-uGqnUSvH6zVaVtLTwOm8EMs7S_glAWwaQ"]
////                let isCorrectCode = numbersView.getOTP() == "111111"
////                if isCorrectCode {
////                    numbersView.finishEnterAnimation(colorForAnimation: .green, isCorrectCode: isCorrectCode)
////                } else {
////                    numbersView.finishEnterAnimation(colorForAnimation: .red, isCorrectCode: isCorrectCode)
////                }
//                data.smsCode = numbersView.getOTP()
//                authService.signUp(signUpModel: data) { (result) in
//                    switch result {
//
//                    case .success():
//                        self.numbersView.finishEnterAnimation(colorForAnimation: .green, isCorrectCode: true)
//                    case .failure(_):
//                        self.numbersView.finishEnterAnimation(colorForAnimation: .green, isCorrectCode: false)
//                    }
//                }
//            }
//        }
    }
}

//MARK: - Constraints
extension OTPViewController {
    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds
        view.addSubview(numbersView)
        view.addSubview(signInLabel)
        view.addSubview(smsCodeLabel)
        view.addSubview(notificationLabel)
        
        signInLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(screenSize.height * 0.02463)
        }
        
        smsCodeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(signInLabel.snp.bottom).offset(11)
        }
        
        
        
        numbersView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(smsCodeLabel.snp.bottom).offset(12)
            make.height.equalTo(56)
        }
        
        notificationLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(numbersView.snp.bottom).offset(screenSize.height * 0.0277)
            make.width.equalTo(screenSize.width * 0.8773)
        }
    }
}

