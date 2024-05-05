//
//  QrCodeErrorPopViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/19/24.
//

import UIKit

protocol QrCodeStartScanningDelegate {
    func startScanning()
}

class QrCodeErrorPopViewController: UIViewController {
    
    var delegate: QrCodeStartScanningDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 1, alpha: 0.6)
        // Do any additional setup after loading the view.
    }
    

    @IBAction func closeButtonTap(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.startScanning()
        }
    }

}
