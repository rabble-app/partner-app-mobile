//
//  Image.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/11/24.
//

import Foundation
import UIKit

extension UIImage {
    
    public static func withColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image =  UIGraphicsImageRenderer(size: size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
        return image
    }

}
