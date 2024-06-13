//
//  ChooseFrequencyViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit
import Moya

protocol ChooseFrequencyViewControllerDelegate: AnyObject {
    func dismissViewController()
}

class ChooseFrequencyViewController: UIViewController {
    
    @IBOutlet var supplierpartnernameLabel: UILabel!
    @IBOutlet var titelLabel: UILabel!
    @IBOutlet var monthButton: UIButton!
    @IBOutlet weak var monthImageView: UIImageView!
    @IBOutlet var twoWeekButton: UIButton!
    @IBOutlet weak var twoWeekImageView: UIImageView!
    @IBOutlet var weekButton: UIButton!
    @IBOutlet weak var weekImageView: UIImageView!
    @IBOutlet var progressBar: UIView!
    @IBOutlet var weekButtonContainer: UIView!
    @IBOutlet var twoWeekButtonContainer: UIView!
    @IBOutlet var monthButtonContainer: UIView!
    @IBOutlet var nextButton: PrimaryButton!
    
    @IBOutlet var stepContainer: UIView!
    @IBOutlet var stepContainer_height: NSLayoutConstraint!
    var isFromEdit: Bool = false
    
    var selectedFrequency: DeliveryFrequency?
    var selectedSupplier: Supplier?
    var partnerTeam: PartnerTeam?
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    let userDataManager = UserDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    private func setUpView() {
        configureProgressBar()
        configureButtons()
        configureLabels()
        nextButton.isEnabled = false
    }
    
    private func configureProgressBar() {
        let progressBarWidth = progressBar.frame.width / 3.0
        let greenProgressBarFrame = CGRect(x: 0, y: 0, width: progressBarWidth, height: progressBar.frame.height)
        
        let completedView = UIView(frame: greenProgressBarFrame)
        completedView.backgroundColor = Colors.ButtonSecondary
        progressBar.addSubview(completedView)
    }
    
    private func configureButtons() {
        weekButton.showsTouchWhenHighlighted = false
        twoWeekButton.showsTouchWhenHighlighted = false
        monthButton.showsTouchWhenHighlighted = false
        
        weekButton.setTitle("", for: .normal)
        twoWeekButton.setTitle("", for: .normal)
        monthButton.setTitle("", for: .normal)
    }
    
    private func configureLabels() {
        if isFromEdit {
            nextButton.setTitle("Save Changes", for: .normal)
            titelLabel.text = "Edit Shipment Frequency"
            stepContainer.isHidden = true
            stepContainer_height.constant = 0
        }
        
        supplierpartnernameLabel.text = "\(selectedSupplier?.businessName ?? "")@\(userDataManager.getUserData()?.partner?.name ?? "")"
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        guard let selectedFrequency = selectedFrequency else {
            print("No frequency selected")
            return
        }
        
        let deliveryFrequencyInSeconds = selectedFrequency.seconds
        if isFromEdit {
            updateTeamFrequency(deliveryFrequencyInSeconds)
        } else {
            goToChooseDeliveryDayViewController(frequency: deliveryFrequencyInSeconds)
        }
    }
    
    private func updateTeamFrequency(_ frequencyInSeconds: Int) {
        guard let teamId = partnerTeam?.id,
              let partnerName = partnerTeam?.name,
              let deliveryDay = partnerTeam?.deliveryDay,
              let productLimit = partnerTeam?.productLimit.toInt() else { return }
        
        LoadingViewController.present(from: self)
        apiProvider.request(.updateBuyingTeam(teamId: teamId, name: partnerName, frequency: frequencyInSeconds, deliveryDay: deliveryDay, productLimit: productLimit)) { result in
            LoadingViewController.dismiss(from: self)
            switch result {
            case let .success(response):
                self.handleSuccessResponse(response, frequencyInSeconds)
            case let .failure(error):
                SnackBar().alert(withMessage: "\(error)", isSuccess: false, parent: self.view)
            }
        }
    }
    
    private func handleSuccessResponse(_ response: Response, _ frequencyInSeconds: Int) {
        do {
            let response = try response.map(UpdateTeamResponse.self)
            if response.statusCode == 200 || response.statusCode == 201 {
                self.partnerTeam?.frequency = frequencyInSeconds
                DispatchQueue.main.async {
                    self.goToChooseDeliveryDayViewController(frequency: nil)
                }
            } else {
                SnackBar().alert(withMessage: response.message, isSuccess: false, parent: self.view)
            }
        } catch {
            handleErrorResponse(response)
        }
    }
    
    private func handleErrorResponse(_ response: Response) {
        do {
            let response = try response.map(StandardResponse.self)
            SnackBar().alert(withMessage: response.message, isSuccess: false, parent: self.view)
        } catch {
            print("Failed to map response data: \(error)")
        }
    }
    
    private func goToChooseDeliveryDayViewController(frequency: Int?) {
        let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseDeliveryDayViewController") as? ChooseDeliveryDayViewController {
            vc.modalPresentationStyle = .custom
            let pushAnimator = PushAnimator()
            vc.transitioningDelegate = pushAnimator
            if isFromEdit {
                vc.partnerTeam = self.partnerTeam
                vc.isFromEdit = isFromEdit
                vc.dismissalDelegate = self
            } else {
                vc.frequency = frequency!
                vc.selectedSupplier = selectedSupplier
            }
            self.title = "Team Settings"
            self.present(vc, animated: true)
        }
    }
    
    private func updateButtonStates(selectedButton: UIButton) {
        nextButton.isEnabled = true
        deselectAllButtons()
        selectedButton.isSelected = true
        updateButtonImages()
    }
    
    private func deselectAllButtons() {
        weekButton.isSelected = false
        twoWeekButton.isSelected = false
        monthButton.isSelected = false
    }
    
    private func updateButtonImages() {
        weekImageView.image = UIImage(named: weekButton.isSelected ? "selected_radioButton" : "unselected_radioButton")
        twoWeekImageView.image = UIImage(named: twoWeekButton.isSelected ? "selected_radioButton" : "unselected_radioButton")
        monthImageView.image = UIImage(named: monthButton.isSelected ? "selected_radioButton" : "unselected_radioButton")
    }
    
    @IBAction func weekButtonTap(_ sender: Any) {
        selectedFrequency = .everyWeek
        updateButtonStates(selectedButton: weekButton)
    }
    
    @IBAction func twoWeekButtonTap(_ sender: Any) {
        selectedFrequency = .everyTwoWeeks
        updateButtonStates(selectedButton: twoWeekButton)
    }
    
    @IBAction func monthButtonTap(_ sender: Any) {
        selectedFrequency = .everyMonth
        updateButtonStates(selectedButton: monthButton)
    }
}

extension ChooseFrequencyViewController: ChooseFrequencyViewControllerDelegate {
    func dismissViewController() {
        self.dismiss(animated: false)
    }
}

enum DeliveryFrequency: String {
    case everyWeek = "every week"
    case everyTwoWeeks = "every two weeks"
    case everyMonth = "every month"
    
    var seconds: Int {
        switch self {
        case .everyWeek:
            return 7 * 24 * 60 * 60 // 7 days in seconds
        case .everyTwoWeeks:
            return 14 * 24 * 60 * 60 // 14 days in seconds
        case .everyMonth:
            return 30 * 24 * 60 * 60 // 30 days in seconds
        }
    }
}
