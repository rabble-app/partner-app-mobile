//
//  ProfilePartnerDetailsViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/25/24.
//

import UIKit

class ProfilePartnerDetailsViewController: UIViewController {

    @IBOutlet weak var storeTypeTextfield: RabbleTextField!
    @IBOutlet weak var fridgeSpaceTextField: RabbleTextField!
    @IBOutlet weak var dryStorageTextField: RabbleTextField!
    
    @IBOutlet weak var storeTypeButton: UIButton!
    @IBOutlet weak var fridgeSpaceButton: UIButton!
    @IBOutlet weak var dryStorageButton: UIButton!
    
    @IBOutlet weak var popupBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        self.storeTypeButton.setTitle("", for: .normal)
        self.fridgeSpaceButton.setTitle("", for: .normal)
        self.dryStorageButton.setTitle("", for: .normal)
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
}
