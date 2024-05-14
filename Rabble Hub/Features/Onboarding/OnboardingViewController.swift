//
//  OnboardingViewController.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/16/24.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var infoContainerView: UIView!
    
    // Contents
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        self.setupGradientView()
    }
    
    func setupGradientView() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.infoContainerView.bounds
        gradientLayer.colors = [UIColor.black.withAlphaComponent(1.0).cgColor,
                                UIColor.black.withAlphaComponent(0.0).cgColor]

        // Set custom locations for the colors
        gradientLayer.locations = [0.6, 0.8] // Adjust these values to control the fade location

        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0) // Start from the bottom
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)   // End at the top

        if let _ = self.infoContainerView.layer.sublayers?.first as? CAGradientLayer {
            self.infoContainerView.layer.sublayers?[0] = gradientLayer
        }
        else {
            self.infoContainerView.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? StoryViewController {
            vc.delegate = self
        }
    }
    
}

extension OnboardingViewController: StoryViewControllerDelegate {
    
    // MARK: StoryViewController delegate
    
    func currentProgressIndexChanged(index: Int) {
        switch index {
        case 0:
            self.titleLabel.text = "RABBLE"
            self.subtitleLabel.text = "The Team Buying Platform"
            self.subjectLabel.text = "Buy as a Team"
            self.descriptionLabel.text = "Combine orders with friends and neighbours to move up the supply chain and buy direct from farmer, producer or importer"
            break
        case 1:
            self.titleLabel.text = "Support"
            self.subtitleLabel.text = "Sustatinable Producers"
            self.subjectLabel.text = "Bypass Conventional Supply Chains"
            self.descriptionLabel.text = "The conventional supply chain fails small producers. Give local producers and sustainable farming practices a chance by going direct"
            break
        case 2:
            self.titleLabel.text = "Help"
            self.subtitleLabel.text = "The Environment"
            self.subjectLabel.text = "Slash your carbon footprint"
            self.descriptionLabel.text = "Align your community and collectively avoid inefficient, CO2 intensive and wasteful supply chains that are bad for the environment and bad for the food itself"
            break
        case 3:
            self.titleLabel.text = "Access"
            self.subtitleLabel.text = "Better Products"
            self.subjectLabel.text = "Access sustainable high quality products"
            self.descriptionLabel.text = "Get access to a curation of the highest quality sustainable producers for supermarket prices"
            break
        default:
            break
        }
    }
    
}
