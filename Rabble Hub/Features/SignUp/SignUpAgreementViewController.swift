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
    
    var isFromOnboardingStage = false
    private let userDataManager = UserDataManager()
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        configurePreviousStepButton()
    }
    
    private func setUpView() {
        firstAgreementLabel.attributedText = createAttributedString(
            fullString: "Commission Rabble agree to pay a standard commission on every order completed at your location, subject to Rabble’s Partnership Agreement.",
            boldPartOfString: "Commission"
        )
        
        secondAgreementLabel.attributedText = createAttributedString(
            fullString: "Each order will be stored securely in the store. You or an employee is to confirm the customer booking.",
            boldPartOfString: "Each order will be stored securely in the store."
        )
    }
    
    private func configurePreviousStepButton() {
        previousStepButton.isEnabled = !isFromOnboardingStage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpStepIndicatorViewController {
            vc.currentStep = .four
        }
    }
    
    @IBAction func previousStepButtonTap(_ sender: Any) {
        dismiss(animated: false)
    }
    
    @IBAction func acceptButtonTap(_ sender: Any) {
        updateUserRecord()
    }
    
    private func updateUserRecord() {
        self.showLoadingIndicator()
        apiProvider.request(.updateUserOnboardingRecord) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingIndicator()
            
            switch result {
            case .success(let response):
                self.handleSuccessResponse(response)
            case .failure(let error):
                self.handleFailure(error)
            }
        }
    }
    
    private func handleSuccessResponse(_ response: Response) {
        do {
            let userResponse = try response.map(UpdateUserRecordResponse.self)
            if userResponse.statusCode == 200 || userResponse.statusCode == 201, let user = userResponse.data {
                updateUserData(with: user)
                navigateToMainTab()
            } else {
                showSnackBar(message: userResponse.message)
            }
        } catch {
            handleErrorResponse(response)
        }
    }
    
    private func handleErrorResponse(_ response: Response) {
        do {
            let errorResponse = try response.map(StandardResponse.self)
            showSnackBar(message: errorResponse.message)
        } catch {
            showSnackBar(message: "An error occurred")
            print("Failed to map response data: \(error)")
        }
    }
    
    private func handleFailure(_ error: MoyaError) {
        showSnackBar(message: error.localizedDescription)
        print("Request failed with error: \(error)")
    }
    
    private func updateUserData(with userRecord: UserRecord) {
        guard var userData = userDataManager.getUserData() else { return }
        userData.phone = userRecord.phone
        userData.email = userRecord.email
        userData.firstName = userRecord.firstName
        userData.lastName = userRecord.lastName
        userData.partner?.postalCode = userRecord.postalCode
        userData.stripeCustomerId = userRecord.stripeCustomerId
        userData.onboardingStage = userRecord.onboardingStage ?? 4
        userDataManager.saveUserData(userData)
    }
    
    private func navigateToMainTab() {
        let storyboard = UIStoryboard(name: "PaymentPopView", bundle: .main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "PaymentPopUpViewController") as? PaymentPopUpViewController {
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            present(vc, animated: true)
        }
    }
    
    private func createAttributedString(fullString: String, boldPartOfString: String) -> NSAttributedString? {
        guard let font = UIFont(name: Properties.Font.SF_PRO_REGULAR, size: 16),
              let boldFont = UIFont(name: Properties.Font.SF_PRO_SEMIBOLD, size: 16) else { return nil }
        
        let nonBoldAttributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: Colors.Gray3]
        let boldAttributes: [NSAttributedString.Key: Any] = [.font: boldFont, .foregroundColor: Colors.Gray1]
        
        let attributedString = NSMutableAttributedString(string: fullString, attributes: nonBoldAttributes)
        if let range = fullString.range(of: boldPartOfString) {
            let nsRange = NSRange(range, in: fullString)
            attributedString.addAttributes(boldAttributes, range: nsRange)
        }
        
        return attributedString
    }
    
    private func showSnackBar(message: String) {
        SnackBar().alert(withMessage: message, isSuccess: false, parent: view)
    }
    
    func paymentPopUpDismissed() {
        let storyboard = UIStoryboard(name: "CreateATeamPopUpView", bundle: .main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CreateATeamPopUpViewController") as? CreateATeamPopUpViewController {
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
    }
}
