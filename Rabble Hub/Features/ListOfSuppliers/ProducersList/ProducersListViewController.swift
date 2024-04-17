//
//  ProducersListViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit

class ProducersListViewController: UIViewController {
    
    @IBOutlet var producersTableview: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Colors.BackgroundPrimary
        
        producersTableview.delegate = self
        producersTableview.dataSource = self
    }

}

extension ProducersListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 372
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProducersListTableViewCell", for: indexPath) as? ProducersListTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    
}
