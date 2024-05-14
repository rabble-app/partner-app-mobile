//
//  MobileInputViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/16/24.
//

import UIKit
import DialCountries
import SafariServices

class MobileInputViewController: UIViewController {
    
    
    @IBOutlet var tickBoxButton: UIButton!
    @IBOutlet var agreementLabel: UILabel!
    @IBOutlet var tickBox: UIView!
    @IBOutlet var flag: UILabel!
    @IBOutlet var countryPickerButton: UIButton!
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var phoneNumberTextfield: UITextField!
    @IBOutlet var phoneNumberContainer: UIView!
    
    var isTickBoxSelected = false
    
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
        
        
        let agreementText = "By proceeding you agree to the "
        let clickableText = "Service Agreement for Rabble Hubs"
        let fullText = NSMutableAttributedString(string: agreementText + clickableText)
        fullText.addAttribute(.foregroundColor, value: Colors.ButtonPrimary, range: NSRange(location: agreementText.count, length: clickableText.count))
        
        let range = (agreementText + clickableText) as NSString
        let clickableRange = range.range(of: clickableText)
        fullText.addAttribute(.link, value: URL(string: "https://rabble.notion.site/Service-Agreement-for-Rabble-Hubs-569c8b4f5ca54a0297587815dd6fe651")!, range: clickableRange)
        
        agreementLabel.attributedText = fullText
        agreementLabel.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnLink))
        agreementLabel.addGestureRecognizer(tapGestureRecognizer)
        
        tickBoxButton.layer.borderWidth = 1.0
        tickBoxButton.layer.borderColor = Colors.Gray5.cgColor
        tickBoxButton.layer.cornerRadius = 4.0
        tickBoxButton.clipsToBounds = true
        
        tickBoxButton.setTitle("", for: .normal)
        
        updateTickBoxButtonUI()
    }
    
    @objc func didTapOnLink(_ sender: UITapGestureRecognizer) {
        guard let url = URL(string: "https://rabble.notion.site/Service-Agreement-for-Rabble-Hubs-569c8b4f5ca54a0297587815dd6fe651") else { return }
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .overFullScreen
        present(safariViewController, animated: true, completion: nil)
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
            phoneNumberTextfield.becomeFirstResponder()
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
    
    func updateTickBoxButtonUI() {
        let image = isTickBoxSelected ? UIImage(named: "icon_tickbox") : UIImage()
        tickBoxButton.setImage(image, for: .normal)
    }

    
    @IBAction func tickBoxButtonTap(_ sender: Any) {
        isTickBoxSelected.toggle()
        updateTickBoxButtonUI()
    }
    
}

extension MobileInputViewController: DialCountriesControllerDelegate {
    func didSelected(with country: Country) {
        self.codeLabel.text = country.dialCode
        self.flag.text = country.flag
    }
}
