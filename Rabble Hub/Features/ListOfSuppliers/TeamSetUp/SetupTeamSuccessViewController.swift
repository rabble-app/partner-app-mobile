//
//  SetupTeamSuccessViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/18/24.
//

import UIKit

class SetupTeamSuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func goToTeamPageButtonTap(_ sender: Any) {
        goToMainTab()
    }
    
    func goToMainTab() {
        let storyboard = UIStoryboard(name: "MainTabStoryboard", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MainTabViewController") as? MainTabViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
            vc.selectedIndex = 3
            vc.reloadSelectedTab()
        }
    }

}
