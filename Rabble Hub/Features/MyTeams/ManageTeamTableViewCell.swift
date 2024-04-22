//
//  ManageTeamTableViewCell.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/22/24.
//

import UIKit

class ManageTeamTableViewCell: UITableViewCell {
    
    @IBOutlet var initialLabel: UILabel!
    @IBOutlet var initialContainer: UIView!
    @IBOutlet var memberName: UILabel!
    @IBOutlet var dot: UIView!
    @IBOutlet var storeVisitCounts: UILabel!
    @IBOutlet var border: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dot.layer.cornerRadius = 2.0
        dot.clipsToBounds = true
        
        initialContainer.layer.cornerRadius = 18.0
        initialContainer.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
