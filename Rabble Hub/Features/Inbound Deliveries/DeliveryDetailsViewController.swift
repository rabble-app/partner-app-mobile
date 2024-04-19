//
//  DeliveryDetailsViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/19/24.
//

import UIKit

class DeliveryDetailsViewController: UIViewController {

    @IBOutlet weak var iconBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        self.iconBackgroundView.layer.cornerRadius = 12.0
    }

    @IBAction func confirmButtonTap(_ sender: Any) {
        
    }
}
