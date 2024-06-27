//
//  QrCodeViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/19/24.
//

import UIKit
import QRCodeReader
import AVFoundation
import Moya

class QrCodeViewController: UIViewController {
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    private let userDataManager = UserDataManager()
    
    @IBOutlet var cameraView: QRCodeReaderView! {
        didSet {
            cameraView.setupComponents(with: QRCodeReaderViewControllerBuilder {
                $0.reader = reader
                $0.showTorchButton = false
                $0.showSwitchCameraButton = false
                $0.showCancelButton = false
                $0.showOverlayView = false
                $0.rectOfInterest = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
            })
        }
    }
    
    lazy var reader: QRCodeReader = QRCodeReader()
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton = true
            $0.preferredStatusBarStyle = .lightContent
            $0.showOverlayView = true
            $0.rectOfInterest = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard checkScanPermissions(), !reader.isRunning else { return }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reader.didFindCode = { [weak self] result in
            guard let self = self else { return }
            print("Completion with result: \(result.value) of type \(result.metadataType)")
            self.getSingleCollection(result.value)
        }
        reader.startScanning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reader.stopScanning()
    }
    
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            presentAlert(for: error)
            return false
        }
    }
    
    private func presentAlert(for error: NSError) {
        let alert: UIAlertController
        
        switch error.code {
        case -11852:
            alert = UIAlertController(title: "Error", message: "This app is not authorized to use the Back Camera.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Setting", style: .default) { _ in
                DispatchQueue.main.async {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        default:
            alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        }
        
        present(alert, animated: true)
    }
    
    private func getSingleCollection(_ collectionId: String) {
        showLoadingIndicator()
        let storeId = userDataManager.getUserData()?.partner?.id ?? ""
        apiProvider.request(.getSingleCollection(storeId: storeId, collectionId: collectionId)) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingIndicator()
            self.handleGetSingleCollectionResponse(result)
        }
    }
    
    private func handleGetSingleCollectionResponse(_ result: Result<Response, MoyaError>) {
        switch result {
        case .success(let response):
            handleSuccessGetSingleCollectionResponse(response)
        case .failure(let error):
            showError(error.localizedDescription)
        }
    }
    
    private func handleSuccessGetSingleCollectionResponse(_ response: Response) {
        do {
            let getSingleCollectionResponse = try response.map(GetSingleCollectionResponse.self)
            if getSingleCollectionResponse.statusCode == 200 {
                showSuccessMessage(getSingleCollectionResponse.message)
                goToOrderDetails(getSingleCollectionResponse.data)
            } else {
                showErrorPop()
                showError(getSingleCollectionResponse.message)
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
    
    private func showSuccessMessage(_ message: String) {
        SnackBar().alert(withMessage: message, isSuccess: true, parent: self.view)
    }
    
    private func goToOrderDetails(_ collectionData: CollectionData) {
        let storyboard = UIStoryboard(name: "CustomerCollectionView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OrderDetailsViewController") as? OrderDetailsViewController {
            vc.isFromScanning = true
            vc.selectedCollectionData = collectionData
            vc.modalPresentationStyle = .overFullScreen
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func showErrorPop() {
        let storyboard = UIStoryboard(name: "QrCodeView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "QrCodeErrorPopViewController") as? QrCodeErrorPopViewController {
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            present(vc, animated: true)
        }
    }
}

extension QrCodeViewController: QRCodeReaderViewControllerDelegate {
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        // Implementation not needed
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capture to: \(newCaptureDevice.device.localizedName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true)
    }
}

extension QrCodeViewController: QrCodeStartScanningDelegate {
    func startScanning() {
        reader.startScanning()
    }
}
