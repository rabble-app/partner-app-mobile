//
//  QrCodeViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/19/24.
//

import UIKit

class QrCodeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func goToOrderDetails() {
        let storyboard = UIStoryboard(name: "CustomerCollectionView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OrderDetailsViewController") as? OrderDetailsViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    

    func showErrorPop() {
        let storyboard = UIStoryboard(name: "QrCodeView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "QrCodeErrorPopViewController") as? QrCodeErrorPopViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }

}
