//
//  CreateALimitViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit

class CreateALimitViewController: UIViewController {

    @IBOutlet var progressBar: UIView!
    
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
    }
    
    
    @IBAction func backButtonTap(_ sender: Any) {
        if let presentingViewController = presentingViewController {
               let pushAnimator = PushAnimator()
               presentingViewController.transitioningDelegate = pushAnimator
           }
           presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        
    }

}
