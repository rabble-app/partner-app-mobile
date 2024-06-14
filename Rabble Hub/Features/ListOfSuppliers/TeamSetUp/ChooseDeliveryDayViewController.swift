//
//  ChooseDeliveryDayViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit
import Moya
import JTAppleCalendar

protocol ChooseDeliveryDayViewControllerDelegate: AnyObject {
    func dismissViewController()
}

class ChooseDeliveryDayViewController: UIViewController {
    
    weak var dismissalDelegate: ChooseFrequencyViewControllerDelegate?
    
    @IBOutlet var supplierpartnernameLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var progressBar: UIView!
    @IBOutlet var calendarContainer: UIView!
    @IBOutlet weak var deliveryDayInstructionsLabel: UILabel!
    @IBOutlet weak var suppliersAvailableDaysLabel: UILabel!
    @IBOutlet weak var previousMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet var stepContainer: UIView!
    @IBOutlet var stepContainer_height: NSLayoutConstraint!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet weak var calendarCollectionView: JTAppleCalendarView!
    
    var isFromEdit: Bool = false
    var frequency = Int()
    var selectedSupplier: Supplier?
    var partnerTeam: PartnerTeam?
    var selectedDate: Date?
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    var deliveryDays: [DeliveryDay]?
    
    let formatter = DateFormatter()
    let userDataManager = UserDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getDeliveryDays()
    }
    
    private func setUpView() {
        configureProgressBar()
        configureCalendarContainer()
        configureButtons()
        configureLabels()
        configureCalendarCollectionView()
        
        if isFromEdit {
            nextButton.setTitle("Save Changes", for: .normal)
            titleLabel.text = "Adjust Delivery Day"
            stepContainer.isHidden = true
            stepContainer_height.constant = 0
        }
        
        supplierpartnernameLabel.text = "\(selectedSupplier?.businessName ?? "")@\(userDataManager.getUserData()?.partner?.name ?? "")"
    }
    
    private func configureProgressBar() {
        let progressBarWidth = 2 * progressBar.frame.width / 3.0
        let completedView = UIView(frame: CGRect(x: 0, y: 0, width: progressBarWidth, height: progressBar.frame.height))
        completedView.backgroundColor = Colors.ButtonSecondary
        progressBar.addSubview(completedView)
    }
    
    private func configureCalendarContainer() {
        calendarContainer.layer.cornerRadius = 10
        calendarContainer.clipsToBounds = true
    }
    
    private func configureButtons() {
        previousMonthButton.setTitle("", for: .normal)
        nextMonthButton.setTitle("", for: .normal)
        nextButton.isEnabled = false
    }
    
    private func configureLabels() {
        var supplierNameDefault = "{supplier.name}"
        var supplierName = supplierNameDefault
        if isFromEdit {
            supplierName = partnerTeam?.name ?? supplierNameDefault
        } else {
            supplierName = selectedSupplier?.businessName ?? supplierNameDefault
        }
        
        deliveryDayInstructionsLabel.text = "Choose the first delivery day you would like \(supplierName) to deliver on. We allow a minimum of two weeks from creating the team for customers to sign up to your buying team"
        suppliersAvailableDaysLabel.text = "\(supplierName)'s available delivery days"
    }
    
    private func configureCalendarCollectionView() {
        calendarCollectionView.calendarDelegate = self
        calendarCollectionView.calendarDataSource = self
        calendarCollectionView.minimumLineSpacing = 0
        calendarCollectionView.minimumInteritemSpacing = 0
        
        calendarCollectionView.visibleDates { visibleDates in
            let date = visibleDates.monthDates.first!.date
            self.formatter.dateFormat = "MMM yyyy"
            self.monthYearLabel.text = self.formatter.string(from: date)
        }
    }
    
    private func getDeliveryDays() {
        var supplierId = ""
        if isFromEdit {
            supplierId = partnerTeam?.producerId ?? ""
        } else {
            supplierId = selectedSupplier?.id ?? ""
        }
        
        let postalCode = userDataManager.getUserData()?.postalCode ?? ""
        LoadingViewController.present(from: self)
        apiProvider.request(.getDeliveryDays(supplierId: supplierId, postalCode: postalCode)) { result in
            LoadingViewController.dismiss(from: self)
            self.handleDeliveryDaysResponse(result)
        }
    }
    
    private func handleDeliveryDaysResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            do {
                let deliveryDaysResponse = try response.map(DeliveryDaysResponse.self)
                if deliveryDaysResponse.statusCode == 200 || deliveryDaysResponse.statusCode == 201 {
                    deliveryDays = deliveryDaysResponse.data
                    DispatchQueue.main.async {
                        self.calendarCollectionView.reloadData()
                    }
                } else {
                    SnackBar().alert(withMessage: deliveryDaysResponse.message, isSuccess: false, parent: view)
                }
            } catch {
                handleStandardError(response)
            }
        case .failure(let error):
            SnackBar().alert(withMessage: "\(error)", isSuccess: false, parent: view)
        }
    }
    
    private func handleStandardError(_ response: Response) {
        do {
            let standardResponse = try response.map(StandardResponse.self)
            SnackBar().alert(withMessage: standardResponse.message, isSuccess: false, parent: view)
        } catch {
            print("Failed to map response data: \(error)")
        }
    }
    
    @IBAction private func previousMonthButtonTapped(_ sender: Any) {
        calendarCollectionView.scrollToSegment(.previous)
    }

    @IBAction private func nextMonthButtonTapped(_ sender: Any) {
        calendarCollectionView.scrollToSegment(.next)
    }
    
    @IBAction private func backButtonTap(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func nextButtonTap(_ sender: Any) {
        if isFromEdit {
            updateBuyingTeam()
        } else {
            if let deliveryDay = getDeliveryDay(for: selectedDate!, deliveryDays: deliveryDays!) {
                goToCreateALimitViewController(deliveryDay: deliveryDay)
            } else {
                print("No delivery on this date")
            }
        }
    }
    
    private func updateBuyingTeam() {
        guard let teamId = partnerTeam?.id,
              let partnerName = partnerTeam?.name,
              let frequency = partnerTeam?.frequency,
              let deliveryDay = selectedDate?.getDayOfWeek()?.rawValue,
              let productLimit = partnerTeam?.productLimit.toInt() else { return }
        
        LoadingViewController.present(from: self)
        apiProvider.request(.updateBuyingTeam(teamId: teamId, name: partnerName, frequency: frequency, deliveryDay: deliveryDay, productLimit: productLimit)) { result in
            LoadingViewController.dismiss(from: self)
            self.handleUpdateResponse(result, deliveryDay: deliveryDay)
        }
    }
    
    private func handleUpdateResponse(_ result: Result<Response, MoyaError>, deliveryDay: String) {
        switch result {
        case .success(let response):
            do {
                let updateResponse = try response.map(UpdateTeamResponse.self)
                if updateResponse.statusCode == 200 || updateResponse.statusCode == 201 {
                    partnerTeam?.deliveryDay = deliveryDay
                    DispatchQueue.main.async {
                        self.goToCreateALimitViewController(deliveryDay: nil)
                    }
                } else {
                    SnackBar().alert(withMessage: updateResponse.message, isSuccess: false, parent: view)
                }
            } catch {
                handleStandardError(response)
            }
        case .failure(let error):
            SnackBar().alert(withMessage: "\(error)", isSuccess: false, parent: view)
        }
    }
    
    private func goToCreateALimitViewController(deliveryDay: DeliveryDay?) {
        let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CreateALimitViewController") as? CreateALimitViewController {
            vc.modalPresentationStyle = .custom
            let pushAnimator = PushAnimator()
            vc.transitioningDelegate = pushAnimator
            if isFromEdit {
                vc.partnerTeam = partnerTeam
                vc.isFromEdit = isFromEdit
                vc.dismissalDelegate = self
            } else {
                vc.frequency = frequency
                vc.selectedSupplier = selectedSupplier
                vc.deliveryDate = selectedDate
                vc.deliveryDay = deliveryDay
            }
            title = "Team Settings"
            present(vc, animated: true)
        }
    }
}

extension ChooseDeliveryDayViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let range = Date().dateRangeFrom2ndTo10thWeek()
        let parameters = ConfigurationParameters(startDate: range.startDate, endDate: range.endDate)
        return parameters
    }
}

extension ChooseDeliveryDayViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendar.JTAppleCalendarView, willDisplay cell: JTAppleCalendar.JTAppleCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
        // Configure cell here before the UI loads
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarViewCell", for: indexPath) as! CalendarViewCell
        cell.deliveryDays = deliveryDays
        cell.configureCell(cellState: cellState, selectedDate: selectedDate)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        selectedDate = date
        nextButton.isEnabled = true
        calendar.reloadData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "MMM yyyy"
        monthYearLabel.text = formatter.string(from: date)
    }
}

extension ChooseDeliveryDayViewController: ChooseDeliveryDayViewControllerDelegate {
    func dismissViewController() {
        dismiss(animated: false) {
            self.dismissalDelegate?.dismissViewController()
        }
    }
}
