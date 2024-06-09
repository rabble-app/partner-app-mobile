//
//  InboundDeliveriesTableViewCell.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/18/24.
//

import UIKit

class InboundDeliveriesTableViewCell: UITableViewCell {

    @IBOutlet var initialLetter: UILabel!
    @IBOutlet var itemsCount: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var teamName: UILabel!
    @IBOutlet var producerName: UILabel!
    @IBOutlet var dateValue: UILabel!
    @IBOutlet var calendarImg: UIImageView!
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var initialBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialBackgroundView.layer.cornerRadius = self.initialBackgroundView.frame.size.height/2
        self.separatorView.layer.cornerRadius = self.separatorView.frame.size.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
