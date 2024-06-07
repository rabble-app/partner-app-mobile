//
//  DeliveryDetailsViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/19/24.
//

import UIKit
import Moya

class DeliveryDetailsViewController: UIViewController {

    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var deliveryNavigationController: UINavigationController?
    @IBOutlet var tableviewHeaderContainer: UIView!
    @IBOutlet weak var tableViewConstraintHeight: NSLayoutConstraint!
    
    @IBOutlet var producerName: UILabel!
    @IBOutlet var teamName: UILabel!
    @IBOutlet var orderNumber: UILabel!
    @IBOutlet var category: UILabel!
    @IBOutlet var deliveryDate: UILabel!
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    private let userDataManager = UserDataManager()
    
    var inboundDeliveryDetail: InboundDelivery?
    var orderDetails = [OrderDetail]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.iconBackgroundView.layer.cornerRadius = 28.0
        
        tableviewHeaderContainer.clipsToBounds = true
        tableviewHeaderContainer.layer.cornerRadius = 10
        tableviewHeaderContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        tableView.showsVerticalScrollIndicator = false
        
        self.tableViewConstraintHeight.constant = 77 * 5 // 5 is the number of orders
        fetchInboundDeliveryDetails()
        
        self.title = "Delivery Details"
    }
    
    func fetchInboundDeliveryDetails() {
        LoadingViewController.present(from: self)
        
        let id = self.inboundDeliveryDetail?.team.id ?? ""
        
        apiProvider.request(.getInboundDeliveryDetails(id: id)) { result in
            LoadingViewController.dismiss(from: self)
            self.handleSuppliersResponse(result)
        }
    }
    
    private func handleSuppliersResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            if let jsonString = String(data: response.data, encoding: .utf8) {
                            print("Raw JSON response: \(jsonString)")
                        }
            self.handleSuccessResponse(response)
        case .failure(let error):
            self.showError(error.localizedDescription)
        }
    }
    
    private func handleSuccessResponse(_ response: Response) {
        do {
            let orderDetailsResponse = try response.map(OrderDetailsResponse.self)
            if orderDetailsResponse.statusCode == 200 {
                self.updateInboundDeliveryDetails(orderDetailsResponse.data)
            } else {
                self.showError(orderDetailsResponse.message)
            }
        } catch {
            self.handleMappingError(response)
        }
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
    
    private func updateInboundDeliveryDetails(_ orderDetailsResponse: [OrderDetail]) {
        if orderDetailsResponse.count > 0 {
            self.orderDetails = orderDetailsResponse
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    private func loadData() {
        self.producerName.text = self.inboundDeliveryDetail?.team.producer.businessName
        self.teamName.text = "\(self.inboundDeliveryDetail?.team.name ?? "") 􀱀"
        self.category.text = self.inboundDeliveryDetail?.team.producer.categories.first?.category.name
        self.orderNumber.text = self.inboundDeliveryDetail?.id.firstAndLastFour().uppercased()
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let dateString = self.inboundDeliveryDetail?.deliveryDate ?? ""
        if let date = isoDateFormatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, HH:mm"
            let formattedDate = dateFormatter.string(from: date)
            self.deliveryDate.text = formattedDate
        } else {
            print("Failed to parse date")
        }
        
        self.tableView.reloadData()
        
    }

    @IBAction func confirmButtonTap(_ sender: Any) {
        let signUpView = UIStoryboard(name: "InboundDeliveriesView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "ManuallyCheckItemsViewController") as! ManuallyCheckItemsViewController
        vc.deliveryNavigationController = self.deliveryNavigationController
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true, completion: nil)
    }
}

extension DeliveryDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryDetailsTableViewCell", for: indexPath) as? DeliveryDetailsTableViewCell else {
            return UITableViewCell()
        }
        
        let orderDetail = orderDetails[indexPath.row]
        
        cell.productNameLabel.text = orderDetail.name
        cell.subtitleLabel.text = "\(orderDetail.measuresPerSubunit) \(orderDetail.unitsOfMeasurePerSubunit)"
        cell.quantityLabel.text = "x\(orderDetail.totalQuantity)"
        return cell
    }
}
