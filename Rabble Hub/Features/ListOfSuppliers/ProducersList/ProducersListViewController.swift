//
//  ProducersListViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit
import SDWebImage

class ProducersListViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var producersTableview: UITableView!
    
    var suppliers = [Supplier]()
    var filteredSuppliers = [Supplier]() // Array to hold filtered suppliers
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Colors.BackgroundPrimary
        
        producersTableview.delegate = self
        producersTableview.dataSource = self
        searchBar.delegate = self
        
        self.getSuppliers()
    }
    
    func getSuppliers() {
        apiprovider.request(.getSuppliers(baseURL: environment.baseURL)) { result in
            switch result {
            case let .success(response):
                // Handle successful response
                do {
                    let response = try response.map(GetSuppliersResponse.self)
                    if response.statusCode == 200 {
                        print("Suppliers: \(response.data)")
                        self.suppliers = response.data
                        self.filteredSuppliers = response.data // Initialize filteredSuppliers with all suppliers initially
                        self.producersTableview.reloadData()
                    } else {
                        print("Error Message: \(response.message)")
                    }
                } catch {
                    print("Failed to map response data: \(error)")
                }
            case let .failure(error):
                // Handle error
                print("Request failed with error: \(error)")
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ProducersListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSuppliers.count // Use filteredSuppliers for number of rows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 372
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProducersListTableViewCell", for: indexPath) as? ProducersListTableViewCell else {
            return UITableViewCell()
        }
        
        let supplier = self.filteredSuppliers[indexPath.row] // Use filteredSuppliers to populate cells
        cell.producerName.text = supplier.businessName
        cell.producerDesc.text = supplier.description
        cell.producerType.text = supplier.categories.first?.category.name
        
        if let imageUrl = URL(string: supplier.imageUrl) {
            cell.producerImage?.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
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

// MARK: - UISearchBarDelegate
extension ProducersListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // If search text is empty, show all suppliers
            filteredSuppliers = suppliers
        } else {
            // Filter suppliers based on business name containing the search text
            filteredSuppliers = suppliers.filter { $0.businessName.localizedCaseInsensitiveContains(searchText) }
        }
        producersTableview.reloadData() // Reload table view to reflect filtered data
    }
}
