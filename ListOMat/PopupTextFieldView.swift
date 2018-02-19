//
//  PopupTextFieldView.swift
//  ListOMat
//
//  Created by Louis Franco on 2/15/18.
//  Copyright © 2018 App-o-Mat. All rights reserved.
//

import UIKit

protocol PopupTextFieldViewDelegate {
    func onTextEntered(text: String)
}

protocol PopupTextFieldViewViewController {
    func addPopupTextField(mainView: UIView, popupTextField: PopupTextFieldView) -> Bool
    func dismiss(popupTextField: PopupTextFieldView)
}

extension PopupTextFieldViewViewController where Self: UIViewController {
    func addPopupTextField(mainView: UIView, popupTextField: PopupTextFieldView) -> Bool {
        if popupTextField.superview != nil {
            popupTextField.textField.becomeFirstResponder()
            return false
        }

        popupTextField.translatesAutoresizingMaskIntoConstraints = false

        mainView.addSubview(popupTextField)
        popupTextField.leadingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        popupTextField.trailingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.trailingAnchor).isActive = true

        mainView.layoutIfNeeded()
        DispatchQueue.main.async {
            popupTextField.textField.becomeFirstResponder()
        }

        return true
    }

    func dismiss(popupTextField: PopupTextFieldView) {
        popupTextField.resignFirstResponder()
        popupTextField.removeFromSuperview()
    }
}

class PopupTextFieldView: UIView, UITextFieldDelegate {

    @IBOutlet var textField: UITextField! = nil
    var popupBottomContraint: NSLayoutConstraint? = nil
    var delegate: PopupTextFieldViewDelegate? = nil

    override func didMoveToSuperview() {
        if let sv = self.superview {
            textField.text = ""
            popupBottomContraint = self.bottomAnchor.constraint(equalTo: sv.safeAreaLayoutGuide.bottomAnchor, constant: 0)
            popupBottomContraint?.isActive = true

            self.textField.delegate = self

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.keyboardNotification(notification:)),
                                                   name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                                   object: nil)

        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }

    // Technique from here https://stackoverflow.com/a/27135992/3937
    @objc
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)

            if endFrameY >= UIScreen.main.bounds.size.height {
                self.popupBottomContraint?.constant = 0.0
            } else {
                self.popupBottomContraint?.constant = -(endFrame?.size.height ?? 0.0)
            }

            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.superview?.layoutIfNeeded() },
                           completion: nil)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text != "" else { return false }

        delegate?.onTextEntered(text: text)
        return true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
