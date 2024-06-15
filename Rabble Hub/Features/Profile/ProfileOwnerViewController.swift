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
        guard let userData = userDataManager.getUserData() else { return }
        originalUserData = userData
        populateFields(with: userData)
    }
    
    private func populateFields(with userData: UserData) {
        firstName.text = userData.firstName
        lastName.text = userData.lastName
        email.text = userData.email
        phone.text = userData.phone
    }
    
    private func updateUserRecord() {
        guard let originalUserData = originalUserData else { return }
        let fieldsToUpdate = getFieldsToUpdate(originalUserData: originalUserData)
        
        LoadingViewController.present(from: self)
        apiProvider.request(.updateUserRecord(
            firstName: fieldsToUpdate.firstName,
            lastName: fieldsToUpdate.lastName,
            email: fieldsToUpdate.email,
            phone: fieldsToUpdate.phone
        )) { [weak self] result in
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
    
    private func getFieldsToUpdate(originalUserData: UserData) -> (firstName: String?, lastName: String?, email: String?, phone: String?) {
        return (
            firstName: firstName.text != originalUserData.firstName ? firstName.text : nil,
            lastName: lastName.text != originalUserData.lastName ? lastName.text : nil,
            email: email.text != originalUserData.email ? email.text : nil,
            phone: phone.text != originalUserData.phone ? phone.text : nil
        )
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
        guard var userData = userDataManager.getUserData() else { return }
        userData.firstName = userRecord.firstName
        userData.lastName = userRecord.lastName
        userData.email = userRecord.email
        userData.phone = userRecord.phone
        userData.partner?.postalCode = userRecord.postalCode
        userData.stripeCustomerId = userRecord.stripeCustomerId
        userDataManager.saveUserData(userData)
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
