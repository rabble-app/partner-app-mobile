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
    @IBOutlet weak var addEmployeeButton: PrimaryButton!
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    private let userDataManager = UserDataManager()
    var employees = [Employee]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(employeesAdded), name: NSNotification.Name("EmployeesAdded"), object: nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.getEmployees()
        self.emptyStateContainer.isHidden = true
        self.tableView.reloadData()
        setUpAccess()
    }
    
    func setUpAccess() {
        if userDataManager.isUserEmployee() {
            addEmployeeButton.isEnabled = false
            tableView.allowsSelection = false
        }
    }
    
    @objc func employeesAdded() {
            DispatchQueue.main.async {
                self.getEmployees()
            }
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
        NotificationCenter.default.post(name: NSNotification.Name("UserRecordUpdated"), object: nil)
        self.dismiss(animated: true)
    }
    
    private func getEmployees() {
       self.showLoadingIndicator()
        let storeId = userDataManager.getUserData()?.partner?.id ?? ""
        apiProvider.request(.getEmployees(storeId: storeId)) { result in
            self.dismissLoadingIndicator()
            self.handleEmployeesResponse(result)
        }
    }
    
    private func handleEmployeesResponse(_ result: Result<Response, MoyaError>) {
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
        
        if var userData = userDataManager.getUserData() {
            userData.employeeCount?.employee = self.employees.count
            userDataManager.saveUserData(userData)
        }
        
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
    
    private func deleteEmployee(_ employee: Employee) {
        self.showLoadingIndicator()
        let storeId = userDataManager.getUserData()?.partner?.id ?? ""
        apiProvider.request(.deleteEmployee(storeId: storeId, employeeId: employee.id)) { result in
            self.dismissLoadingIndicator()
            self.handleDeleteEmployeeResponse(result)
        }
    }
    

    private func handleDeleteEmployeeResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            handleSuccessDeleteResponse(response)
        case .failure(let error):
            showError(error.localizedDescription)
        }
    }
    
    private func handleSuccessDeleteResponse(_ response: Response) {
        do {
            let deleteMemberResponse = try response.map(DeleteEmployeeResponse.self)
            if deleteMemberResponse.statusCode == 200 {
                self.showSuccessMessage(deleteMemberResponse.message)
                self.getEmployees()
            } else {
                showError(deleteMemberResponse.message)
            }
        } catch {
            handleMappingError(response)
        }
    }
    
    func showSuccessMessage(_ message: String) {
        SnackBar().alert(withMessage: message, isSuccess: true, parent: self.view)
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
        let employee = self.employees[indexPath.row]
        cell.employeeNameLabel.text = "\(employee.user.firstName) \(employee.user.lastName)"
        cell.employeeNumberLabel.text = employee.user.phone
        
        let word = cell.employeeNameLabel.text?.prefix(1).uppercased()
        if let firstLetter = word?.first {
            cell.nameInitialLabel.text = String(firstLetter).uppercased()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let removeAction = UIAlertAction(title: "Remove Employee", style: .destructive) { _ in
            self.deleteEmployee(self.employees[indexPath.row])
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
