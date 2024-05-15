//
//  OtpInputViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/16/24.
//

import UIKit
import EliteOTPField

class OtpInputViewController: UIViewController {
    
    public var phoneNumber: String = ""
    public var sid: String = ""
    private var code: String = ""
    
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var ontpContainer: UIView!
    
    lazy var otpField: EliteOTPField = {
        let borderColor: CGColor = Colors.Gray5.cgColor
        let backgroundColor: UIColor = .white
        
        let field = EliteOTPField()
        field.slotCount = 6
        field.animationType = .none
        field.slotPlaceHolder = ""
        field.enableUnderLineViews = false
        field.emptySlotBackgroundColor = backgroundColor
        field.filledSlotBackgroundColor = backgroundColor
        field.slotCornerRaduis = 12
        field.filledSlotTextColor = Colors.Gray1
        field.isBorderEnabled = true
        field.emptySlotBorderColor = borderColor
        field.emptySlotBorderWidth = 1
        field.filledSlotBorderWidth = 1
        field.filledSlotBorderColor = borderColor
        field.build()
        return field
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.BackgroundPrimary
        self.descLabel.text = "Enter the 6 digit verification code we sent to you on \(phoneNumber)"
        if let range = (descLabel.text as NSString?)?.range(of: phoneNumber) {
            let attributedString = NSMutableAttributedString(string: descLabel.text ?? "")
            attributedString.addAttribute(.foregroundColor, value: Colors.Gray2 , range: range)
            descLabel.attributedText = attributedString
        }
       
        self.ontpContainer.addSubview(self.otpField)
        self.otpField.otpDelegete = self
        self.addOtpWithNSLayoutConstraints()
    }
    
    private func addOtpWithNSLayoutConstraints() {
        self.otpField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.otpField.centerYAnchor.constraint(equalTo: self.ontpContainer.centerYAnchor),
            self.otpField.centerXAnchor.constraint(equalTo: self.ontpContainer.centerXAnchor),
            self.otpField.widthAnchor.constraint(equalTo: self.ontpContainer.widthAnchor, constant: 0),
            self.otpField.heightAnchor.constraint(equalToConstant: ontpContainer.frame.height)
        ])
    }
    
    func verifyOTP() {
        apiprovider.request(.verifyOtp(phone: self.phoneNumber, sid: self.sid, code: self.code, baseURL: environment.baseURL)) { result in
            switch result {
            case let .success(response):
                // Handle successful response
                do {
                    let response = try response.map(VerifyOTPResponse.self)
                    let tokenManager = UserDefaultsTokenManager()
                    let token = response.data?.token
                    tokenManager.saveToken(token ?? "")
                    self.goToSignUp()
                } catch {
                    print("Failed to map response data: \(error)")
                }
            case let .failure(error):
                // Handle error
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func goToSignUp() {
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
    
    @IBAction func continueButtonTap(_ sender: Any) {
        self.verifyOTP()
    }
}


extension OtpInputViewController : EliteOTPFieldDelegete {
   func didEnterLastDigit(otp: String) {
       print(otp) // Here's the Digits
       self.code = otp
   }
}
