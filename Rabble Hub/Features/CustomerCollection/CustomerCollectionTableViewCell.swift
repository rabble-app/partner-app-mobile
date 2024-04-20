//
//  CustomerCollectionTableViewCell.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/18/24.
//

import UIKit

class CustomerCollectionTableViewCell: UITableViewCell {

    @IBOutlet var initialNameContainer: UIView!
    @IBOutlet var initialNameLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var teammateNameLabel: UILabel!
    @IBOutlet var dot: UIView!
    @IBOutlet var itemsCountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        dot.layer.cornerRadius = 2.0
        dot.clipsToBounds = true
        
        initialNameContainer.layer.cornerRadius = 18.0
        initialNameContainer.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
