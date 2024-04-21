//
//  ManuallyCheckItemsViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/21/24.
//

import UIKit

class ManuallyCheckItemsViewController: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.reloadData()
    }
    
    @IBAction func cameraButtonTap(_ sender: Any) {
        
    }
    
    @IBAction func checkInStoreButtonTap(_ sender: Any) {
        
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension ManuallyCheckItemsViewController: UITableViewDelegate, UITableViewDataSource {
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
