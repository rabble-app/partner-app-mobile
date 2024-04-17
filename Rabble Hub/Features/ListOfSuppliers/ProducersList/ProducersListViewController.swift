//
//  ProducersListViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit

class ProducersListViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseFrequencyViewController") as? ChooseFrequencyViewController {
            vc.modalPresentationStyle = .custom
            let pushAnimator = PushAnimator()
            vc.transitioningDelegate = pushAnimator 
            self.title = "Team Settings"
            self.present(vc, animated: true)
        }
    }
    
    
}
