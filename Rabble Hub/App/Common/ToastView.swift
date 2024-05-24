//
//  ToastView.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/23/24.
//

import Foundation
import UIKit
import Toast_Swift

class ToastView {
    static let shared = ToastView()
    
    private init() {} // This prevents others from using the default '()' initializer for this class.
    
    func showToast(_ isSuccess: Bool, message: String, in view: UIView) {
        var style = ToastStyle()
        var image = UIImage()
        style.cornerRadius = 8
        style.imageSize = CGSize(width: 20, height: 20)
        style.maxWidthPercentage = 0.9
        
        if isSuccess {
            style.backgroundColor = Colors.ToastSuccessBackgroundColor
            style.messageColor = Colors.ToastSuccessFontColor
            image = UIImage(imageLiteralResourceName: "toast_success")
        } else {
            style.backgroundColor = Colors.ToastErrorBackgroundColor
            style.messageColor = Colors.ToastErrorFontColor
            image = UIImage(imageLiteralResourceName: "toast_error")
        }
        
        view.makeToast(message, duration: 3.0, position: .top, image: image, style: style)
    }
}
