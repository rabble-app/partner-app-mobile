//
//  MobileInputViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/16/24.
//

import UIKit
import DialCountries

class MobileInputViewController: UIViewController {
    
    
    @IBOutlet var flag: UILabel!
    @IBOutlet var countryPickerButton: UIButton!
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var phoneNumberTextfield: UITextField!
    @IBOutlet var phoneNumberContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.BackgroundPrimary
        setUpView()
        let country = Country.getCurrentCountry()
        self.codeLabel.text = country?.dialCode
        self.flag.text = country?.flag
    }
    
    func setUpView(){
        
        phoneNumberContainer.layer.borderWidth = 1.0
        phoneNumberContainer.layer.borderColor = Colors.Gray5.cgColor
        phoneNumberContainer.layer.cornerRadius = 12.0
        phoneNumberContainer.clipsToBounds = true
        
        countryPickerButton.layer.borderWidth = 1.0
        countryPickerButton.layer.borderColor = Colors.Gray5.cgColor
        countryPickerButton.layer.cornerRadius = 12.0
        countryPickerButton.clipsToBounds = true
    }
    
    
    @IBAction func countryPickerButtonTap(_ sender: Any) {
        DispatchQueue.main.async {
            let cv = DialCountriesController(locale: Locale(identifier: "en"))
            cv.delegate = self
            cv.show(vc: self)
        }
    }
    
    @IBAction func continueButtonTap(_ sender: Any) {
        guard let phoneNumber = phoneNumberTextfield.text, !phoneNumber.isEmpty else {
            // Set border color of phoneNumberContainer to red
            phoneNumberContainer.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        // Reset border color of phoneNumberContainer
        phoneNumberContainer.layer.borderColor = Colors.Gray5.cgColor
        
        
        let storyboard = UIStoryboard(name: "OnboardingView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OtpInputViewController") as? OtpInputViewController {
            vc.modalPresentationStyle = .overFullScreen
            
            vc.phoneNumber = "\(codeLabel.text ?? "") \(phoneNumberTextfield.text ?? "")"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}

extension MobileInputViewController: DialCountriesControllerDelegate {
    func didSelected(with country: Country) {
        self.codeLabel.text = country.dialCode
        self.flag.text = country.flag
    }
}
