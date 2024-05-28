//
//  CreateATeamPopUpViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/16/24.
//

import UIKit

protocol ShowSuppliersDelegate {
    func onTapShowSuppliers()
}

class CreateATeamPopUpViewController: UIViewController {
    
    var delegate: ShowSuppliersDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 1, alpha: 0.6)
        // Do any additional setup after loading the view.
    }
    

    @IBAction func showMeSuppliersButtonTap(_ sender: Any) {
//        delegate?.onTapShowSuppliers()
        let storyboard = UIStoryboard(name: "ProducersListView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ProducersListViewController") as? ProducersListViewController {
            vc.modalPresentationStyle = .formSheet
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        self.dismiss(animated: false)
    }
    @IBAction func skipButtonTap(_ sender: Any) {
        goToMainTab()
    }
    
    func goToMainTab() {
        let storyboard = UIStoryboard(name: "MainTabStoryboard", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MainTabViewController") as? MainTabViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
}
