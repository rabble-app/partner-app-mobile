//
//  PaymentPopUpViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/16/24.
//

import UIKit

class PaymentPopUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 1, alpha: 0.6)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func connectButtonTap(_ sender: Any) {
      
    }
    
    @IBAction func skipButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CreateATeamPopUpView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CreateATeamPopUpViewController") as? CreateATeamPopUpViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
}
