//
//  RabbleProgressView.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/11/24.
//

import UIKit

class RabbleProgressView: UIProgressView {
    
    // Completion block type
    typealias CompletionBlock = (Int) -> Void
    
    // Property to hold the completion block
    var completion: CompletionBlock?
    
    var inProgress = false
    var animator: UIViewPropertyAnimator?
    // Default tint color
    private let brandTintColor: UIColor = Colors.ButtonPrimary
    
    // Override the initializer to set the default tint color
    override init(frame: CGRect) {
        super.init(frame: frame)

        let img = UIImage.withColor(brandTintColor)
        self.progressImage = img
        
        self.progressTintColor = brandTintColor
    }
    
    // Required initializer when subclassing UIProgressView
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.progressTintColor = brandTintColor
    }
    
    // Overrides the progress Tint Color with image to avoid fade effect
    open override var progressTintColor: UIColor! {
        didSet {
            let img = UIImage.withColor(progressTintColor)
            progressImage = img
        }
    }
    
    /// Sets progress with animation and allows specifying a completion block to execute when the animation finishes.
    func setProgress(_ progress: Float, duration: TimeInterval, animated: Bool, completion: @escaping CompletionBlock) {
 
        print("setProgress: " + "\(self.tag)")
        // Set the completion block
        self.completion = completion

        self.progress = 0.0
        layoutIfNeeded()

        if let currentAnimator = self.animator {
            currentAnimator.stopAnimation(true)
        }
        
        self.animator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            self.progress = progress
            self.layoutIfNeeded()
        }
        
        self.animator!.startAnimation()
        
        self.animator!.addCompletion { position in
            switch position {
            case .start:
                break
            case .current:
                break
            case .end:
                
                if self.completion != nil {
                    self.completion?(self.tag)
                }
                
                break
            @unknown default:
                break
            }
            
            self.animator = nil
        }
    }
    
    /// Stops the progress animation, optionally allowing to finish or reset the progress.
    func stopProgress(finishAnimation: Bool) {
        if self.animator != nil {
            if isInProgress() {
                self.completion = nil
                self.animator?.stopAnimation(false)
                self.animator?.finishAnimation(at: .end)
                
                if finishAnimation {
                    self.progress = 1.0
                }
                else {
                    self.progress = 0.0
                }
                
                self.animator = nil
            }
        }
    }
    
    /// Checks if a progress animation is currently in progress.
    func isInProgress() -> Bool {
        guard let fractionComplete = self.animator?.fractionComplete else {
            return false
        }

        return fractionComplete != 0.0 || fractionComplete != 1.0
    }
    
    /// Checks if progress is half or more than half completed.
    func isProgressMoreThanHalf() -> Bool {
        guard let fractionComplete = self.animator?.fractionComplete else {
            if self.progress == 1.0 {
                return true
            }
            
            return false
        }
        
        return fractionComplete >= 0.5
    }
}
