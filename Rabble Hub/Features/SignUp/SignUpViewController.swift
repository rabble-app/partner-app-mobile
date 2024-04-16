//
//  SignUpViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/15/24.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpStepIndicatorViewController {
            vc.currentStep = .one
        }
    }
}
