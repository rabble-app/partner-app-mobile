//
//  CalendarViewCell.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/27/24.
//

import UIKit
import JTAppleCalendar

class CalendarViewCell: JTAppleCell {
    @IBOutlet weak var backgroundContentView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    var deliveryDays: [DeliveryDay]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundContentView.layer.cornerRadius = self.backgroundContentView.frame.height / 2
    }
    
    func configureCell(cellState: CellState, selectedDate: Date?) {
        
        self.isHidden = !cellState.date.isThisMonth()
        
        self.isUserInteractionEnabled = false
        if let deliveryDays = self.deliveryDays {
            self.isUserInteractionEnabled = isDeliveryDay(for: cellState.date, deliveryDays: deliveryDays)
        }

        self.dateLabel.text = cellState.text
        self.backgroundContentView.backgroundColor = .clear
        
        if cellState.date.isToday() {
            self.dateLabel.textColor = .calendarViewToday
        }
        else if self.isUserInteractionEnabled {
            self.dateLabel.textColor = .calendarTextHighlight
        }
        else {
            self.dateLabel.textColor = .gray4
        }
        
        if let date = selectedDate, date.isSameDay(as: cellState.date) {
            self.dateLabel.textColor = .calendarTextHighlight
            self.dateLabel.font = self.dateLabel.font.withSize(24)
            self.backgroundContentView.backgroundColor = .calendarDayBackground
        }
        else {
            self.backgroundContentView.backgroundColor = .clear
            self.dateLabel.font = self.dateLabel.font.withSize(20)
        }
    }
    
    func isDeliveryDay(for date: Date, deliveryDays: [DeliveryDay]) -> Bool {
        guard let weekday = date.getDayOfWeek() else { return false }
        for deliveryDay in deliveryDays {
            if let day = deliveryDay.day, let deliveryDayEnum = Weekday(rawValue: day.uppercased()), deliveryDayEnum == weekday {
                return true
            }
        }
        return false
    }
}
