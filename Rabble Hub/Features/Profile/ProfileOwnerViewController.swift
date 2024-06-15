//
//  ProfileOwnerViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/25/24.
//

import UIKit
import Moya

class ProfileOwnerViewController: UIViewController {
    
    @IBOutlet var firstName: RabbleTextField!
    @IBOutlet var lastName: RabbleTextField!
    @IBOutlet var email: RabbleTextField!
    @IBOutlet var phone: RabbleTextField!
    @IBOutlet var saveBtn: PrimaryButton!
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    private let userDataManager = UserDataManager()
    
    private var originalFirstName: String?
    private var originalLastName: String?
    private var originalEmail: String?
    private var originalPhone: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func loadData() {
        if let userData = userDataManager.getUserData() {
            self.firstName.text = userData.firstName
            self.lastName.text = userData.lastName
            self.email.text = userData.email
            self.phone.text = userData.phone
            
            self.originalFirstName = userData.firstName
            self.originalLastName = userData.lastName
            self.originalEmail = userData.email
            self.originalPhone = userData.phone
        }
    }
    
    private func updateUserRecord() {
        guard let currentFirstName = firstName.text,
              let currentLastName = lastName.text,
              let currentEmail = email.text,
              let currentPhone = phone.text else {
            return
        }
        
        let firstNameToSend = currentFirstName == originalFirstName ? nil : currentFirstName
        let lastNameToSend = currentLastName == originalLastName ? nil : currentLastName
        let emailToSend = currentEmail == originalEmail ? nil : currentEmail
        let phoneToSend = currentPhone == originalPhone ? nil : currentPhone
        
        LoadingViewController.present(from: self)
        apiProvider.request(.updateUserRecord(firstName: firstNameToSend, lastName: lastNameToSend, email: emailToSend, phone: phoneToSend)) { [weak self] result in
            guard let self = self else { return }
            LoadingViewController.dismiss(from: self)
            
            switch result {
            case .success(let response):
                self.handleSuccessResponse(response)
            case .failure(let error):
                self.handleFailure(error)
            }
        }
    }
    
    private func handleSuccessResponse(_ response: Response) {
        do {
            let response = try response.map(UpdateUserRecordResponse.self)
            if response.statusCode == 200 || response.statusCode == 201, let user = response.data {
                updateUserData(with: user)
                SnackBar().alert(withMessage: response.message, isSuccess: true, parent: view)
                NotificationCenter.default.post(name: NSNotification.Name("UserRecordUpdated"), object: nil)
                self.dismiss(animated: true)
            } else {
                SnackBar().alert(withMessage: "Failed to update user record", isSuccess: false, parent: view)
            }
        } catch {
            handleErrorResponse(response)
        }
    }

    private func handleErrorResponse(_ response: Response) {
        do {
            let response = try response.map(StandardResponse.self)
            SnackBar().alert(withMessage: response.message, isSuccess: false, parent: view)
        } catch {
            SnackBar().alert(withMessage: "An error occurred", isSuccess: false, parent: view)
            print("Failed to map response data: \(error)")
        }
    }
    
    private func handleFailure(_ error: MoyaError) {
        SnackBar().alert(withMessage: error.localizedDescription, isSuccess: false, parent: view)
        print("Request failed with error: \(error)")
    }
    
    private func updateUserData(with userRecord: UserRecord) {
        if var userData = userDataManager.getUserData() {
            userData.firstName = userRecord.firstName
            userData.lastName = userRecord.lastName
            userData.email = userRecord.email
            userData.phone = userRecord.phone
            userData.partner?.postalCode = userRecord.postalCode
            userData.stripeCustomerId = userRecord.stripeCustomerId
            userDataManager.saveUserData(userData)
        }
    }

    @IBAction func saveChangesButtonTap(_ sender: Any) {
        updateUserRecord()
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
