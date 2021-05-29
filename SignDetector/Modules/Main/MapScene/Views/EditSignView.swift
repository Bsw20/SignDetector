//
//  EditSignView.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 16.05.2021.
//

import Foundation
import UIKit

protocol EditSignViewDelegate: NSObjectProtocol {
    func editButtonTapped(view: EditSignView, model: SignModel?)
    func closeButtonTapped(view: EditSignView)
}

class EditSignView: UIView {
    //MARK: - Variables
    weak var customDelegate: EditSignViewDelegate?
    public var isViewHidden: Bool = true
    var shownY: CGFloat = UIScreen.main.bounds.height - (150 + 49 + 70)
    var hiddenY: CGFloat = UIScreen.main.bounds.height
    
    var signModel: SignModel?
    
    public var isShown: Bool = false
    //MARK: - Controls
    private var containerView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private var signNameLabel = UILabel(text: SignsJSONHolder.shared.getSignByIndex(index: 0)!.name,
                                        fontSize: 18,
                                        textColor: .baseGrayTextColor(),
                                        textAlignment: .left,
                                        numberOfLines: 0)
    
    private var topContainerView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private var signImageView: WebImageView = {
        let imageView = WebImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.image = #imageLiteral(resourceName: "Icon")
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .baseOrange()
        button.setTitle("Редактировать", for: .normal)
        button.titleLabel?.font = UIFont.sfUIMedium(with: 14)
        button.setTitleColor(#colorLiteral(red: 0.9960784314, green: 0.9529411765, blue: 0.9254901961, alpha: 1), for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    private var closeViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "CloseViewVector"), for: .normal)
        return button
    }()
    
    //MARK: - Lifecycle
    init() {
        super.init(frame: .zero)
//        translatesAutoresizingMaskIntoConstraints = false
        closeViewButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        layer.cornerRadius = 20
        clipsToBounds = true
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(signModel: SignModel) {
        onMainThread {[weak self] in
            guard let self = self else { return }
            self.signImageView.image = nil
            self.signModel = signModel
            let signDescription = SignsJSONHolder.shared.getSignNameBy(id: signModel.type)
            self.signNameLabel.text = signDescription
            
            self.signImageView.image = UIImage(named: signModel.type)
            self.signImageView.set(imageURL: ServerAddressConstants.GET_SIGN_PHOTO_ADDRESS + "/\(signModel.uuid)", placeholder: UIImage(named: signModel.type)) { result in
                switch result {
                
                case .success(_):
                    break
                case .failure(_):
                    self.signImageView.image = UIImage(named: signModel.type)
                }
            }
            
            
        }
    }
    
    public func configure(isEditingEnable: Bool) {
        editButton.isEnabled = isEditingEnable
    }
    
    
    
    //MARK: - objc funcs
    @objc private func closeButtonTapped() {
        customDelegate?.closeButtonTapped(view: self)
    }
    
    @objc private func editButtonTapped() {
        customDelegate?.editButtonTapped(view: self, model: signModel)
    }
}

//MARK: - Constraints
extension EditSignView {
    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds
        addSubview(containerView)
        
        
        containerView.addSubview(editButton)
        containerView.addSubview(topContainerView)
        topContainerView.addSubview(signImageView)
        topContainerView.addSubview(signNameLabel)
        topContainerView.addSubview(closeViewButton)
        

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        editButton.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        topContainerView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(editButton.snp.top)
        }
        
        signImageView.snp.makeConstraints { make in
            make.width.height.equalTo(screenSize.width * 0.16)
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        closeViewButton.snp.makeConstraints { make in
            make.width.height.equalTo(11.5 * UIScreen.main.scale)
            make.right.equalToSuperview().inset(20)
            make.top.equalTo(signImageView.snp.top)
        }
        
        signNameLabel.snp.makeConstraints { make in
            make.left.equalTo(signImageView.snp.right).offset(17)
            make.centerY.equalToSuperview()
            make.right.equalTo(closeViewButton.snp.left).inset(20)
        }
    }
}
