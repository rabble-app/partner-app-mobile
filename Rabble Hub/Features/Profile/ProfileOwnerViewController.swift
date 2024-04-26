//
//  ProfileOwnerViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/25/24.
//

import UIKit

class ProfileOwnerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func saveChangesButtonTap(_ sender: Any) {
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
