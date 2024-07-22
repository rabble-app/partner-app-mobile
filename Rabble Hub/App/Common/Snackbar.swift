//
//  Snackbar.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/24/24.
//

import UIKit

class SnackBar {
    
    var tview: UIView?
    var isAnimating: Bool = false
    var tparent: UIView?
    
    func alert(withMessage msg: String, isSuccess: Bool, parent: UIView) {
        showAlert(withMessage: msg, iconName: isSuccess ? "toast_success" : "toast_error", backgroundColor: isSuccess ? Colors.ToastSuccessBackgroundColor : Colors.ToastErrorBackgroundColor, parent: parent, duration: isSuccess ? 2.0 : 3.0, textColor: isSuccess ? Colors.ToastSuccessFontColor : Colors.ToastErrorFontColor)
    }
    
    func alertInfo(withMessage msg: String, parent: UIView) {
        showAlert(withMessage: msg, iconName: "toast_info", backgroundColor: Colors.ToastInfoBackgroundColor, parent: parent, duration: 3.0, textColor: Colors.ToastInfoFontColor)
    }
    
    private func showAlert(withMessage msg: String, iconName: String, backgroundColor: UIColor, parent: UIView, duration: Double, textColor: UIColor) {
        guard let topWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        tparent = topWindow
        
        let topPadding: CGFloat = tparent?.safeAreaInsets.top ?? 0
        let horizontalPadding: CGFloat = 16
        let iconSize = CGSize(width: 20, height: 19)
        
        let iconImageView = createIconImageView(iconName: iconName, iconSize: iconSize)
        let messageLabel = createMessageLabel(message: msg, availableWidth: parent.bounds.size.width - (horizontalPadding * 2) - iconSize.width, horizontalPadding: horizontalPadding, textColor: textColor)
        
        let snackbarHeight = max(messageLabel.bounds.height + 32, 54)
        
        let initialFrame = CGRect(x: horizontalPadding / 2, y: -snackbarHeight, width: parent.bounds.size.width - horizontalPadding, height: snackbarHeight)
        let finalFrame = CGRect(x: horizontalPadding / 2, y: topPadding + horizontalPadding / 2, width: parent.bounds.size.width - horizontalPadding, height: snackbarHeight)
        
        setupSnackbarView(initialFrame: initialFrame, finalFrame: finalFrame, backgroundColor: backgroundColor, iconImageView: iconImageView, messageLabel: messageLabel, duration: duration)
    }
    
    private func createIconImageView(iconName: String, iconSize: CGSize) -> UIImageView {
        let iconImageView = UIImageView(frame: CGRect(x: 12, y: 17, width: iconSize.width, height: iconSize.height))
        iconImageView.image = UIImage(named: iconName)
        return iconImageView
    }
    
    private func createMessageLabel(message: String, availableWidth: CGFloat, horizontalPadding: CGFloat, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = message
        label.textColor = textColor
        
        let labelSize = message.boundingRect(with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font!], context: nil).size
        
        label.frame = CGRect(x: 24 + horizontalPadding, y: 18, width: availableWidth, height: labelSize.height)
        
        return label
    }
    
    private func setupSnackbarView(initialFrame: CGRect, finalFrame: CGRect, backgroundColor: UIColor, iconImageView: UIImageView, messageLabel: UILabel, duration: Double) {
        tview?.removeFromSuperview()
        tview = UIView(frame: initialFrame)
        tview?.backgroundColor = backgroundColor
        tview?.layer.cornerRadius = 8
        tview?.layer.masksToBounds = true
        
        tview?.addSubview(iconImageView)
        tview?.addSubview(messageLabel)
        
        tparent?.addSubview(tview!)
        
        isAnimating = true
        animateSnackbarView(to: finalFrame, duration: duration)
    }
    
    private func animateSnackbarView(to finalFrame: CGRect, duration: Double) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.tview?.frame = finalFrame
            }, completion: { finished in
                if finished {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        UIView.animate(withDuration: 1.0, animations: {
                            self.tview?.frame.origin.y = -finalFrame.height
                        }, completion: { finished in
                            if finished {
                                self.isAnimating = false
                                self.tview?.removeFromSuperview()
                            }
                        })
                    }
                }
            })
        }
    }
}
