//
//  ManageEmployeeViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/26/24.
//

import UIKit
import Moya

class ManageEmployeeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var emptyStateContainer: UIView!
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    private let userDataManager = UserDataManager()
    var employees = [Employee]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.emptyStateContainer.isHidden = true
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getEmployees()
    }
    
    @IBAction func addEmployeeButtonTap(_ sender: Any) {
        
        
        let storyboard = UIStoryboard(name: "ManageEmployeeView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ManageEmployeeAddEmployeeViewController") as? ManageEmployeeAddEmployeeViewController {
            vc.modalPresentationStyle = .automatic
            vc.isModalInPresentation = true
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func getEmployees() {
       self.showLoadingIndicator()
        let id = userDataManager.getUserData()?.id ?? ""
        apiProvider.request(.getEmployees(storeId: id)) { result in
            self.dismissLoadingIndicator()
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
            let employeesResponse = try response.map(GetEmployeesResponse.self)
            if employeesResponse.statusCode == 200 {
                //MARK: Update table and reload
                self.updateEmployees(employeesResponse.data)
            } else {
                self.showError(employeesResponse.message)
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
    
    private func updateEmployees(_ employees: [Employee]) {
        self.employees = employees
        if employees.count > 0 {
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
    }
    
}

extension ManageEmployeeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeTableViewCell", for: indexPath) as? EmployeeTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let removeAction = UIAlertAction(title: "Remove Employee", style: .destructive) { _ in
            // remove employee here then reload table view
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
