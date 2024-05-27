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
    
    @IBOutlet var stepContainer: UIView!
    @IBOutlet var stepContainer_height: NSLayoutConstraint!
    @IBOutlet var nextButton: UIButton!
    var isFromEdit: Bool = false
    var frequency = Int()
    var selectedSupplier: Supplier?
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider

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
        
        self.calendarCollectionView.calendarDelegate = self
        self.calendarCollectionView.calendarDataSource = self
    }
    
    func getDeliveryDays() {
        
        guard let supplierId = selectedSupplier?.id else { return }
        
        LoadingViewController.present(from: self)
        apiProvider.request(.getDeliveryDays(supplierId: supplierId)) { result in
            LoadingViewController.dismiss(from: self)
            
            switch result {
            case let .success(response):
                // Handle successful response
                do {
                    let response = try response.map(DeliveryDaysResponse.self)
                    if response.statusCode == 200 || response.statusCode == 201 {
                        print(response.data as Any)
                        SnackBar().alert(withMessage: response.message, isSuccess: true, parent: self.view)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            // reload calendar
                            self.calendarCollectionView.reloadData()
                        }
                        
                    }else{
                        SnackBar().alert(withMessage: response.message, isSuccess: false, parent: self.view)
                        print("Error Message: \(response.message)")
                    }
                    
                } catch {
                    do {
                        let response = try response.map(StandardResponse.self)
                        SnackBar().alert(withMessage: response.message[0], isSuccess: false, parent: self.view)
                    } catch {
                        SnackBar().alert(withMessage: "An error has occured", isSuccess: false, parent: self.view)
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
            let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
            if let vc = storyboard.instantiateViewController(withIdentifier: "CreateALimitViewController") as? CreateALimitViewController {
                vc.modalPresentationStyle = .custom
                let pushAnimator = PushAnimator()
                vc.transitioningDelegate = pushAnimator
                vc.frequency = self.frequency
                vc.selectedSupplier = self.selectedSupplier
                self.title = "Team Settings"
                self.present(vc, animated: true)
            }
        }
    }
    
}


extension ChooseDeliveryDayViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func configureCalendar(_ calendar: JTAppleCalendar.JTAppleCalendarView) -> JTAppleCalendar.ConfigurationParameters {
        
        let parameters = ConfigurationParameters(startDate: Date(), endDate: Date())
        return parameters
    }
    

    func calendar(_ calendar: JTAppleCalendar.JTAppleCalendarView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarViewCell", for: indexPath) as! CalendarViewCell
        cell.configureCell(cellState: cellState)
        return cell
    }
    
    
    func calendar(_ calendar: JTAppleCalendar.JTAppleCalendarView, willDisplay cell: JTAppleCalendar.JTAppleCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
//        let cell:CalendarViewCell = cell as! CalendarViewCell
//        cell.configureCell(cellState: cellState)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 44, height: 44)
    }
    
}
