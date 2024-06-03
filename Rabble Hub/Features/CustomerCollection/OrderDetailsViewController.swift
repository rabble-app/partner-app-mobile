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
    @IBOutlet var tableviewHeaderContainer: UIView!
    @IBOutlet var iconContainer: UIView!
    @IBOutlet weak var tableViewConstraintHeight: NSLayoutConstraint!
    
    var isFromScanning: Bool = false
    
    var selectedCollectionData: CollectionData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.loadData()
        
    }
    
    private func loadData() {
        if let data = selectedCollectionData {
            // Update the UI with the data
            print(data)
            
            self.usernameLabel.text = (selectedCollectionData?.user.firstName ?? "") + " " + (selectedCollectionData?.user.lastName ?? "")
            self.teamnameLabel.text = selectedCollectionData?.order.team.name ?? ""
            
            self.categoryValueLabel.text = selectedCollectionData?.order.team.producer.categories.first?.category.name
            
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let dateString = selectedCollectionData?.dateOfCollection ?? nil,
               let date = isoDateFormatter.date(from: dateString) {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM, HH:mm"
                let formattedDate = dateFormatter.string(from: date)
                
                self.dateTimeValueLabel.text = formattedDate
            } else {
                print("Failed to parse date")
            }

            
            self.tableViewConstraintHeight.constant = CGFloat(95 * (selectedCollectionData?.items.count ?? 0)) // 10 is the number of orders
            
            self.ordersTableview.reloadData()
            
        }
    }
    
    private func setUpView() {
        ordersTableview.delegate = self
        ordersTableview.dataSource = self
        
        tableviewHeaderContainer.clipsToBounds = true
        tableviewHeaderContainer.layer.cornerRadius = 10
        tableviewHeaderContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        ordersTableview.clipsToBounds = true
        ordersTableview.layer.cornerRadius = 10
        ordersTableview.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        iconContainer.layer.cornerRadius = 28.0
        iconContainer.clipsToBounds = true
        ordersTableview.showsVerticalScrollIndicator = false
    }
}

extension OrderDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCollectionData?.items.count ?? 0
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
        
        let items = selectedCollectionData?.items[indexPath.row]
        cell.supplierLabel.text = items?.product.name
        cell.quantityLabel.text = "x \(items?.amount ?? "")"
        cell.descLabel.text = "\(items?.product.measuresPerSubUnit ?? 0) \(items?.product.unitsOfMeasurePerSubUnit ?? "")"
        
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


