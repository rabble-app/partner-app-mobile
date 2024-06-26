//
//  MainTabViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/19/24.
//

import UIKit

class MainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customerCollectionView = UIStoryboard(name: "CustomerCollectionView", bundle: nil)
        let inboundDeliveriesView = UIStoryboard(name: "InboundDeliveriesView", bundle: nil)
        let qrCodeView = UIStoryboard(name: "QrCodeView", bundle: nil)
        let myTeamsView = UIStoryboard(name: "MyTeamsView", bundle: nil)
        let profileView = UIStoryboard(name: "ProfileView", bundle: nil)
        
        
        guard let firstViewController = customerCollectionView.instantiateInitialViewController(),
              let secondViewController = inboundDeliveriesView.instantiateInitialViewController(),
              let thirdViewController = qrCodeView.instantiateInitialViewController(),
              let fourthViewController = myTeamsView.instantiateInitialViewController(),
              let fifthViewController = profileView.instantiateInitialViewController()else {
            fatalError("Failed to instantiate view controllers from storyboard references")
        }
        
        // Set up the view controllers for the tab bar controller
        viewControllers = [firstViewController, secondViewController, thirdViewController, fourthViewController, fifthViewController]
        
        // Configure tab bar item properties
        firstViewController.tabBarItem =  UITabBarItem(title: "Collections", image: UIImage(named: "icon_tab_collections"), tag: 0)
        secondViewController.tabBarItem =  UITabBarItem(title: "Deliveries", image: UIImage(named: "icon_tab_deliveries"), tag: 1)
        thirdViewController.tabBarItem =  UITabBarItem(title: "Scan QR", image: UIImage(named: "icon_tab_scan_qr"), tag: 2)
        fourthViewController.tabBarItem =  UITabBarItem(title: "My Teams", image: UIImage(named: "icon_tab_my_teams"), tag: 3)
        fifthViewController.tabBarItem =  UITabBarItem(title: "Profile", image: UIImage(named: "icon_tab_profile"), tag: 4)
    }

    func reloadSelectedTab() {
        guard let selectedVC = self.selectedViewController else { return }
        
        // Remove the selected view controller
        var viewControllers = self.viewControllers
        viewControllers?.remove(at: self.selectedIndex)
        
        // Re-add the selected view controller
        viewControllers?.insert(selectedVC, at: self.selectedIndex)
        self.viewControllers = viewControllers
    }
}
