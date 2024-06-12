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
    var isFromEdit: Bool = false
    var frequency = Int()
    var selectedSupplier: Supplier?
    var partnerTeam: PartnerTeam?
    var selectedDate: Date?
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    var deliveryDays: [DeliveryDay]?
    
    @IBOutlet weak var calendarCollectionView: JTAppleCalendarView!
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // fetch the available delivery days
        getDeliveryDays()
    }
    
    func setUpView() {
        let progressBarWidth = 2 * progressBar.frame.width / 3.0
        let completedProgressBarWidth = progressBarWidth
        let greenProgressBarFrame = CGRect(x: 0, y: 0, width: completedProgressBarWidth, height: progressBar.frame.height)
        
        let completedView = UIView(frame: greenProgressBarFrame)
        completedView.backgroundColor = Colors.ButtonSecondary
        
        progressBar.addSubview(completedView)
        
        calendarContainer.layer.cornerRadius = 10
        calendarContainer.clipsToBounds = true
        nextButton.isEnabled = false
        if isFromEdit {
            nextButton.setTitle("Save Changes", for: .normal)
            self.titleLabel.text = "Adjust Delivery Day"
            self.stepContainer.isHidden = true
            self.stepContainer_height.constant = 0
        }
        
        var supplierName = "{supplier.name}"
        if isFromEdit {
            if let name = partnerTeam?.name != nil ? partnerTeam?.name : "{supplier.name}" {
                supplierName = name
            }
        }
        else {
            if let name = selectedSupplier?.businessName != nil ? selectedSupplier?.businessName : "{supplier.name}" {
                supplierName = name
            }
        }
        
        self.deliveryDayInstructionsLabel.text = "Choose the first delivery day you would like \(supplierName) to deliver on. We allow a minimum of two weeks from creating the team for customers to sign up to your buying team"
        self.suppliersAvailableDaysLabel.text = "\(supplierName)'s available delivery days"
        self.calendarCollectionView.calendarDelegate = self
        self.calendarCollectionView.calendarDataSource = self
        
        self.calendarCollectionView.minimumLineSpacing = 0
        self.calendarCollectionView.minimumInteritemSpacing = 0
        
        self.previousMonthButton.setTitle("", for: .normal)
        self.nextMonthButton.setTitle("", for: .normal)
        
        self.calendarCollectionView.visibleDates { (visibleDates) in
            let date = visibleDates.monthDates.first!.date
            self.formatter.dateFormat = "MMM yyyy"
            self.monthYearLabel.text = self.formatter.string(from: date)
        }
    }
    
    func getDeliveryDays() {
        var supplierId = ""
        if isFromEdit {
            guard let producerId = partnerTeam?.producerId else { return }
            supplierId = producerId
        }
        else {
            guard let selectedSupplierId = selectedSupplier?.id else { return }
            supplierId = selectedSupplierId
        }
        
        var postalCode = "SE154NX"
        if let code = StoreManager.shared.postalCode {
            postalCode = code
        }
        
        LoadingViewController.present(from: self)
        apiProvider.request(.getDeliveryDays(supplierId: supplierId, postalCode: postalCode)) { result in
            LoadingViewController.dismiss(from: self)
            self.handleResponse(result: result)
        }
    }
    
    private func handleResponse(result: Result<Response, MoyaError>) {
        switch result {
        case let .success(response):
            // Handle successful response
            do {
                let response = try response.map(DeliveryDaysResponse.self)
                if response.statusCode == 200 || response.statusCode == 201 {
                    print(response.data as Any)
                    self.deliveryDays = response.data
                    DispatchQueue.main.async {
                        self.calendarCollectionView.reloadData()
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
    
    @IBAction func previousMonthButtonTapped(_ sender: Any) {
        
        self.calendarCollectionView.scrollToSegment(.previous)
    }

    
    @IBAction func nextMonthButtonTapped(_ sender: Any) {
        
        self.calendarCollectionView.scrollToSegment(.next)
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        if let presentingViewController = presentingViewController {
            let pushAnimator = PushAnimator()
            presentingViewController.transitioningDelegate = pushAnimator
        }
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        if isFromEdit {
            
            guard let teamId = partnerTeam?.id,
                  let partnerName = partnerTeam?.name,
                  let frequency = partnerTeam?.frequency,
                  let deliveryDay = selectedDate?.getDayOfWeek()?.rawValue,
                  let productLimit = partnerTeam?.productLimit.toInt()
            else { return }
            
            LoadingViewController.present(from: self)
            apiProvider.request(.updateBuyingTeam(teamId: teamId, name: partnerName, frequency: frequency, deliveryDay: deliveryDay, productLimit: productLimit)) { result in
                LoadingViewController.dismiss(from: self)
                switch result {
                case let .success(response):
                    // Handle successful response
                    do {
                        let response = try response.map(UpdateTeamResponse.self)
                        if response.statusCode == 200 || response.statusCode == 201 {
                            print(response.data as Any)
                            self.partnerTeam?.deliveryDay = deliveryDay
                            DispatchQueue.main.async {
                                self.goToCreateALimitViewController(deliveryDay: nil)
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
            
            if let deliveryDay = getDeliveryDay(for: selectedDate!, deliveryDays: self.deliveryDays!) {
                goToCreateALimitViewController(deliveryDay: deliveryDay)
            } else {
                print("No delivery on this date")
            }
        }
    }
    
    func goToCreateALimitViewController(deliveryDay: DeliveryDay?) {
        
        let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CreateALimitViewController") as? CreateALimitViewController {
            vc.modalPresentationStyle = .custom
            let pushAnimator = PushAnimator()
            vc.transitioningDelegate = pushAnimator
            if isFromEdit {
                vc.partnerTeam = self.partnerTeam
                vc.isFromEdit = isFromEdit
                vc.dismissalDelegate = self
            }
            else {
                vc.frequency = self.frequency
                vc.selectedSupplier = self.selectedSupplier
                vc.deliveryDate = selectedDate
                vc.deliveryDay = deliveryDay
            }
            self.title = "Team Settings"
            self.present(vc, animated: true)
        }
    }
}


extension ChooseDeliveryDayViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendar.JTAppleCalendarView) -> JTAppleCalendar.ConfigurationParameters {
        let range = Date().dateRangeFrom2ndTo10thWeek()
        print("Start date: \(range.startDate)")
        print("End date: \(range.endDate)")
        
        let parameters = ConfigurationParameters(startDate: range.startDate, endDate: range.endDate)
        return parameters
    }
}

extension ChooseDeliveryDayViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendar.JTAppleCalendarView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarViewCell", for: indexPath) as! CalendarViewCell
        cell.deliveryDays = self.deliveryDays
        cell.configureCell(cellState: cellState, selectedDate: self.selectedDate)
        return cell
    }
    
    
    func calendar(_ calendar: JTAppleCalendar.JTAppleCalendarView, willDisplay cell: JTAppleCalendar.JTAppleCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
        //        let cell:CalendarViewCell = cell as! CalendarViewCell
        //        cell.configureCell(cellState: cellState)
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        selectedDate = date
        nextButton.isEnabled = true
        calendar.reloadData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "MMM yyyy"
        self.monthYearLabel.text = formatter.string(from: date)
    }
}

extension ChooseDeliveryDayViewController: ChooseDeliveryDayViewControllerDelegate {
    func dismissViewController() {
        self.dismiss(animated: false) {
            self.dismissalDelegate?.dismissViewController()
        }
    }
}
