//
//  RabbleSheetTableViewCell.swift
//  Rabble Hub
//
//  Created by aljon antiola on 6/4/24.
//

import UIKit

class RabbleSheetTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedIndicatorImage: UIImageView!
    @IBOutlet weak var optionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.selectedIndicatorImage.isHidden = !selected
    }
    
}
