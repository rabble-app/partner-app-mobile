//
//  SignUpProfileViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/17/24.
//

import UIKit
import Moya

class SignUpProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var backButton: TertiaryButton!
    @IBOutlet var continueButton: PrimaryButton!
    @IBOutlet var firstName: RabbleTextField!
    @IBOutlet var lastName: RabbleTextField!
    @IBOutlet var email: RabbleTextField!
    
    private let userDataManager = UserDataManager()
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    var isFromOnboardingStage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        continueButton.isEnabled = false
        [firstName, lastName, email].forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        backButton.isEnabled = !isFromOnboardingStage
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateContinueButtonState()
    }
    
    private func updateContinueButtonState() {
        let allFieldsFilled = [firstName, lastName, email].allSatisfy { !($0.text?.isEmpty ?? true) }
        continueButton.isEnabled = allFieldsFilled
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpStepIndicatorViewController {
            vc.currentStep = .two
        }
    }
    
    func updateUserRecord() {
        guard let firstName = firstName.text,
              let lastName = lastName.text,
              let email = email.text else {
            return
        }
        
        self.showLoadingIndicator()
        apiProvider.request(.updateUserRecord(firstName: firstName, lastName: lastName, email: email, phone: nil)) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingIndicator()
            
            switch result {
            case .success(let response):
                self.handleResponse(response)
            case .failure(let error):
                self.handleFailure(error)
            }
        }
    }
    
    private func handleResponse(_ response: Response) {
        do {
            let userResponse = try response.map(UpdateUserRecordResponse.self)
            if userResponse.statusCode == 200 || userResponse.statusCode == 201, let user = userResponse.data {
                updateUserData(with: user)
                showSnackBar(message: userResponse.message, isSuccess: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.goToAddStoreOpenHours()
                }
            } else {
                showSnackBar(message: userResponse.message, isSuccess: false)
            }
        } catch {
            handleErrorResponse(response)
        }
    }
    
    private func handleErrorResponse(_ response: Response) {
        do {
            let errorResponse = try response.map(StandardResponse.self)
            showSnackBar(message: errorResponse.message)
        } catch {
            showSnackBar(message: "An error occurred")
            print("Failed to map response data: \(error)")
        }
    }
    
    private func handleFailure(_ error: MoyaError) {
        showSnackBar(message: error.localizedDescription)
        print("Request failed with error: \(error)")
    }
    
    private func updateUserData(with userRecord: UserRecord) {
        guard var userData = userDataManager.getUserData() else { return }
        userData.firstName = userRecord.firstName
        userData.lastName = userRecord.lastName
        userData.email = userRecord.email
        userData.phone = userRecord.phone
        userData.partner?.postalCode = userRecord.postalCode
        userData.stripeCustomerId = userRecord.stripeCustomerId
        userDataManager.saveUserData(userData)
    }
    
    @IBAction func previousStepButtonTap(_ sender: Any) {
        dismiss(animated: false)
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        updateUserRecord()
    }
    
    private func goToAddStoreOpenHours() {
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        if let vc = signUpView.instantiateViewController(withIdentifier: "SignUpScheduleViewController") as? SignUpScheduleViewController {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        }
    }
    
    private func showSnackBar(message: String, isSuccess: Bool = false) {
        SnackBar().alert(withMessage: message, isSuccess: isSuccess, parent: view)
    }
}
