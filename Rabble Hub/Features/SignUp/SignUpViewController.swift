//
//  SignUpViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/15/24.
//

import UIKit
import Moya

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var continueButton: PrimaryButton!
    @IBOutlet var storeName: RabbleTextField!
    @IBOutlet var postalCode: RabbleTextField!
    @IBOutlet var city: RabbleTextField!
    @IBOutlet var street: RabbleTextField!
    @IBOutlet var direction: RabbleTextView!
    @IBOutlet var storeType: RabbleTextField!
    @IBOutlet weak var storeTypeButton: UIButton!
    @IBOutlet var shelfSpace: RabbleTextField!
    @IBOutlet weak var shelfSpaceButton: UIButton!
    @IBOutlet var dryStorageSpace: RabbleTextField!
    @IBOutlet weak var dryStorageButton: UIButton!
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    let selectAnOptionText = "Select an option"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        continueButton.isEnabled = false
        postalCode.text = "SE154NX" // Postal code that returns suppliers
        
        // Add observers for text change events in text fields
        [storeName, postalCode, city, street, storeType, shelfSpace, dryStorageSpace].compactMap { $0 }.forEach { textField in
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        
        self.storeTypeButton.setTitle("", for: .normal)
        self.shelfSpaceButton.setTitle("", for: .normal)
        self.dryStorageButton.setTitle("", for: .normal)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateContinueButtonState()
    }
    
    private func updateContinueButtonState() {
        // Define the default values for storeType, shelfSpace, and dryStorageSpace
        let defaultStoreType = "Store Type"
        let defaultShelfSpace = selectAnOptionText
        let defaultDryStorageSpace = selectAnOptionText

        // Check if all text fields have input
        let allFieldsFilled = [storeName, postalCode, city, street, storeType, shelfSpace, dryStorageSpace].compactMap { $0 }.allSatisfy { textField in
            guard let text = textField.text else { return false }
            // Check if the field is not empty and does not contain the default value
            return !text.isEmpty && !(textField == storeType && text == defaultStoreType) && !(textField == shelfSpace && text == defaultShelfSpace) && !(textField == dryStorageSpace && text == defaultDryStorageSpace)
        }
        continueButton.isEnabled = allFieldsFilled
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpStepIndicatorViewController {
            vc.currentStep = .one
        }
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        fetchSuppliers()
    }
    
    @IBAction func storeTypeButtonTapped(_ sender: Any) {
        let rabbleSheetViewController = RabbleSheetViewController()
        rabbleSheetViewController.headerTitle = "Store Type"
        rabbleSheetViewController.items =  ["Item 1", "Item 2", "Item 3", "Item 4"]
        rabbleSheetViewController.itemSelected = { item in
            self.storeType.text = item
            self.updateContinueButtonState()
        }
        present(rabbleSheetViewController, animated: true, completion: nil)
    }
    
    @IBAction func shelfSpaceButtonTapped(_ sender: Any) {
        let rabbleSheetViewController = RabbleSheetViewController()
        rabbleSheetViewController.headerTitle = selectAnOptionText
        rabbleSheetViewController.items =  ["5 cubic feet", "10 cubic feet", "15 cubic feet", "20 cubic feet", "25 cubic feet"]
        rabbleSheetViewController.itemSelected = { item in
            self.shelfSpace.text = item
            self.updateContinueButtonState()
        }
        present(rabbleSheetViewController, animated: true, completion: nil)
    }
    
    @IBAction func dryStorageButtonTapped(_ sender: Any) {
        let rabbleSheetViewController = RabbleSheetViewController()
        rabbleSheetViewController.headerTitle = selectAnOptionText
        rabbleSheetViewController.items =  ["10 cubic feet", "20 cubic feet", "30 cubic feet", "40 cubic feet", "50 cubic feet"]
        rabbleSheetViewController.itemSelected = { item in
            self.dryStorageSpace.text = item
            self.updateContinueButtonState()
        }
        present(rabbleSheetViewController, animated: true, completion: nil)
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
                    self.updateUserDataPostalCode(store)
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
            SnackBar().alert(withMessage: response.message, isSuccess: false, parent: self.view)
        } catch {
            SnackBar().alert(withMessage: "An error has occurred", isSuccess: false, parent: self.view)
            print("Failed to map response data: \(error)")
        }
    }
    
    private func updateUserDataPostalCode(_ store: Store) {
        let userDataManager = UserDataManager()
        if var userData = userDataManager.getUserData() {
            userData.partner?.postalCode = self.postalCode.text
            userData.partner?.id = store.id
            userDataManager.saveUserData(userData)
        }
    }
    
    private func goToCreateUserProfile() {
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpProfileViewController") as! SignUpProfileViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
}
