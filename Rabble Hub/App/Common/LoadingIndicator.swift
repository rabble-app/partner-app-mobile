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
    
    func show() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        window.endEditing(true)
        
        guard spinnerView == nil else { return }
        
        let spinnerView = UIView(frame: window.bounds)
        spinnerView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = spinnerView.center
        activityIndicator.color = .white.withAlphaComponent(0.8)
        activityIndicator.startAnimating()
        
        spinnerView.addSubview(activityIndicator)
        window.addSubview(spinnerView)
        
        self.spinnerView = spinnerView
    }
    
    func dismiss() {
        spinnerView?.removeFromSuperview()
        spinnerView = nil
    }
}

extension UIViewController {
    func showLoadingIndicator() {
        DispatchQueue.main.async {
            LoadingIndicator.shared.show()
        }
    }
    
    func dismissLoadingIndicator() {
        DispatchQueue.main.async {
            LoadingIndicator.shared.dismiss()
        }
    }
}
