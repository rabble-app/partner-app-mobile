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
        fetchUserData()
    }
    
    private func fetchUserData() {
        guard let userData = userDataManager.getUserData() else { return }
        originalUserData = userData
        fillUserFields(with: userData)
    }
    
    private func fillUserFields(with userData: UserData) {
        firstName.text = userData.firstName
        lastName.text = userData.lastName
        email.text = userData.email
        phone.text = userData.phone
    }
    
    private func submitUserUpdates() {
        guard let originalUser = originalUserData else { return }
        let updatedFields = extractChangedFields(from: originalUser)
        
        self.showLoadingIndicator()
        apiProvider.request(.updateUserRecord(
            firstName: updatedFields.newFirstName,
            lastName: updatedFields.newLastName,
            email: updatedFields.newEmail,
            phone: updatedFields.newPhone
        )) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingIndicator()
            
            switch result {
            case .success(let response):
                self.processSuccessResponse(response)
            case .failure(let error):
                self.processFailure(error)
            }
        }
    }
    
    private func extractChangedFields(from originalUser: UserData) -> (newFirstName: String?, newLastName: String?, newEmail: String?, newPhone: String?) {
        return (
            newFirstName: firstName.text != originalUser.firstName ? firstName.text : nil,
            newLastName: lastName.text != originalUser.lastName ? lastName.text : nil,
            newEmail: email.text != originalUser.email ? email.text : nil,
            newPhone: phone.text != originalUser.phone ? phone.text : nil
        )
    }
    
    private func processSuccessResponse(_ response: Response) {
        do {
            let updateResponse = try response.map(UpdateUserRecordResponse.self)
            if updateResponse.statusCode == 200 || updateResponse.statusCode == 201, let updatedUser = updateResponse.data {
                refreshUserData(with: updatedUser)
                displaySnackBar(message: updateResponse.message, isSuccess: true)
                NotificationCenter.default.post(name: NSNotification.Name("UserRecordUpdated"), object: nil)
                dismiss(animated: true)
            } else {
                displaySnackBar(message: "Failed to update user record")
            }
        } catch {
            processErrorResponse(response)
        }
    }
    
    private func processErrorResponse(_ response: Response) {
        do {
            let errorResponse = try response.map(StandardResponse.self)
            displaySnackBar(message: errorResponse.message)
        } catch {
            displaySnackBar(message: "An error occurred")
            print("Failed to map response data: \(error)")
        }
    }
    
    private func processFailure(_ error: MoyaError) {
        displaySnackBar(message: error.localizedDescription)
        print("Request failed with error: \(error)")
    }
    
    private func refreshUserData(with updatedUser: UserRecord) {
        guard var userData = userDataManager.getUserData() else { return }
        userData.firstName = updatedUser.firstName
        userData.lastName = updatedUser.lastName
        userData.email = updatedUser.email
        userData.phone = updatedUser.phone
        userData.partner?.postalCode = updatedUser.postalCode
        userData.stripeCustomerId = updatedUser.stripeCustomerId
        userDataManager.saveUserData(userData)
    }
    
    @IBAction func saveChangesButtonTap(_ sender: Any) {
        submitUserUpdates()
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func displaySnackBar(message: String, isSuccess: Bool = false) {
        SnackBar().alert(withMessage: message, isSuccess: isSuccess, parent: view)
    }
}
