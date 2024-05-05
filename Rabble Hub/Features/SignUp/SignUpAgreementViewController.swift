//
//  SignUpAgreementViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/18/24.
//

import UIKit

class SignUpAgreementViewController: UIViewController, PaymentPopUpDelegate {
    
    
    
    @IBOutlet weak var firstAgreementLabel: UILabel!
    @IBOutlet weak var secondAgreementLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
    }
    
    func setUpView() {
        if let firstAgreementText = configureString(fullString: "Commission Rabble agree to pay a standard commission on every order completed at your location, subject to Rabble’s Partnership Agreement.", boldPartOfString: "Commission") {
            self.firstAgreementLabel.attributedText = firstAgreementText
        }
        
        if let secondAgreementText = configureString(fullString: "Each order will be stored securely in the store. You or an employee is to confirm the customer booking.", boldPartOfString: "Each order will be stored securely in the store.") {
            self.secondAgreementLabel.attributedText = secondAgreementText
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpStepIndicatorViewController {
            vc.currentStep = .four
        }
    }
    
    @IBAction func previousStepButtonTap(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func acceptButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "PaymentPopView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "PaymentPopUpViewController") as? PaymentPopUpViewController {
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
    
    // Helper
    
    func configureString(fullString: NSString, boldPartOfString: NSString) -> NSAttributedString? {
        
        guard let font = UIFont(name: Properties.Font.SF_PRO_REGULAR, size: 16) else { return nil }
        guard let boldFont = UIFont(name: Properties.Font.SF_PRO_SEMIBOLD, size: 16) else { return nil }
        
        let nonBoldFontAttribute = [NSAttributedString.Key.font:font, NSAttributedString.Key.foregroundColor: Colors.Gray3]
        let boldFontAttribute = [NSAttributedString.Key.font:boldFont, NSAttributedString.Key.foregroundColor: Colors.Gray1]
        
        let combinedString = NSMutableAttributedString(string: fullString as String, attributes: nonBoldFontAttribute)
        combinedString.addAttributes(boldFontAttribute, range: fullString.range(of: boldPartOfString as String))
        return combinedString
    }
    
    func paymentPopUpDismissed() {
        let storyboard = UIStoryboard(name: "CreateATeamPopUpView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CreateATeamPopUpViewController") as? CreateATeamPopUpViewController {
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
}
