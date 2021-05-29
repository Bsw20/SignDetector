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
    func backFromEditType()
    func signWasEdited(controller: EditLocationViewController, oldModel: EditingSignModel, newModel: EditingSignModel )
}

class EditLocationViewController: UIViewController {
    enum ViewType {
        case create(model: EditingSignModel)
        case edit(model: EditingSignModel)
    }
    //MARK: - Variables
    weak var customDelegate: EditLocationViewControllerDelegate?
    private var model: EditingSignModel
    
    private var oldSignType: String!
    private var viewType: ViewType
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
    private var addressButton: ImagedButton = {
       let button = ImagedButton(text: "Мельникова, 6", image: UIImage(named: "LocationAddressVector"))
        return button
    }()
    
    private var signTypeButton: ImagedButton = {
       let button = ImagedButton(text: "Выберите тип знака", image: UIImage(named: "SignTypeVector"))
        return button
    }()
    
    private var confirmLabel = UILabel(text: "Подтвержден",
                                       fontSize: 18,
                                       textColor: #colorLiteral(red: 0.2431372549, green: 0.262745098, blue: 0.3294117647, alpha: 1),
                                       textAlignment: .left)
    
    
    private var confirmedSignsSwitch: UISwitch = {
       let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
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
        self.viewType = viewType
        switch viewType {
        
        case .create(model: let model):
            self.model = model
            topLabel.text = "Новый участок"
            addressButton.configure(text: model.address)
            signTypeButton.configure(text: "Выберите тип знака")
            confirmLabel.isHidden = true
            confirmedSignsSwitch.isHidden = true
        case .edit(model: let model):
            self.model = model
            topLabel.text = "Редактировать участок"
            addressButton.configure(text: model.address)
            if let signName = model.signName {
                signTypeButton.configure(text: SignsJSONHolder.shared.getSignNameBy(id: signName), image: UIImage(named: signName))
            }
            oldSignType = model.signName
            confirmedSignsSwitch.isOn = model.confirmed
            
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
        confirmedSignsSwitch.addTarget(self, action: #selector(confirmedSignsSwitchTapped), for: .valueChanged)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
    }
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.168627451, green: 0.1803921569, blue: 0.231372549, alpha: 1)
        
        
    }
    
    //MARK: - objc funcs
    @objc private func backButtonTapped() {
        switch viewType {
        
        case .create(model: let model):
            navigationController?.popViewController(animated: true)
        case .edit(model: let model):
            customDelegate?.backFromEditType()
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func confirmedSignsSwitchTapped() {
        print(confirmedSignsSwitch.isOn)
    }
    
    @objc private func saveButtonTapped() {
        print(#function)
        guard model.signName != nil else {
            UIApplication.showAlert(title: "Ошибка!", message: "Выберите тип знака")
            return
        }
        
        switch viewType {
        
        case .create(model: _):
            UserAPIService.shared.addSign(model: .init(uuid: model.uuid,lat: model.latitude, lon: model.longitude, name: model.signName!, address: model.address)) { result in
                switch result {
                
                case .success():
                    onMainThread {[weak self] in
                        guard let self = self else { return }
                        self.customDelegate?.signWasSaved(signId: self.model.uuid)
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    onMainThread {[weak self] in
                        print(error.message)
                        UIApplication.showAlert(title: "Ошибка!", message: "Не получилось добавить знак, попробуйте позже.")
                    }
                }
            }
        case .edit(model: let oldModel):
            UserAPIService.shared.editSign(model: .init(uuid: model.uuid,
                                                        oldName: oldSignType,
                                                        lat: model.latitude,
                                                        lon: model.longitude,
                                                        name: model.signName!,
                                                        address: model.address,
                                                        confirmed: confirmedSignsSwitch.isOn)) { [weak self]result in
                guard let self = self else { return }
                switch result {
                
                case .success():
                    onMainThread {[weak self] in
                        guard let self = self else { return }
//                        self.customDelegate?.signWasSaved(signId: self.model.uuid)
                        self.customDelegate?.signWasEdited(controller: self, oldModel: oldModel, newModel: .init(uuid: self.model.uuid,
                                                                                                                 address: self.model.address, latitude: self.model.latitude,
                                                                                                                 longitude: self.model.longitude,
                                                                                                                 confirmed: self.confirmedSignsSwitch.isOn, signName: self.model.signName!))
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(_):
                    onMainThread {[weak self] in
                        UIApplication.showAlert(title: "Ошибка!", message: "Не получилось изменить знак, попробуйте позже.")
                    }
                }
            }
        }
        

    }
}
//MARK: - ImagedButtonDelegate
extension EditLocationViewController: ImagedButtonDelegate {
    func buttonTapped(button: ImagedButton) {
        if button == signTypeButton {
            let vc = SelectSignsViewController(viewModel: model.signName == nil ? .create : .edit(signName: model.signName!))
            vc.customDelegate = self
            navigationController?.push(vc)
        }
    }
}

//MARK: - SelectSignsViewControllerDelegate
extension EditLocationViewController: SelectSignsViewControllerDelegate {
    func applyButtonTapped(signName: String) {
        self.model.signName = signName
//        let model = LocalManager.shared.getSignByIndex(index: indexPath.item)
        signTypeButton.configure(text: SignsJSONHolder.shared.getSignNameBy(id: signName), image: UIImage(named: signName))
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
        
        view.addSubview(confirmedSignsSwitch)
        view.addSubview(confirmLabel)
        
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
        
        confirmedSignsSwitch.snp.makeConstraints { make in
            make.right.equalTo(addressButton.snp.right)
            make.top.equalTo(signTypeButton.snp.bottom).offset(20)
        }
        
        confirmLabel.snp.makeConstraints { make in
            make.top.equalTo(confirmedSignsSwitch.snp.top)
            make.left.equalTo(signTypeLabel.snp.left).offset(5)
            make.right.equalTo(confirmedSignsSwitch.snp.left).inset(20)
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

