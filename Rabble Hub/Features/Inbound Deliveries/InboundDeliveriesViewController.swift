//
//  InboundDeliveriesViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/18/24.
//

import UIKit
import Moya

class InboundDeliveriesViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var segmentedController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    private let userDataManager = UserDataManager()
    
    var period = "today"
    var searchStr = ""
    
    var inboundDeliveryData = [InboundDelivery]()
    
    @IBOutlet var emptyStateDesc: UILabel!
    @IBOutlet var emptyStateTitle: UILabel!
    @IBOutlet var emptyStateContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        searchBar.delegate = self
        
        segmentedController.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchInboundDelivery()
    }
    
    private func loadEmptyState() {
        if period == "today" {
            emptyStateTitle.text = "No Deliveries Today"
            emptyStateDesc.text = "You have no inbound deliveries scheduled for today."
        }else if period == "upcoming" {
            emptyStateTitle.text = "No Upcoming Deliveries"
            emptyStateDesc.text = "You have no inbound deliveries scheduled in the near future."
        }else{
            emptyStateTitle.text = "No Past Deliveries"
            emptyStateDesc.text = "You have no past inbound deliveries."
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            period = "today"
        case 1:
            period = "upcoming"
        case 2:
            period = "completed"
        default:
            period = "today"
        }
        fetchInboundDelivery()
    }
    
    
    func fetchInboundDelivery() {
        guard let userData = userDataManager.getUserData() else { 
            showError("Invalid user data")
            return }
        
        // Use Partner ID if user is Partner
        var id = userDataManager.getUserData()?.partner?.id

        // User Employee partner ID if user is Employee
        if userDataManager.isUserEmployee() {
            id = userData.employees?.first?.partner.id
        }

        if let storeId = id {
            self.showLoadingIndicator()
            apiProvider.request(.getInboundDelivery(storeId: storeId, offset: 0, period: period, search: searchStr)) { result in
                self.dismissLoadingIndicator()
                self.handleInboundDeliveryResponse(result)
            }
        } else {
            // Handle the case where both ids are nil, if necessary
            showError("Invalid user")
        }
    }
    
    private func handleInboundDeliveryResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                            print("Raw JSON response: \(jsonString)")
                        }
            self.handleSuccessResponse(response)
        case .failure(let error):
            self.showError(error.localizedDescription)
        }
    }
    
    private func handleSuccessResponse(_ response: Response) {
        do {
            let inboundDeliveryResponse = try response.map(InboundDeliveryResponse.self)
            if inboundDeliveryResponse.statusCode == 200 {
                self.updateInboundDelivery(inboundDeliveryResponse.data)
            } else {
                self.showError(inboundDeliveryResponse.message)
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
        showEmptyState()
        SnackBar().alert(withMessage: message, isSuccess: false, parent: self.view)
    }
    
    private func updateInboundDelivery(_ inboundDelivery: [InboundDelivery]) {
        if inboundDelivery.count > 0 {
            self.inboundDeliveryData = inboundDelivery
            self.emptyStateContainer.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }else{
            self.showEmptyState()
        }
    }
    
    private func showEmptyState() {
        self.tableView.isHidden = true
        self.emptyStateContainer.isHidden = false
        loadEmptyState()
    }

}

extension InboundDeliveriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inboundDeliveryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InboundDeliveriesTableViewCell", for: indexPath) as? InboundDeliveriesTableViewCell else {
            return UITableViewCell()
        }
        
        if segmentedController.selectedSegmentIndex == 0 {
            cell.calendarImg.tintColor = Colors.Today
            cell.dateValue.textColor = Colors.Today
        } else if segmentedController.selectedSegmentIndex == 1 {
            cell.calendarImg.tintColor = Colors.Upcoming
            cell.dateValue.textColor =  Colors.Upcoming
        } else {
            cell.calendarImg.tintColor = Colors.Past
            cell.dateValue.textColor = Colors.Past
        }
        
        let inboundDelivery = self.inboundDeliveryData[indexPath.row]
        cell.producerName.text = inboundDelivery.team.producer.businessName
        cell.teamName.text = inboundDelivery.team.name
        cell.itemsCount.text = "\(inboundDelivery.count.basket) items"
        
        let word = inboundDelivery.team.producer.businessName.prefix(1).uppercased()
        if let firstLetter = word.first {
            cell.initialLetter.text = String(firstLetter).uppercased()
        }
        
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let dateString = inboundDelivery.deliveryDate
        if let date = isoDateFormatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM"
            let formattedDate = dateFormatter.string(from: date)
            cell.date.text = formattedDate
        } else {
            print("Failed to parse date")
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "InboundDeliveriesView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "DeliveryDetailsViewController") as? DeliveryDetailsViewController {
            vc.modalPresentationStyle = .overFullScreen
            vc.hidesBottomBarWhenPushed = true
            vc.deliveryNavigationController = self.navigationController
            vc.inboundDeliveryDetail = self.inboundDeliveryData[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = Colors.BackgroundPrimary
        
        let label = UILabel(frame: CGRect(x: 0, y: 8, width: tableView.frame.width - 32, height: 24))
        label.font = UIFont(name: "SFPro-Regular", size: 12) // SF Pro Regular
        label.textColor = Colors.graySectionHeader
        
        switch segmentedController.selectedSegmentIndex {
        case 0:
            label.text = "DELIVERIES TODAY"
        case 1:
            label.text = "UPCOMING DELIVERIES"
        case 2:
            label.text = "COMPLETED DELIVERIES"
        default:
            label.text = "DELIVERIES TODAY"
        }

        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 77
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return 40
    }
    
}


extension InboundDeliveriesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchStr = searchText
        if searchText.count >= 3 {
            fetchInboundDelivery()
        }else{
            searchStr = ""
            fetchInboundDelivery()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        fetchInboundDelivery()
    }
}
