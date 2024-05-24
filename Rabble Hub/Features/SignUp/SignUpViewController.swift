//
//  SignUpViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/15/24.
//

import Foundation
import UIKit
import Moya

class SignUpViewController: UIViewController {
    
    @IBOutlet var storeName: RabbleTextField!
    @IBOutlet var postalCode: RabbleTextField!
    @IBOutlet var city: RabbleTextField!
    @IBOutlet var street: RabbleTextField!
    @IBOutlet var direction: RabbleTextView!
    @IBOutlet var storeType: RabbleTextField!
    @IBOutlet var shelfSpace: RabbleTextField!
    @IBOutlet var dryStorageSpace: RabbleTextField!
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        
        //MARK: postal code that returns suppliers
        self.postalCode.text = "SE154NX"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpStepIndicatorViewController {
            vc.currentStep = .one
        }
    }
    
    func saveStoreProfile(){
        LoadingViewController.present(from: self)
        apiProvider.request(.saveStoreProfile(name: storeName.text ?? "", postalCode: postalCode.text ?? "", city: city.text ?? "", streetAddress: street.text ?? "", direction: direction.text ?? "", storeType: storeType.text ?? "", shelfSpace: shelfSpace.text ?? "", dryStorageSpace: dryStorageSpace.text ?? "")) { result in
            LoadingViewController.dismiss(from: self)
            switch result {
            case let .success(response):
                // Handle successful response
                do {
                    let response = try response.map(SaveStoreProfileResponse.self)
                    if response.statusCode == 200 || response.statusCode == 201 {
                        print(response.data as Any)
                        guard let store = response.data else {
                            return
                        }
                        
                        SnackBar().alert(withMessage: response.message, isSuccess: true, parent: self.view)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.saveStore(store)
                            self.goToCreateUserProfile()
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
    
    func saveStore(_ store: Store) {
        StoreManager.shared.store = store
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        self.saveStoreProfile()
    }
    
    func goToCreateUserProfile(){
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpProfileViewController") as! SignUpProfileViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
}
