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
    
    @IBOutlet var continueButton: PrimaryButton!
    public var phoneNumber: String = ""
    public var sid: String = ""
    public var code: String = ""
    
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var ontpContainer: UIView!
    
  
    
    @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
    
    private let userDataManager = UserDataManager()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotif(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotif(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupView() {
        view.backgroundColor = Colors.BackgroundPrimary
        descLabel.text = "Enter the 6 digit verification code we sent to you on \(phoneNumber)"
        highlightPhoneNumberInDescLabel()
        continueButton.isEnabled = false
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
    
    // MARK: - Keyboard notifications
    
    @objc private func keyboardWillShowNotif(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
              let size = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        var offset: CGFloat = 0.0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            offset = window?.safeAreaInsets.bottom ?? 0.0
        }
        
        if (size.height - offset) > self.continueButtonBottomConstraint.constant {
            self.continueButtonBottomConstraint.constant = size.height - offset
            view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHideNotif(notification: NSNotification) {
        self.continueButtonBottomConstraint.constant = 0
        view.layoutIfNeeded()
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
            SnackBar().alert(withMessage: errorResponse.message, isSuccess: false, parent: view)
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
        
        if let userData = response.data {
            userDataManager.saveUserData(userData)
        }
        
        SnackBar().alert(withMessage: response.message, isSuccess: true, parent: view)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let tokenManager = UserDefaultsTokenManager()
            let token = response.data?.token
            tokenManager.saveToken(token ?? "")
            if let onboardingStage = response.data?.onboardingStage {
                if onboardingStage == 0 {
                    self.goToSignUp()
                } else if onboardingStage == 1 {
                    self.goToSignUpProfile()
                } else if onboardingStage == 2 {
                    self.goToSignUpSchedule()
                    
                } else if onboardingStage == 3 {
                    self.goToSignUpAgreement()
                } else {
                    self.goToMainTab()
                }
            }
            
            
        }
    }
    
    func goToSignUp() {
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
    
    func goToSignUpProfile() {
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpProfileViewController") as! SignUpProfileViewController
        vc.modalPresentationStyle = .fullScreen
        vc.isFromOnboardingStage = true
        present(vc, animated: false)
    }
    
    func goToSignUpSchedule() {
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpScheduleViewController") as! SignUpScheduleViewController
        vc.modalPresentationStyle = .fullScreen
        vc.isFromOnboardingStage = true
        present(vc, animated: false)
    }
    
    func goToSignUpAgreement() {
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpAgreementViewController") as! SignUpAgreementViewController
        vc.modalPresentationStyle = .fullScreen
        vc.isFromOnboardingStage = true
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
        continueButton.isEnabled = true
    }
}
