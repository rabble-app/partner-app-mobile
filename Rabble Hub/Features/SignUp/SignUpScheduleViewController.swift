//
//  SignUpScheduleViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/17/24.
//

import UIKit
import Moya

class SignUpScheduleViewController: UIViewController {
    
    var defaultHeight = 0.0
    var selectedStoreHoursType: StoreHoursType = .allTheTime
    var customDays = CustomOpenHoursModel()
    var customMonToFri = CustomOpenHoursModel()
    var allTheTimeSched = CustomOpenHoursModel()
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentContentViewConstraintHeight: NSLayoutConstraint!
    
    @IBOutlet weak var segmentContentView: UIView!
    @IBOutlet weak var scheduleSegmentedControlButton: UISegmentedControl!
    
    @IBOutlet weak var wholeDaySwitchButton: UISwitch!
    @IBOutlet weak var nextButton: PrimaryButton!
    @IBOutlet weak var segmentFirstView: UIView!
    @IBOutlet weak var segmentSecondView: UIView!
    
    @IBOutlet weak var tableViewContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.defaultHeight = self.segmentContentViewConstraintHeight.constant;
        UIScrollView.appearance().contentInsetAdjustmentBehavior = .always
        
        tableViewContainerView.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initiateCustomDaysObjects() // call this once to initiate the schedules
        self.tableView.reloadData()
    }
    
    func initiateCustomDaysObjects() {
        let storeId = StoreManager.shared.store?.id ?? ""
        self.customMonToFri = CustomOpenHoursModel(storeId: storeId, type: .monToFri, customOpenHours: [])
        self.customMonToFri.populateCustomOpenHours()
        
        self.customDays = CustomOpenHoursModel(storeId: storeId, type: .custom, customOpenHours: [])
        self.customDays.populateCustomOpenHours()
        
        self.allTheTimeSched = CustomOpenHoursModel(storeId: storeId, type: .allTheTime, customOpenHours: [])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpStepIndicatorViewController {
            vc.currentStep = .three
        }
    }
    
    @IBAction func wholeDaySwitchButtonChanged(_ sender: Any) {
        self.nextButton.isEnabled = self.wholeDaySwitchButton.isOn
    }
    
    @IBAction func scheduleSegmentedControlTap(_ sender: Any) {
        
        // Open 24/7
        if (sender as AnyObject).selectedSegmentIndex == 0 {
            self.segmentContentViewConstraintHeight.constant = defaultHeight
            segmentFirstView.isHidden = false
            tableViewContainerView.isHidden = true
            selectedStoreHoursType = .allTheTime
            self.nextButton.isEnabled = self.wholeDaySwitchButton.isOn
        }
        // Mon - Fri
        else if (sender as AnyObject).selectedSegmentIndex == 1 {
            self.segmentContentViewConstraintHeight.constant = 617
            segmentFirstView.isHidden = true
            tableViewContainerView.isHidden = false
            selectedStoreHoursType = .monToFri
            self.nextButton.isEnabled = true
        }
        // Custom
        else {
            self.segmentContentViewConstraintHeight.constant = 864
            segmentFirstView.isHidden = true
            tableViewContainerView.isHidden = false
            selectedStoreHoursType = .custom
            self.nextButton.isEnabled = true
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func previousStepButtonTap(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func nextButtonStep(_ sender: Any) {
        
        self.addStoreHours()
    }
    
    
    // Add Store Hours
    
    func addStoreHours() {
        
        var param: CustomOpenHoursModel?
        
        if (selectedStoreHoursType == .custom) {
            param = self.customDays
        }
        else if (selectedStoreHoursType == .monToFri) {
            param = self.customMonToFri
        }
        else {
            param = self.allTheTimeSched
        }
        
        LoadingViewController.present(from: self)
        apiProvider.request(.addStoreHours(customOpenHoursModel: param)) { result in
            LoadingViewController.dismiss(from: self)
            switch result {
            case let .success(response):
                // Handle successful response
                do {
                    let response = try response.map(AddStoreHoursResponse.self)
                    if response.statusCode == 200 || response.statusCode == 201 {
                        print(response.data)
                        SnackBar().alert(withMessage: response.message, isSuccess: true, parent: self.view)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.goToSignUpAgreementView()
                        }
                    } else {
                        SnackBar().alert(withMessage: response.message, isSuccess: false, parent: self.view)
                        print("Error Message: \(response.message)")
                    }
                } catch {
                    do {
                        let response = try response.map(StandardResponse.self)
                        SnackBar().alert(withMessage: response.message[0], isSuccess: false, parent: self.view)
                    } catch {
                        print("Failed to map response data: \(error)")
                    }
                }
            case let .failure(error):
                // Handle error
                SnackBar().alert(withMessage: "\(error)", isSuccess: false, parent: self.view)
                print("Request failed with error: \(error)")
            }
        }
    }
    
    
    func goToSignUpAgreementView() {
        let signUpView = UIStoryboard(name: "SignUpView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "SignUpAgreementViewController") as! SignUpAgreementViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
    
    // Helper
    func getIndexDayFromInt(index: Int) -> CellIndexDay {
        switch index {
        case 0:
            return .mon
        case 1:
            return .tue
        case 2:
            return .wed
        case 3:
            return .thu
        case 4:
            return .fri
        case 5:
            return .sat
        case 6:
            return .sun
        default:
            return .mon
        }
    }
}

extension SignUpScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedStoreHoursType == .monToFri {
            return 5
        }
        else if self.selectedStoreHoursType == .custom {
            return 7
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SignUpScheduleTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "SignUpScheduleCell") as! SignUpScheduleTableViewCell
        
        cell.customObjectUpdated = { object in
            DispatchQueue.main.async {
                if self.selectedStoreHoursType == .monToFri {
                    self.customMonToFri.updateCustomOpenHour(object)
                }
                else if self.selectedStoreHoursType == .custom {
                    self.customDays.updateCustomOpenHour(object)
                }
                
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = NSIndexSet(indexesIn: range)
                tableView.reloadSections(sections as IndexSet, with: .automatic)
            }
            
        }
        
        cell.resetExpandedProperties = {
            DispatchQueue.main.async {
                if self.selectedStoreHoursType == .monToFri {
                    self.customMonToFri.resetExpandedProperties()
                }
                else if self.selectedStoreHoursType == .custom {
                    self.customDays.resetExpandedProperties()
                }
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell:SignUpScheduleTableViewCell = cell as! SignUpScheduleTableViewCell
        
        if self.selectedStoreHoursType == .monToFri {
            cell.configureCell(mode: .monFri, object: self.customMonToFri.customOpenHours[indexPath.row])
        }
        else if self.selectedStoreHoursType == .custom {
            cell.configureCell(mode: .custom, object: self.customDays.customOpenHours[indexPath.row])
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var isExpanded = false
        
        if self.selectedStoreHoursType == .monToFri {
            isExpanded = self.customMonToFri.customOpenHours[indexPath.row].startTimeExpanded || self.customMonToFri.customOpenHours[indexPath.row].endTimeExpanded
        }
        else if self.selectedStoreHoursType == .custom {
            isExpanded =  self.customDays.customOpenHours[indexPath.row].startTimeExpanded || self.customDays.customOpenHours[indexPath.row].endTimeExpanded
        }
        
        return isExpanded ? 311 : 117
    }
    
}
