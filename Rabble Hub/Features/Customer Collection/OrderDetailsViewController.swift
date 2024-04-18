//
//  OrderDetailsViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/18/24.
//

import UIKit

class OrderDetailsViewController: UIViewController {

    @IBOutlet var ordersTableview: UITableView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var teamnameLabel: UILabel!
    @IBOutlet var categoryValueLabel: UILabel!
    @IBOutlet var dateTimeValueLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ordersTableview.delegate = self
        ordersTableview.dataSource = self
    }
}

extension OrderDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailsTableViewCell", for: indexPath) as? OrderDetailsTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
//        if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseFrequencyViewController") as? ChooseFrequencyViewController {
//            vc.modalPresentationStyle = .custom
//            let pushAnimator = PushAnimator()
//            vc.transitioningDelegate = pushAnimator
//            self.title = "Team Settings"
//            self.present(vc, animated: true)
//        }
    }
    
    
}


