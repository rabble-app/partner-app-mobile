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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Colors.BackgroundPrimary
        
        producersTableview.delegate = self
        producersTableview.dataSource = self
        
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
                               self.producersTableview.reloadData()
                           }else{
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

extension ProducersListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suppliers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 372
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProducersListTableViewCell", for: indexPath) as? ProducersListTableViewCell else {
            return UITableViewCell()
        }
        
        let supplier = self.suppliers[indexPath.row]
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
