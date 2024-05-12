//
//  OnboardingViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/16/24.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var infoContainerView: UIView!

    @IBOutlet weak var gradientBGView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }
    
    func setupView() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.gradientBGView.bounds
        gradientLayer.colors = [UIColor.black.withAlphaComponent(1.0).cgColor,
                                UIColor.black.withAlphaComponent(0.0).cgColor]

        // Set custom locations for the colors
        gradientLayer.locations = [0.6, 0.8] // Adjust these values to control the fade location

        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0) // Start from the bottom
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)   // End at the top

        self.infoContainerView.layer.insertSublayer(gradientLayer, at: 0)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? StoryViewController {
            vc.delegate = self
        }
    }
    
}

extension OnboardingViewController: StoryViewControllerDelegate {
    
    func currentProgressIndexChanged(index: Int) {
        print("Index: " + "\(index)")
    }
    
}
