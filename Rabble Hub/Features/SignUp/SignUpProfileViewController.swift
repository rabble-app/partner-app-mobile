//
//  SignUpProfileViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/17/24.
//

import UIKit
import Moya

class SignUpProfileViewController: UIViewController, UITextFieldDelegate  {
    
   
    @IBOutlet var backButton: TertiaryButton!
    @IBOutlet var continueButton: PrimaryButton!
    @IBOutlet var firstName: RabbleTextField!
    @IBOutlet var lastName: RabbleTextField!
    @IBOutlet var email: RabbleTextField!
    //private let userRecordManager = UserRecordManager()
    private let userDataManager = UserDataManager()
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    var isFromOnboardingStage = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.isEnabled = false
        
        // Set the delegate for all text fields
        [firstName, lastName, email].forEach { textField in
            textField?.delegate = self
        }
        
        // Add observers for text change events in text fields
        [firstName, lastName, email].compactMap { $0 }.forEach { textField in
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        
        if isFromOnboardingStage {
            self.backButton.isEnabled = false
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateContinueButtonState()
    }
    
    private func updateContinueButtonState() {
        // Check if all text fields have input
        let allFieldsFilled = [firstName, lastName, email].compactMap { $0 }.allSatisfy { textField in
            guard let text = textField.text else { return false }
            return !text.isEmpty
        }
        continueButton.isEnabled = allFieldsFilled
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpStepIndicatorViewController {
            vc.currentStep = .two
        }
    }
    
    func updateUserRecord() {
        guard let firstName = firstName.text, let lastName = lastName.text, let email = email.text else {
            return
        }
        
        LoadingViewController.present(from: self)
        apiProvider.request(.updateUserRecord(firstName: firstName, lastName: lastName, email: email)) { [weak self] result in
            guard let self = self else { return }
            
            LoadingViewController.dismiss(from: self)
            
            switch result {
            case let .success(response):
                self.handleSuccessResponse(response)
            case let .failure(error):
                self.handleFailure(error)
            }
        }
    }
    
    private func handleSuccessResponse(_ response: Response) {
        do {
            let response = try response.map(UpdateUserRecordResponse.self)
            if response.statusCode == 200 || response.statusCode == 201 {
                if let user = response.data {
                    saveUser(user)
                    updateUserData(with: user)
                    SnackBar().alert(withMessage: response.message, isSuccess: true, parent: view)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.goToAddStoreOpenHours()
                    }
                } else {
                    SnackBar().alert(withMessage: "Failed to update user record", isSuccess: false, parent: view)
                }
            } else {
                SnackBar().alert(withMessage: response.message, isSuccess: false, parent: view)
            }
        } catch {
            handleErrorResponse(response)
        }
    }

    private func handleErrorResponse(_ response: Response) {
        do {
            let response = try response.map(StandardResponse.self)
            SnackBar().alert(withMessage: response.message ?? "An error occurred", isSuccess: false, parent: view)
        } catch {
            SnackBar().alert(withMessage: "An error occurred", isSuccess: false, parent: view)
            print("Failed to map response data: \(error)")
        }
    }
    
    private func handleFailure(_ error: MoyaError) {
        SnackBar().alert(withMessage: error.localizedDescription, isSuccess: false, parent: view)
        print("Request failed with error: \(error)")
    }
    
    func saveUser(_ user: UserRecord) {
        //userRecordManager.user = user
    }
    
    private func updateUserData(with userRecord: UserRecord) {
        if var userData = userDataManager.getUserData() {
            userData.phone = userRecord.phone
            userData.email = userRecord.email
            userData.firstName = userRecord.firstName
            userData.lastName = userRecord.lastName
            userData.postalCode = userRecord.postalCode
            userData.stripeCustomerId = userRecord.stripeCustomerId
            userData.partner?.id = userRecord.id
            userDataManager.saveUserData(userData)
        }
    }
    
    @IBAction func previousStepButtonTap(_ sender: Any) {
        dismiss(animated: false)
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        updateUserRecord()
    }
    
    func goToAddStoreOpenHours() {
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpScheduleViewController") as! SignUpScheduleViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
}
