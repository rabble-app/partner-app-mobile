//
//  SignUpViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/15/24.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet var storeName: RabbleTextField!
    @IBOutlet var postalCode: RabbleTextField!
    @IBOutlet var city: RabbleTextField!
    @IBOutlet var street: RabbleTextField!
    @IBOutlet var direction: RabbleTextView!
    @IBOutlet var storeType: RabbleTextField!
    @IBOutlet var shelfSpace: RabbleTextField!
    @IBOutlet var dryStorageSpace: RabbleTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpStepIndicatorViewController {
            vc.currentStep = .one
        }
    }
    
    func saveStoreProfile(){
        apiprovider.request(.saveStoreProfile(name: storeName.text ?? "", postalCode: postalCode.text ?? "", city: city.text ?? "", streetAddress: street.text ?? "", direction: direction.text ?? "", storeType: storeType.text ?? "", shelfSpace: shelfSpace.text ?? "", dryStorageSpace: dryStorageSpace.text ?? "", baseURL: environment.baseURL)) { result in
            switch result {
            case let .success(response):
                // Handle successful response
                do {
                    let response = try response.map(SaveStoreProfileResponse.self)
                    if response.statusCode == 200 || response.statusCode == 201 {
                        print(response.data)
                        self.saveStore(response.data)
                        self.goToSavePartnerProfile()
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
    
    func saveStore(_ store: Store) {
        StoreManager.shared.store = store
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        self.saveStoreProfile()
    }
    
    func goToSavePartnerProfile(){
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpProfileViewController") as! SignUpProfileViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
}
