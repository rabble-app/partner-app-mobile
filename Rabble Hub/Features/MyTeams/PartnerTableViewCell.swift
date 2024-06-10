//
//  PartnerTableViewCell.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/19/24.
//

import UIKit

class PartnerTableViewCell: UITableViewCell {
    
    @IBOutlet var supplierName: UILabel!
    @IBOutlet var container: UIView!
    @IBOutlet var img: UIImageView!
    @IBOutlet var hostContainer: UIView!
    @IBOutlet var hostLabel: UILabel!
    @IBOutlet var membersCount: UILabel!
    @IBOutlet var partnerCategory: UILabel!
    @IBOutlet var deliveryDetailsLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var frequencyContainer: UIView!
    @IBOutlet var frequencyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        container.layer.borderWidth = 1.0
        container.layer.borderColor = Colors.Gray5.cgColor
        container.layer.cornerRadius = 8.0
        container.clipsToBounds = true
        
        hostContainer.layer.cornerRadius = 12.5
        hostContainer.clipsToBounds = true
        
        frequencyContainer.layer.cornerRadius = 11.0
        frequencyContainer.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
