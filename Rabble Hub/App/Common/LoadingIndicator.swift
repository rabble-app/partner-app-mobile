//
//  LoadingIndicator.swift
//  Rabble Hub
//
//  Created by aljon antiola on 6/18/24.
//

import Foundation
import UIKit

class LoadingIndicator {
    static let shared = LoadingIndicator()
    
    private init() {}
    
    private var spinnerView: UIView?
    
    func show(in viewController: UIViewController) {
        guard spinnerView == nil else { return }
        
        let spinnerView = UIView(frame: viewController.view.bounds)
        spinnerView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = spinnerView.center
        activityIndicator.startAnimating()
        
        spinnerView.addSubview(activityIndicator)
        viewController.view.addSubview(spinnerView)
        
        self.spinnerView = spinnerView
    }
    
    func dismiss() {
        spinnerView?.removeFromSuperview()
        spinnerView = nil
    }
}

extension UIViewController {
    func showLoadingIndicator() {
        LoadingIndicator.shared.show(in: self)
    }
    
    func dismissLoadingIndicator() {
        LoadingIndicator.shared.dismiss()
    }
}
