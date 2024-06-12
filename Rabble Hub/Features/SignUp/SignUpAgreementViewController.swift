//
//  SignUpAgreementViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/18/24.
//

import UIKit
import Moya

class SignUpAgreementViewController: UIViewController, PaymentPopUpDelegate {
    
    @IBOutlet var previousStepButton: TertiaryButton!
    @IBOutlet weak var firstAgreementLabel: UILabel!
    @IBOutlet weak var secondAgreementLabel: UILabel!
    var isFromOnboardingStage = Bool()
    private let userDataManager = UserDataManager()
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
        if isFromOnboardingStage {
            self.previousStepButton.isEnabled = false
        }
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
        self.updateUserRecord()
    }
    
    
    func updateUserRecord() {
        LoadingViewController.present(from: self)
        apiProvider.request(.updateUserOnboardingRecord) { [weak self] result in
            guard let self = self else { return }
            
            LoadingViewController.dismiss(from: self)
            
            switch result {
            case let .success(response):
                self.handleSuccessResponse(response)
            case let .failure(error):
                self.handleFailure(error)
            }
        }
    }
    
    private func handleSuccessResponse(_ response: Response) {
        do {
            let response = try response.map(UpdateUserRecordResponse.self)
            if response.statusCode == 200 || response.statusCode == 201 {
                if let user = response.data {
                    self.updateUserData(with: user)
                    self.gotoMainTab()
                } else {
                    SnackBar().alert(withMessage: "Failed to update user record", isSuccess: false, parent: view)
                }
            } else {
                SnackBar().alert(withMessage: response.message, isSuccess: false, parent: view)
            }
        } catch {
            handleErrorResponse(response)
        }
    }

    private func handleErrorResponse(_ response: Response) {
        do {
            let response = try response.map(StandardResponse.self)
            SnackBar().alert(withMessage: response.message, isSuccess: false, parent: view)
        } catch {
            SnackBar().alert(withMessage: "An error occurred", isSuccess: false, parent: view)
            print("Failed to map response data: \(error)")
        }
    }
    
    private func handleFailure(_ error: MoyaError) {
        SnackBar().alert(withMessage: error.localizedDescription, isSuccess: false, parent: view)
        print("Request failed with error: \(error)")
    }
    
    
    private func updateUserData(with userRecord: UserRecord) {
        if var userData = userDataManager.getUserData() {
            userData.phone = userRecord.phone
            userData.email = userRecord.email
            userData.firstName = userRecord.firstName
            userData.lastName = userRecord.lastName
            userData.postalCode = userRecord.postalCode
            userData.stripeCustomerId = userRecord.stripeCustomerId
            userData.partner?.id = userRecord.id
            userData.onboardingStage = userRecord.onboardingStage ?? 4
            userDataManager.saveUserData(userData)
        }
    }
    
    private func gotoMainTab() {
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
