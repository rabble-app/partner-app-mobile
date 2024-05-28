//
//  OtpInputViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/16/24.
//

import UIKit
import EliteOTPField
import Moya

class OtpInputViewController: UIViewController {
    
    public var phoneNumber: String = ""
    public var sid: String = ""
    public var code: String = ""
    
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
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
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
        LoadingViewController.present(from: self)
        apiProvider.request(.verifyOtp(phone: self.phoneNumber, sid: self.sid, code: self.code)) { result in
            LoadingViewController.dismiss(from: self)
            switch result {
            case let .success(response):
                // Handle successful response
                do {
                    let response = try response.map(VerifyOTPResponse.self)
                    
                    if response.statusCode == 200 {
                        SnackBar().alert(withMessage: response.message, isSuccess: true, parent: self.view)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            let tokenManager = UserDefaultsTokenManager()
                            let token = response.data?.token
                            tokenManager.saveToken(token ?? "")
                            
                            if let partnerId = response.data?.partner?.id {
                                self.goToMainTab()
                            }
                            else {
                                self.goToSignUp()
                            }
                        }
                        
                       
                    } else {
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
    
    func goToSignUp() {
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
    
    func goToMainTab() {
        let storyboard = UIStoryboard(name: "MainTabStoryboard", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MainTabViewController") as? MainTabViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func continueButtonTap(_ sender: Any) {
        self.verifyOTP()
    }
    
    @IBAction func resendOTPTap(_ sender: Any) {
        self.sendOTP()
    }
    
    func sendOTP() {
        LoadingViewController.present(from: self)
        apiProvider.request(.sendOtp(phone: self.phoneNumber)) { result in
            LoadingViewController.dismiss(from: self)
            switch result {
            case let .success(response):
                // Handle successful response
                do {
                    let response = try response.map(SendOTPResponse.self)
                    if response.statusCode == 200 {
                        SnackBar().alert(withMessage: response.message, isSuccess: true, parent: self.view)
                        self.sid = response.data?.sid ?? ""
                    } else {
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
}

extension OtpInputViewController: EliteOTPFieldDelegete {
    func didEnterLastDigit(otp: String) {
        print(otp) // Here's the Digits
        self.code = otp
    }
}
