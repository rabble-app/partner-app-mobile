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
        let rabbleSheetViewController = RabbleSheetViewController()
        rabbleSheetViewController.headerTitle = "Store Type"
        rabbleSheetViewController.items =  ["Item 1", "Item 2", "Item 3", "Item 4"]
        rabbleSheetViewController.itemSelected = { item in
            self.storeTypeTextfield.text = item
        }
        present(rabbleSheetViewController, animated: true, completion: nil)
    }
    
    @IBAction func fridgeSpaceButtonTapped(_ sender: Any) {
        let rabbleSheetViewController = RabbleSheetViewController()
        rabbleSheetViewController.headerTitle = "Select an option"
        rabbleSheetViewController.items =  ["5 cubic feet", "10 cubic feet", "15 cubic feet", "20 cubic feet", "25 cubic feet"]
        rabbleSheetViewController.itemSelected = { item in
            self.fridgeSpaceTextField.text = item
        }
        present(rabbleSheetViewController, animated: true, completion: nil)
    }
    
    @IBAction func dryStorageButtonTapped(_ sender: Any) {
        let rabbleSheetViewController = RabbleSheetViewController()
        rabbleSheetViewController.headerTitle = "Select an option"
        rabbleSheetViewController.items =  ["10 cubic feet", "20 cubic feet", "30 cubic feet", "40 cubic feet", "50 cubic feet"]
        rabbleSheetViewController.itemSelected = { item in
            self.dryStorageTextField.text = item
        }
        present(rabbleSheetViewController, animated: true, completion: nil)
    }

    @IBAction func saveChangesButtonTap(_ sender: Any) {
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
