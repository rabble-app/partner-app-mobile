//
//  ManuallyCheckItemsViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/21/24.
//

import UIKit
import AVFoundation
import Moya

class ManuallyCheckItemsViewController: UIViewController {

    var deliveryNavigationController: UINavigationController?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var checkInButton: PrimaryButton!
    @IBOutlet weak var noteTextView: RabbleTextView!
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var noImageView: UIView!
    @IBOutlet weak var withImageView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewConstraintHeight: NSLayoutConstraint!
    
    @IBOutlet weak var totalQuantityChecked: UILabel!
    
    var inboundDeliveryDetail: InboundDelivery?
    var orderDetails: [OrderDetail]?
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.reloadData()
        self.imagePicker.delegate = self
        
        self.checkInButton.isEnabled = false
        self.imageContainerViewHeightConstraint.constant = 76
        self.withImageView.isHidden = true
        self.cameraButton.setTitle("", for: .normal)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))

        guard let orderCount = self.orderDetails?.count else {
            self.tableViewConstraintHeight.constant = CGFloat(70 * 0)
            return
        }
        
        self.tableViewConstraintHeight.constant = CGFloat(70 * orderCount)
    }
    
    @IBAction func cameraButtonTap(_ sender: Any) {
        checkCameraPermission()
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                // The user has previously granted access to the camera.
                self.openCamera()
            case .notDetermined:
                // Request camera access
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.openCamera()
                    } else {
                        // Display an alert or handle denial gracefully
                    }
                }
            case .denied, .restricted:
                // Display an alert or prompt the user to enable camera access in settings
                let alert  = UIAlertController(title: "Warning", message: "You need to enable camera access in settings.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            default:
                break
            }
        }
    
    func openCamera() {
        DispatchQueue.main.async {
            if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.imagePicker.allowsEditing = true
                self.imagePicker.delegate = self
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else{
                let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func checkInStoreButtonTap(_ sender: Any) {
        checkInStore()
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func checkInStore() {
        LoadingViewController.present(from: self)
   
        guard let storeId = UserDataManager().getUserData()?.partner?.id,
              let orderId = inboundDeliveryDetail?.id,
              let orders = self.orderDetails
        else {
            LoadingViewController.dismiss(from: self)
            return
        }
        
        var imageData: Data?
        if let imageJpg = self.imageView.image?.jpegData(compressionQuality: 0.8) {
            imageData = imageJpg
        }
        let products = OrderDetailsProcessor.getProductIdsAndQuantities(from: orders)
        if products.count == 0 {
            LoadingViewController.dismiss(from: self)
            return
        }
        
        apiProvider.request(.confirmOrderReceipt(
            storeId: storeId,
            orderId: orderId,
            products: products,
            note: noteTextView.text,
            file: imageData)) { result in
                LoadingViewController.dismiss(from: self)
                self.handleResponse(result)
            }
    }
    
    func updateCheckInButtonStatus() {
        self.checkInButton.isEnabled = false
        guard let imageJpg = self.imageView.image, let orders = self.orderDetails else {
            return
        }
        
        let products = OrderDetailsProcessor.getProductIdsAndQuantities(from: orders)
        if products.count != self.orderDetails?.count {
            return
        }
        self.checkInButton.isEnabled = true
    }
    
    private func handleResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            do {
                let createResponse = try response.map(CreateBuyingTeamResponse.self)
                if createResponse.statusCode == 200 || createResponse.statusCode == 201 {
                    SnackBar().alert(withMessage: createResponse.message, isSuccess: true, parent: self.view)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.gotoSuccessState()
                    }
                } else {
                    self.showSnackBar(message: createResponse.message, isSuccess: false)
                }
            } catch {
                self.handleErrorResponse(response)
            }
        case .failure(let error):
            self.showSnackBar(message: "\(error)", isSuccess: false)
        }
    }
    
    private func handleErrorResponse(_ response: Response) {
        do {
            let standardResponse = try response.map(StandardResponse.self)
            self.showSnackBar(message: standardResponse.message , isSuccess: false)
        } catch {
            print("Failed to map response data: \(error)")
        }
    }
    
    private func showSnackBar(message: String, isSuccess: Bool) {
        SnackBar().alert(withMessage: message, isSuccess: isSuccess, parent: self.view)
    }
    
    private func gotoSuccessState() {
        let inboundView = UIStoryboard(name: "InboundDeliveriesView", bundle: nil)
        let vc = inboundView.instantiateViewController(withIdentifier: "SuccessStateViewController") as! SuccessStateViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.isModalInPresentation = true
        vc.deliveryNavigationController = self.deliveryNavigationController
        present(vc, animated: true, completion: nil)
    }
}

extension ManuallyCheckItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let orderCount = self.orderDetails?.count else {
            return 0
        }
        
        return orderCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmDeliveryTableViewCell", for: indexPath) as? ConfirmDeliveryTableViewCell else {
            return UITableViewCell()
        }
        
        guard let orderDetail = orderDetails?[indexPath.row] else {
            return cell
        }
        
        cell.quantityDidChange = { cell, quantity in
            if let indexPath = tableView.indexPath(for: cell) {
                self.orderDetails?[indexPath.row].quantity = quantity
                self.totalQuantityChecked.text = OrderDetailsProcessor.getTotalQuantity(from: self.orderDetails).toString()
                
                self.updateCheckInButtonStatus()
            }
        }
        cell.itemTitleLabel.text = orderDetail.name
        cell.itemSubtitleLabel.text =  "\(orderDetail.measuresPerSubunit) \(orderDetail.unitsOfMeasurePerSubunit)"
        
        return cell
    }
}

extension ManuallyCheckItemsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get the image from the info dictionary.
        if let editedImage = info[.editedImage] as? UIImage {
            self.imageContainerViewHeightConstraint.constant = 206
            self.withImageView.isHidden = false
            self.noImageView.isHidden = true
            self.imageView.image = editedImage
            self.updateCheckInButtonStatus()
        }
        
        // Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}
