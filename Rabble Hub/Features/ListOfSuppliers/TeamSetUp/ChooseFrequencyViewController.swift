//
//  ChooseFrequencyViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit

class ChooseFrequencyViewController: UIViewController {
    
    @IBOutlet var monthButton: UIButton!
    @IBOutlet var twoWeekButton: UIButton!
    @IBOutlet var weekButton: UIButton!
    @IBOutlet var progressBar: UIView!
    @IBOutlet var weekButtonContainer: UIView!
    @IBOutlet var twoWeekButtonContainer: UIView!
    @IBOutlet var monthButtonContainer: UIView!
    
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
        completedView.backgroundColor = Colors.ButtonPrimary
        progressBar.addSubview(completedView)
        
        weekButton.showsTouchWhenHighlighted = false
        twoWeekButton.showsTouchWhenHighlighted = false
        monthButton.showsTouchWhenHighlighted = false
        
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseDeliveryDayViewController") as? ChooseDeliveryDayViewController {
            vc.modalPresentationStyle = .custom
            let pushAnimator = PushAnimator()
            vc.transitioningDelegate = pushAnimator
            self.title = "Team Settings"
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func weekButtonTap(_ sender: Any) {
        // Deselect other buttons
        twoWeekButton.isSelected = false
        monthButton.isSelected = false
        
        // Toggle the button's selected state
        weekButton.isSelected = true
        
        // Update button images based on selection state
        updateButtonImages()
    }
    
    @IBAction func twoWeekButtonTap(_ sender: Any) {
        // Deselect other buttons
        weekButton.isSelected = false
        monthButton.isSelected = false
        
        // Toggle the button's selected state
        twoWeekButton.isSelected = true
        
        // Update button images based on selection state
        updateButtonImages()
    }
    
    @IBAction func monthButtonTap(_ sender: Any) {
        // Deselect other buttons
        weekButton.isSelected = false
        twoWeekButton.isSelected = false
        
        // Toggle the button's selected state
        monthButton.isSelected = true
        
        // Update button images based on selection state
        updateButtonImages()
    }
    
    func updateButtonImages() {
        // Update button images based on selection state
        weekButton.setBackgroundImage(UIImage(named: weekButton.isSelected ? "selected_radioButton" : "unselected_radioButton"), for: .normal)
        twoWeekButton.setBackgroundImage(UIImage(named: twoWeekButton.isSelected ? "selected_radioButton" : "unselected_radioButton"), for: .normal)
        monthButton.setBackgroundImage(UIImage(named: monthButton.isSelected ? "selected_radioButton" : "unselected_radioButton"), for: .normal)
    }
    
    
}
