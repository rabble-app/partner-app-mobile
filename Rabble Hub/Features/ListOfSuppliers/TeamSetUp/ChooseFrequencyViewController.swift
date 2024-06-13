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
    @IBOutlet var twoWeekButton: UIButton!
    @IBOutlet var weekButton: UIButton!
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
    
    func setUpView() {
        let progressBarWidth = progressBar.frame.width / 3.0
        let completedProgressBarWidth = progressBarWidth
        let greenProgressBarFrame = CGRect(x: 0, y: 0, width: completedProgressBarWidth, height: progressBar.frame.height)
        
        let completedView = UIView(frame: greenProgressBarFrame)
        completedView.backgroundColor = Colors.ButtonSecondary
        progressBar.addSubview(completedView)
        
        weekButton.showsTouchWhenHighlighted = false
        twoWeekButton.showsTouchWhenHighlighted = false
        monthButton.showsTouchWhenHighlighted = false
        
        if isFromEdit {
            nextButton.setTitle("Save Changes", for: .normal)
            self.titelLabel.text = "Edit Shipment Frequency"
            self.stepContainer.isHidden = true
            self.stepContainer_height.constant = 0
        }
        
        nextButton.isEnabled = false
        
        supplierpartnernameLabel.text = "\(selectedSupplier?.businessName ?? "")@\(userDataManager.getUserData()?.partner?.name ?? "")"
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        guard let selectedFrequency = selectedFrequency else {
                   // Handle the case where no frequency is selected
                   print("No frequency selected")
                   return
               }
        
        let deliveryFrequencyInSeconds = selectedFrequency.seconds
        
        if isFromEdit {
            guard let teamId = partnerTeam?.id,
                  let partnerName = partnerTeam?.name,
                  let deliveryDay = partnerTeam?.deliveryDay,
                  let productLimit = partnerTeam?.productLimit.toInt()
            else { return }
            
            LoadingViewController.present(from: self)
            apiProvider.request(.updateBuyingTeam(teamId: teamId, name: partnerName, frequency: deliveryFrequencyInSeconds, deliveryDay: deliveryDay, productLimit: productLimit)) { result in
                LoadingViewController.dismiss(from: self)
                switch result {
                case let .success(response):
                    // Handle successful response
                    do {
                        let response = try response.map(UpdateTeamResponse.self)
                        if response.statusCode == 200 || response.statusCode == 201 {
                            self.partnerTeam?.frequency = deliveryFrequencyInSeconds
                            DispatchQueue.main.async {
                                self.goToChooseDeliveryDayViewController(frequency: nil)
                            }
                        } else {
                            SnackBar().alert(withMessage: response.message, isSuccess: false, parent: self.view)
                        }
                        
                    } catch {
                        do {
                            let response = try response.map(StandardResponse.self)
                            SnackBar().alert(withMessage: response.message, isSuccess: false, parent: self.view)
                        } catch {
                            print("Failed to map response data: \(error)")
                        }
                    }
                case let .failure(error):
                    // Handle error
                    SnackBar().alert(withMessage: "\(error)", isSuccess: false, parent: self.view)
                }
                
            }
        } else {
            goToChooseDeliveryDayViewController(frequency: deliveryFrequencyInSeconds)
        }
        
    }
    
    func goToChooseDeliveryDayViewController(frequency: Int?) {
        let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseDeliveryDayViewController") as? ChooseDeliveryDayViewController {
            vc.modalPresentationStyle = .custom
            let pushAnimator = PushAnimator()
            vc.transitioningDelegate = pushAnimator
            if isFromEdit {
                vc.partnerTeam = self.partnerTeam
                vc.isFromEdit = isFromEdit
                vc.dismissalDelegate = self
            }
            else {
                vc.frequency = frequency!
                vc.selectedSupplier = selectedSupplier
            }
            self.title = "Team Settings"
            self.present(vc, animated: true)
        }
    }
    
    func updateButtonStates(selectedButton: UIButton) {
        nextButton.isEnabled = true
        // Deselect all buttons
        weekButton.isSelected = false
        twoWeekButton.isSelected = false
        monthButton.isSelected = false
        
        // Select the specified button
        selectedButton.isSelected = true
        
        // Update button images based on selection state
        updateButtonImages()
    }
    
    func updateButtonImages() {
        // Update button images based on selection state
        weekButton.setBackgroundImage(UIImage(named: weekButton.isSelected ? "selected_radioButton" : "unselected_radioButton"), for: .normal)
        twoWeekButton.setBackgroundImage(UIImage(named: twoWeekButton.isSelected ? "selected_radioButton" : "unselected_radioButton"), for: .normal)
        monthButton.setBackgroundImage(UIImage(named: monthButton.isSelected ? "selected_radioButton" : "unselected_radioButton"), for: .normal)
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
