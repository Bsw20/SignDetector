//
//  PersonalCabinetViewController.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 27.04.2021.
//

import Foundation
import UIKit
import SnapKit

class PersonalCabinetViewController: UIViewController {
    //MARK: - Variables
    private var profileModel = PersonalCabinetModel(profileImage: nil,
                                                    phoneNumber: "89858182278",
                                                    fio: "Карпунькин Ярослав",
                                                    detectedSignsCount: 15,
                                                    time: 11,
                                                    position: .manager)
    
    //MARK: - Contols
    private var profileImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        imageView.image = UIImage(named: "Component 1")
        return imageView
    }()
    
    private var fioLabel = UILabel(text: "Константин Константинопольский",
                                   font: UIFont.sfUIMedium(with: 24),
                                   textColor: .black,
                                   textAlignment: .center,
                                   numberOfLines: 2)
    
    private var jobPositionLabel = UILabel(text: "Пользователь",
                                           font: UIFont.sfUISemibold(with: 18),
                                           textColor: #colorLiteral(red: 0.9529411765, green: 0.4392156863, blue: 0.07058823529, alpha: 1),
                                           textAlignment: .center,
                                           numberOfLines: 1,
                                           backgroundColor: #colorLiteral(red: 0.9960784314, green: 0.9529411765, blue: 0.9254901961, alpha: 1))
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupUI()
        setupConstraints()
        
    }
    
    //MARK: - Funcs
    private func setupUI() {
        view.backgroundColor = .white
        tableView.tableFooterView = UIView(frame: .zero)
        jobPositionLabel.lineBreakMode = .byCharWrapping
        jobPositionLabel.clipsToBounds = true
        jobPositionLabel.layer.cornerRadius = 15
        
        profileImageView.layer.cornerRadius = 0.234 * UIScreen.main.bounds.width * 0.3413

    }
    
    private func configure() {
        jobPositionLabel.text = profileModel.position.description()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MyProfileInfoTableViewCell.self, forCellReuseIdentifier: MyProfileInfoTableViewCell.reuseId)
        
    }
    //MARK: - Objc funcs
}

//MARK: - TableView
extension PersonalCabinetViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyProfileInfoTableViewCell.reuseId, for: indexPath) as! MyProfileInfoTableViewCell
        cell.configure(topText: "НОМЕР ТЕЛЕФОНА", bottomText: "8999999999")
        switch indexPath.row {
        case 0:
            cell.configure(topText: "НОМЕР ТЕЛЕФОНА", bottomText: profileModel.phoneNumber)
        case 1:
            cell.configure(topText: "ЗНАКОВ ОБНАРУЖЕНО", bottomText: "\(profileModel.detectedSignsCount)")
        case 2:
            cell.configure(topText: "ВРЕМЯ РАБОТЫ", bottomText: "\(profileModel.time)")
        default:
            break
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
}

//MARK: - Constraints
extension PersonalCabinetViewController {
    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds
        
        view.addSubview(profileImageView)
        view.addSubview(fioLabel)
        view.addSubview(jobPositionLabel)
        view.addSubview(tableView)
        
        profileImageView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(37)
            make.width.equalTo(screenSize.width * 0.3413)
            make.height.equalTo(screenSize.width * 0.3413)
            make.centerX.equalToSuperview()
        }
        
        fioLabel.snp.makeConstraints { (make) in
            make.width.equalTo(screenSize.width * 0.8746)
            make.top.equalTo(profileImageView.snp.bottom).offset(21)
            make.centerX.equalToSuperview()
        }
        
        let jobLabelHeight = "1".sizeOfString(usingFont: UIFont.sfUISemibold(with: 18)).height
        
        jobPositionLabel.snp.makeConstraints { (make) in
            let size = profileModel.position.description().sizeOfString(usingFont: UIFont.sfUISemibold(with: 18))
            make.width.equalTo(size.width + 40)
            make.height.equalTo(jobLabelHeight + 20)
            make.top.equalTo(fioLabel.snp.bottom).offset(21)
            make.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(jobPositionLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.874)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}
