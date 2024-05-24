//
//  LoadingViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/24/24.
//

import Foundation
import UIKit

class LoadingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the loading screen
        
        // Background view
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        view.addSubview(backgroundView)
        
        // Container view for the spinner
        let containerView = UIView()
        containerView.frame = CGRect(x: (view.frame.width - 100) / 2, y: (view.frame.height - 98) / 2, width: 100, height: 98)
//        containerView.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.7)
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        view.addSubview(containerView)
        
        // Activity indicator (spinner)
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = CGPoint(x: containerView.frame.width / 2, y: containerView.frame.height / 2)
        containerView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    // Static function to present the loading view controller
    static func present(from viewController: UIViewController) {
        let loadingVC = LoadingViewController()
        loadingVC.modalPresentationStyle = .overFullScreen
        viewController.present(loadingVC, animated: false, completion: nil)
    }
    
    // Static function to dismiss the loading view controller
     static func dismiss(from viewController: UIViewController) {
         viewController.dismiss(animated: false, completion: nil)
     }
}
