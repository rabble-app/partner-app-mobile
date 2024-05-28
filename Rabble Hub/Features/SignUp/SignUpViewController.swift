//
//  SignUpViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/15/24.
//

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
        navigationController?.navigationBar.isHidden = true
        postalCode.text = "SE154NX" // Postal code that returns suppliers
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpStepIndicatorViewController {
            vc.currentStep = .one
        }
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        fetchSuppliers()
    }
    
    private func fetchSuppliers() {
        LoadingViewController.present(from: self)
        apiProvider.request(.saveStoreProfile(name: storeName.text ?? "",
                                              postalCode: postalCode.text ?? "",
                                              city: city.text ?? "",
                                              streetAddress: street.text ?? "",
                                              direction: direction.text ?? "",
                                              storeType: storeType.text ?? "",
                                              shelfSpace: shelfSpace.text ?? "",
                                              dryStorageSpace: dryStorageSpace.text ?? "")) { [weak self] result in
            guard let self = self else { return }
            LoadingViewController.dismiss(from: self)
            switch result {
            case .success(let response):
                self.handleResponse(response)
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    private func handleResponse(_ response: Response) {
        do {
            let mappedResponse = try response.map(SaveStoreProfileResponse.self)
            if mappedResponse.statusCode == 200 || mappedResponse.statusCode == 201 {
                guard let store = mappedResponse.data else { return }
                SnackBar().alert(withMessage: mappedResponse.message, isSuccess: true, parent: self.view)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.saveStore(store)
                    self.goToCreateUserProfile()
                }
            } else {
                self.handleErrorResponse(response)
            }
        } catch {
            self.handleErrorResponse(response)
        }
    }
    
    private func handleError(_ error: Error) {
        SnackBar().alert(withMessage: "\(error)", isSuccess: false, parent: self.view)
        print("Request failed with error: \(error)")
    }
    
    private func handleErrorResponse(_ response: Response) {
        do {
            let response = try response.map(StandardResponse.self)
            SnackBar().alert(withMessage: response.message[0], isSuccess: false, parent: self.view)
        } catch {
            SnackBar().alert(withMessage: "An error has occurred", isSuccess: false, parent: self.view)
            print("Failed to map response data: \(error)")
        }
    }
    
    func saveStore(_ store: Store) {
        StoreManager.shared.store = store
    }
    
    private func goToCreateUserProfile() {
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpProfileViewController") as! SignUpProfileViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
}
