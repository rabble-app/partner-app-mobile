//
//  CreateALimitViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit

class CreateALimitViewController: UIViewController {

    @IBOutlet var progressBar: UIView!
    @IBOutlet var selectOptionButton: UIButton!
    @IBOutlet var primaryDescLabel: UILabel!
    @IBOutlet var secondaryDescLabel: UILabel!
    @IBOutlet var reminderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    func setUpView() {
        let progressBarWidth = 3 * progressBar.frame.width / 3.0
        let completedProgressBarWidth = progressBarWidth
        let greenProgressBarFrame = CGRect(x: 0, y: 0, width: completedProgressBarWidth, height: progressBar.frame.height)
        
        let completedView = UIView(frame: greenProgressBarFrame)
        completedView.backgroundColor = Colors.ButtonPrimary
        
        progressBar.addSubview(completedView)
        
        selectOptionButton.layer.borderWidth = 1.0
        selectOptionButton.layer.borderColor = Colors.Gray5.cgColor
        selectOptionButton.layer.cornerRadius = 12.0
        selectOptionButton.clipsToBounds = true
        
    }
    
    
    @IBAction func backButtonTap(_ sender: Any) {
        if let presentingViewController = presentingViewController {
               let pushAnimator = PushAnimator()
               presentingViewController.transitioningDelegate = pushAnimator
           }
           presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectOptionButtonTap(_ sender: Any) {
        
    }
    @IBAction func nextButtonTap(_ sender: Any) {
        
    }

}
