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
        let field = EliteOTPField()
        field.slotCount = 6
        field.animationType = .none
        field.slotPlaceHolder = ""
        field.enableUnderLineViews = false
        field.emptySlotBackgroundColor = .white
        field.filledSlotBackgroundColor = .white
        field.slotCornerRaduis = 12
        field.filledSlotTextColor = Colors.Gray1
        field.isBorderEnabled = true
        field.emptySlotBorderColor = Colors.Gray5.cgColor
        field.emptySlotBorderWidth = 1
        field.filledSlotBorderWidth = 1
        field.filledSlotBorderColor = Colors.Gray5.cgColor
        field.build()
        return field
    }()
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupOtpField()
    }
    
    private func setupView() {
        view.backgroundColor = Colors.BackgroundPrimary
        descLabel.text = "Enter the 6 digit verification code we sent to you on \(phoneNumber)"
        highlightPhoneNumberInDescLabel()
    }
    
    private func highlightPhoneNumberInDescLabel() {
        if let range = descLabel.text?.range(of: phoneNumber) {
            let attributedString = NSMutableAttributedString(string: descLabel.text ?? "")
            attributedString.addAttribute(.foregroundColor, value: Colors.Gray2, range: NSRange(range, in: descLabel.text ?? ""))
            descLabel.attributedText = attributedString
        }
    }
    
    private func setupOtpField() {
        ontpContainer.addSubview(otpField)
        otpField.otpDelegete = self
        otpField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            otpField.centerYAnchor.constraint(equalTo: ontpContainer.centerYAnchor),
            otpField.centerXAnchor.constraint(equalTo: ontpContainer.centerXAnchor),
            otpField.widthAnchor.constraint(equalTo: ontpContainer.widthAnchor),
            otpField.heightAnchor.constraint(equalTo: ontpContainer.heightAnchor)
        ])
    }
    
    private func handleSuccessResponse<T: Decodable>(_ response: Response, modelType: T.Type, onSuccess: @escaping (T) -> Void) {
        do {
            let response = try response.map(T.self)
            onSuccess(response)
        } catch {
            handleErrorResponse(response)
        }
    }
    
    private func handleErrorResponse(_ response: Response) {
        do {
            let errorResponse = try response.map(StandardResponse.self)
            SnackBar().alert(withMessage: errorResponse.message[0], isSuccess: false, parent: view)
        } catch {
            SnackBar().alert(withMessage: "An error has occurred", isSuccess: false, parent: view)
            print("Failed to map response data: \(error)")
        }
    }
    
    private func handleFailure(_ error: MoyaError) {
        SnackBar().alert(withMessage: "\(error)", isSuccess: false, parent: view)
        print("Request failed with error: \(error)")
    }
    
    func verifyOTP() {
        LoadingViewController.present(from: self)
        apiProvider.request(.verifyOtp(phone: phoneNumber, sid: sid, code: code)) { result in
            LoadingViewController.dismiss(from: self)
            switch result {
            case let .success(response):
                self.handleSuccessResponse(response, modelType: VerifyOTPResponse.self) { response in
                    if response.statusCode == 200 {
                        self.handleVerificationSuccess(response)
                    } else {
                        SnackBar().alert(withMessage: response.message, isSuccess: false, parent: self.view)
                        print("Error Message: \(response.message)")
                    }
                }
            case let .failure(error):
                self.handleFailure(error)
            }
        }
    }
    
    private func handleVerificationSuccess(_ response: VerifyOTPResponse) {
        SnackBar().alert(withMessage: response.message, isSuccess: true, parent: view)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let tokenManager = UserDefaultsTokenManager()
            let token = response.data?.token
            tokenManager.saveToken(token ?? "")
            if let _ = response.data?.partner?.id {
                self.goToMainTab()
            } else {
                self.goToSignUp()
            }
        }
    }
    
    func goToSignUp() {
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
    
    func goToMainTab() {
        let storyboard = UIStoryboard(name: "MainTabStoryboard", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MainTabViewController") as? MainTabViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func continueButtonTap(_ sender: Any) {
        verifyOTP()
    }
    
    @IBAction func resendOTPTap(_ sender: Any) {
        sendOTP()
    }
    
    func sendOTP() {
        LoadingViewController.present(from: self)
        apiProvider.request(.sendOtp(phone: phoneNumber)) { result in
            LoadingViewController.dismiss(from: self)
            switch result {
            case let .success(response):
                self.handleSuccessResponse(response, modelType: SendOTPResponse.self) { response in
                    if response.statusCode == 200 {
                        SnackBar().alert(withMessage: response.message, isSuccess: true, parent: self.view)
                        self.sid = response.data?.sid ?? ""
                    } else {
                        SnackBar().alert(withMessage: response.message, isSuccess: false, parent: self.view)
                        print("Error Message: \(response.message)")
                    }
                }
            case let .failure(error):
                self.handleFailure(error)
            }
        }
    }
}

extension OtpInputViewController: EliteOTPFieldDelegete {
    func didEnterLastDigit(otp: String) {
        print(otp) // Digits entered
        code = otp
    }
}
