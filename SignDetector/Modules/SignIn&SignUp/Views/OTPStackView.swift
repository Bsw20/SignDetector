//
//  OTPStackView.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 26.04.2021.
//

import Foundation
import UIKit

protocol OTPDelegate: class {
    func didChangeValidity(isValid: Bool)
    func animationWithCorrectCodeFinished()
}

class OTPStackView: UIStackView {
    let numberOfFields = 6
    var textFieldsCollection: [OTPTextField] = []
    weak var delegate: OTPDelegate?
    var showsWarningColor = false
    
    var isCorrectCode: Bool = false
    
    //Colors
    let inactiveFieldBorderColor =  #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1)
    let textBackgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1)
    let activeFieldBorderColor = #colorLiteral(red: 0.9803921569, green: 0.8039215686, blue: 0, alpha: 1)
    var remainingStrStack: [String] = []
    
    required init(coder: NSCoder) {
        fatalError("It isn't implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
        addOTPFields()
    }
    
    private final func setupStackView() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .center
        self.distribution = .fillEqually
        self.spacing = 5
    }
    
    private final func addOTPFields() {
        for index in 0..<numberOfFields{
            let field = OTPTextField()
            textFieldsCollection.append(field)
            setupTextField(field)
            index != 0 ? (field.previousTextField = textFieldsCollection[index-1]) : (field.previousTextField = nil)
            index != 0 ? (textFieldsCollection[index-1].nextTextField = field) : ()
        }
        textFieldsCollection[0].becomeFirstResponder()
    }
    
    private final func setupTextField(_ textField: OTPTextField){
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.addArrangedSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textField.heightAnchor.constraint(equalTo: self.heightAnchor),
            textField.widthAnchor.constraint(equalToConstant: 40)
        ])

        textField.backgroundColor = textBackgroundColor
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = false
        textField.font = UIFont.sfUIMedium(with: 40)
        textField.textColor = .baseGrayTextColor()
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 2
        textField.layer.borderColor = inactiveFieldBorderColor.cgColor
        textField.keyboardType = .numberPad
        textField.autocorrectionType = .yes
        textField.textContentType = .oneTimeCode
        textField.tintColor = .clear
    }
    
    private final func checkForValidity(){
        for fields in textFieldsCollection{
            if (fields.text == ""){
                delegate?.didChangeValidity(isValid: false)
                return
            }
        }
        delegate?.didChangeValidity(isValid: true)
    }
    
    final func getOTP() -> String {
        var OTP = ""
        for textField in textFieldsCollection{
            OTP += textField.text ?? ""
        }
        return OTP
    }
    
    final func setAllFieldColor(isWarningColor: Bool = false, color: UIColor){
        for textField in textFieldsCollection{
            textField.layer.borderColor = color.cgColor
        }
        showsWarningColor = isWarningColor
    }
    
    final func finishEnterAnimation(colorForAnimation: UIColor, isCorrectCode: Bool) {
        textFieldsCollection[numberOfFields - 1].resignFirstResponder()
        self.isCorrectCode = isCorrectCode
        
        for textField in self.textFieldsCollection{
            textField.isUserInteractionEnabled = false
            if textField == textFieldsCollection.last {
                textField.layer.animateBorderColor(from: .clear, to: colorForAnimation, withDuration: 0.5, autoreverses: isCorrectCode ? false : true, animationDelegate: self)
                continue
            }
            
            textField.layer.animateBorderColor(from: .clear, to: colorForAnimation, withDuration: 0.5, autoreverses: isCorrectCode ? false : true)
        }
    }
    
    private final func autoFillTextField(with string: String) {
        remainingStrStack = string.reversed().compactMap{String($0)}
        for textField in textFieldsCollection {
            if let charToAdd = remainingStrStack.popLast() {
                textField.text = String(charToAdd)
            } else {
                break
            }
        }
        checkForValidity()
        remainingStrStack = []
    }
}

extension OTPStackView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if isCorrectCode {
            delegate?.animationWithCorrectCodeFinished()
            return
        }
        textFieldsCollection[0].layer.borderColor = activeFieldBorderColor.cgColor
        for textField in self.textFieldsCollection{
            UIView.transition(with: textField, duration: 0.25, options: .transitionCrossDissolve, animations: {
                textField.textColor = self.textBackgroundColor
            }) { (_) in
                textField.text = ""
                textField.textColor = .baseGrayTextColor()
                textField.isUserInteractionEnabled = true
                self.textFieldsCollection[0].becomeFirstResponder()
            }
        }
    }
}

//MARK: - UITextFieldDelegate
extension OTPStackView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if showsWarningColor {
            setAllFieldColor(color: inactiveFieldBorderColor)
            showsWarningColor = false
        }
        textField.layer.borderColor = activeFieldBorderColor.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = inactiveFieldBorderColor.cgColor
        checkForValidity()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range:NSRange,
                   replacementString string: String) -> Bool {
        guard let textField = textField as? OTPTextField else { return true }
        if string.count > 1 {
            textField.resignFirstResponder()
            autoFillTextField(with: string)
            return false
        } else {
            if (range.length == 0){
                if textField.nextTextField == nil {
                    textField.text? = string
                    textField.resignFirstResponder()
                }else{
                    textField.text? = string
                    textField.nextTextField?.becomeFirstResponder()
                }
                return false
            }
            return true
        }
    }
}
