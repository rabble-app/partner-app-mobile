//
//  PaymentPopUpViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/16/24.
//

import UIKit

protocol PaymentPopUpDelegate: AnyObject {
    func paymentPopUpDismissed()
}

class PaymentPopUpViewController: UIViewController, ShowSuppliersDelegate {
    
    weak var delegate: PaymentPopUpDelegate?
    
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
            vc.delegate = self
            self.present(vc, animated: true)
        }
        
//        self.dismiss(animated: true) { [self] in
//            delegate?.paymentPopUpDismissed()
//        }
    }
    
    func onTapShowSuppliers() {
        self.dismiss(animated: true) {
            let storyboard = UIStoryboard(name: "ProducersListView", bundle: Bundle.main)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ProducersListViewController") as? ProducersListViewController {
                vc.modalPresentationStyle = .formSheet
                self.present(vc, animated: true)
            }
        }
    }
    
}
