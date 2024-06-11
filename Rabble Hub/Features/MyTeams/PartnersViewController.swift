//
//  PartnersViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/19/24.
//

import UIKit
import Moya

class PartnersViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var partnerTableview: UITableView!
    @IBOutlet var emptyStateContainer: UIView!
    
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    private let userDataManager = UserDataManager()
    private var partnerTeams = [PartnerTeam]()
    private var filteredpartnerTeams = [PartnerTeam]()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        partnerTableview.delegate = self
        partnerTableview.dataSource = self
        searchBar.delegate = self
        fetchPartnerTeams()
        
        emptyStateContainer.isHidden = true
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
    }

    @IBAction func setupNewBuyingTeamButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ProducersListView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ProducersListViewController") as? ProducersListViewController {
            vc.modalPresentationStyle = .formSheet
            self.present(vc, animated: true)
        }
    }
    
    
    private func fetchPartnerTeams() {
        LoadingViewController.present(from: self)
        let id = userDataManager.getUserData()?.id ?? ""
        apiProvider.request(.getPartnerTeams(storeId: id)) { result in
            LoadingViewController.dismiss(from: self)
            self.handleSuppliersResponse(result)
        }
    }
    
    private func handleSuppliersResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            print(response)
            self.handleSuccessResponse(response)
        case .failure(let error):
            self.showError(error.localizedDescription)
        }
    }
    
    private func handleSuccessResponse(_ response: Response) {
        do {
            let partnerTeamsResponse = try response.map(GetPartnerTeamsResponse.self)
            if partnerTeamsResponse.statusCode == 200 {
                self.updatePartnerTeams(partnerTeamsResponse.data)
            } else {
                self.showError(partnerTeamsResponse.message)
            }
        } catch {
            self.handleMappingError(response)
        }
    }
    
    private func handleMappingError(_ response: Response) {
        do {
            let errorResponse = try response.map(StandardResponse.self)
            self.showError(errorResponse.message)
        } catch {
            print("Failed to map response data: \(error)")
        }
    }
    
    private func showError(_ message: String) {
        SnackBar().alert(withMessage: message, isSuccess: false, parent: self.view)
    }
    
    private func updatePartnerTeams(_ partnerTeams: [PartnerTeam]) {
        self.partnerTeams = partnerTeams
        self.filteredpartnerTeams = partnerTeams
        
        if partnerTeams.count > 0 {
            self.emptyStateContainer.isHidden = true
            self.partnerTableview.isHidden = false
            self.partnerTableview.reloadData()
        }else{
            self.showEmptyState()
        }
    }
    
    private func showEmptyState() {
        self.partnerTableview.isHidden = true
        self.emptyStateContainer.isHidden = false
    }
}

extension PartnersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredpartnerTeams.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PartnerTableViewCell", for: indexPath) as? PartnerTableViewCell else {
            return UITableViewCell()
        }
        
        let team = self.filteredpartnerTeams[indexPath.row]
        cell.configure(with: team)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "MyTeamsView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "PartnerDetailsViewController") as? PartnerDetailsViewController {
            vc.partnerTeam = self.filteredpartnerTeams[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}


// MARK: - ProducersListTableViewCell Extension
extension PartnerTableViewCell {
    func configure(with team: PartnerTeam) {
        if let imageUrl = URL(string: team.imageUrl) {
            img?.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
        supplierName.text = team.name
        membersCount.text = "\(team.members.count) members"
        partnerCategory.text = team.producer.categories.first?.category.name
        deliveryDetailsLabel.text = team.nextDeliveryDate
        titleLabel.text = "\(team.name) @ \(team.producer.businessName)"
        
        //TODO: frequencyLabel
        
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateString = team.nextDeliveryDate

        if let deliveryDate = isoDateFormatter.date(from: dateString) {
            let currentDate = Date()
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.day], from: currentDate, to: deliveryDate)
            
            if let daysUntilDelivery = dateComponents.day {
                deliveryDetailsLabel.text = "Next delivery day is in \(daysUntilDelivery) days"
            } else {
                print("Failed to calculate the number of days")
            }
        } else {
            print("Failed to parse date")
        }
        
        
    }
}


// MARK: - UISearchBarDelegate
extension PartnersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredpartnerTeams = searchText.isEmpty ? partnerTeams : partnerTeams.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
        partnerTableview.reloadData()
    }
}
