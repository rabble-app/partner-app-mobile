//
//  ConfirmDeliveryTableViewCell.swift
//  Rabble Hub
//
//  Created by aljon antiola on 6/6/24.
//

import UIKit

class ConfirmDeliveryTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemSubtitleLabel: UILabel!
    @IBOutlet weak var quantityTextField: UITextField!
    
    var quantityDidChange: ((ConfirmDeliveryTableViewCell, String) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.quantityTextField.delegate = self
        self.quantityTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        quantityDidChange?(self, textField.text ?? "")
    }

}
