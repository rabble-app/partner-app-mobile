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
        guard let topWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        tparent = topWindow
        
        var topPadding: CGFloat = 0
        var bottomPadding: CGFloat = 0
        var tx: CGFloat = 16
        
        if #available(iOS 11.0, *) {
            topPadding = tparent?.safeAreaInsets.top ?? 0
            bottomPadding = tparent?.safeAreaInsets.bottom ?? 0
        }
        
        let iconv = UIImageView(frame: CGRect(x: 16, y: 17, width: 20, height: 19))
        
        var backgroundColor: UIColor
        var messageColor: UIColor
        var image: UIImage?
        
        if isSuccess {
            backgroundColor = Colors.ToastSuccessBackgroundColor
            messageColor =  Colors.ToastSuccessFontColor
            image = UIImage(named: "toast_success")
        } else {
            backgroundColor = Colors.ToastErrorBackgroundColor
            messageColor = Colors.ToastErrorFontColor
            image = UIImage(named: "toast_error")
        }
        
        if let image = image {
            iconv.image = image
            tx = 60
        }
        
        let w = parent.bounds.size.width - 16
        let tw = w - (tx + 16)
        var h: CGFloat = 54
       
        let labelSize2 = msg.boundingRect(with: CGSize(width: tw, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], context: nil).size
        let th2 = labelSize2.height
        
        if th2 > 22 {
            h = th2 + 32
        }
        
        let y = -h
        let frame = CGRect(x: 8, y: y, width: w, height: h)
        let frame2 = CGRect(x: 8, y: (topPadding + 8), width: w, height: h)
        
        tview?.removeFromSuperview()
        tview = UIView(frame: frame)
        tview?.layer.cornerRadius = 8
        tview?.layer.masksToBounds = true
        
        if let iconImage = iconv.image {
            iconv.center.y = tview!.frame.height / 2
            tview?.addSubview(iconv)
        }
        
        let msglb = UILabel(frame: CGRect(x: tx - 16, y: 18, width: tw, height: th2))
        msglb.textColor = messageColor
        msglb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        msglb.numberOfLines = 0
        msglb.text = msg
        tview?.addSubview(msglb)
        
        tparent?.addSubview(tview!)
        tview?.snapshotView(afterScreenUpdates: true)
        isAnimating = true
        tview?.backgroundColor = backgroundColor
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.tview?.frame = frame2
            }, completion: { finished in
                if finished {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        UIView.animate(withDuration: 1.0, animations: {
                            self.tview?.frame = frame
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
