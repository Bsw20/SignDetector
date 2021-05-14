//
//  EditLocationViewController.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 14.05.2021.
//

import Foundation
import UIKit

protocol EditLocationViewControllerDelegate: NSObjectProtocol {
    func signWasSaved(signId: String)
}

class EditLocationViewController: UIViewController {
    enum ViewType {
        case create(model: EditingSignModel)
    }
    //MARK: - Variables
    weak var customDelegate: EditLocationViewControllerDelegate?
    private var model: EditingSignModel
    //MARK: - Controls
    private var topLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.sfUISemibold(with: 32)
        label.numberOfLines = 2
        label.text = "Редактировать участок"
        label.textColor = .black
        return label
    }()
    
    private var addressLabel = UILabel(text: "АДРЕС",
                                        fontSize: 12,
                                        textColor: #colorLiteral(red: 0.3921568627, green: 0.4235294118, blue: 0.5294117647, alpha: 1))
    private var signTypeLabel = UILabel(text: "ТИП ЗНАКА",
                                        fontSize: 12,
                                        textColor: #colorLiteral(red: 0.3921568627, green: 0.4235294118, blue: 0.5294117647, alpha: 1))
    private var saveButton = UIButton.getLittleRoundButton(text: "СОХРАНИТЬ",
                                                           isEnabled: true)
//    private var addressButton: UIButton = {
//        let button = UIButton.getLittleRoundButton(text: "Мельникова, 6",
//                                                   backgroundColor: #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.9725490196, alpha: 1),
//                                                   disabledBackgroundColor: #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.9725490196, alpha: 1),
//                                                   textColor: #colorLiteral(red: 0.2431372549, green: 0.262745098, blue: 0.3294117647, alpha: 1),
//                                                   image: UIImage(named: "LocationAddressVector"),
//                                                   font: UIFont.sfUIMedium(with: 18),
//                                                   isEnabled: false)
//        button.contentHorizontalAlignment = .right
//        button.titleLabel?.textAlignment = .left
//
//        return button
//    }()
    private var addressButton: ImagedButton = {
       let button = ImagedButton(text: "Мельникова, 6", image: UIImage(named: "LocationAddressVector"))
        return button
    }()
    
    private var signTypeButton: ImagedButton = {
       let button = ImagedButton(text: "Выберите тип знака", image: UIImage(named: "SignTypeVector"))
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupUI()
        setupConstraints()
    }
    
    //MARK: - Init
    init(viewType: ViewType) {
        switch viewType {
        
        case .create(model: let model):
            self.model = model
            topLabel.text = "Новый участок"
            addressButton.configure(text: model.address)
            signTypeButton.configure(text: "Выберите тип знака")
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - funcs
    private func configure() {
        addressButton.customDelegate = self
        signTypeButton.customDelegate = self
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.168627451, green: 0.1803921569, blue: 0.231372549, alpha: 1)
    }
    
    //MARK: - objc funcs
    @objc private func saveButtonTapped() {
        print(#function)
    }
}
//MARK: - ImagedButtonDelegate
extension EditLocationViewController: ImagedButtonDelegate {
    func buttonTapped(button: ImagedButton) {
        if button == signTypeButton {
            navigationController?.push(SelectSignsViewController())
        }
    }
}
//MARK: - Constraintts
extension EditLocationViewController {
    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds
        let safeArea = view.safeAreaLayoutGuide
        let defaultLeftOffset = screenSize.width * 0.064
        
        view.addSubview(addressButton)
        view.addSubview(addressLabel)
        view.addSubview(saveButton)
        view.addSubview(signTypeLabel)
        view.addSubview(signTypeButton)
        view.addSubview(topLabel)
        
        topLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea.snp.top)
            make.left.equalTo(safeArea.snp.left).offset(defaultLeftOffset)
            make.width.equalTo(screenSize.width * 0.7)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(defaultLeftOffset)
            make.top.equalTo(topLabel.snp.bottom).offset(12)
        }
        
        addressButton.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenSize.width * 0.872)
            make.height.equalTo(59)
        }
        
        signTypeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(defaultLeftOffset)
            make.top.equalTo(addressButton.snp.bottom).offset(12)
        }
        
        signTypeButton.snp.makeConstraints { make in
            make.top.equalTo(signTypeLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenSize.width * 0.872)
            make.height.equalTo(59)
        }
        
        
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.872)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().inset(21)
        }
    }
}



//MARK: - SwiftUI
import SwiftUI

struct EditLocationVCProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        let tabBarVC = EditLocationViewController(viewType: .create(model: .init(address: "Мельникова, 6", latitude: 56.1, longitude: 55.3)))
        
        func makeUIViewController(context: Context) -> some EditLocationViewController {
            return tabBarVC
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}

