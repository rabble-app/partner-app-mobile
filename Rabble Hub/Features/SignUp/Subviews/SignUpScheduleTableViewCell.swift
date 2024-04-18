//
//  SignUpScheduleTableViewCell.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/17/24.
//

import UIKit

class SignUpScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var dayContentView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var daySwitch: UISwitch!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var endTimeButton: UIButton!
    
    @IBOutlet weak var dayLabelLeftConstraint: NSLayoutConstraint!
    var currentMode:CellMode = .monFri
    var currentIndex:CellIndexDay = .mon
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.startTimeButton.layer.cornerRadius = 6.0
        self.endTimeButton.layer.cornerRadius = 6.0
        self.dayContentView.layer.cornerRadius = 8.0
        self.dayButton.setTitle("", for: .normal)
    }
    
    func configureCell(mode: CellMode, index: CellIndexDay) {
        self.currentMode = mode
        self.currentIndex = index
        
        if mode == .monFri {
            dayLabelLeftConstraint.constant = 16
            daySwitch.isHidden = true
        }
        else if mode == .custom {
            dayLabelLeftConstraint.constant = 73
            daySwitch.isHidden = false
        }
        
        self.dayLabel.text = index.rawValue
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
