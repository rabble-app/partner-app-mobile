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
    @IBOutlet var contentView_height: NSLayoutConstraint!
    @IBOutlet var orderTableview_height: NSLayoutConstraint!
    @IBOutlet var tableviewHeaderContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ordersTableview.delegate = self
        ordersTableview.dataSource = self
        scrollView.delegate = self
        
        self.setUpView()
           
    }
    
    func setUpView() {
        
        orderTableview_height.constant = 2 * 95
        contentView_height.constant = 780 + orderTableview_height.constant
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentView_height.constant)
        
        initialContainer.layer.cornerRadius = 36.0
        initialContainer.clipsToBounds = true
        hostContainer.layer.cornerRadius = 12.0
        hostContainer.clipsToBounds = true
        
        nextDdeliveryContainer.layer.borderWidth = 1.0
        nextDdeliveryContainer.layer.borderColor = Colors.Gray5.cgColor
        nextDdeliveryContainer.layer.cornerRadius = 13.0
        nextDdeliveryContainer.clipsToBounds = true
        
        tableviewHeaderContainer.roundCorners([.topLeft, .topRight], radius: 13)
        ordersTableview.roundCorners([.bottomLeft, .bottomRight], radius: 13)
    }
    

    @IBAction func manageTeamButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyTeamsView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ManageTeamViewController") as? ManageTeamViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension PartnerDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailsTableViewCell", for: indexPath) as? OrderDetailsTableViewCell else {
            return UITableViewCell()
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.border.isHidden = true
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

