//
//  MobileInputViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/16/24.
//

import UIKit
import DialCountries

class MobileInputViewController: UIViewController {
    
    @IBOutlet var flagImg: UIImageView!
    @IBOutlet var countryPickerButton: UIButton!
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var phoneNumberTextfield: UITextField!
    @IBOutlet var phoneNumberContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let country = Country.getCurrentCountry()
        self.codeLabel.text = country?.dialCode
        self.flagImg.image = UIImage(named: country?.flag ?? "")
    }
    
    func setUpView(){
        
        phoneNumberContainer.layer.borderWidth = 1.0
        if let borderColor = UIColor(hexString: "#E0E0E0") {
            phoneNumberContainer.layer.borderColor = borderColor.cgColor
        }
        phoneNumberContainer.layer.cornerRadius = 12.0
        phoneNumberContainer.clipsToBounds = true
        
        countryPickerButton.layer.borderWidth = 1.0
        if let borderColor = UIColor(hexString: "#E0E0E0") {
            countryPickerButton.layer.borderColor = borderColor.cgColor
        }
        countryPickerButton.layer.cornerRadius = 12.0
        countryPickerButton.clipsToBounds = true
    }
    
    
    @IBAction func countryPickerButtonTap(_ sender: Any) {
        DispatchQueue.main.async {
            let cv = DialCountriesController(locale: Locale(identifier: "ar"))
            cv.delegate = self
            cv.show(vc: self)
        }
    }
}

extension MobileInputViewController: DialCountriesControllerDelegate {
    func didSelected(with country: Country) {
        self.codeLabel.text = country.dialCode
        self.flagImg.image = UIImage(named: country.flag)
    }
}
