//
//  PartnerDetailsViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/21/24.
//

import UIKit
import Moya

class PartnerDetailsViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var img: UIImageView!
    @IBOutlet var initialContainer: UIView!
    @IBOutlet var initialLabel: UILabel!
    @IBOutlet var hostContainer: UIView!
    @IBOutlet var hostLabel: UILabel!
    @IBOutlet var partnerName: UILabel!
    @IBOutlet var deliveryFrequency: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var nextDdeliveryContainer: UIView!
    @IBOutlet var nextDeliveryDate: UILabel!
    @IBOutlet var ordersTableview: UITableView!
    @IBOutlet var contentView_height: NSLayoutConstraint!
    @IBOutlet var orderTableview_height: NSLayoutConstraint!
    @IBOutlet var tableviewHeaderContainer: UIView!
    @IBOutlet var imageContainer: UIView!
    
    var partnerTeam: PartnerTeam?
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    var orderDetails = [OrderDetail]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ordersTableview.delegate = self
        ordersTableview.dataSource = self
        scrollView.delegate = self
        
        self.setUpView()
        self.loadData()
        self.fetchPartnerDetails()
    }
    
    
    func setUpView() {
        orderTableview_height.constant = 2 * 95
        view.layoutIfNeeded()
        
        contentView_height.constant = 780 + orderTableview_height.constant
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentView_height.constant)
        
        initialContainer.layer.cornerRadius = 36.0
        initialContainer.clipsToBounds = true
        hostContainer.layer.cornerRadius = 12.0
        hostContainer.clipsToBounds = true
        imageContainer.layer.cornerRadius = 8.0
        imageContainer.clipsToBounds = true
        
//        nextDdeliveryContainer.layer.borderWidth = 1.0
//        nextDdeliveryContainer.layer.borderColor = Colors.Gray5.cgColor
        nextDdeliveryContainer.layer.cornerRadius = 13.0
        nextDdeliveryContainer.clipsToBounds = true
        
        tableviewHeaderContainer.roundCorners([.topLeft, .topRight], radius: 13)
        ordersTableview.roundCorners([.bottomLeft, .bottomRight], radius: 13)
    }
    
    private func loadData() {
        partnerName.text = partnerTeam?.name
        descLabel.text = partnerTeam?.description
        
        let word = partnerTeam?.name.prefix(1).uppercased()
        if let firstLetter = word?.first {
            initialLabel.text = String(firstLetter).uppercased()
        }
        
        if let imageUrl = URL(string: partnerTeam?.imageUrl ?? "placeholderImage") {
            img?.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
        
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let dateString = partnerTeam?.nextDeliveryDate ?? ""
        if let date = isoDateFormatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM YYYY"
            let formattedDate = dateFormatter.string(from: date)
            self.nextDeliveryDate.text = formattedDate
        } else {
            print("Failed to parse date")
        }

    }
    
    private func fetchPartnerDetails() {
        guard let id = partnerTeam?.id else { return }
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
//        tableViewConstraintHeight.constant = CGFloat(77 * orderDetails.count) + 20
//        tableView.isHidden = orderDetails.isEmpty
        ordersTableview.reloadData()
    }
    
    @IBAction func shareButtonTap(_ sender: Any) {
        
    }
    
    @IBAction func manageTeamButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MyTeamsView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ManageTeamViewController") as? ManageTeamViewController {
            vc.partnerTeam = self.partnerTeam
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension PartnerDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetails.count
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
        
        let orderDetail = orderDetails[indexPath.row]
        cell.supplierLabel.text = orderDetail.name
        cell.descLabel.text = "\(orderDetail.measuresPerSubunit) \(orderDetail.unitsOfMeasurePerSubunit)"
        cell.quantityLabel.text = "x\(orderDetail.totalQuantity)"
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

