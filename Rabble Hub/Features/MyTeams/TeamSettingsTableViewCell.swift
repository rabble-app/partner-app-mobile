//
//  TeamSettingsTableViewCell.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/22/24.
//

import UIKit

struct TeamSetting {
    let title: String
    let imageName: String
}

class TeamSettingsTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var imageContainer: UIView!
    @IBOutlet var border: UIView!
    
    func configure(with setting: TeamSetting) {
        titleLabel.text = setting.title
        iconImageView.image = UIImage(named: setting.imageName)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        imageContainer.layer.cornerRadius = 18.0
        imageContainer.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
