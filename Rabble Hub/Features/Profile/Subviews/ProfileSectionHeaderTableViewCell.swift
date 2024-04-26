//
//  ProfileSectionHeaderTableViewCell.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/24/24.
//

import UIKit

class ProfileSectionHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var sectionHeaderTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(menu: Menu) {
        self.sectionHeaderTitleLabel.text = menu.titleName
    }

}
