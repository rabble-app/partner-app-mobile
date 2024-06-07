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
    @IBOutlet var tableviewHeaderContainer: UIView!
    @IBOutlet weak var tableViewConstraintHeight: NSLayoutConstraint!
    
    @IBOutlet var producerName: UILabel!
    @IBOutlet var teamName: UILabel!
    @IBOutlet var orderNumber: UILabel!
    @IBOutlet var category: UILabel!
    @IBOutlet var deliveryDate: UILabel!
    
    var deliveryNavigationController: UINavigationController?
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
        tableView.delegate = self
        tableView.dataSource = self
        iconBackgroundView.layer.cornerRadius = 28.0
        
        setupHeaderView()
        setupTableView()
        
        fetchInboundDeliveryDetails()
        title = "Delivery Details"
    }
    
    private func setupHeaderView() {
        tableviewHeaderContainer.clipsToBounds = true
        tableviewHeaderContainer.layer.cornerRadius = 10
        tableviewHeaderContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    private func setupTableView() {
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.showsVerticalScrollIndicator = false
        tableView.reloadData()
    }

    private func fetchInboundDeliveryDetails() {
        guard let id = inboundDeliveryDetail?.team.id else { return }
        
        LoadingViewController.present(from: self)
        
        apiProvider.request(.getInboundDeliveryDetails(id: id)) { result in
            LoadingViewController.dismiss(from: self)
            self.handleSuppliersResponse(result)
        }
    }
    
    private func handleSuppliersResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            handleSuccessResponse(response)
        case .failure(let error):
            showError(error.localizedDescription)
        }
    }
    
    private func handleSuccessResponse(_ response: Response) {
        do {
            let orderDetailsResponse = try response.map(OrderDetailsResponse.self)
            if orderDetailsResponse.statusCode == 200 {
                updateInboundDeliveryDetails(orderDetailsResponse.data)
            } else {
                showError(orderDetailsResponse.message)
            }
        } catch {
            handleMappingError(response)
        }
    }
    
    private func handleMappingError(_ response: Response) {
        do {
            let errorResponse = try response.map(StandardResponse.self)
            showError(errorResponse.message)
        } catch {
            print("Failed to map response data: \(error)")
        }
    }
    
    private func showError(_ message: String) {
        SnackBar().alert(withMessage: message, isSuccess: false, parent: self.view)
    }
    
    private func updateInboundDeliveryDetails(_ orderDetailsResponse: [OrderDetail]) {
        orderDetails = orderDetailsResponse
        tableViewConstraintHeight.constant = CGFloat(77 * orderDetails.count)
        tableView.isHidden = orderDetails.isEmpty
        tableView.reloadData()
    }

    private func loadData() {
        guard let detail = inboundDeliveryDetail else { return }
        
        producerName.text = detail.team.producer.businessName
        teamName.text = "\(detail.team.name) 􀱀"
        category.text = detail.team.producer.categories.first?.category.name
        orderNumber.text = detail.id.firstAndLastFour().uppercased()
        
        if let deliveryDate = ISO8601DateFormatter().date(from: detail.deliveryDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, HH:mm"
            self.deliveryDate.text = dateFormatter.string(from: deliveryDate)
        } else {
            print("Failed to parse date")
        }
        
        tableView.reloadData()
    }

    @IBAction func confirmButtonTap(_ sender: Any) {
        let signUpView = UIStoryboard(name: "InboundDeliveriesView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "ManuallyCheckItemsViewController") as! ManuallyCheckItemsViewController
        vc.deliveryNavigationController = deliveryNavigationController
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
