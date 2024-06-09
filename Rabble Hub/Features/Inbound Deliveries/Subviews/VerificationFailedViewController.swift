//
//  VerificationFailedViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/26/24.
//

import UIKit

class VerificationFailedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func retryButtonTap(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func contactSupportButtonTap(_ sender: Any) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
