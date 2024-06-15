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
    
    private var originalUserData: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func loadData() {
        if let userData = userDataManager.getUserData() {
            originalUserData = userData
            firstName.text = userData.firstName
            lastName.text = userData.lastName
            email.text = userData.email
            phone.text = userData.phone
        }
    }
    
    private func updateUserRecord() {
        guard let currentFirstName = firstName.text,
              let currentLastName = lastName.text,
              let currentEmail = email.text,
              let currentPhone = phone.text,
              let originalUserData = originalUserData else { return }
        
        let firstNameToSend = currentFirstName != originalUserData.firstName ? currentFirstName : nil
        let lastNameToSend = currentLastName != originalUserData.lastName ? currentLastName : nil
        let emailToSend = currentEmail != originalUserData.email ? currentEmail : nil
        let phoneToSend = currentPhone != originalUserData.phone ? currentPhone : nil
        
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
            let userResponse = try response.map(UpdateUserRecordResponse.self)
            if userResponse.statusCode == 200 || userResponse.statusCode == 201, let user = userResponse.data {
                updateUserData(with: user)
                showSnackBar(message: userResponse.message, isSuccess: true)
                NotificationCenter.default.post(name: NSNotification.Name("UserRecordUpdated"), object: nil)
                dismiss(animated: true)
            } else {
                showSnackBar(message: "Failed to update user record")
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
        dismiss(animated: true)
    }
    
    private func showSnackBar(message: String, isSuccess: Bool = false) {
        SnackBar().alert(withMessage: message, isSuccess: isSuccess, parent: view)
    }
}
