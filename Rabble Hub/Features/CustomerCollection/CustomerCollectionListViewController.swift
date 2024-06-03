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
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    var collectionData = [CollectionData]()
    
    var period = "today"
    var searchStr = ""
    
    private let userDataManager = UserDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionTableview.delegate = self
        collectionTableview.dataSource = self
        
        fetchCustomerCollections()
        segmentedBar.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
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
        let id = userDataManager.getUserData()?.partner?.id ?? ""
       // LoadingViewController.present(from: self)
        apiProvider.request(.getCustomerCollection(storeId: id, offset: 0, period: period, search: searchStr)) { result in
           // LoadingViewController.dismiss(from: self)
            self.handleSuppliersResponse(result)
            
        }
    }
    
    private func handleSuppliersResponse(_ result: Result<Response, MoyaError>) {
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
        SnackBar().alert(withMessage: message, isSuccess: false, parent: self.view)
    }
    
    private func updateCollectionData(_ collectionData: [CollectionData]) {
        self.collectionData = collectionData
        self.collectionTableview.reloadData()
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
        cell.usernameLabel.text = collection.user.firstName + " " + collection.user.lastName
        cell.teammateNameLabel.text = collection.order.team.name
        cell.itemsCountLabel.text = "\(collection.items.count) Items"
        
        let word = collection.user.firstName.prefix(1).uppercased()
        if let firstLetter = word.first {
            let firstLetterString = String(firstLetter).uppercased()
            cell.initialNameLabel.text = "\(firstLetter)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "CustomerCollectionView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OrderDetailsViewController") as? OrderDetailsViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}

