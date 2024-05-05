//
//  InboundDeliveriesViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/18/24.
//

import UIKit

class InboundDeliveriesViewController: UIViewController {

    @IBOutlet var segmentedController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    

    @IBAction func deliveriesSegmentedControlTap(_ sender: Any) {
        self.tableView.reloadData()
    }

}

extension InboundDeliveriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InboundDeliveriesTableViewCell", for: indexPath) as? InboundDeliveriesTableViewCell else {
            return UITableViewCell()
        }
        
        if segmentedController.selectedSegmentIndex == 0 {
            cell.calendarImg.tintColor = Colors.Today
            cell.dateValue.textColor = Colors.Today
        } else if segmentedController.selectedSegmentIndex == 1 {
            cell.calendarImg.tintColor = Colors.Upcoming
            cell.dateValue.textColor =  Colors.Upcoming
        } else {
            cell.calendarImg.tintColor = Colors.Past
            cell.dateValue.textColor = Colors.Past
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "InboundDeliveriesView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "DeliveryDetailsViewController") as? DeliveryDetailsViewController {
            vc.modalPresentationStyle = .overFullScreen
            vc.deliveryNavigationController = self.navigationController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "DELIVERIES TODAY"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 77
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return 24
    }
    
}
