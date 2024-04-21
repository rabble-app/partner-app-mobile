//
//  ManuallyCheckItemsViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/21/24.
//

import UIKit
import AVFoundation

class ManuallyCheckItemsViewController: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cameraButton: UIButton!
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var noImageView: UIView!
    @IBOutlet weak var withImageView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageContainerViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.reloadData()
        self.imagePicker.delegate = self
        
        self.imageContainerViewHeightConstraint.constant = 76
        self.withImageView.isHidden = true
        self.cameraButton.setTitle("", for: .normal)
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
        
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension ManuallyCheckItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryDetailsTableViewCell", for: indexPath) as? DeliveryDetailsTableViewCell else {
            return UITableViewCell()
        }

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
        }
        
        // Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}
