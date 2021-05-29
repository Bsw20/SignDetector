//
//  VideoModeView.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 02.05.2021.
//

import Foundation
import UIKit

protocol VideoModelViewDelegate: NSObjectProtocol {
    func modeDidChange(isOn: Bool)
}

class VideoModeView: UIView {
    //MARK: - Variables
    weak var customDelegate: VideoModelViewDelegate?
    
    //MARK: - Controls
    private var label = UILabel(text: "Режим записи",
                                        fontSize: 16,
                                        textColor: .black)
    private var modeSwitch: UISwitch = {
       let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        modeSwitch.isOn = UDManager.isCameraWorkOnStart()
        configure()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = #colorLiteral(red: 0.9763854146, green: 0.9765252471, blue: 0.9763546586, alpha: 1)
        modeSwitch.addTarget(self, action: #selector(switchTapped), for: .valueChanged)
    }
    
    public func isVideoOn() -> Bool {
        return modeSwitch.isOn
    }
    
    //MARK: - Objc funcs
    @objc private func switchTapped() {
        customDelegate?.modeDidChange(isOn: modeSwitch.isOn)
    }

    
    
}

//MARK: - Constraints
extension VideoModeView {
    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds
        addSubview(label)
        addSubview(modeSwitch)
        
        self.snp.makeConstraints { (make) in
            make.height.equalTo(0.0825 * screenSize.height)
            make.width.equalTo(screenSize.width)
        }
        
        label.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(0.0613 * screenSize.width)
        }
        
        modeSwitch.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(0.0613 * screenSize.width)
            make.centerY.equalToSuperview()
        }
    }
}
