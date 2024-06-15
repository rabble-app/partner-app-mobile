//
//  RabbleSheetViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 6/3/24.
//

import UIKit

class RabbleSheetViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var continueButton: PrimaryButton!
    @IBOutlet weak var tableView: UITableView!
    
    var headerTitle: String?
    var selectedIndex: IndexPath?
    var itemSelected: ((String) -> ())?
    var dismissed: (() -> ())?
    
    var items: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissed?()
    }
    
    func setupUI() {
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
        self.continueButton.isEnabled = self.selectedIndex != nil
        self.closeButton.setTitle("", for: .normal)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "RabbleSheetTableViewCell", bundle: nil), forCellReuseIdentifier: "RabbleSheetTableViewCell")
        
        if let headerTitle = self.headerTitle {
            self.headerLabel.text = headerTitle
        }
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let index = self.selectedIndex, let items = items else {
            self.continueButton.isEnabled = false
            return
        }
        
        self.itemSelected?(items[index.row])
        self.dismiss(animated: true)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension RabbleSheetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = items?.count else {
            return 0
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RabbleSheetTableViewCell", for: indexPath) as? RabbleSheetTableViewCell else {
            return UITableViewCell()
        }
        
        if let items = items {
            cell.optionLabel.text = items[indexPath.row]
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        self.continueButton.isEnabled = self.selectedIndex != nil
    }
    
}
