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
                $0.reader                 = reader
                $0.showTorchButton        = false
                $0.showSwitchCameraButton = false
                $0.showCancelButton       = false
                $0.showOverlayView        = false
                $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
            })
        }
    }
    lazy var reader: QRCodeReader = QRCodeReader()
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader                  = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton         = true
            $0.preferredStatusBarStyle = .lightContent
            $0.showOverlayView         = true
            $0.rectOfInterest          = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
            
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard checkScanPermissions(), !reader.isRunning else { return }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reader.didFindCode = { [self] result in
            print("Completion with result: \(result.value) of type \(result.metadataType)")
            self.getSingleCollection(result.value)
        }
        
        reader.startScanning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        reader.stopScanning()
    }
    
    private func getSingleCollection(_ collectionId: String) {
        self.showLoadingIndicator()
        let storeId = userDataManager.getUserData()?.partner?.id ?? ""
        apiProvider.request(.getSingleCollection(storeId: storeId, collectionId: collectionId)) { result in
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
                self.showSuccessMessage(getSingleCollectionResponse.message)
                self.goToOrderDetails(getSingleCollectionResponse.data)
            } else {
                self.showErrorPop()
                showError(getSingleCollectionResponse.message)
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
    
    func goToOrderDetails(_ collectionData: CollectionData) {
        let storyboard = UIStoryboard(name: "CustomerCollectionView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OrderDetailsViewController") as? OrderDetailsViewController {
            vc.isFromScanning = true
            vc.selectedCollectionData = collectionData
            vc.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func showErrorPop() {
        let storyboard = UIStoryboard(name: "QrCodeView", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "QrCodeErrorPopViewController") as? QrCodeErrorPopViewController {
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
}

extension QrCodeViewController: QRCodeReaderViewControllerDelegate {
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        //reader.stopScanning()
//        let alert = UIAlertController(
//            title: "QRCodeReader",
//            message: String (format:"%@ (of type %@)", result.value, result.metadataType),
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//        
//        self.present(alert, animated: true, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capture to: \(newCaptureDevice.device.localizedName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
}


extension QrCodeViewController: QrCodeStartScanningDelegate {
    func startScanning() {
        self.reader.startScanning()
    }
}
