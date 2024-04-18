//
//  SignUpStepIndicatorViewController.swift
//  Rabble Partner
//
//  Created by aljon antiola on 4/15/24.
//

import UIKit

class SignUpStepIndicatorViewController: UIViewController {
    
    @IBOutlet weak var step1LineView: UIView!
    @IBOutlet weak var step2LineView: UIView!
    @IBOutlet weak var step3LineView: UIView!
    
    @IBOutlet weak var step1ImageView: UIImageView!
    @IBOutlet weak var step2ImageView: UIImageView!
    @IBOutlet weak var step3ImageView: UIImageView!
    @IBOutlet weak var step4ImageView: UIImageView!
    
    var currentStep = Step.one
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setCurrentStep(currentStep: currentStep)
    }
    
    func setCurrentStep(currentStep: Step) {
        step1LineView.backgroundColor = .gray4
        step2LineView.backgroundColor = .gray4
        step3LineView.backgroundColor = .gray4
        
        step1ImageView.tintColor = .gray4
        step2ImageView.tintColor = .gray4
        step3ImageView.tintColor = .gray4
        step4ImageView.tintColor = .gray4
        
        switch currentStep {
        case .one:
            step1ImageView.tintColor = .stepTintBlue
            break
        case .two:
            step1LineView.backgroundColor = .orange1
            step1ImageView.tintColor = .stepTintBlue
            step2ImageView.tintColor = .stepTintBlue
            break
        case .three:
            step1LineView.backgroundColor = .orange1
            step2LineView.backgroundColor = .orange1
            step1ImageView.tintColor = .stepTintBlue
            step2ImageView.tintColor = .stepTintBlue
            step3ImageView.tintColor = .stepTintBlue
            break
        case .four:
            step1LineView.backgroundColor = .orange1
            step2LineView.backgroundColor = .orange1
            step3LineView.backgroundColor = .orange1
            step1ImageView.tintColor = .stepTintBlue
            step2ImageView.tintColor = .stepTintBlue
            step3ImageView.tintColor = .stepTintBlue
            step4ImageView.tintColor = .stepTintBlue
            break
        }
    }
}
