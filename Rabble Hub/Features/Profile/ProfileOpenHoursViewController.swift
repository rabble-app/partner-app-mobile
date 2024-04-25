//
//  ProfileOpenHoursViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/25/24.
//

import UIKit

class ProfileOpenHoursViewController: UIViewController {

    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var tableViewContainerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentContentViewConstraintHeight: NSLayoutConstraint!
    
    var currentSegmentIndex = 0
    var defaultHeight = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIScrollView.appearance().contentInsetAdjustmentBehavior = .always
        
        tableViewContainerView.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.defaultHeight = self.segmentContentViewConstraintHeight.constant;
    }

    @IBAction func segmentControlButtonTap(_ sender: Any) {
        self.currentSegmentIndex = (sender as AnyObject).selectedSegmentIndex
        
        // Open 24/7
        if (sender as AnyObject).selectedSegmentIndex == 0 {
            self.segmentContentViewConstraintHeight.constant = defaultHeight
            firstView.isHidden = false
            tableViewContainerView.isHidden = true
        }
        // Mon - Fri
        else if (sender as AnyObject).selectedSegmentIndex == 1 {
            self.segmentContentViewConstraintHeight.constant = 617
            firstView.isHidden = true
            tableViewContainerView.isHidden = false
        }
        // Custom
        else {
            self.segmentContentViewConstraintHeight.constant = 864
            firstView.isHidden = true
            tableViewContainerView.isHidden = false
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func open24HoursSwitchTap(_ sender: Any) {
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}


extension ProfileOpenHoursViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        
        let cell:SignUpScheduleTableViewCell = cell as! SignUpScheduleTableViewCell
            
        if self.currentSegmentIndex == 1 {
            cell.configureCell(mode: .monFri, index: getIndexDayFromInt(index: indexPath.row))
        }
        else if self.currentSegmentIndex == 2 {
            cell.configureCell(mode: .custom, index: getIndexDayFromInt(index: indexPath.row))
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 117
    }
    
    // Helper
    func getIndexDayFromInt(index: Int) -> CellIndexDay {
        switch index {
        case 0:
            return .mon
        case 1:
            return .tue
        case 2:
            return .wed
        case 3:
            return .thu
        case 4:
            return .fri
        case 5:
            return .sat
        case 6:
            return .sun
        default:
            return .mon
        }
    }
    
}
