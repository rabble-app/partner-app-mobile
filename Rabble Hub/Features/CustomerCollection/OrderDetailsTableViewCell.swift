//
//  OrderDetailsTableViewCell.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/18/24.
//

import UIKit

class OrderDetailsTableViewCell: UITableViewCell {
    
    
    @IBOutlet var border: UIView!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var supplierLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
