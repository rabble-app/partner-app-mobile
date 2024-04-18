//
//  CreateATeamPopUpViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/16/24.
//

import UIKit

class CreateATeamPopUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func showMeSuppliersButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ProducersListView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ProducersListViewController") as? ProducersListViewController {
            vc.modalPresentationStyle = .formSheet
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func skipButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CustomerCollectionView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CustomerCollectionListViewController") as? CustomerCollectionListViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
}
