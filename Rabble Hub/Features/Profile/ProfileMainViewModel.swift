//
//  ProfileMainViewModel.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/24/24.
//

import Foundation
import UIKit

class Menu {
    
    var titleName: String?
    var subtitleNameLabel: String?
    var mode: ProfileMenuCellMode?
    var iconImageName: String?
    var iconViewBgColor: UIColor?
    var separatorLine = false
    var controllerName: String?
    
    init(titleName: String? = nil, subtitleNameLabel: String? = nil, mode: ProfileMenuCellMode, iconImageName: String? = nil, iconViewBgColor: UIColor? = nil, separatorLine: Bool, controllerName: String? = nil) {
        self.titleName = titleName
        self.subtitleNameLabel = subtitleNameLabel
        self.mode = mode
        self.iconImageName = iconImageName
        self.iconViewBgColor = iconViewBgColor
        self.separatorLine = separatorLine
        self.controllerName = controllerName
    }
}

class ProfileMainViewModel {
    
    var menus = [Menu]()
    
    init() {
        // Section 1
        let storeName = Menu(titleName: "Store name", subtitleNameLabel: "email@email.com", mode: .headerUI, iconViewBgColor: .gray3, separatorLine: true)
        // Section: STORE PROFILE
        let sectionProfile = Menu(titleName: "STORE PROFILE", mode: .sectionUI, separatorLine: false)
        let ownerProfile = Menu(titleName: "Owner profile", subtitleNameLabel: "Maxwell Beard", mode: .textUI, iconImageName: "person.fill", iconViewBgColor: .iconBgBlue, separatorLine: true, controllerName: "ProfileOwnerViewController")
        let partnerDetails = Menu(titleName: "Partner details", subtitleNameLabel: "Postcode", mode: .textUI, iconImageName: "at", iconViewBgColor: .iconBgBlue, separatorLine: true, controllerName: "ProfilePartnerDetailsViewController")
        let openHours = Menu(titleName: "Open hours", subtitleNameLabel: "24/7", mode: .textUI, iconImageName: "phone.fill", iconViewBgColor: .iconBgBlue, separatorLine: false, controllerName: "ProfileOpenHoursViewController")
        // Section: MANAGE EMPLOYEES
        let sectionManageEmployees = Menu(titleName: "MANAGE EMPLOYEES", mode: .sectionUI, separatorLine: false)
        let employees = Menu(titleName: "Employees", subtitleNameLabel: "3", mode: .textUI, iconImageName: "person.2.fill", iconViewBgColor: .iconBgBlue, separatorLine: false)
        // Section: SYSTEM
        let sectionSystem = Menu(titleName: "SYSTEM", mode: .sectionUI, separatorLine: true)
        let darkMode = Menu(titleName: "Dark mode", mode: .switchUI, iconImageName: "moon.fill", iconViewBgColor: .iconBgPurple, separatorLine: true)
        let notifications = Menu(titleName: "Notifications", subtitleNameLabel: "Enabled", mode: .textUI, iconImageName: "bell.fill", iconViewBgColor: .iconBgRed, separatorLine: true)
        let help = Menu(titleName: "Help", mode: .infoUI, iconImageName: "info", iconViewBgColor: .iconBgBlue, separatorLine: false)
        let logout = Menu(titleName: "Log out", mode: .buttonUI, separatorLine: false)
        

        menus = [storeName, sectionProfile, ownerProfile, partnerDetails, openHours, sectionManageEmployees, employees, sectionSystem, darkMode, notifications, help, logout]
    }
    
    func getCellHeightForMode(mode: ProfileMenuCellMode) -> CGFloat {
        switch mode {
        case .headerUI:
            return 100.0
        case .buttonUI:
            return 90.0
        default:
            return 50.0
        }
    }
    
    func getCellForMode(mode: ProfileMenuCellMode, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch mode {
        case .headerUI:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileStoreInfoTableViewCell", for: indexPath) as? ProfileStoreInfoTableViewCell else {
                return UITableViewCell()
            }
            
            return cell
        case .textUI, .switchUI, .infoUI:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileMenuTableViewCell", for: indexPath) as? ProfileMenuTableViewCell else {
                return UITableViewCell()
            }
            
            return cell
            
        case .buttonUI:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileButtonTableViewCell", for: indexPath) as? ProfileButtonTableViewCell else {
                return UITableViewCell()
            }
            
            return cell
            
        case .sectionUI:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSectionHeaderTableViewCell", for: indexPath) as? ProfileSectionHeaderTableViewCell else {
                return UITableViewCell()
            }
            
            return cell
        }
    }
    
}
