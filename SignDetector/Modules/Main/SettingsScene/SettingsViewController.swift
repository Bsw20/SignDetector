//
//  SettingsViewController.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 29.04.2021.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
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
    
    private var topLabel = UILabel(text: "Настройки",
                                        font: UIFont.sfUISemibold(with: 32),
                                        textColor: .black)
    
    private var turnOnLabel = UILabel(text: "Включать запись при входе в приложение",
                                      font: UIFont.sfUIMedium(with: 16),
                                      textColor: #colorLiteral(red: 0.168627451, green: 0.1803921569, blue: 0.231372549, alpha: 1),
                                      textAlignment: .left,
                                      numberOfLines: 2)
    
    private var turnOffLabel = UILabel(text: "Выключать запись при выходе из приложения",
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
    
    private var topSwitch: UISwitch = {
       let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    private var bottomSwitch: UISwitch = {
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
    
    
    //MARK: - Funcs
    private func configure() {
        signOutButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        topSwitch.addTarget(self, action: #selector(turnOnSwitchTapped), for: .valueChanged)
        bottomSwitch.addTarget(self, action: #selector(turnoOffSwitchTapped), for: .valueChanged)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
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
        let vc = UIApplication.getTopViewController()
        
        let alertController = UIAlertController(title: "Выйти?", message: "Вы уверены, что хотите выйти из аккаунта?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .default) { (_) in
            debugPrint("Cancel")
        }
        let exitAction = UIAlertAction(title: "Выйти", style: .destructive) { (_) in
            debugPrint("EXIT")
        }
//        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.addAction(exitAction)
        UIApplication.getTopViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func turnOnSwitchTapped() {
        print(topSwitch.isOn)
    }
    
    @objc private func turnoOffSwitchTapped() {
        print(bottomSwitch.isOn)
    }
}

//MARK: - Controls
extension SettingsViewController {
    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds
        let defaultLefOffset = 0.064 * screenSize.width
        let multiplyConstant = 0.9
        view.addSubview(topLabel)
        view.addSubview(turnOnLabel)
        view.addSubview(turnOffLabel)
        view.addSubview(topSwitch)
        view.addSubview(bottomSwitch)
        view.addSubview(signOutButton)
        view.addSubview(firstSeparator)
        view.addSubview(secondSeparator)
        view.addSubview(thirdSeparator)
        
        topLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(screenSize.height * 0.1)
            make.left.equalToSuperview().offset(defaultLefOffset)
        }
        
        turnOnLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLefOffset)
            make.width.equalTo(screenSize.width * 0.517)
            make.top.equalTo(topLabel.snp.bottom).offset(17)
            make.right.lessThanOrEqualTo(bottomSwitch.snp.left)
        }
        
        firstSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(turnOnLabel.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(multiplyConstant)
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
        
        turnOffLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLefOffset)
            make.width.equalTo(screenSize.width * 0.517)
            make.top.equalTo(firstSeparator.snp.bottom).offset(17)
            make.right.lessThanOrEqualTo(topSwitch.snp.left)
        }
        
        secondSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(turnOffLabel.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(multiplyConstant)
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
        
        topSwitch.snp.makeConstraints { (make) in
            make.top.equalTo(turnOnLabel.snp.top)
            make.right.equalToSuperview().inset(screenSize.width * 0.061)
        }
        
        bottomSwitch.snp.makeConstraints { (make) in
            make.top.equalTo(turnOffLabel.snp.top)
            make.right.equalToSuperview().inset(screenSize.width * 0.061)
            
        }
        
        signOutButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(defaultLefOffset)
            make.top.equalTo(secondSeparator.snp.bottom)
            make.height.equalTo(63)
            make.width.equalToSuperview()
        }
        
        thirdSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(signOutButton.snp.bottom)
            make.width.equalToSuperview().multipliedBy(multiplyConstant)
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
