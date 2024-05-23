//
//  ChooseFrequencyViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit

class ChooseFrequencyViewController: UIViewController {
    
    @IBOutlet var titelLabel: UILabel!
    @IBOutlet var monthButton: UIButton!
    @IBOutlet var twoWeekButton: UIButton!
    @IBOutlet var weekButton: UIButton!
    @IBOutlet var progressBar: UIView!
    @IBOutlet var weekButtonContainer: UIView!
    @IBOutlet var twoWeekButtonContainer: UIView!
    @IBOutlet var monthButtonContainer: UIView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var stepContainer: UIView!
    @IBOutlet var stepContainer_height: NSLayoutConstraint!
    var isFromEdit: Bool = false
    
    var selectedFrequency: DeliveryFrequency?
    var selectedSupplier: Supplier?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: library for calendar https://github.com/patchthecode/JTAppleCalendar?tab=readme-ov-file
        setUpView()
    }
    
    func setUpView() {
        let progressBarWidth = progressBar.frame.width / 3.0
        let completedProgressBarWidth = progressBarWidth
        let greenProgressBarFrame = CGRect(x: 0, y: 0, width: completedProgressBarWidth, height: progressBar.frame.height)
        
        let completedView = UIView(frame: greenProgressBarFrame)
        completedView.backgroundColor = Colors.ButtonSecondary
        progressBar.addSubview(completedView)
        
        weekButton.showsTouchWhenHighlighted = false
        twoWeekButton.showsTouchWhenHighlighted = false
        monthButton.showsTouchWhenHighlighted = false
        
        if isFromEdit {
            nextButton.setTitle("Save Changes", for: .normal)
            self.titelLabel.text = "Edit Shipment Frequency"
            self.stepContainer.isHidden = true
            self.stepContainer_height.constant = 0
        }
        
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        guard let selectedFrequency = selectedFrequency else {
                   // Handle the case where no frequency is selected
                   print("No frequency selected")
                   return
               }
        
        let deliveryFrequencyInSeconds = selectedFrequency.seconds
        
        if isFromEdit {
            dismiss(animated: true, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseDeliveryDayViewController") as? ChooseDeliveryDayViewController {
                vc.modalPresentationStyle = .custom
                let pushAnimator = PushAnimator()
                vc.transitioningDelegate = pushAnimator
                vc.frequency = deliveryFrequencyInSeconds
                vc.selectedSupplier = selectedSupplier
                self.title = "Team Settings"
                self.present(vc, animated: true)
            }
        }
        
    }
    
    func updateButtonStates(selectedButton: UIButton) {
        // Deselect all buttons
        weekButton.isSelected = false
        twoWeekButton.isSelected = false
        monthButton.isSelected = false
        
        // Select the specified button
        selectedButton.isSelected = true
        
        // Update button images based on selection state
        updateButtonImages()
    }
    
    func updateButtonImages() {
        // Update button images based on selection state
        weekButton.setBackgroundImage(UIImage(named: weekButton.isSelected ? "selected_radioButton" : "unselected_radioButton"), for: .normal)
        twoWeekButton.setBackgroundImage(UIImage(named: twoWeekButton.isSelected ? "selected_radioButton" : "unselected_radioButton"), for: .normal)
        monthButton.setBackgroundImage(UIImage(named: monthButton.isSelected ? "selected_radioButton" : "unselected_radioButton"), for: .normal)
    }
    
    @IBAction func weekButtonTap(_ sender: Any) {
        selectedFrequency = .everyWeek
        updateButtonStates(selectedButton: weekButton)
    }
    
    @IBAction func twoWeekButtonTap(_ sender: Any) {
        selectedFrequency = .everyTwoWeeks
        updateButtonStates(selectedButton: twoWeekButton)
    }
    
    @IBAction func monthButtonTap(_ sender: Any) {
        selectedFrequency = .everyMonth
        updateButtonStates(selectedButton: monthButton)
    }
}


enum DeliveryFrequency: String {
    case everyWeek = "every week"
    case everyTwoWeeks = "every two weeks"
    case everyMonth = "every month"
    
    var seconds: Int {
        switch self {
        case .everyWeek:
            return 7 * 24 * 60 * 60 // 7 days in seconds
        case .everyTwoWeeks:
            return 14 * 24 * 60 * 60 // 14 days in seconds
        case .everyMonth:
            return 30 * 24 * 60 * 60 // 30 days in seconds
        }
    }
}
