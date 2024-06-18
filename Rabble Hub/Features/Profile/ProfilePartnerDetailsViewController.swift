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
        apiProvider.request(.getStoreInformation(partnerId: partner.id)) { result in
            self.handleSuppliersResponse(result)
        }
    }
    
    private func handleSuppliersResponse(_ result: Result<Response, MoyaError>) {
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
        
        let rabbleSheetViewController = RabbleSheetViewController()
        rabbleSheetViewController.headerTitle = "Store Type"
        rabbleSheetViewController.items =  ["Item 1", "Item 2", "Item 3", "Item 4"]
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
        
        let rabbleSheetViewController = RabbleSheetViewController()
        rabbleSheetViewController.headerTitle = "Select an option"
        rabbleSheetViewController.items =  ["5 cubic feet", "10 cubic feet", "15 cubic feet", "20 cubic feet", "25 cubic feet"]
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
        
        let rabbleSheetViewController = RabbleSheetViewController()
        rabbleSheetViewController.headerTitle = "Select an option"
        rabbleSheetViewController.items =  ["10 cubic feet", "20 cubic feet", "30 cubic feet", "40 cubic feet", "50 cubic feet"]
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
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
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
