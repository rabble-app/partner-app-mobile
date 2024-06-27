//
//  OrderDetailsViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/18/24.
//

import UIKit
import Moya

class OrderDetailsViewController: UIViewController {
    
    @IBOutlet var ordersTableview: UITableView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var teamnameLabel: UILabel!
    @IBOutlet var categoryValueLabel: UILabel!
    @IBOutlet var dateTimeValueLabel: UILabel!
    @IBOutlet var tableviewHeaderContainer: UIView!
    @IBOutlet var iconContainer: UIView!
    @IBOutlet weak var tableViewConstraintHeight: NSLayoutConstraint!
    
    var isFromScanning: Bool = false
    @IBOutlet var collectOrderBtn: PrimaryButton!
    
    var selectedCollectionData: CollectionData?
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    private let userDataManager = UserDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.loadData()
        
    }
    
    private func loadData() {
        if selectedCollectionData != nil {
            self.usernameLabel.text = (selectedCollectionData?.user.firstName ?? "") + " " + (selectedCollectionData?.user.lastName ?? "")
            self.teamnameLabel.text = selectedCollectionData?.order.team.name ?? ""
            
            self.categoryValueLabel.text = selectedCollectionData?.order.team.producer.categories.first?.category.name
            
            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let dateString = selectedCollectionData?.dateOfCollection ?? nil,
               let date = isoDateFormatter.date(from: dateString) {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM, HH:mm"
                let formattedDate = dateFormatter.string(from: date)
                
                self.dateTimeValueLabel.text = formattedDate
            } else {
                print("Failed to parse date")
            }

            
            self.tableViewConstraintHeight.constant = CGFloat(95 * (selectedCollectionData?.items.count ?? 0)) // 10 is the number of orders
            
            self.ordersTableview.reloadData()
            
        }
    }
    
    private func setUpView() {
        ordersTableview.delegate = self
        ordersTableview.dataSource = self
        
        tableviewHeaderContainer.clipsToBounds = true
        tableviewHeaderContainer.layer.cornerRadius = 10
        tableviewHeaderContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        ordersTableview.clipsToBounds = true
        ordersTableview.layer.cornerRadius = 10
        ordersTableview.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        iconContainer.layer.cornerRadius = 28.0
        iconContainer.clipsToBounds = true
        ordersTableview.showsVerticalScrollIndicator = false
        
        if isFromScanning {
            self.collectOrderBtn.isHidden = false
        }
    }
    
    @IBAction func collectOrder(_ sender: Any) {
        self.markOrderAsCollected()
    }
    
    func markOrderAsCollected(){
        self.showLoadingIndicator()
        let storeId = userDataManager.getUserData()?.partner?.id ?? ""
        apiProvider.request(.updateOrderAsCollected(storeId: storeId, collectionId: selectedCollectionData?.id ?? "")) { result in
            self.dismissLoadingIndicator()
            self.handleOrderCollectedResponse(result)
        }
    }
    
    private func handleOrderCollectedResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            handleSuccessOrderCollectedResponse(response)
        case .failure(let error):
            showError(error.localizedDescription)
        }
    }
    
    private func handleSuccessOrderCollectedResponse(_ response: Response) {
        do {
            let orderCollectedResponse = try response.map(MarkOrderCollectedResponse.self)
            if orderCollectedResponse.statusCode == 200 {
                self.showSuccessMessage(orderCollectedResponse.message)
                self.goToSuccessPage()
            } else {
                showError(orderCollectedResponse.message)
            }
        } catch {
            handleMappingError(response)
        }
    }
    
    func showSuccessMessage(_ message: String) {
        SnackBar().alert(withMessage: message, isSuccess: true, parent: self.view)
    }
    
    private func handleMappingError(_ response: Response) {
        do {
            let errorResponse = try response.map(StandardResponse.self)
            self.showError(errorResponse.message)
        } catch {
            print("Failed to map response data: \(error)")
        }
    }
    
    private func showError(_ message: String) {
        SnackBar().alert(withMessage: message, isSuccess: false, parent: self.view)
    }
    
    private func goToSuccessPage() {
        let storyboard = UIStoryboard(name: "QrCodeView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OrderCollectedViewController") as? OrderCollectedViewController {
            vc.selectedCollectionData = self.selectedCollectionData
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
}

extension OrderDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCollectionData?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailsTableViewCell", for: indexPath) as? OrderDetailsTableViewCell else {
            return UITableViewCell()
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.border.isHidden = true
        }
        
        let items = selectedCollectionData?.items[indexPath.row]
        cell.supplierLabel.text = items?.product.name
        cell.quantityLabel.text = "x \(items?.quantity ?? "")"
        cell.descLabel.text = "\(items?.product.measuresPerSubUnit ?? 0) \(items?.product.unitsOfMeasurePerSubUnit ?? "")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
        //        if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseFrequencyViewController") as? ChooseFrequencyViewController {
        //            vc.modalPresentationStyle = .custom
        //            let pushAnimator = PushAnimator()
        //            vc.transitioningDelegate = pushAnimator
        //            self.title = "Team Settings"
        //            self.present(vc, animated: true)
        //        }
    }
    
    
}


