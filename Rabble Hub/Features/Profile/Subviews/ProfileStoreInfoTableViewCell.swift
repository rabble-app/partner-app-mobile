//
//  ProfileStoreInfoTableViewCell.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/24/24.
//

import UIKit

class ProfileStoreInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var initialView: UIView!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var separatorLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initialView.layer.cornerRadius = 25
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(menu: Menu) {
        self.titleLabel.text = menu.titleName
        self.subtitleLabel.text = menu.subtitleNameLabel
        self.separatorLineView.isHidden = !menu.separatorLine
    }

}
