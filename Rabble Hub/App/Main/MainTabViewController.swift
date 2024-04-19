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
        
        // Instantiate view controllers from different storyboards
        
        let customerCollectionView = UIStoryboard(name: "CustomerCollectionView", bundle: nil)
        let inboundDeliveriesView = UIStoryboard(name: "InboundDeliveriesView", bundle: nil)
        
        guard let firstViewController = customerCollectionView.instantiateInitialViewController(),
              let secondViewController = inboundDeliveriesView.instantiateInitialViewController() else {
            fatalError("Failed to instantiate view controllers from storyboard references")
        }
        
        // Set up the view controllers for the tab bar controller
        viewControllers = [firstViewController, secondViewController]
        
        // Configure tab bar item properties
        firstViewController.tabBarItem =  UITabBarItem(title: "Collections", image: UIImage(named: "icon_tab_collections"), tag: 0)
        secondViewController.tabBarItem =  UITabBarItem(title: "Deliveries", image: UIImage(named: "icon_tab_deliveries"), tag: 1)
    }

}
