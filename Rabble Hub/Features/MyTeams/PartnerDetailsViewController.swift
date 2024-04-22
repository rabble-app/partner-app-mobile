//
//  PartnerDetailsViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/21/24.
//

import UIKit

class PartnerDetailsViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var img: UIImageView!
    @IBOutlet var initialContainer: UIView!
    @IBOutlet var initialLabel: UILabel!
    @IBOutlet var hostContainer: UIView!
    @IBOutlet var hostLabel: UILabel!
    @IBOutlet var partnerName: UILabel!
    @IBOutlet var deliveryFrequency: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var nextDdeliveryContainer: UIView!
    @IBOutlet var nextDeliveryDate: UILabel!
    @IBOutlet var ordersTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ordersTableview.delegate = self
        ordersTableview.dataSource = self
        scrollView.delegate = self
    }
    

    @IBAction func manageTeamButtonTap(_ sender: Any) {
        
    }
    
}

extension PartnerDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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

