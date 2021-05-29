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
    struct AuthModel {
        internal init(type: OTPViewController.AuthType, login: String) {
            self.type = type
            if login.count >  0 && login.prefix(1) == "7" {
                self.login = login.replace(0, "8")
            } else {
                self.login = login
            }
        }
        
        var type: AuthType
        var login: String
    }
    typealias AuthType = NetworkingGlobalModels.AuthType
    //MARK: - Variables
    private var authModel: AuthModel
    //MARK: - Controls
    private lazy var numbersView: OTPStackView = OTPStackView()
    private var signInLabel = UILabel(text: "Вход",
                                      font: UIFont.sfUISemibold(with: 32),
                                      textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
                                      textAlignment: .center)
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
    public init(authModel: AuthModel) {
        self.authModel = authModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
//        navigationController?.push(PersonalDataViewController())
        switch authModel.type {
        
        case .registered:
            if UDManager.needToSetName() {
                navigationController?.push(PersonalDataViewController(), completion: {
                    
                })
            } else {
//                navigationController?.setupAsBaseScreen(MainTabBarController(), animated: true)
                SceneDelegate.shared().setRootController(controller: MainTabBarController())
            }
        case .notRegistered:
            navigationController?.push(PersonalDataViewController(), completion: {
                
            })
        }
    }
    
    
    func didChangeValidity(isValid: Bool) {
//        numbersView.finishEnterAnimation(colorForAnimation: .green, isCorrectCode: true)
        if isValid {
            AuthService.shared.auth(model: .init(type: authModel.type, login: authModel.login, smsCode: numbersView.getOTP())) {[weak self] result in
                print(result)
                switch result {
                
                case .success():
                    self?.numbersView.finishEnterAnimation(colorForAnimation: .green, isCorrectCode: true)
                case .failure(let error):
                    if error.code == 500 {
                        self?.numbersView.finishEnterAnimation(colorForAnimation: .red, isCorrectCode: false)
                        return
                    }
                    UIApplication.showAlert(title: "Ошибка!", message: error.message)
                }
            }
        }
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

