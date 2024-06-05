//
//  DeliveryDetailsViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/19/24.
//

import UIKit

class DeliveryDetailsViewController: UIViewController {

    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var deliveryNavigationController: UINavigationController?
    @IBOutlet var tableviewHeaderContainer: UIView!
    @IBOutlet weak var tableViewConstraintHeight: NSLayoutConstraint!
    
    @IBOutlet var producerName: UILabel!
    @IBOutlet var teamName: UILabel!
    @IBOutlet var orderNumber: UILabel!
    @IBOutlet var category: UILabel!
    @IBOutlet var deliveryDate: UILabel!
    
    
    var inboundDeliveryDetail: InboundDelivery?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    private func setupView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.iconBackgroundView.layer.cornerRadius = 28.0
        
        tableviewHeaderContainer.clipsToBounds = true
        tableviewHeaderContainer.layer.cornerRadius = 10
        tableviewHeaderContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        tableView.showsVerticalScrollIndicator = false
        
        self.tableViewConstraintHeight.constant = 77 * 5 // 5 is the number of orders
        
        self.title = "Delivery Details"

    }
    
    private func loadData() {
        self.producerName.text = self.inboundDeliveryDetail?.team.producer.businessName
        self.teamName.text = "\(self.inboundDeliveryDetail?.team.name ?? "") 􀱀"
        self.category.text = self.inboundDeliveryDetail?.team.producer.categories.first?.category.name
        self.orderNumber.text = ""
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let dateString = self.inboundDeliveryDetail?.deliveryDate ?? ""
        if let date = isoDateFormatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, HH:mm"
            let formattedDate = dateFormatter.string(from: date)
            self.deliveryDate.text = formattedDate
        } else {
            print("Failed to parse date")
        }
        
    }

    @IBAction func confirmButtonTap(_ sender: Any) {
        let signUpView = UIStoryboard(name: "InboundDeliveriesView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "ManuallyCheckItemsViewController") as! ManuallyCheckItemsViewController
        vc.deliveryNavigationController = self.deliveryNavigationController
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true, completion: nil)
    }
}

extension DeliveryDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryDetailsTableViewCell", for: indexPath) as? DeliveryDetailsTableViewCell else {
            return UITableViewCell()
        }

        return cell
    }
}
