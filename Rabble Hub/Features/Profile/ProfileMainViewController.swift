//
//  ProfileMainViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/22/24.
//

import UIKit

class ProfileMainViewController: UIViewController {

    @IBOutlet var email: UILabel!
    @IBOutlet var storeName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let viewModel = ProfileMainViewModel()
    private let userDataManager = UserDataManager()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.reloadData()
    }
    
    func navigateToLoginScreen() {

        let storyboard = UIStoryboard(name: "OnboardingView", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OnboardingNavigationController") as? UINavigationController {
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                window.rootViewController = vc
                UIView.transition(with: window, duration: 0.1, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        }
    }
}

extension ProfileMainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMenu = self.viewModel.menus[indexPath.row]
        var vc: UIViewController?
        
        if let controllerName = selectedMenu.controllerName {
            if controllerName == "ProfileOwnerViewController" {
                let profileView = UIStoryboard(name: "ProfileView", bundle: nil)
                vc = profileView.instantiateViewController(withIdentifier: "ProfileOwnerViewController") as! ProfileOwnerViewController
            }
            else if controllerName == "ProfilePartnerDetailsViewController" {
                let profileView = UIStoryboard(name: "ProfileView", bundle: nil)
                vc = profileView.instantiateViewController(withIdentifier: "ProfilePartnerDetailsViewController") as! ProfilePartnerDetailsViewController
            }
            else if controllerName == "ProfileOpenHoursViewController" {
                let profileView = UIStoryboard(name: "ProfileView", bundle: nil)
                vc = profileView.instantiateViewController(withIdentifier: "ProfileOpenHoursViewController") as! ProfileOpenHoursViewController
            }
            else if controllerName == "ManageEmployeeViewController" {
                let profileView = UIStoryboard(name: "ManageEmployeeView", bundle: nil)
                vc = profileView.instantiateViewController(withIdentifier: "ManageEmployeeViewController") as! ManageEmployeeViewController
            }
            
            if let menuVC = vc {
                menuVC.modalPresentationStyle = .automatic
                menuVC.isModalInPresentation = true
                present(menuVC, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.menus.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.getCellHeightForMode(mode: self.viewModel.menus[indexPath.row].mode ?? .infoUI)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.viewModel.getCellForMode(mode: self.viewModel.menus[indexPath.row].mode ?? .infoUI, tableView: tableView, indexPath: indexPath)
        if let cell = cell as? ProfileButtonTableViewCell {
            cell.buttonTapped = {
                self.userDataManager.logoutUser()
                DispatchQueue.main.async {
                    self.navigateToLoginScreen()
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let mode = self.viewModel.menus[indexPath.row].mode else {
            return
        }
        
        switch mode {
        case .headerUI:
            if let cell = cell as? ProfileStoreInfoTableViewCell {
                cell.titleLabel.text = userDataManager.getUserData()?.partner?.name
                cell.subtitleLabel.text = userDataManager.getUserData()?.email
            }
            break
        case .sectionUI:
            if let cell = cell as? ProfileSectionHeaderTableViewCell {
                cell.configureCell(menu: self.viewModel.menus[indexPath.row])
            }
            
            break
        case .textUI:
            if let cell = cell as? ProfileMenuTableViewCell {
                cell.configureCell(menu: self.viewModel.menus[indexPath.row])
                if indexPath.row == 1 {
                    cell.subtitleLabel.text = "\(userDataManager.getUserData()?.firstName ?? "") \(userDataManager.getUserData()?.lastName ?? "")"
                }else if indexPath.row == 2 {
                    cell.subtitleLabel.text = "\(userDataManager.getUserData()?.postalCode ?? "")"
                }else if indexPath.row == 3 {
                    //Open hours
                    cell.subtitleLabel.text = "\(userDataManager.getUserData()?.postalCode ?? "")"
                }
            }
            break
        case .switchUI, .infoUI:
            if let cell = cell as? ProfileMenuTableViewCell {
                cell.configureCell(menu: self.viewModel.menus[indexPath.row])
            }
            
            break
            
        case .buttonUI:
            break
        }
    }
}
