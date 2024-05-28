//
//  ProfileScheduleTableViewCell.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/27/24.
//

import UIKit


class ProfileScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var dayContentView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var daySwitch: UISwitch!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeButton: UIButton!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var dayLabelLeftConstraint: NSLayoutConstraint!
    var currentMode:CellMode = .monFri
    var currentIndex:CellIndexDay = .mon
    
    var resetExpandedProperties: (() -> ())?
    var customObjectUpdated: ((CustomOpenHour) -> ())?
    var customObject: CustomOpenHour?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.startTimeButton.layer.cornerRadius = 6.0
        self.endTimeButton.layer.cornerRadius = 6.0
        self.dayContentView.layer.cornerRadius = 8.0
        self.dayButton.setTitle("", for: .normal)
        self.startTimeButton.setTitle("", for: .normal)
        self.endTimeButton.setTitle("", for: .normal)
    }
    
    func configureCell(mode: CellMode, object: CustomOpenHour) {
        customObject = object
        
        if mode == .monFri {
            dayLabelLeftConstraint.constant = 16
            daySwitch.isHidden = true
        }
        else if mode == .custom {
            dayLabelLeftConstraint.constant = 73
            daySwitch.isHidden = false
            daySwitch.isOn = object.enabled
        }
    
        startTimeLabel.isEnabled = false
        endTimeLabel.isEnabled = false
        
        if object.startTimeExpanded {
            setTimePickerTime(from: object.startTime, animated: false)
            startTimeLabel.isEnabled = true
        }
        else if object.endTimeExpanded {
            setTimePickerTime(from: object.endTime, animated: false)
            endTimeLabel.isEnabled = true
        }
        
        self.dayLabel.text = object.scheduleDay.rawValue
    
        timePicker.isEnabled = object.enabled
        startTimeButton.isEnabled = object.enabled
        endTimeButton.isEnabled = object.enabled
        
        refreshTimeLabels()
        refreshButtons()
    }
    
    func refreshButtons() {
        if let isWholeDay = customObject?.open24Hours, isWholeDay {
            if let image = UIImage(systemName: "checkmark.circle.fill") {
                dayButton.setImage(image, for: .normal)
            }
            
            self.startTimeButton.isEnabled = false
            self.endTimeButton.isEnabled = false
        }
        else {
            if let image = UIImage(named: "icon_circle_unselected") {
                dayButton.setImage(image, for: .normal)
            }
            
            if let isEnabled = customObject?.enabled {
                self.startTimeButton.isEnabled = isEnabled
                self.endTimeButton.isEnabled = isEnabled
                self.dayButton.isEnabled = isEnabled
            }
        }
    }
    
    func refreshTimeLabels() {
        self.startTimeLabel.text = customObject?.startTime
        self.endTimeLabel.text = customObject?.endTime
    }
    
    @IBAction func daySwitchTap(_ sender: Any) {
        if daySwitch.isOn {
            customObject?.startTimeExpanded = false
            customObject?.endTimeExpanded = false
        }
    
        customObject?.enabled = daySwitch.isOn
        customObjectUpdated?(customObject!)
    }
    
    @IBAction func dayButtonTap(_ sender: Any) {
        if let isWholeDay = customObject?.open24Hours, isWholeDay {
            customObject?.open24Hours = false
        }
        else {
            customObject?.open24Hours = true
            customObject?.startTime = "9:00 AM"
            customObject?.endTime = "8:59 AM"
            
            customObject?.startTimeExpanded = false
            customObject?.endTimeExpanded = false
        }
        
        refreshTimeLabels()
        refreshButtons()
        customObjectUpdated?(customObject!)
    }
    
    @IBAction func startTimeButtonTap(_ sender: Any) {
        // toggle time picker view
        if let expanded = customObject?.startTimeExpanded, expanded {
            resetExpandedProperties?()
            customObject?.startTimeExpanded = false
        }
        else {
            resetExpandedProperties?()
            customObject?.startTimeExpanded = true
        }
        
        customObject?.endTimeExpanded = false
        self.customObjectUpdated?(self.customObject!)
    }
    
    @IBAction func endTimeButtonTap(_ sender: Any) {
        // toggle time picker view
        if let expanded = customObject?.endTimeExpanded, expanded {
            resetExpandedProperties?()
            customObject?.endTimeExpanded = false
        }
        else {
            resetExpandedProperties?()
            customObject?.endTimeExpanded = true
        }

        customObject?.startTimeExpanded = false
        self.customObjectUpdated?(self.customObject!)
    }
    
    @IBAction func timePickerChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // 12-hour format with AM/PM
        let timeString = dateFormatter.string(from: timePicker.date)
        
        if let expanded = customObject?.startTimeExpanded, expanded {
            customObject?.startTime = timeString
        }
        else {
            customObject?.endTime = timeString
        }
        
        self.customObjectUpdated?(self.customObject!)
    }
    
    func setTimePickerTime(from timeString: String, animated: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // 12-hour format with AM/PM
        
        if let time = dateFormatter.date(from: timeString) {
            timePicker.setDate(time, animated: animated)
        } else {
            print("Invalid time string format")
        }
    }
}
