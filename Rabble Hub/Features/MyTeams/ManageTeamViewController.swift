//
//  ManageTeamViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/22/24.
//

import UIKit

struct Section {
    var title: String
    var items: [TeamSetting]
}

class ManageTeamViewController: UIViewController {
    
    @IBOutlet var segmentedController: UISegmentedControl!
    @IBOutlet var teamTableview: UITableView!
    @IBOutlet var deleteTeamButton: UIButton!
    
    @IBOutlet var tableView_bottom_button: NSLayoutConstraint!
    @IBOutlet var tableView_bottom: NSLayoutConstraint!
    
    var sections: [Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamTableview.delegate = self
        teamTableview.dataSource = self
        segmentedController.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        let teamInfoSection = Section(title: "Team Info", items: [
            TeamSetting(title: "Team Name", imageName: "icon_team")
        ])
        let teamSettingsSection = Section(title: "Team Settings", items: [
            TeamSetting(title: "Shipment frequency", imageName: "icon_frequency"),
            TeamSetting(title: "Adjust delivery date", imageName: "icon_calendar"),
            TeamSetting(title: "Product limit", imageName: "icon_product_limit")
        ])
        sections = [teamInfoSection, teamSettingsSection]
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        teamTableview.reloadData()
        
        if segmentedController.selectedSegmentIndex == 0 {
            tableView_bottom_button.isActive = true
            tableView_bottom.isActive = false
            deleteTeamButton.isHidden = false
            teamTableview.isScrollEnabled = false
        } else {
            tableView_bottom_button.isActive = false
            tableView_bottom.isActive = true
            deleteTeamButton.isHidden = true
            teamTableview.isScrollEnabled = true
        }
    }
    
    @IBAction func deleteTeamButtonTap(_ sender: Any) {
        
    }
    
}

extension ManageTeamViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if segmentedController.selectedSegmentIndex == 0 {
            return sections.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedController.selectedSegmentIndex == 0 {
            if section == 0 {
                return 1
            }
            return 3
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
            
            let item = sections[indexPath.section].items[indexPath.row]
            cell.configure(with: item)
            
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
        if segmentedController.selectedSegmentIndex == 0 {
            let section = indexPath.section
            let item = sections[section].items[indexPath.row]
            
            if section == 1 {
                let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
                
                if indexPath.row == 0 {
                    if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseFrequencyViewController") as? ChooseFrequencyViewController {
                        vc.modalPresentationStyle = .custom
                        vc.isFromEdit = true
                        vc.title = "Edit Shipment Frequency"
                        self.present(vc, animated: true)
                    }
                }else if indexPath.row == 1 {
                    if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseDeliveryDayViewController") as? ChooseDeliveryDayViewController {
                        vc.modalPresentationStyle = .custom
                        vc.isFromEdit = true
                        vc.title = "Adjust Delivery Day"
                        self.present(vc, animated: true)
                    }
                }else{
                    if let vc = storyboard.instantiateViewController(withIdentifier: "CreateALimitViewController") as? CreateALimitViewController {
                        vc.modalPresentationStyle = .custom
                        vc.isFromEdit = true
                        vc.title = "Edit Product Limit"
                        self.present(vc, animated: true)
                    }
                }
                
            }
            
        }else{
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segmentedController.selectedSegmentIndex == 0 {
            return sections[section].title
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if segmentedController.selectedSegmentIndex == 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
            headerView.backgroundColor = Colors.BackgroundPrimary
            
            let label = UILabel(frame: CGRect(x: 16, y: 8, width: tableView.frame.width - 32, height: 24))
            label.font = UIFont(name: "SFPro-Regular", size: 12) // SF Pro Regular
            label.textColor = Colors.Gray4
            label.text = sections[section].title
            headerView.addSubview(label)
            
            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if segmentedController.selectedSegmentIndex == 0 {
            return 24
        }
        return 0
    }


    
    
}
