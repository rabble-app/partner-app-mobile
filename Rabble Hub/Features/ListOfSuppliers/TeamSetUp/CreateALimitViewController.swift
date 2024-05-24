//
//  CreateALimitViewController.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import UIKit
import Moya

class CreateALimitViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var progressBar: UIView!
    @IBOutlet var selectOptionButton: UIButton!
    @IBOutlet var primaryDescLabel: UILabel!
    @IBOutlet var secondaryDescLabel: UILabel!
    @IBOutlet var reminderLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var stepContainer_height: NSLayoutConstraint!
    @IBOutlet var stepContainer: UIView!
    var isFromEdit: Bool = false
    var frequency = Int()
    var selectedSupplier: Supplier?
    
    var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    func setUpView() {
        let progressBarWidth = 3 * progressBar.frame.width / 3.0
        let completedProgressBarWidth = progressBarWidth
        let greenProgressBarFrame = CGRect(x: 0, y: 0, width: completedProgressBarWidth, height: progressBar.frame.height)
        
        let completedView = UIView(frame: greenProgressBarFrame)
        completedView.backgroundColor = Colors.ButtonSecondary
        
        progressBar.addSubview(completedView)
        
        selectOptionButton.layer.borderWidth = 1.0
        selectOptionButton.layer.borderColor = Colors.Gray5.cgColor
        selectOptionButton.layer.cornerRadius = 12.0
        selectOptionButton.clipsToBounds = true
        
        if isFromEdit {
            nextButton.setTitle("Save Changes", for: .normal)
            self.titleLabel.text = "Edit Product Limit"
            self.stepContainer.isHidden = true
            self.stepContainer_height.constant = 0
        }
        
    }
    
    
    @IBAction func backButtonTap(_ sender: Any) {
        if let presentingViewController = presentingViewController {
               let pushAnimator = PushAnimator()
               presentingViewController.transitioningDelegate = pushAnimator
           }
           presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectOptionButtonTap(_ sender: Any) {
        
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        if isFromEdit {
            dismiss(animated: true, completion: nil)
        }else{
            self.createBuyingTeam()
           
        }
    }
    
    func goToSetUpTeamSuccess() {
        let storyboard = UIStoryboard(name: "TeamSetUp", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SetupTeamSuccessViewController") as? SetupTeamSuccessViewController {
            vc.modalPresentationStyle = .custom
            let pushAnimator = PushAnimator()
            vc.transitioningDelegate = pushAnimator
            self.present(vc, animated: true)
        }
    }
    
    func createBuyingTeam() {
        
        guard let postalCode = StoreManager.shared.postalCode else {
             return
         }
        
        guard let storeId = StoreManager.shared.storeId else {
             return
         }
        
        guard let userId = StoreManager.shared.userId else {
             return
         }
        
        LoadingViewController.present(from: self)
        //MARK: Some values are still placeholder
        apiProvider.request(.createBuyingTeam(
            name: self.selectedSupplier?.businessName ?? "",
            postalCode: postalCode,
            producerId: selectedSupplier?.id ?? "",
            hostId: userId,
            partnerId: storeId,
            frequency: self.frequency,
            description: "",
            productLimit: 100, //placeholder
            deliveryDay: "MONDAY", //placeholder
            nextDeliveryDate: "2024-07-10 15:00:00.000", //placeholder
            orderCutOffDate: "2024-07-07 15:00:00.000" //placeholder
        )) { result in
            LoadingViewController.dismiss(from: self)
            switch result {
            case let .success(response):
                // Handle successful response
                do {
                    let response = try response.map(CreateBuyingTeamResponse.self)
                    if response.statusCode == 200 || response.statusCode == 201 {
                        print(response.data as Any)
                        SnackBar().alert(withMessage: response.message, isSuccess: true, parent: self.view)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.goToSetUpTeamSuccess()
                        }
                       
                    }else{
                        SnackBar().alert(withMessage: response.message, isSuccess: false, parent: self.view)
                        print("Error Message: \(response.message)")
                    }
                    
                } catch {
                    SnackBar().alert(withMessage: "\(error)", isSuccess: false, parent: self.view)
                    print("Failed to map response data: \(error)")
                }
            case let .failure(error):
                // Handle error
                SnackBar().alert(withMessage: "\(error)", isSuccess: false, parent: self.view)
                print("Request failed with error: \(error)")
            }
            
        }
    }

}
