//
//  StoryViewController.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/9/24.
//

import UIKit

protocol StoryViewControllerDelegate {
    func currentProgressIndexChanged(index: Int)
}

class StoryViewController: UIViewController {

    var delegate: StoryViewControllerDelegate?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    // Progress views
    
    @IBOutlet weak var progressView1: RabbleProgressView!
    @IBOutlet weak var progressView2: RabbleProgressView!
    @IBOutlet weak var progressView3: RabbleProgressView!
    @IBOutlet weak var progressView4: RabbleProgressView!
    
    var currentProgressIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.setTitle("", for: .normal)
        nextButton.setTitle("", for: .normal)
        
        resetProgressBar()
        setCurrentProgressIndex(index: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
    }
    
    func resetProgressBar() {
        progressView1.progress = 0.0
        progressView2.progress = 0.0
        progressView3.progress = 0.0
        progressView4.progress = 0.0
    }
    
    func setCurrentProgressIndex(index: Int) {

        switch index {
        case 0:
            self.animateProgress(progressView: progressView1)
            break
        case 1:
            self.animateProgress(progressView: progressView2)
            break
        case 2:
            self.animateProgress(progressView: progressView3)
            break
        case 3:
            self.animateProgress(progressView: progressView4)
            break
        default:
            return
        }
        
        self.currentProgressIndex = index
        self.delegate?.currentProgressIndexChanged(index: index)
    }
    
    func previousStory() {
        DispatchQueue.main.async{
            switch self.currentProgressIndex {
            case 0:
                self.progressView1.stopProgress(finishAnimation: false)
                self.progressView1.progress = 0.0
                
                break
            case 1:
                if !self.progressView2.isProgressMoreThanHalf() {
                    self.currentProgressIndex -= 1
                }
                self.progressView2.stopProgress(finishAnimation: false)
                self.progressView2.progress = 0.0
                
                break
            case 2:
                if !self.progressView3.isProgressMoreThanHalf() {
                    self.currentProgressIndex -= 1
                }
                self.progressView3.stopProgress(finishAnimation: false)
                self.progressView3.progress = 0.0
                
                break
            case 3:
                if !self.progressView4.isProgressMoreThanHalf() {
                    self.currentProgressIndex -= 1
                }
                self.progressView4.stopProgress(finishAnimation: false)
                self.progressView4.progress = 0.0
                
                break
            default:
                break
            }
            
            self.setCurrentProgressIndex(index: self.currentProgressIndex)
        }
    }
    
    func nextStory() {
        DispatchQueue.main.async{
            switch self.currentProgressIndex {
            case 0:
                self.currentProgressIndex += 1
                self.progressView1.progress = 1.0
                break
            case 1:
                self.currentProgressIndex += 1
                self.progressView2.progress = 1.0
                break
            case 2:
                self.currentProgressIndex += 1
                self.progressView3.progress = 1.0
                break
            case 3:
                self.progressView4.progress = 1.0
                
                break
            default:
                break
            }
            
            self.setCurrentProgressIndex(index: self.currentProgressIndex)
        }
    }
    
    func animateProgress(progressView: RabbleProgressView) {
        
        progressView.setProgress(1.0, duration: 3.0, animated: true) {
            self.setCurrentProgressIndex(index: self.currentProgressIndex + 1)
        }
    }
    
    // MARK: Actions
    
    @IBAction func backButtonTap(_ sender: Any) {
        previousStory()
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
        nextStory()
    }
    
}
