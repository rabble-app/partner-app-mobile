//
//  ProfileButtonTableViewCell.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/24/24.
//

import UIKit

class ProfileButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.button.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func buttonTap(_ sender: Any) {
        
    }
}
