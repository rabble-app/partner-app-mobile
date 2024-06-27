//
//  CustomerCollectionListViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/18/24.
//

import UIKit
import Moya

class CustomerCollectionListViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var segmentedBar: UISegmentedControl!
    @IBOutlet var collectionTableview: UITableView!
    
    @IBOutlet var emptyStateDesc: UILabel!
    @IBOutlet var emptyStateTitle: UILabel!
    @IBOutlet var emptyStateContainer: UIView!
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    var collectionData = [CollectionData]()
  
    var period = "today"
    var searchStr = ""
    
    private let userDataManager = UserDataManager()
   // private let userRecordManager = UserRecordManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionTableview.delegate = self
        collectionTableview.dataSource = self
        searchBar.delegate = self
        
        emptyStateContainer.isHidden = true
        
        fetchCustomerCollections()
        segmentedBar.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    private func loadEmptyState() {
        if period == "today" {
            emptyStateTitle.text = "No Collections Today"
            emptyStateDesc.text = "You have no customer collections scheduled for today."
        }else if period == "upcoming" {
            emptyStateTitle.text = "No Upcoming Collections"
            emptyStateDesc.text = "You have no customer collections scheduled in the near future."
        }else{
            emptyStateTitle.text = "No Completed Collections"
            emptyStateDesc.text = "You have no completed customer collections."
        }
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            period = "today"
        case 1:
            period = "upcoming"
        case 2:
            period = "past"
        default:
            period = "today"
        }
        fetchCustomerCollections()
    }
    
    func fetchCustomerCollections() {
   
        let id: String? = userDataManager.getUserData()?.partner?.id

        if let storeId = id {
            self.showLoadingIndicator()
            apiProvider.request(.getCustomerCollection(storeId: storeId, offset: 0, period: period, search: searchStr)) { result in
                self.handlecustomerCollectionResponse(result)
                self.dismissLoadingIndicator()
            }
        } else {
            // Handle the case where both ids are nil, if necessary
            print("Error: No valid id found")
        }
    }
    
    private func handlecustomerCollectionResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            self.handleSuccessResponse(response)
        case .failure(let error):
            self.showError(error.localizedDescription)
        }
    }
    
    private func handleSuccessResponse(_ response: Response) {
        do {
            let collectionResponse = try response.map(CustomerCollectionResponse.self)
            if collectionResponse.statusCode == 200 {
                self.updateCollectionData(collectionResponse.data)
            } else {
                self.showError(collectionResponse.message)
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
        self.showEmptyState()
        SnackBar().alert(withMessage: message, isSuccess: false, parent: self.view)
    }
    
    private func updateCollectionData(_ collectionData: [CollectionData]) {
        self.collectionData = collectionData
        if collectionData.count > 0 {
            self.emptyStateContainer.isHidden = true
            self.collectionTableview.isHidden = false
            self.collectionTableview.reloadData()
        }else{
            self.showEmptyState()
        }
    }
    
    private func showEmptyState() {
        self.collectionTableview.isHidden = true
        self.emptyStateContainer.isHidden = false
        loadEmptyState()
    }
}

extension CustomerCollectionListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 77
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCollectionTableViewCell", for: indexPath) as? CustomerCollectionTableViewCell else {
            return UITableViewCell()
        }
        let collection = self.collectionData[indexPath.row]
        cell.usernameLabel.text = (collection.user.firstName) + " " + (collection.user.lastName)
        cell.teammateNameLabel.text = collection.order.team.name
        cell.itemsCountLabel.text = "\(collection.items.count) Items"
        
        let word = collection.user.firstName.prefix(1).uppercased()
        if let firstLetter = word.first {
            cell.initialNameLabel.text = String(firstLetter).uppercased()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "CustomerCollectionView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OrderDetailsViewController") as? OrderDetailsViewController {
            vc.modalPresentationStyle = .overFullScreen
            vc.selectedCollectionData = self.collectionData[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension CustomerCollectionListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchStr = searchText
        if searchText.count >= 3 {
            fetchCustomerCollections()
        }else{
            searchStr = ""
            fetchCustomerCollections()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        fetchCustomerCollections()
    }
}
