//
//  ProfilePartnerDetailsViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/25/24.
//

import Moya
import UIKit

class ProfilePartnerDetailsViewController: UIViewController {

    @IBOutlet weak var storeNameTextField: RabbleTextField!
    @IBOutlet weak var postalCodeTextField: RabbleTextField!
    @IBOutlet weak var cityTextField: RabbleTextField!
    @IBOutlet weak var streetAddressTextField: RabbleTextField!
    @IBOutlet weak var directionsTextView: RabbleTextView!
    @IBOutlet weak var storeTypeTextfield: RabbleTextField!
    @IBOutlet weak var fridgeSpaceTextField: RabbleTextField!
    @IBOutlet weak var dryStorageTextField: RabbleTextField!
    
    @IBOutlet weak var storeTypeButton: UIButton!
    @IBOutlet weak var fridgeSpaceButton: UIButton!
    @IBOutlet weak var dryStorageButton: UIButton!
    
    @IBOutlet weak var popupBackgroundView: UIView!
    
    private var originalStoreData: StoreData?
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    private let userDataManager = UserDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPartnerDetails()
    }
    
    func setupUI() {
        self.storeTypeButton.setTitle("", for: .normal)
        self.fridgeSpaceButton.setTitle("", for: .normal)
        self.dryStorageButton.setTitle("", for: .normal)
    }
   
    private func fetchPartnerDetails() {
        guard let partner = userDataManager.getUserData()?.partner else { return }
        self.showLoadingIndicator()
        apiProvider.request(.getStoreInformation(partnerId: partner.id)) { result in
            self.handlePartnerDetailsResponse(result)
            self.dismissLoadingIndicator()
        }
    }
    
    private func handlePartnerDetailsResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            handleSuccessResponse(response)
        case .failure(let error):
            displaySnackBar(message: (error.localizedDescription), isSuccess: false)
        }
    }
    
    private func handleSuccessResponse(_ response: Response) {
        do {
            let storeInformationResponse = try response.map(StoreInformationResponse.self)
            if storeInformationResponse.statusCode == 200 {
                self.originalStoreData = storeInformationResponse.data
                self.configureStoreInformationUI(storeData: storeInformationResponse.data)
            } else {
                displaySnackBar(message: storeInformationResponse.message, isSuccess: true)
            }
        } catch {
            handleMappingError(response)
        }
    }
    
    private func handleMappingError(_ response: Response) {
        do {
            let errorResponse = try response.map(StandardResponse.self)
            displaySnackBar(message: errorResponse.message, isSuccess: false)
        } catch {
            print("Failed to map response data: \(error)")
        }
    }
    

    /// Configure Store Information fields
    func configureStoreInformationUI(storeData: StoreData) {
        self.storeNameTextField.text = storeData.name
        self.postalCodeTextField.text = storeData.postalCode
 
        if let city = storeData.city {
            self.cityTextField.text = city
        }
        if let streetAddress = storeData.streetAddress {
            self.streetAddressTextField.text = streetAddress
        }
        if let direction = storeData.direction {
            self.directionsTextView.text = direction
        }
        if let storeType = storeData.storeType {
            self.storeTypeTextfield.text = storeType
        }
        if let shelfSpace = storeData.shelfSpace {
            self.fridgeSpaceTextField.text = shelfSpace
        }
        if let dryStorageSpace = storeData.dryStorageSpace {
            self.dryStorageTextField.text = dryStorageSpace
        }
        
    }
    
    @IBAction func storeTypeButtonTapped(_ sender: Any) {
        self.showViewWithAnimation(view: self.popupBackgroundView)
        let items = ["Item 1", "Item 2", "Item 3", "Item 4"]
        let rabbleSheetViewController = RabbleSheetViewController()
        rabbleSheetViewController.headerTitle = "Store Type"
        rabbleSheetViewController.items =  items
        if let index = items.indexOfIgnoringCase(self.storeTypeTextfield.text ?? "") {
            rabbleSheetViewController.setIndex(index: index)
        }
        rabbleSheetViewController.itemSelected = { item in
            self.storeTypeTextfield.text = item
        }
        rabbleSheetViewController.dismissed = {
            self.hideViewWithAnimation(view: self.popupBackgroundView)
        }
        rabbleSheetViewController.modalPresentationStyle = .overFullScreen
        present(rabbleSheetViewController, animated: true, completion: nil)
    }
    
    @IBAction func fridgeSpaceButtonTapped(_ sender: Any) {
        self.showViewWithAnimation(view: self.popupBackgroundView)
        let items = ["5 cubic feet", "10 cubic feet", "15 cubic feet", "20 cubic feet", "25 cubic feet"]
        let rabbleSheetViewController = RabbleSheetViewController()
        rabbleSheetViewController.headerTitle = "Select an option"
        rabbleSheetViewController.items = items
        if let index = items.indexOfIgnoringCase(self.fridgeSpaceTextField.text ?? "") {
            rabbleSheetViewController.setIndex(index: index)
        }
        rabbleSheetViewController.itemSelected = { item in
            self.fridgeSpaceTextField.text = item
        }
        rabbleSheetViewController.dismissed = {
            self.hideViewWithAnimation(view: self.popupBackgroundView)
        }
        rabbleSheetViewController.modalPresentationStyle = .overFullScreen
        present(rabbleSheetViewController, animated: true, completion: nil)
    }
    
    @IBAction func dryStorageButtonTapped(_ sender: Any) {
        self.showViewWithAnimation(view: self.popupBackgroundView)
        let items = ["10 cubic feet", "20 cubic feet", "30 cubic feet", "40 cubic feet", "50 cubic feet"]
        let rabbleSheetViewController = RabbleSheetViewController()
        rabbleSheetViewController.headerTitle = "Select an option"
        rabbleSheetViewController.items = items
        if let index = items.indexOfIgnoringCase(self.dryStorageTextField.text ?? "") {
            rabbleSheetViewController.setIndex(index: index)
        }
        rabbleSheetViewController.itemSelected = { item in
            self.dryStorageTextField.text = item
        }
        rabbleSheetViewController.dismissed = {
            self.hideViewWithAnimation(view: self.popupBackgroundView)
        }
        rabbleSheetViewController.modalPresentationStyle = .overFullScreen
        present(rabbleSheetViewController, animated: true, completion: nil)
    }

    @IBAction func saveChangesButtonTap(_ sender: Any) {
        saveStoreProfile()
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("UserRecordUpdated"), object: nil)
        self.dismiss(animated: true)
    }
    
    private func saveStoreProfile() {
           self.showLoadingIndicator()
           let userDataManager = UserDataManager()
           let storeId = userDataManager.getUserData()?.partner?.id ?? ""
           
           let name = storeNameTextField.text != originalStoreData?.name ? storeNameTextField.text : nil
           let postalCode = postalCodeTextField.text != originalStoreData?.postalCode ? postalCodeTextField.text : nil
           let city = cityTextField.text != originalStoreData?.city ? cityTextField.text : nil
           let streetAddress = streetAddressTextField.text != originalStoreData?.streetAddress ? streetAddressTextField.text : nil
           let direction = directionsTextView.text != originalStoreData?.direction ? directionsTextView.text : nil
           let storeType = storeTypeTextfield.text != originalStoreData?.storeType ? storeTypeTextfield.text : nil
           let shelfSpace = fridgeSpaceTextField.text != originalStoreData?.shelfSpace ? fridgeSpaceTextField.text : nil
           let dryStorageSpace = dryStorageTextField.text != originalStoreData?.dryStorageSpace ? dryStorageTextField.text : nil
           
           apiProvider.request(.updateStoreProfile(storeId: storeId,
                                                   name: name,
                                                   postalCode: postalCode,
                                                   city: city,
                                                   streetAddress: streetAddress,
                                                   direction: direction,
                                                   storeType: storeType,
                                                   shelfSpace: shelfSpace,
                                                   dryStorageSpace: dryStorageSpace)) { [weak self] result in
               guard let self = self else { return }
               self.dismissLoadingIndicator()
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
            // Check if partner is nil, if so, initialize it
            if userData.partner == nil {
                userData.partner = PartnerData(id: store.id, openHours: userData.partner?.openHours, name: store.name, postalCode: self.postalCodeTextField.text)
            } else {
                // Update existing partner data
                userData.partner?.postalCode = self.postalCodeTextField.text
                userData.partner?.id = store.id
            }
            
            userDataManager.saveUserData(userData)
        }
    }
}

extension ProfilePartnerDetailsViewController {
    
    // Function to hide the view with animation
    func hideViewWithAnimation(view: UIView, duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 0.0
        }) { _ in
            view.isHidden = true
        }
    }

    // Function to show the view with animation
    func showViewWithAnimation(view: UIView, duration: TimeInterval = 0.1) {
        view.isHidden = false
        view.alpha = 0.0
        UIView.animate(withDuration: duration) {
            view.alpha = 1.0
        }
    }
    
    private func displaySnackBar(message: String, isSuccess: Bool = false) {
        SnackBar().alert(withMessage: message, isSuccess: isSuccess, parent: view)
    }
}
