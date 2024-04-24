//
//  ProfileMenuTableViewCell.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/24/24.
//

import UIKit

class ProfileMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var bottomSeparatorLineView: UIView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var separatorLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.iconView.layer.cornerRadius = 16
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(menu: Menu) {
        self.titleLabel.text = menu.titleName
        self.iconView.backgroundColor = menu.iconViewBgColor
        self.iconImageView.image = UIImage(systemName: menu.iconImageName ?? "")?.withRenderingMode(.alwaysTemplate)
        self.switchButton.isHidden = true
        self.subtitleLabel.isHidden = true
        self.accessoryType = .disclosureIndicator
        self.separatorLineView.isHidden = !menu.separatorLine
        
        switch menu.mode {
        case .textUI:
            self.subtitleLabel.isHidden = false
            self.subtitleLabel.text = menu.subtitleNameLabel
            break
        case .switchUI:
            self.switchButton.isHidden = false
            self.accessoryType = .none
            break
        default:
            
            break
        }
    }
    
  
    @IBAction func switchButtonTap(_ sender: Any) {
        
    }
}
