//
//  SignUpProfileViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/17/24.
//

import UIKit
import Moya

class SignUpProfileViewController: UIViewController {
    
    @IBOutlet var firstName: RabbleTextField!
    @IBOutlet var lastName: RabbleTextField!
    @IBOutlet var email: RabbleTextField!
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpStepIndicatorViewController {
            vc.currentStep = .two
        }
    }
    
    
    func updateUserRecord() {
        apiProvider.request(.updateUserRecord(firstName: firstName.text ?? "", lastName: lastName.text ?? "", email: email.text ?? "")) { result in
            switch result {
            case let .success(response):
                // Handle successful response
                do {
                    let response = try response.map(UpdateUserRecordResponse.self)
                    if response.statusCode == 200 || response.statusCode == 201 {
                        print(response.data)
                        self.saveUser(response.data)
                        self.goToAddStoreOpenHours()
                    }else{
                        print("Error Message: \(response.message)")
                    }
                    
                } catch {
                    print("Failed to map response data: \(error)")
                }
            case let .failure(error):
                // Handle error
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func saveUser(_ user: User) {
        UserManager.shared.user = user
    }
    
    @IBAction func previousStepButtonTap(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        self.updateUserRecord()
    }
    
    func goToAddStoreOpenHours() {
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpScheduleViewController") as! SignUpScheduleViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
    
    
}
