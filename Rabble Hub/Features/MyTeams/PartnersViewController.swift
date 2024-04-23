//
//  PartnersViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/19/24.
//

import UIKit

class PartnersViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var partnerTableview: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        partnerTableview.delegate = self
        partnerTableview.dataSource = self
    }

    @IBAction func setupNewBuyingTeamButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ProducersListView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ProducersListViewController") as? ProducersListViewController {
            vc.modalPresentationStyle = .formSheet
            self.present(vc, animated: true)
        }
    }
}

extension PartnersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PartnerTableViewCell", for: indexPath) as? PartnerTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "MyTeamsView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "PartnerDetailsViewController") as? PartnerDetailsViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}
