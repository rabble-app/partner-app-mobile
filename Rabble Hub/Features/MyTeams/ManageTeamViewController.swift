//
//  ManageTeamViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/22/24.
//

import UIKit
import Moya

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
    
    @IBOutlet var emptyStateContainer: UIView!
    
    var sections: [Section] = []
    var partnerTeam: PartnerTeam?
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyStateContainer.isHidden = true
        
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
    
    private func loadEmptyState() {
        if segmentedController.selectedSegmentIndex == 0 && partnerTeam?.members.count ?? 0 < 0 {
            showEmptyState()
            return
        }
        hideEmptyState()
    }
    
    private func showEmptyState() {
        self.teamTableview.isHidden = true
        self.emptyStateContainer.isHidden = false
    }
    
    private func hideEmptyState() {
        self.teamTableview.isHidden = false
        self.emptyStateContainer.isHidden = true
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        loadEmptyState()
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
    
    private func deleteMember(_ member: Member) {
        LoadingViewController.present(from: self)
        apiProvider.request(.deleteMember(id: member.id)) { result in
            LoadingViewController.dismiss(from: self)
            self.handleSuppliersResponse(result)
        }
    }
    

    private func handleSuppliersResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            handleSuccessResponse(response)
        case .failure(let error):
            showError(error.localizedDescription)
        }
    }
    
    private func handleSuccessResponse(_ response: Response) {
        do {
            let deleteMemberResponse = try response.map(DeleteMemberResponse.self)
            if deleteMemberResponse.statusCode == 200 {
                self.loadEmptyState()
                self.showSuccessMessage(deleteMemberResponse.message)
                self.teamTableview.reloadData()
            } else {
                showError(deleteMemberResponse.message)
            }
        } catch {
            handleMappingError(response)
        }
    }
    
    private func handleMappingError(_ response: Response) {
        do {
            let errorResponse = try response.map(StandardResponse.self)
            showError(errorResponse.message)
        } catch {
            print("Failed to map response data: \(error)")
        }
    }
    
    func showSuccessMessage(_ message: String) {
        SnackBar().alert(withMessage: message, isSuccess: true, parent: self.view)
    }
    
    private func showError(_ message: String) {
        SnackBar().alert(withMessage: message, isSuccess: false, parent: self.view)
    }
    
    @IBAction func deleteTeamButtonTap(_ sender: Any) {
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete this team?", preferredStyle: .actionSheet)
        
        let removeAction = UIAlertAction(title: "Delete Team", style: .destructive) { _ in
            self.deleteTeam()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteTeam() {
        LoadingViewController.present(from: self)
        guard let teamId = partnerTeam?.id else {
            return
        }
        
        apiProvider.request(.deleteBuyingTeam(teamId: teamId)) { result in
            self.handleDeleteTeamResponse(result)
            LoadingViewController.dismiss(from: self)
        }
    }
    
    private func handleDeleteTeamResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            handleDeleteSuccessResponse(response)
        case .failure(let error):
            showError(error.localizedDescription)
        }
    }
    
    private func handleDeleteSuccessResponse(_ response: Response) {
        do {
            let deleteTeamResponse = try response.map(DeleteTeamResponse.self)
            if deleteTeamResponse.statusCode == 200 {
                self.showSuccessMessage(deleteTeamResponse.message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.goToMainTab()
                }
            } else {
                showError(deleteTeamResponse.message)
            }
        } catch {
            handleMappingError(response)
        }
    }
    
    func goToMainTab() {
        let storyboard = UIStoryboard(name: "MainTabStoryboard", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MainTabViewController") as? MainTabViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
            vc.selectedIndex = 3
            vc.reloadSelectedTab()
        }
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
            return partnerTeam?.members.count ?? 0
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
            let member = partnerTeam?.members[indexPath.row]
            cell.memberName.text = "\(member?.user.firstName ?? "") \(member?.user.lastName ?? "")"
            
            let word = member?.user.firstName?.prefix(1).uppercased()
            if let firstLetter = word?.first {
                cell.initialLabel.text = String(firstLetter).uppercased()
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
                        vc.partnerTeam = self.partnerTeam
                        vc.title = "Edit Shipment Frequency"
                        self.present(vc, animated: true)
                    }
                }else if indexPath.row == 1 {
                    if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseDeliveryDayViewController") as? ChooseDeliveryDayViewController {
                        vc.modalPresentationStyle = .custom
                        vc.isFromEdit = true
                        vc.partnerTeam = self.partnerTeam
                        vc.title = "Adjust Delivery Day"
                        self.present(vc, animated: true)
                    }
                }else{
                    if let vc = storyboard.instantiateViewController(withIdentifier: "CreateALimitViewController") as? CreateALimitViewController {
                        vc.modalPresentationStyle = .custom
                        vc.isFromEdit = true
                        vc.partnerTeam = self.partnerTeam
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
                if let member = self.partnerTeam?.members[indexPath.row] {
                    self.deleteMember(member)
                }
                
               
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
