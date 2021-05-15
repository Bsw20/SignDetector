//
//  SignsClusterView.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 15.05.2021.
//

import Foundation
import UIKit

class SignsClusterView: UIView {
    //MARK: - Controls
    private var centerLabel = UILabel(text: "1000",
                                      font: UIFont.sfUISemibold(with: 16),
                                        textColor: .baseOrange(),
                                        textAlignment: .center)
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .red
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - funcs
    public func configure(count: Int) {
        centerLabel.text = "\(count)"
    }
}

//MARK: - Constraints
extension SignsClusterView {
    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds
        let baseWidth = "100".sizeOfString(usingFont: UIFont.sfUISemibold(with: 16)).width
        
        let size = baseWidth + 20
        layer.cornerRadius = size / 2
        addSubview(centerLabel)
        
        snp.makeConstraints { make in
            make.width.height.equalTo(size)
        }
        centerLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
