//
//  SignUpScheduleTableViewCell.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/17/24.
//

import UIKit

class SignUpScheduleTableViewCell: UITableViewCell {

    enum CellMode {
      case monFri, custom
    }
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var daySwitch: UISwitch!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var endTimeButton: UIButton!
    
    @IBOutlet weak var dayLabelLeftConstraint: NSLayoutConstraint!
    var currentMode:CellMode = .monFri
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        if currentMode == .monFri {
//            dayLabelLeftConstraint.constant = 16
//            daySwitch.isHidden = true
//        }
//        else if currentMode == .custom {
//            dayLabelLeftConstraint.constant = 73
//            daySwitch.isHidden = false
//        }
    }
    
    func configureCell(mode: CellMode) {
//        self.currentMode = mode
        
        if mode == .monFri {
            dayLabelLeftConstraint.constant = 16
            daySwitch.isHidden = true
        }
        else if mode == .custom {
            dayLabelLeftConstraint.constant = 73
            daySwitch.isHidden = false
        }
    }
    
    @IBAction func daySwitchTap(_ sender: Any) {
        
    }
    
    @IBAction func dayButtonTap(_ sender: Any) {
        
    }
    
    @IBAction func startTimeButtonTap(_ sender: Any) {
        
    }
    
    @IBAction func endTimeButtonTap(_ sender: Any) {
        
    }
}
