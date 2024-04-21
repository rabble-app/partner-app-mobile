//
//  SuccessStateViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/21/24.
//

import UIKit

class SuccessStateViewController: UIViewController {

    var deliveryNavigationController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backToDeliveriesButtonTap(_ sender: Any) {
        // Dismiss all presented view controllers
        self.presentingViewController?.presentingViewController?.dismiss(animated: true) {
            // If there's a navigation controller, pop to the root view controller
            if let navController = self.deliveryNavigationController {
                navController.popToRootViewController(animated: true)
            }
        }
    }
}
