//
//  MobileInputViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/16/24.
//

import UIKit
import DialCountries
import SafariServices
import Toast_Swift
import Moya

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
    
    private var phoneNumber: String = ""
    private var sid: String = ""
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.BackgroundPrimary
        setUpView()
        let country = Country.getCurrentCountry()
        self.codeLabel.text = country?.dialCode
        self.flag.text = country?.flag
        
        
        //MARK: Use this user id to delete the user
        //method:Delete
        /// url: auth/quit/e6378db9-daba-4aef-ace7-17d12ac95fc1
        guard let userId = StoreManager.shared.userId else {
            return
        }
        
        print(userId)
    }
    
    func setUpView(){
        
        self.phoneNumberContainer.layer.borderWidth = 1.0
        self.phoneNumberContainer.layer.borderColor = Colors.Gray5.cgColor
        self.phoneNumberContainer.layer.cornerRadius = 12.0
        self.phoneNumberContainer.clipsToBounds = true
        
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
        guard validatePhoneNumber() else { return }
        guard validateTickBox() else { return }
        
        sendOTP()
    }
    
    func validatePhoneNumber() -> Bool {
        guard let phoneNumber = phoneNumberTextfield.text, !phoneNumber.isEmpty else {
            setBorderColor(of: phoneNumberContainer, to: UIColor.red)
            phoneNumberTextfield.becomeFirstResponder()
            return false
        }
        
        setBorderColor(of: phoneNumberContainer, to: Colors.Gray5)
        return true
    }
    
    func validateTickBox() -> Bool {
        if !isTickBoxSelected {
            setBorderColor(of: tickBoxButton, to: UIColor.red)
            return false
        }
        
        setBorderColor(of: tickBoxButton, to: Colors.Gray5)
        return true
    }
    
    
    private func setBorderColor(of view: UIView, to color: UIColor) {
        view.layer.borderColor = color.cgColor
    }
    
    func sendOTP() {
        LoadingViewController.present(from: self)
        self.phoneNumber = "\(codeLabel.text ?? "")\(phoneNumberTextfield.text ?? "")"
        apiProvider.request(.sendOtp(phone: self.phoneNumber)) { result in
            LoadingViewController.dismiss(from: self)
            switch result {
            case let .success(response):
                // Handle successful response
                do {
                    let response = try response.map(SendOTPResponse.self)
                    if response.statusCode == 200 {
                        
                        //ToastView.shared.showToast(true, message: response.message, in: self.view)
                        SnackBar().alert(withMessage: response.message, isSuccess: true, parent: self.view)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.sid = response.data?.sid ?? ""
                            self.goToVerifyOTP()
                        }
                    }else{
                        //ToastView.shared.showToast(false, message: response.message, in: self.view)
                        SnackBar().alert(withMessage: response.message, isSuccess: false, parent: self.view)
                        print("Error Message: \(response.message)")
                    }
                } catch {
                    do {
                        let response = try response.map(StandardResponse.self)
                        SnackBar().alert(withMessage: response.message[0], isSuccess: false, parent: self.view)
                    } catch {
                        SnackBar().alert(withMessage: "An error has occured", isSuccess: false, parent: self.view)
                        print("Failed to map response data: \(error)")
                    }
                }
            case let .failure(error):
                // Handle error
                SnackBar().alert(withMessage: "\(error)", isSuccess: false, parent: self.view)
                print("Request failed with error: \(error)")
            }
        }
    }
    
    
    func goToVerifyOTP() {
        let storyboard = UIStoryboard(name: "OnboardingView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OtpInputViewController") as? OtpInputViewController {
            vc.modalPresentationStyle = .overFullScreen
            vc.phoneNumber = self.phoneNumber
            vc.sid = self.sid
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func updateTickBoxButtonUI() {
        setBorderColor(of: tickBoxButton, to: Colors.Gray5)
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
