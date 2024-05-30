//
//  ChooseDeliveryDayViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit
import Moya
import JTAppleCalendar

class ChooseDeliveryDayViewController: UIViewController {
    
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
        
        if isFromEdit {
            nextButton.setTitle("Save Changes", for: .normal)
            self.titleLabel.text = "Adjust Delivery Day"
            self.stepContainer.isHidden = true
            self.stepContainer_height.constant = 0
        }
        
        if let supplierName = selectedSupplier?.businessName != nil ? selectedSupplier?.businessName : "{supplier.name}" {
            self.deliveryDayInstructionsLabel.text = "Choose the first delivery day you would like \(supplierName) to deliver on. We allow a minimum of two weeks from creating the team for customers to sign up to your buying team"
            self.suppliersAvailableDaysLabel.text = "\(supplierName)'s available delivery days"
        }
        
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
        
        guard let supplierId = selectedSupplier?.id else { return }
        guard let postalCode = StoreManager.shared.postalCode else { return }
        
        LoadingViewController.present(from: self)
        apiProvider.request(.getDeliveryDays(supplierId: supplierId, postalCode: postalCode)) { result in
            LoadingViewController.dismiss(from: self)
            
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
                        print("Error Message: \(response.message)")
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
                print("Request failed with error: \(error)")
            }
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
            dismiss(animated: true, completion: nil)
        }else{
            
            if let deliveryDay = getDeliveryDay(for: selectedDate!, deliveryDays: self.deliveryDays!) {
                let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
                if let vc = storyboard.instantiateViewController(withIdentifier: "CreateALimitViewController") as? CreateALimitViewController {
                    vc.modalPresentationStyle = .custom
                    let pushAnimator = PushAnimator()
                    vc.transitioningDelegate = pushAnimator
                    vc.frequency = self.frequency
                    vc.selectedSupplier = self.selectedSupplier
                    vc.deliveryDay = deliveryDay
                    self.title = "Team Settings"
                    self.present(vc, animated: true)
                }
            } else {
                print("No delivery on this date")
            }
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
        calendar.reloadData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "MMM yyyy"
        self.monthYearLabel.text = formatter.string(from: date)
    }
}
