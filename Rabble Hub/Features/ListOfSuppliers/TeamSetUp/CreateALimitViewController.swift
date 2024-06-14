//
//  CreateALimitViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit
import Moya

class CreateALimitViewController: UIViewController {

    weak var dismissalDelegate: ChooseDeliveryDayViewControllerDelegate?
    
    @IBOutlet var supplierpartnernameLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var progressBar: UIView!
    @IBOutlet var selectOptionButton: UIButton!
    @IBOutlet var primaryDescLabel: UILabel!
    @IBOutlet var secondaryDescLabel: UILabel!
    @IBOutlet var reminderLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var stepContainer_height: NSLayoutConstraint!
    @IBOutlet var stepContainer: UIView!
    @IBOutlet weak var selectionLabel: UILabel!
    
    var isFromEdit: Bool = false
    var frequency: Int = 0
    var selectedSupplier: Supplier?
    var partnerTeam: PartnerTeam?
    var deliveryDay: DeliveryDay?
    var deliveryDate: Date?
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    let userDataManager = UserDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        configureProgressBar()
        configureSelectOptionButton()
        configureLabels()
        nextButton.isEnabled = false
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
    
    private func configureLabels() {
        if isFromEdit {
            nextButton.setTitle("Save Changes", for: .normal)
            titleLabel.text = "Edit Product Limit"
            stepContainer.isHidden = true
            stepContainer_height.constant = 0
        }
        supplierpartnernameLabel.text = "\(selectedSupplier?.businessName ?? "")@\(userDataManager.getUserData()?.partner?.name ?? "")"
    }
    
    @IBAction private func backButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func selectOptionButtonTap(_ sender: Any) {
        let rabbleSheetViewController = RabbleSheetViewController()
        rabbleSheetViewController.headerTitle = "Select an option"
        rabbleSheetViewController.items = ["10 cubic feet", "20 cubic feet", "30 cubic feet", "40 cubic feet", "50 cubic feet"]
        rabbleSheetViewController.itemSelected = { item in
            self.selectionLabel.text = item
            self.nextButton.isEnabled = true
        }
        present(rabbleSheetViewController, animated: true, completion: nil)
    }
    
    @IBAction private func nextButtonTap(_ sender: Any) {
        if isFromEdit {
            updateBuyingTeam()
        } else {
            createBuyingTeam()
        }
    }
    
    private func updateBuyingTeam() {
        guard let teamId = partnerTeam?.id,
              let partnerName = partnerTeam?.name,
              let frequency = partnerTeam?.frequency,
              let deliveryDay = partnerTeam?.deliveryDay else { return }
        
        var productLimit = partnerTeam?.productLimit.toInt()
        if let limit = selectionLabel.text {
            productLimit = limit.components(separatedBy: " ").first?.toInt()
        }
        
        LoadingViewController.present(from: self)
        apiProvider.request(.updateBuyingTeam(teamId: teamId, name: partnerName, frequency: frequency, deliveryDay: deliveryDay, productLimit: productLimit!)) { result in
            LoadingViewController.dismiss(from: self)
            self.handleUpdateResponse(result, productLimit: productLimit)
        }
    }
    private func handleUpdateResponse(_ result: Result<Response, MoyaError>, productLimit: Int?) {
        switch result {
        case .success(let response):
            do {
                let updateResponse = try response.map(UpdateTeamResponse.self)
                if updateResponse.statusCode == 200 || updateResponse.statusCode == 201 {
                    if let limit = productLimit?.toString() {
                        partnerTeam?.productLimit = limit
                    }
                    self.showSnackBar(message: updateResponse.message, isSuccess: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.dismiss(animated: false) {
                            self.dismissalDelegate?.dismissViewController()
                        }
                    }
                } else {
                    self.showSnackBar(message: updateResponse.message, isSuccess: false)
                }
            } catch {
                self.handleStandardError(response)
            }
        case .failure(let error):
            self.showSnackBar(message: "\(error)", isSuccess: false)
        }
    }
    
    private func createBuyingTeam() {
        guard let postalCode = userDataManager.getUserData()?.partner?.postalCode,
              let storeId = userDataManager.getUserData()?.partner?.id,
              let partnerName = userDataManager.getUserData()?.partner?.name,
              let userId = userDataManager.getUserData()?.id,
              let deliveryDayStr = deliveryDay?.day,
              let deliveryDateStr = deliveryDate?.toString(),
              let nextCutOffDateStr = deliveryDay?.getCutoffDate(from: deliveryDate!)?.toString() else { return }
        
        var productLimit = "100"
        if let limit = selectionLabel.text {
            productLimit = limit.components(separatedBy: " ").first ?? "100"
        }
        
        LoadingViewController.present(from: self)
        
        apiProvider.request(.createBuyingTeam(
            name: "\(selectedSupplier?.businessName ?? "")@\(partnerName)",
            postalCode: postalCode,
            producerId: selectedSupplier?.id ?? "",
            hostId: userId,
            partnerId: storeId,
            frequency: frequency,
            description: "",
            productLimit: productLimit.toInt()!,
            deliveryDay: deliveryDayStr,
            nextDeliveryDate: deliveryDateStr,
            orderCutOffDate: nextCutOffDateStr
        )) { result in
            LoadingViewController.dismiss(from: self)
            self.handleCreateResponse(result)
        }
    }
    
    private func handleCreateResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            do {
                let createResponse = try response.map(CreateBuyingTeamResponse.self)
                if createResponse.statusCode == 200 || createResponse.statusCode == 201 {
                    self.showSnackBar(message: createResponse.message, isSuccess: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.goToSetUpTeamSuccess()
                    }
                } else {
                    self.showSnackBar(message: createResponse.message, isSuccess: false)
                }
            } catch {
                self.handleStandardError(response)
            }
        case .failure(let error):
            self.showSnackBar(message: "\(error)", isSuccess: false)
        }
    }
    
    private func handleStandardError(_ response: Response) {
        do {
            let standardResponse = try response.map(StandardResponse.self)
            showSnackBar(message: standardResponse.message, isSuccess: false)
        } catch {
            print("Failed to map response data: \(error)")
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
    
    private func showSnackBar(message: String, isSuccess: Bool) {
        SnackBar().alert(withMessage: message, isSuccess: isSuccess, parent: view)
    }
    
    private func setBorder(for view: UIView, color: UIColor, width: CGFloat = 1.0, radius: CGFloat = 0.0) {
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = width
        view.layer.cornerRadius = radius
        view.clipsToBounds = true
    }
}
