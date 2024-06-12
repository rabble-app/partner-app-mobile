//
//  ProducersListViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit
import SDWebImage
import Moya

class ProducersListViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var producersTableview: UITableView!
    
    private var suppliers = [Supplier]()
    private var filteredSuppliers = [Supplier]()
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    private let userDataManager = UserDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchSuppliers()
    }
    
    private func setupView() {
        view.backgroundColor = Colors.BackgroundPrimary
        producersTableview.delegate = self
        producersTableview.dataSource = self
        searchBar.delegate = self
    }
    
    private func fetchSuppliers() {
       // guard let postalCode = userDataManager.getUserData()?.postalCode else { return }

       // LoadingViewController.present(from: self)
        var postalId: String? = userDataManager.getUserData()?.postalCode

        apiProvider.request(.getSuppliers(offset: 0, postalId: postalId ?? "")) { result in
            guard let presentingViewController = self.presentingViewController else {
                // Unable to get presenting view controller
                return
            }
            
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
            let suppliersResponse = try response.map(GetSuppliersResponse.self)
            if suppliersResponse.statusCode == 200 {
                self.updateSuppliers(suppliersResponse.data ?? [])
            } else {
                self.showError(suppliersResponse.message)
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
    
    private func updateSuppliers(_ newSuppliers: [Supplier]) {
        suppliers = newSuppliers
        filteredSuppliers = newSuppliers
        producersTableview.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ProducersListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSuppliers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 372
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProducersListTableViewCell", for: indexPath) as? ProducersListTableViewCell else {
            return UITableViewCell()
        }
        
        let supplier = filteredSuppliers[indexPath.row]
        cell.configure(with: supplier)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseFrequencyViewController") as? ChooseFrequencyViewController {
            vc.modalPresentationStyle = .custom
            let pushAnimator = PushAnimator()
            vc.transitioningDelegate = pushAnimator
            vc.selectedSupplier = filteredSuppliers[indexPath.row]
            title = "Team Settings"
            present(vc, animated: true)
        }
    }
}

// MARK: - UISearchBarDelegate
extension ProducersListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredSuppliers = searchText.isEmpty ? suppliers : suppliers.filter {
            $0.businessName.localizedCaseInsensitiveContains(searchText)
        }
        producersTableview.reloadData()
    }
}

// MARK: - ProducersListTableViewCell Extension
extension ProducersListTableViewCell {
    func configure(with supplier: Supplier) {
        producerName.text = supplier.businessName
        producerDesc.text = supplier.description
        producerType.text = supplier.categories.first?.category.name
        if let imageUrl = URL(string: supplier.imageUrl) {
            producerImage?.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
    }
}
