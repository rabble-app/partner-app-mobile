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
    
    @IBOutlet weak var step1View: UIView!
    @IBOutlet weak var step2View: UIView!
    @IBOutlet weak var step3View: UIView!
    @IBOutlet weak var step4View: UIView!
    
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
        step1LineView.backgroundColor = .gray5
        step2LineView.backgroundColor = .gray5
        step3LineView.backgroundColor = .gray5
        
        step1View.backgroundColor = .gray5
        step2View.backgroundColor = .gray5
        step3View.backgroundColor = .gray5
        step4View.backgroundColor = .gray5
        
        step1ImageView.tintColor = .gray4
        step2ImageView.tintColor = .gray4
        step3ImageView.tintColor = .gray4
        step4ImageView.tintColor = .gray4
        
        switch currentStep {
        case .one:
            step1View.backgroundColor = .black
            step1ImageView.tintColor = .buttonPrimary
            break
        case .two:
            step1View.backgroundColor = .black
            step2View.backgroundColor = .black
            step1LineView.backgroundColor = .buttonPrimary
            step1ImageView.tintColor = .buttonPrimary
            step2ImageView.tintColor = .buttonPrimary
            break
        case .three:
            step1View.backgroundColor = .black
            step2View.backgroundColor = .black
            step3View.backgroundColor = .black
            step1LineView.backgroundColor = .buttonPrimary
            step2LineView.backgroundColor = .buttonPrimary
            step1ImageView.tintColor = .buttonPrimary
            step2ImageView.tintColor = .buttonPrimary
            step3ImageView.tintColor = .buttonPrimary
            break
        case .four:
            step1View.backgroundColor = .black
            step2View.backgroundColor = .black
            step3View.backgroundColor = .black
            step4View.backgroundColor = .black
            step1LineView.backgroundColor = .buttonPrimary
            step2LineView.backgroundColor = .buttonPrimary
            step3LineView.backgroundColor = .buttonPrimary
            step1ImageView.tintColor = .buttonPrimary
            step2ImageView.tintColor = .buttonPrimary
            step3ImageView.tintColor = .buttonPrimary
            step4ImageView.tintColor = .buttonPrimary
            break
        }
    }
}
