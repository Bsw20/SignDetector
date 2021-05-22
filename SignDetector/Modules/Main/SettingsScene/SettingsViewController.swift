//
//  SettingsViewController.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 29.04.2021.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    struct Config {
        var showConfirmedSigns: Bool
        var showUnconfirmedSigns: Bool
    }
    
    private var startConfig = Config(showConfirmedSigns: APIManager.showConfirmedSignsOnMap,
                                     showUnconfirmedSigns: APIManager.showUnconfirmedSignsOnMap)
    //MARK: - Controls
    private var firstSeparator: UIView = {
       let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9568627451, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var secondSeparator: UIView = {
       let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9568627451, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var thirdSeparator: UIView = {
       let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9568627451, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var fourthSeparator: UIView = {
       let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9568627451, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var topLabel = UILabel(text: "Настройки",
                                        font: UIFont.sfUISemibold(with: 32),
                                        textColor: .black)
    
    private var turnOnVideoLabel = UILabel(text: "Включать запись при входе в приложение",
                                      font: UIFont.sfUIMedium(with: 16),
                                      textColor: #colorLiteral(red: 0.168627451, green: 0.1803921569, blue: 0.231372549, alpha: 1),
                                      textAlignment: .left,
                                      numberOfLines: 2)
    
    private var showConfirmedSignsLabel = UILabel(text: "Показывать подтвержденные знаки",
                                       font: UIFont.sfUIMedium(with: 16),
                                       textColor: #colorLiteral(red: 0.168627451, green: 0.1803921569, blue: 0.231372549, alpha: 1),
                                       textAlignment: .left,
                                       numberOfLines: 2,
                                       backgroundColor: .white)
    
    private var showUncomfirmedSignsLabel = UILabel(text: "Показывать неподтвержденные знаки",
                                       font: UIFont.sfUIMedium(with: 16),
                                       textColor: #colorLiteral(red: 0.168627451, green: 0.1803921569, blue: 0.231372549, alpha: 1),
                                       textAlignment: .left,
                                       numberOfLines: 2,
                                       backgroundColor: .white)
    
    
    private var signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitleColor(.baseRed(), for: .normal)
        button.setTitle("Выйти", for: .normal)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private var turnOnVideoSwitch: UISwitch = {
       let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    private var confirmedSignsSwitch: UISwitch = {
       let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    private var unconfirmedSignsSwitch: UISwitch = {
       let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    
    
    //MARK: - Variables
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startConfig.showConfirmedSigns = APIManager.showConfirmedSignsOnMap
        startConfig.showUnconfirmedSigns = APIManager.showUnconfirmedSignsOnMap
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.post(name: .settingsChanged, object: nil, userInfo: [:])
        if didSettingsChanged() {
            print("POST NOTIFICATION")
            NotificationCenter.default.post(name: .settingsChanged, object: nil)
        }
    }
    
    
    //MARK: - Funcs
    private func didSettingsChanged() -> Bool{
        return !(startConfig.showConfirmedSigns == APIManager.showConfirmedSignsOnMap
            && startConfig.showUnconfirmedSigns == APIManager.showUnconfirmedSignsOnMap)
    }
    private func configure() {
        signOutButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        turnOnVideoSwitch.addTarget(self, action: #selector(turnOnSwitchTapped), for: .valueChanged)
        confirmedSignsSwitch.addTarget(self, action: #selector(confirmedSignsSwitchTapped), for: .valueChanged)
        unconfirmedSignsSwitch.addTarget(self, action: #selector(unconfirmedSignsSwitchTapped), for: .valueChanged)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        turnOnVideoSwitch.isOn = APIManager.isCameraWorkOnStart()
        confirmedSignsSwitch.isOn = APIManager.showConfirmedSignsOnMap
        unconfirmedSignsSwitch.isOn = APIManager.showUnconfirmedSignsOnMap
        
//        self.navigationController?.navigationBar.tintColor = .black
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.sfUISemibold(with: 32)]
//        self.navigationItem.title = "Настройки"
////        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.largeTitleDisplayMode = .always
//        self.navigationItem.titleView = topSegmentedControl
//        navigationItem.rightBarButtonItem = rightBarButtonItem
//
//        let appearance = UINavigationBarAppearance()
//        appearance.backgroundColor = #colorLiteral(red: 0.9843137255, green: 0.9882352941, blue: 1, alpha: 1)
//        navigationController?.navigationBar.standardAppearance = appearance
//        navigationController?.navigationBar.compactAppearance = appearance
//        navigationController?.navigationBar.scrollEdgeAppearance = appearance
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    //MARK: - Objc funcs
    @objc private func exitButtonTapped() {
        
        let alertController = UIAlertController(title: "Выйти?", message: "Вы уверены, что хотите выйти из аккаунта?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .default) { (_) in
            debugPrint("Cancel")
        }
        let exitAction = UIAlertAction(title: "Выйти", style: .destructive) { (_) in
            debugPrint("EXIT")
            APIManager.logOut()
        }
//        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.addAction(exitAction)
        UIApplication.getTopViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func turnOnSwitchTapped() {
        print(#function)
        print(turnOnVideoSwitch.isOn)
        APIManager.setIsCameraWorkOnStart(shouldWork: turnOnVideoSwitch.isOn)
    }
    
    @objc private func confirmedSignsSwitchTapped() {
        print(#function)
        print(confirmedSignsSwitch.isOn)
        APIManager.showConfirmedSignsOnMap = confirmedSignsSwitch.isOn
    }
    
    @objc private func unconfirmedSignsSwitchTapped() {
        print(#function)
        print(unconfirmedSignsSwitch.isOn)
        APIManager.showUnconfirmedSignsOnMap = unconfirmedSignsSwitch.isOn
    }
}

//MARK: - Controls
extension SettingsViewController {
    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds
        let defaultLefOffset = 0.064 * screenSize.width
        let multiplyConstant = 0.9
        view.addSubview(topLabel)
        view.addSubview(turnOnVideoLabel)
        view.addSubview(showConfirmedSignsLabel)
        view.addSubview(showUncomfirmedSignsLabel)
        
        view.addSubview(turnOnVideoSwitch)
        view.addSubview(confirmedSignsSwitch)
        view.addSubview(unconfirmedSignsSwitch)
        
        view.addSubview(signOutButton)
        view.addSubview(firstSeparator)
        view.addSubview(secondSeparator)
        view.addSubview(thirdSeparator)
        view.addSubview(fourthSeparator)
        
        topLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(screenSize.height * 0.1)
            make.left.equalToSuperview().offset(defaultLefOffset)
        }
        
        turnOnVideoLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLefOffset)
            make.width.equalTo(screenSize.width * 0.517)
            make.top.equalTo(topLabel.snp.bottom).offset(17)
            make.right.lessThanOrEqualTo(confirmedSignsSwitch.snp.left)
        }
        
        firstSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(turnOnVideoLabel.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(multiplyConstant)
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
        
        showConfirmedSignsLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLefOffset)
            make.width.equalTo(screenSize.width * 0.517)
            make.top.equalTo(firstSeparator.snp.bottom).offset(17)
            make.right.lessThanOrEqualTo(confirmedSignsSwitch.snp.left)
        }
        
        secondSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(showConfirmedSignsLabel.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(multiplyConstant)
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
        
        showUncomfirmedSignsLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLefOffset)
            make.width.equalTo(screenSize.width * 0.517)
            make.top.equalTo(secondSeparator.snp.bottom).offset(17)
            make.right.lessThanOrEqualTo(unconfirmedSignsSwitch.snp.left)
        }
        
        thirdSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(showUncomfirmedSignsLabel.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(multiplyConstant)
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
        
        turnOnVideoSwitch.snp.makeConstraints { (make) in
            make.top.equalTo(turnOnVideoLabel.snp.top)
            make.right.equalToSuperview().inset(screenSize.width * 0.061)
        }
        
        confirmedSignsSwitch.snp.makeConstraints { (make) in
            make.top.equalTo(showConfirmedSignsLabel.snp.top)
            make.right.equalToSuperview().inset(screenSize.width * 0.061)
            
        }
        
        unconfirmedSignsSwitch.snp.makeConstraints { (make) in
            make.top.equalTo(showUncomfirmedSignsLabel.snp.top)
            make.right.equalToSuperview().inset(screenSize.width * 0.061)
            
        }
        
        signOutButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLefOffset)
            make.top.equalTo(thirdSeparator.snp.bottom)
            make.height.equalTo(63)
            make.width.equalToSuperview()
        }
        
        fourthSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(signOutButton.snp.bottom)
            make.width.equalToSuperview().multipliedBy(multiplyConstant)
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
