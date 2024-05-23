//
//  ChooseDeliveryDayViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit

class ChooseDeliveryDayViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var progressBar: UIView!
    @IBOutlet var calendarContainer: UIView!
    
    @IBOutlet var stepContainer: UIView!
    @IBOutlet var stepContainer_height: NSLayoutConstraint!
    @IBOutlet var nextButton: UIButton!
    var isFromEdit: Bool = false
    var frequency = Int()
    var selectedSupplier: Supplier?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    func setUpView() {
        let progressBarWidth = 2 * progressBar.frame.width / 3.0
        let completedProgressBarWidth = progressBarWidth
        let greenProgressBarFrame = CGRect(x: 0, y: 0, width: completedProgressBarWidth, height: progressBar.frame.height)
        
        let completedView = UIView(frame: greenProgressBarFrame)
        completedView.backgroundColor = Colors.ButtonSecondary
        
        progressBar.addSubview(completedView)
        
        calendarContainer.layer.cornerRadius = 10
        calendarContainer.clipsToBounds = true
        
        if isFromEdit {
            nextButton.setTitle("Save Changes", for: .normal)
            self.titleLabel.text = "Adjust Delivery Day"
            self.stepContainer.isHidden = true
            self.stepContainer_height.constant = 0
        }
    }
    
    
    @IBAction func backButtonTap(_ sender: Any) {
        if let presentingViewController = presentingViewController {
               let pushAnimator = PushAnimator()
               presentingViewController.transitioningDelegate = pushAnimator
           }
           presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        if isFromEdit {
            dismiss(animated: true, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
            if let vc = storyboard.instantiateViewController(withIdentifier: "CreateALimitViewController") as? CreateALimitViewController {
                vc.modalPresentationStyle = .custom
                let pushAnimator = PushAnimator()
                vc.transitioningDelegate = pushAnimator
                vc.frequency = self.frequency
                vc.selectedSupplier = self.selectedSupplier
                self.title = "Team Settings"
                self.present(vc, animated: true)
            }
        }
    }
    
}
