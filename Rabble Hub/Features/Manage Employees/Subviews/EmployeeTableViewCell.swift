//
//  EmployeeTableViewCell.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/26/24.
//

import UIKit

class EmployeeTableViewCell: UITableViewCell {


    @IBOutlet weak var nameInitialView: UIView!
    @IBOutlet weak var nameInitialLabel: UILabel!
    
    @IBOutlet weak var employeeNameLabel: UILabel!
    @IBOutlet weak var employeeNumberLabel: UILabel!
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.nameInitialView.layer.cornerRadius = 18
        self.statusView.layer.cornerRadius = 16
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
