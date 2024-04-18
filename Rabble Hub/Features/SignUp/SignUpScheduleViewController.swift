//
//  SignUpScheduleViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/17/24.
//

import UIKit

class SignUpScheduleViewController: UIViewController {
    var defaultHeight = 0.0
    var currentSegmentIndex = 0
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentContentViewConstraintHeight: NSLayoutConstraint!
    
    @IBOutlet weak var segmentContentView: UIView!
    @IBOutlet weak var scheduleSegmentedControlButton: UISegmentedControl!
    
    @IBOutlet weak var segmentFirstView: UIView!
    @IBOutlet weak var segmentSecondView: UIView!
    
    @IBOutlet weak var tableViewContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.defaultHeight = self.segmentContentViewConstraintHeight.constant;
        UIScrollView.appearance().contentInsetAdjustmentBehavior = .always
        
        tableViewContainerView.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpStepIndicatorViewController {
            vc.currentStep = .three
        }
    }
    
    @IBAction func scheduleSegmentedControlTap(_ sender: Any) {
        
        self.currentSegmentIndex = (sender as AnyObject).selectedSegmentIndex
        
        // Open 24/7
        if (sender as AnyObject).selectedSegmentIndex == 0 {
            self.segmentContentViewConstraintHeight.constant = defaultHeight
            segmentFirstView.isHidden = false
            tableViewContainerView.isHidden = true
        }
        // Mon - Fri
        else if (sender as AnyObject).selectedSegmentIndex == 1 {
            self.segmentContentViewConstraintHeight.constant = 617
            segmentFirstView.isHidden = true
            tableViewContainerView.isHidden = false
        }
        // Custom
        else {
            self.segmentContentViewConstraintHeight.constant = 800
            segmentFirstView.isHidden = true
            tableViewContainerView.isHidden = false
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func previousStepButtonTap(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func nextButtonStep(_ sender: Any) {
        
    }
}

extension SignUpScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.currentSegmentIndex == 1 {
            return 5
        }
        else if self.currentSegmentIndex == 2 {
            return 7
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SignUpScheduleTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "SignUpScheduleCell") as! SignUpScheduleTableViewCell
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var cell:SignUpScheduleTableViewCell = cell as! SignUpScheduleTableViewCell
            
        if self.currentSegmentIndex == 1 {
            cell.configureCell(mode: .monFri)
        }
        else if self.currentSegmentIndex == 2 {
            cell.configureCell(mode: .custom)
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 117
    }
    
}
