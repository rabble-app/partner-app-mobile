//
//  CreateALimitViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit
import Moya

class CreateALimitViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var progressBar: UIView!
    @IBOutlet var selectOptionButton: UIButton!
    @IBOutlet var primaryDescLabel: UILabel!
    @IBOutlet var secondaryDescLabel: UILabel!
    @IBOutlet var reminderLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var stepContainer_height: NSLayoutConstraint!
    @IBOutlet var stepContainer: UIView!
    
    var isFromEdit: Bool = false
    var frequency: Int = 0
    var selectedSupplier: Supplier?
    var deliveryDay: DeliveryDay?
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        configureProgressBar()
        configureSelectOptionButton()
        
        if isFromEdit {
            nextButton.setTitle("Save Changes", for: .normal)
            titleLabel.text = "Edit Product Limit"
            stepContainer.isHidden = true
            stepContainer_height.constant = 0
        }
    }
    
    private func configureProgressBar() {
        let progressBarWidth = 3 * progressBar.frame.width / 3.0
        let completedView = UIView(frame: CGRect(x: 0, y: 0, width: progressBarWidth, height: progressBar.frame.height))
        completedView.backgroundColor = Colors.ButtonSecondary
        progressBar.addSubview(completedView)
    }
    
    private func configureSelectOptionButton() {
        setBorder(for: selectOptionButton, color: Colors.Gray5, width: 1.0, radius: 12.0)
    }
    
    @IBAction private func backButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func selectOptionButtonTap(_ sender: Any) {
        // Add your functionality here
    }
    
    @IBAction private func nextButtonTap(_ sender: Any) {
        if isFromEdit {
            dismiss(animated: true, completion: nil)
        } else {
            createBuyingTeam()
        }
    }
    
    private func goToSetUpTeamSuccess() {
        let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SetupTeamSuccessViewController") as? SetupTeamSuccessViewController {
            vc.modalPresentationStyle = .custom
            let pushAnimator = PushAnimator()
            vc.transitioningDelegate = pushAnimator
            present(vc, animated: true)
        }
    }
    
    private func createBuyingTeam() {
        guard let postalCode = StoreManager.shared.postalCode,
              let storeId = StoreManager.shared.storeId,
              let userId = StoreManager.shared.userId else { return }
        
        guard let deliveryDayStr = self.deliveryDay?.day,
              let nextDeliveryDateStr = self.deliveryDay?.getNextDeliveryDate()?.toString(),
              let nextCutOffDateStr = self.deliveryDay?.getNextCutoffDate()?.toString()
        else { return }
        
        LoadingViewController.present(from: self)
        
        apiProvider.request(.createBuyingTeam(
            name: selectedSupplier?.businessName ?? "",
            postalCode: postalCode,
            producerId: selectedSupplier?.id ?? "",
            hostId: userId,
            partnerId: storeId,
            frequency: frequency,
            description: "",
            productLimit: 100, // placeholder
            deliveryDay: deliveryDayStr,
            nextDeliveryDate: nextDeliveryDateStr,
            orderCutOffDate: nextCutOffDateStr
        )) { result in
            LoadingViewController.dismiss(from: self)
            self.handleResponse(result)
        }
    }
    
    private func handleResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            do {
                let createResponse = try response.map(CreateBuyingTeamResponse.self)
                if createResponse.statusCode == 200 || createResponse.statusCode == 201 {
                    SnackBar().alert(withMessage: createResponse.message, isSuccess: true, parent: self.view)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.goToSetUpTeamSuccess()
                    }
                } else {
                    self.showSnackBar(message: createResponse.message, isSuccess: false)
                }
            } catch {
                self.handleErrorResponse(response)
            }
        case .failure(let error):
            self.showSnackBar(message: "\(error)", isSuccess: false)
        }
    }
    
    private func handleErrorResponse(_ response: Response) {
        do {
            let standardResponse = try response.map(StandardResponse.self)
            self.showSnackBar(message: standardResponse.message , isSuccess: false)
        } catch {
            print("Failed to map response data: \(error)")
        }
    }
    
    private func showSnackBar(message: String, isSuccess: Bool) {
        SnackBar().alert(withMessage: message, isSuccess: isSuccess, parent: self.view)
    }
    
    private func setBorder(for view: UIView, color: UIColor, width: CGFloat = 1.0, radius: CGFloat = 0.0) {
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = width
        view.layer.cornerRadius = radius
        view.clipsToBounds = true
    }
}
