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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    func setupView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.iconBackgroundView.layer.cornerRadius = 12.0
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
