//
//  OrderCollectedViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/9/24.
//

import UIKit

class OrderCollectedViewController: UIViewController {
   
    @IBOutlet var descLabel: UILabel!
    var selectedCollectionData: CollectionData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    
    private func setUpView() {
        self.descLabel.text = "This order has been picked up by \(selectedCollectionData?.user.firstName ?? "") \(selectedCollectionData?.user.lastName ?? ""), make sure to see what else you could offer \(selectedCollectionData?.user.firstName ?? "") \(selectedCollectionData?.user.lastName ?? "") on their next collection on their next collection day."
    }
    

    @IBAction func newScan(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MainTabStoryboard", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MainTabViewController") as? MainTabViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
            vc.selectedIndex = 2
            vc.reloadSelectedTab()
        }
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
