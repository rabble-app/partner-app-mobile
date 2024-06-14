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

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        // Do any additional setup after loading the view.
    }
    
    func loadData() {
        self.firstName.text = userDataManager.getUserData()?.firstName
        self.lastName.text = userDataManager.getUserData()?.lastName
        self.email.text = userDataManager.getUserData()?.email
        self.phone.text = userDataManager.getUserData()?.phone
    }
    
    func updateUserRecord() {
        guard let firstName = firstName.text, let lastName = lastName.text, let email = email.text, let phone = phone.text else {
            return
        }
        
        LoadingViewController.present(from: self)
        apiProvider.request(.updateUserProfile(firstName: firstName, lastName: lastName, email: email, phone: phone)) { [weak self] result in
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
                    updateUserData(with: user)
                    SnackBar().alert(withMessage: response.message, isSuccess: true, parent: view)
                    self.dismiss(animated: true)
                    
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
            userData.phone = userRecord.phone
            userData.email = userRecord.email
            userData.firstName = userRecord.firstName
            userData.lastName = userRecord.lastName
            userData.postalCode = userRecord.postalCode
            userData.stripeCustomerId = userRecord.stripeCustomerId
//            userData.partner?.id = userRecord.id
            userDataManager.saveUserData(userData)
        }
    }

    @IBAction func saveChangesButtonTap(_ sender: Any) {
        self.updateUserRecord()
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
