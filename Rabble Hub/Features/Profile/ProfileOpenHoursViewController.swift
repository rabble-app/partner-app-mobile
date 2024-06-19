//
//  ProfileOpenHoursViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/25/24.
//

import UIKit
import Moya

class ProfileOpenHoursViewController: UIViewController {

    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var tableViewContainerView: UIView!
    
    @IBOutlet weak var segmentControlButton: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentContentViewConstraintHeight: NSLayoutConstraint!
    
    var customDays = CustomOpenHoursModel()
    var customMonToFri = CustomOpenHoursModel()
    var allTheTimeSched = CustomOpenHoursModel()
    
    var selectedStoreHoursType: StoreHoursType = .allTheTime
    var currentSegmentIndex = 0
    var defaultHeight = 0.0
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    private let userDataManager = UserDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIScrollView.appearance().contentInsetAdjustmentBehavior = .always
        
        tableViewContainerView.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initiateCustomDaysObjects()
    }
    
    func initiateCustomDaysObjects() {
        let userDataManager = UserDataManager()
        let storeId = userDataManager.getUserData()?.partner?.id ?? ""
        self.customMonToFri = CustomOpenHoursModel(storeId: storeId, type: .monToFri, customOpenHours: [])
        self.customMonToFri.populateCustomOpenHours(isEnable: true)
        
        self.customDays = CustomOpenHoursModel(storeId: storeId, type: .custom, customOpenHours: [])
        self.customDays.populateCustomOpenHours(isEnable: false)
        
        self.allTheTimeSched = CustomOpenHoursModel(storeId: storeId, type: .allTheTime, customOpenHours: [])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.defaultHeight = self.segmentContentViewConstraintHeight.constant;
        fetchStoreHours()
    }
    
    func fetchStoreHours() {
        guard let partner = userDataManager.getUserData()?.partner else { return }
        self.showLoadingIndicator()

        apiProvider.request(.getStoreOpenHours(partnerId: partner.id)) { result in
            self.handleSuppliersResponse(result)
            self.dismissLoadingIndicator()
        }
    }
    
    private func handleSuppliersResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            handleSuccessResponse(response)
        case .failure(let error):
            displaySnackBar(message: (error.localizedDescription), isSuccess: false)
        }
    }
    
    private func handleSuccessResponse(_ response: Response) {
        do {
            let storeOpenHourResponse = try response.map(StoreOpenHourResponse.self)
            if storeOpenHourResponse.statusCode == 200 {
                self.loadStoreHourData(storeOpenHourData: storeOpenHourResponse.data)
            } else {
                displaySnackBar(message: storeOpenHourResponse.message, isSuccess: true)
            }
        } catch {
            handleMappingError(response)
        }
    }
    
    private func handleMappingError(_ response: Response) {
        do {
            let errorResponse = try response.map(StandardResponse.self)
            displaySnackBar(message: errorResponse.message, isSuccess: false)
        } catch {
            print("Failed to map response data: \(error)")
        }
    }
    
    func loadStoreHourData(storeOpenHourData: StoreOpenHourData) {
        switch storeOpenHourData.type {
        case StoreHoursType.allTheTime.rawValue:
            segmentControlButton.selectedSegmentIndex = 0
            segmentControlButton.sendActions(for: .valueChanged)
            break
        case StoreHoursType.monToFri.rawValue:
            guard let customOpenHours = storeOpenHourData.customOpenHours else { return }
            for customOpenHour in customOpenHours {
                let updatedOpenHour = CustomOpenHour(scheduleDay: Day(rawValue: customOpenHour.day)!, startTime: customOpenHour.startTime, endTime: customOpenHour.endTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false)
                self.customMonToFri.updateCustomOpenHour(updatedOpenHour)
            }
            segmentControlButton.selectedSegmentIndex = 1
            segmentControlButton.sendActions(for: .valueChanged)
            break
        case StoreHoursType.custom.rawValue:
            guard let customOpenHours = storeOpenHourData.customOpenHours else { return }
            for customOpenHour in customOpenHours {
                let updatedOpenHour = CustomOpenHour(scheduleDay: Day(rawValue: customOpenHour.day)!, startTime: customOpenHour.startTime, endTime: customOpenHour.endTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false)
                self.customDays.updateCustomOpenHour(updatedOpenHour)
            }

            segmentControlButton.selectedSegmentIndex = 2
            segmentControlButton.sendActions(for: .valueChanged)
            break
        default:
            break
        }

    }

    @IBAction func segmentControlButtonTap(_ sender: Any) {
        self.currentSegmentIndex = (sender as AnyObject).selectedSegmentIndex
        
        self.loadSelectedIndex(index: self.currentSegmentIndex)
    }
    
    func loadSelectedIndex(index: Int) {
        // Open 24/7
        if index == 0 {
            self.segmentContentViewConstraintHeight.constant = defaultHeight
            firstView.isHidden = false
            tableViewContainerView.isHidden = true
            selectedStoreHoursType = .allTheTime
        }
        // Mon - Fri
        else if index == 1 {
            self.segmentContentViewConstraintHeight.constant = 617
            firstView.isHidden = true
            tableViewContainerView.isHidden = false
            selectedStoreHoursType = .monToFri
        }
        // Custom
        else {
            self.segmentContentViewConstraintHeight.constant = 864
            firstView.isHidden = true
            tableViewContainerView.isHidden = false
            selectedStoreHoursType = .custom
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func open24HoursSwitchTap(_ sender: Any) {
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func displaySnackBar(message: String, isSuccess: Bool = false) {
        SnackBar().alert(withMessage: message, isSuccess: isSuccess, parent: view)
    }
}


extension ProfileOpenHoursViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.currentSegmentIndex == 1 {
            return 5
        }
        else if self.currentSegmentIndex == 2 {
            return 7
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ProfileScheduleTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ProfileScheduleCell") as! ProfileScheduleTableViewCell
        
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
        
        let cell:ProfileScheduleTableViewCell = cell as! ProfileScheduleTableViewCell
            
        if self.selectedStoreHoursType == .monToFri {
            cell.configureCell(mode: .monFri, object: self.customMonToFri.customOpenHours[indexPath.row])
        }
        else if self.selectedStoreHoursType == .custom {
            cell.configureCell(mode: .custom, object: self.customDays.customOpenHours[indexPath.row])
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 117
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
