//
//  DeliveryDetailsViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/19/24.
//

import UIKit
import Moya

class DeliveryDetailsViewController: UIViewController {
    
    @IBOutlet var confirmButton: PrimaryButton!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tableviewHeaderContainer: UIView!
    @IBOutlet weak var tableViewConstraintHeight: NSLayoutConstraint!
    
    @IBOutlet var producerName: UILabel!
    @IBOutlet var teamName: UILabel!
    @IBOutlet var orderNumber: UILabel!
    @IBOutlet var category: UILabel!
    @IBOutlet var deliveryDate: UILabel!
    @IBOutlet weak var teamNameButton: UIButton!
    
    var deliveryNavigationController: UINavigationController?
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    private let userDataManager = UserDataManager()
    private let teamManager = TeamManager()
    
    var inboundDeliveryDetail: InboundDelivery?
    var orderDetails = [OrderDetail]()
    var partnerTeam: PartnerTeam?
    
    var isFromCompleted = false
    
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
        fetchPartnerTeams()
        title = "Delivery Details"
        teamNameButton.setTitle("", for: .normal)
        
        if isFromCompleted {
            self.confirmButton.isHidden = true
        }
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
        
        self.showLoadingIndicator()
        
        apiProvider.request(.getInboundDeliveryDetails(id: id)) { result in
            self.dismissLoadingIndicator()
            self.handleDeliveryDetailsResponse(result)
        }
    }
    
    private func fetchPartnerTeams() {
        teamManager.fetchPartnerTeams(userDataManager: userDataManager) { result in
            switch result {
            case .success(let partnerTeamsResponse):
                self.processPartnerTeams(partnerTeamsResponse.data)
            case .failure(let error):
                self.showError(error.localizedDescription)
            }
        }
    }
    
    private func processPartnerTeams(_ partnerTeams: [PartnerTeam]) {
        
        guard let id = inboundDeliveryDetail?.team.id else { return }
        
        let filteredTeams = partnerTeams.filter { $0.id == id }
        
        if filteredTeams.count > 0 {
            partnerTeam = filteredTeams.first
        } else {
            // Handle empty teams
            // Your logic here for handling empty filtered teams
        }
    }
    
    private func handleDeliveryDetailsResponse(_ result: Result<Response, MoyaError>) {
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
        tableViewConstraintHeight.constant = CGFloat(77 * orderDetails.count) + 10 + 77
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
    
    @IBAction func teamNameButtonTapped(_ sender: Any) {
        guard let partnerTeam = self.partnerTeam else { return }
        goToTeamDetailView(team: partnerTeam)
    }
    
    @IBAction func call(_ sender: Any) {
        let phoneNumber = inboundDeliveryDetail?.team.producer.user.phone ?? ""
        if let phoneURL = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            // Handle the error (e.g., show an alert to the user)
            let alert = UIAlertController(title: "Error", message: "Cannot make a call from this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func confirmButtonTap(_ sender: Any) {
        let signUpView = UIStoryboard(name: "InboundDeliveriesView", bundle: nil)
        let vc = signUpView.instantiateViewController(withIdentifier: "ManuallyCheckItemsViewController") as! ManuallyCheckItemsViewController
        vc.deliveryNavigationController = self.deliveryNavigationController
        vc.orderDetails = self.orderDetails
        vc.inboundDeliveryDetail = self.inboundDeliveryDetail
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true, completion: nil)
    }
    
    func goToTeamDetailView(team: PartnerTeam) {
        let storyboard = UIStoryboard(name: "MyTeamsView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "PartnerDetailsViewController") as? PartnerDetailsViewController {
            vc.partnerTeam = team
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
