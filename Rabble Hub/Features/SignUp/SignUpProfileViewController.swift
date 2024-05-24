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
        LoadingViewController.present(from: self)
        apiProvider.request(.updateUserRecord(firstName: firstName.text ?? "", lastName: lastName.text ?? "", email: email.text ?? "")) { result in
            LoadingViewController.dismiss(from: self)
            switch result {
            case let .success(response):
                // Handle successful response
                do {
                    let response = try response.map(UpdateUserRecordResponse.self)
                    if response.statusCode == 200 || response.statusCode == 201 {
                        print(response.data as Any)
                        guard let user = response.data else {
                            return
                        }
                        SnackBar().alert(withMessage: response.message, isSuccess: true, parent: self.view)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.saveUser(user)
                            self.goToAddStoreOpenHours()
                        }
                       
                    }else{
                        SnackBar().alert(withMessage: response.message, isSuccess: false, parent: self.view)
                        print("Error Message: \(response.message)")
                    }
                    
                } catch {
                    do {
                        let response = try response.map(StandardResponse.self)
                        SnackBar().alert(withMessage: response.message[0], isSuccess: false, parent: self.view)
                    } catch {
                        SnackBar().alert(withMessage: "An error has occured", isSuccess: false, parent: self.view)
                        print("Failed to map response data: \(error)")
                    }
                }
            case let .failure(error):
                // Handle error
                SnackBar().alert(withMessage: "\(error)", isSuccess: false, parent: self.view)
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
