//
//  ManageEmployeeAddEmployeeViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/26/24.
//

import UIKit
import DialCountries
import Moya

class ManageEmployeeAddEmployeeViewController: UIViewController, UITextFieldDelegate  {

    @IBOutlet var flag: UILabel!
    @IBOutlet var countryPickerButton: UIButton!
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var phoneNumberTextfield: UITextField!
    @IBOutlet var phoneNumberContainer: UIView!
    @IBOutlet var name: RabbleTextField!
    @IBOutlet var lastName: RabbleTextField!
    
    @IBOutlet var addEmployeeBtn: PrimaryButton!
    @IBOutlet weak var addEmployeeViewBottomConstraint: NSLayoutConstraint!
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    private let userDataManager = UserDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpDefaultCountry()
        
        
    }
    
    func setUpDefaultCountry() {
        if let country = Country.getCurrentCountry() {
            codeLabel.text = country.dialCode
            flag.text = country.flag
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateContinueButtonState()
    }
    
    private func updateContinueButtonState() {
        let allFieldsFilled = [name, lastName, phoneNumberTextfield].allSatisfy { !($0.text?.isEmpty ?? true) }
        addEmployeeBtn.isEnabled = allFieldsFilled
    }
    
    func setUpView() {
        
        phoneNumberContainer.layer.borderWidth = 1.0
        phoneNumberContainer.layer.borderColor = Colors.Gray5.cgColor
        phoneNumberContainer.layer.cornerRadius = 12.0
        phoneNumberContainer.clipsToBounds = true
        
        countryPickerButton.layer.borderWidth = 1.0
        countryPickerButton.layer.borderColor = Colors.Gray5.cgColor
        countryPickerButton.layer.cornerRadius = 12.0
        countryPickerButton.clipsToBounds = true
        
        addEmployeeBtn.isEnabled = false
        [name, lastName, phoneNumberTextfield].forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    
    
    // MARK: - Keyboard notifications
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
              let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        var safeAreaOffSet: CGFloat = 0.0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            safeAreaOffSet = window?.safeAreaInsets.bottom ?? 0.0
        }
        
        if (keyboardSize.height - safeAreaOffSet) > self.addEmployeeViewBottomConstraint.constant {
            self.addEmployeeViewBottomConstraint.constant = keyboardSize.height - safeAreaOffSet
            view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        self.addEmployeeViewBottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    @IBAction func countryPickerButtonTap(_ sender: Any) {
        DispatchQueue.main.async {
            let cv = DialCountriesController(locale: Locale(identifier: "en"))
            cv.delegate = self
            cv.show(vc: self)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func addEmployeeButtonTap(_ sender: Any) {
        guard let phoneNumber = phoneNumberTextfield.text, !phoneNumber.isEmpty else {
            // Set border color of phoneNumberContainer to red
            phoneNumberContainer.layer.borderColor = UIColor.red.cgColor
            phoneNumberTextfield.becomeFirstResponder()
            return
        }
        
        // Reset border color of phoneNumberContainer
        phoneNumberContainer.layer.borderColor = Colors.Gray5.cgColor
        self.addEmployee()
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func addEmployee() {
        let phone = "\(codeLabel.text ?? "")\(phoneNumberTextfield.text ?? "")"
        guard let firstName = name.text,
              let lastName = lastName.text else {
            return
        }
        
        self.showLoadingIndicator()
        let storeId = userDataManager.getUserData()?.partner?.id ?? ""
        apiProvider.request(.addEmployee(storeId: storeId, firstName: firstName, lastName: lastName, phone: phone)) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingIndicator()
            
            switch result {
            case .success(let response):
                self.handleResponse(response)
            case .failure(let error):
                self.handleFailure(error)
            }
        }
    }
    
    private func handleResponse(_ response: Response) {
        do {
            let userResponse = try response.map(AddEmployeesResponse.self)
            if userResponse.statusCode == 200 || userResponse.statusCode == 201 {
                showSnackBar(message: userResponse.message, isSuccess: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    NotificationCenter.default.post(name: NSNotification.Name("EmployeesAdded"), object: nil)
                    self.dismiss(animated: true)
                }
            } else {
                showSnackBar(message: userResponse.message, isSuccess: false)
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
    
    private func showSnackBar(message: String, isSuccess: Bool = false) {
        SnackBar().alert(withMessage: message, isSuccess: isSuccess, parent: view)
    }
}

// MARK: - DialCountriesControllerDelegate methods

extension ManageEmployeeAddEmployeeViewController: DialCountriesControllerDelegate {
    
    func didSelected(with country: Country) {
        self.codeLabel.text = country.dialCode
        self.flag.text = country.flag
    }
}
