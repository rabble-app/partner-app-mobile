//
//  ManageTeamViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/22/24.
//

import UIKit

class ManageTeamViewController: UIViewController {
    
    @IBOutlet var segmentedController: UISegmentedControl!
    @IBOutlet var teamTableview: UITableView!
    @IBOutlet var deleteTeamButton: UIButton!
    
    @IBOutlet var tableView_bottom_button: NSLayoutConstraint!
    @IBOutlet var tableView_bottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamTableview.delegate = self
        teamTableview.dataSource = self
        segmentedController.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        teamTableview.reloadData()
        
        if segmentedController.selectedSegmentIndex == 0 {
            tableView_bottom_button.isActive = true
            tableView_bottom.isActive = false
            deleteTeamButton.isHidden = false
        } else {
            tableView_bottom_button.isActive = false
            tableView_bottom.isActive = true
            deleteTeamButton.isHidden = true
        }
    }
    
    @IBAction func deleteTeamButtonTap(_ sender: Any) {
        
    }
    
}

extension ManageTeamViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedController.selectedSegmentIndex == 0 {
            return 4
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segmentedController.selectedSegmentIndex == 0 {
            return 64
        }else{
            return 82
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentedController.selectedSegmentIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TeamSettingsTableViewCell", for: indexPath) as? TeamSettingsTableViewCell else {
                return UITableViewCell()
            }
            
            let settings = [
                TeamSetting(title: "Team Name", imageName: "icon_team"),
                TeamSetting(title: "Shipment frequency", imageName: "icon_frequency"),
                TeamSetting(title: "Adjust delivery date", imageName: "icon_calendar"),
                TeamSetting(title: "Product limit", imageName: "icon_product_limit")
            ]
            
            cell.configure(with: settings[indexPath.row])
            
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                cell.border.isHidden = true
            }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ManageTeamTableViewCell", for: indexPath) as? ManageTeamTableViewCell else {
                return UITableViewCell()
            }
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                cell.border.isHidden = true
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let removeAction = UIAlertAction(title: "Remove Member", style: .destructive) { _ in
            // Perform remove action here
            // For example, you can delete the selected item from your data source and reload the table view
            // dataSourceArray.remove(at: indexPath.row)
            // tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
}
