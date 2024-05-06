//
//  ManageEmployeeAddEmployeeViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/26/24.
//

import UIKit
import DialCountries

class ManageEmployeeAddEmployeeViewController: UIViewController {

    @IBOutlet var flag: UILabel!
    @IBOutlet var countryPickerButton: UIButton!
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var phoneNumberTextfield: UITextField!
    @IBOutlet var phoneNumberContainer: UIView!

    @IBOutlet weak var addEmployeeViewBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        let country = Country.getCurrentCountry()
        self.codeLabel.text = country?.dialCode
        self.flag.text = country?.flag
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUpView() {
        
        phoneNumberContainer.layer.borderWidth = 1.0
        phoneNumberContainer.layer.borderColor = Colors.Gray5.cgColor
        phoneNumberContainer.layer.cornerRadius = 12.0
        phoneNumberContainer.clipsToBounds = true
        
        countryPickerButton.layer.borderWidth = 1.0
        countryPickerButton.layer.borderColor = Colors.Gray5.cgColor
        countryPickerButton.layer.cornerRadius = 12.0
        countryPickerButton.clipsToBounds = true
    }
    
    
    // MARK: - Keyboard notifications
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
              let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        var safeAreaOffSet: CGFloat = 0.0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            safeAreaOffSet = window?.safeAreaInsets.bottom ?? 0.0
        }
        
        if (keyboardSize.height - safeAreaOffSet) > self.addEmployeeViewBottomConstraint.constant {
            self.addEmployeeViewBottomConstraint.constant = keyboardSize.height - safeAreaOffSet
            view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        self.addEmployeeViewBottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    @IBAction func countryPickerButtonTap(_ sender: Any) {
        DispatchQueue.main.async {
            let cv = DialCountriesController(locale: Locale(identifier: "en"))
            cv.delegate = self
            cv.show(vc: self)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func addEmployeeButtonTap(_ sender: Any) {
        guard let phoneNumber = phoneNumberTextfield.text, !phoneNumber.isEmpty else {
            // Set border color of phoneNumberContainer to red
            phoneNumberContainer.layer.borderColor = UIColor.red.cgColor
            phoneNumberTextfield.becomeFirstResponder()
            return
        }
        
        // Reset border color of phoneNumberContainer
        phoneNumberContainer.layer.borderColor = Colors.Gray5.cgColor
        
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

// MARK: - DialCountriesControllerDelegate methods

extension ManageEmployeeAddEmployeeViewController: DialCountriesControllerDelegate {
    
    func didSelected(with country: Country) {
        self.codeLabel.text = country.dialCode
        self.flag.text = country.flag
    }
}
