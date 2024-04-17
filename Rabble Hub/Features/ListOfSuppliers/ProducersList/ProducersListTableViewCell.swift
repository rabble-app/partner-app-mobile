//
//  ProducersListTableViewCell.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit

class ProducersListTableViewCell: UITableViewCell {
    
    @IBOutlet var producerImage: UIImageView!
    @IBOutlet var producerName: UILabel!
    @IBOutlet var producerType: UILabel!
    @IBOutlet var producerDesc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        producerImage.layer.cornerRadius = 8.0
        producerImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
