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

class MobileInputViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var continueButton: PrimaryButton!
    @IBOutlet var tickBoxButton: UIButton!
    @IBOutlet var agreementLabel: UILabel!
    @IBOutlet var tickBox: UIView!
    @IBOutlet var flag: UILabel!
    @IBOutlet var countryPickerButton: UIButton!
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var phoneNumberTextfield: UITextField!
    @IBOutlet var phoneNumberContainer: UIView!
    
    @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
    private var phoneNumber: String = ""
    private var sid: String = ""
    var isTickBoxSelected = false
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpDefaultCountry()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        
        agreementLabel.attributedText = createAttributedAgreementText()
        agreementLabel.isUserInteractionEnabled = true
        agreementLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnLink)))
        
        tickBoxButton.layer.borderWidth = 1.0
        tickBoxButton.layer.borderColor = Colors.Gray5.cgColor
        tickBoxButton.layer.cornerRadius = 4.0
        tickBoxButton.clipsToBounds = true
        tickBoxButton.setTitle("", for: .normal)
        
        phoneNumberTextfield.delegate = self
        
        updateTickBoxButtonUI()
        
        continueButton.isEnabled = false
    }
    
    // MARK: - Keyboard notifications
    
    @objc private func keyboardWillShowNotification(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
              let kSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        var sOffset: CGFloat = 0.0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            sOffset = window?.safeAreaInsets.bottom ?? 0.0
        }
        
        if (kSize.height - sOffset) > self.continueButtonBottomConstraint.constant {
            self.continueButtonBottomConstraint.constant = kSize.height - sOffset
            view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHideNotification(notification: NSNotification) {
        self.continueButtonBottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    // MARK: - UITextField delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Call updateContinueButtonState after text is changed in the text field
        updateContinueButtonState()
        return true
    }
    
    func updateContinueButtonState() {
        continueButton.isEnabled = validatePhoneNumber() && validateTickBox()
    }
    
    func createAttributedAgreementText() -> NSAttributedString {
        let agreementText = "By proceeding you agree to the "
        let clickableText = "Service Agreement for Rabble Hubs"
        let fullText = NSMutableAttributedString(string: agreementText + clickableText)
        
        let range = (agreementText + clickableText) as NSString
        let clickableRange = range.range(of: clickableText)
        
        fullText.addAttribute(.foregroundColor, value: Colors.ButtonPrimary, range: NSRange(location: agreementText.count, length: clickableText.count))
        fullText.addAttribute(.link, value: URL(string: "https://rabble.notion.site/Service-Agreement-for-Rabble-Hubs-569c8b4f5ca54a0297587815dd6fe651")!, range: clickableRange)
        
        return fullText
    }
    
    func setUpDefaultCountry() {
        if let country = Country.getCurrentCountry() {
            codeLabel.text = country.dialCode
            flag.text = country.flag
        }
    }
    
    @objc func didTapOnLink() {
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
//            setBorderColor(of: phoneNumberContainer, to: UIColor.red)
            phoneNumberTextfield.becomeFirstResponder()
            return false
        }
        setBorderColor(of: phoneNumberContainer, to: Colors.Gray5)
        return true
    }
    
    func validateTickBox() -> Bool {
        if !isTickBoxSelected {
//            setBorderColor(of: tickBoxButton, to: UIColor.red)
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
        guard let phoneNumber = phoneNumberTextfield.text, let dialCode = codeLabel.text else { return }
        self.phoneNumber = "\(dialCode)\(phoneNumber)"
        apiProvider.request(.sendOtp(phone: self.phoneNumber)) { result in
            LoadingViewController.dismiss(from: self)
            switch result {
            case let .success(response):
                self.handleSuccessResponse(response)
            case let .failure(error):
                self.handleError(error)
            }
        }
    }
    
    func handleSuccessResponse(_ response: Response) {
        do {
            let response = try response.map(SendOTPResponse.self)
            if response.statusCode == 200 {
                showSuccessMessage(response.message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.sid = response.data?.sid ?? ""
                    self.goToVerifyOTP()
                }
            } else {
                showErrorMessage(response.message)
                print("Error Message: \(response.message)")
            }
        } catch {
            handleMappingError(response)
        }
    }
    
    func handleError(_ error: Error) {
        showErrorMessage("\(error)")
        print("Request failed with error: \(error)")
    }
    
    private func handleMappingError(_ response: Response) {
        do {
            let errorResponse = try response.map(StandardResponse.self)
            self.showErrorMessage(errorResponse.message ?? "An error occurred")
        } catch {
            print("Failed to map response data: \(error)")
        }
    }
    
    func showSuccessMessage(_ message: String) {
        SnackBar().alert(withMessage: message, isSuccess: true, parent: self.view)
    }
    
    func showErrorMessage(_ message: String) {
        SnackBar().alert(withMessage: message, isSuccess: false, parent: self.view)
    }
    
    func goToVerifyOTP() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "OtpInputViewController") as? OtpInputViewController else { return }
        vc.modalPresentationStyle = .overFullScreen
        vc.phoneNumber = self.phoneNumber
        vc.sid = self.sid
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateTickBoxButtonUI() {
        setBorderColor(of: tickBoxButton, to: Colors.Gray5)
        let image = isTickBoxSelected ? UIImage(named: "icon_tickbox") : UIImage()
        tickBoxButton.setImage(image, for: .normal)
    }
    
    @IBAction func tickBoxButtonTap(_ sender: Any) {
        isTickBoxSelected.toggle()
        updateTickBoxButtonUI()
        updateContinueButtonState()
    }
}

extension MobileInputViewController: DialCountriesControllerDelegate {
    func didSelected(with country: Country) {
        codeLabel.text = country.dialCode
        flag.text = country.flag
    }
}
