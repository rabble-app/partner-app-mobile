//
//  Colors.swift
//  Rabble Partner
//
//  Created by Franz Henri De Guzman on 4/16/24.
//

import Foundation
import UIKit

@objcMembers
class Colors: NSObject {
    static let Error: UIColor = .systemPink
    
    /// Color used mostly as the base background color of any view controller. First level of content background base. (Also used as "Primary" button text color.)
    static let BackgroundPrimary = Colors.getColor(named: "background_primary")
    static let ButtonPrimary = Colors.getColor(named: "button_primary")
    static let ButtonSecondary = Colors.getColor(named: "button_secondary")
    static let ButtonTertiary = Colors.getColor(named: "button_tertiary")
    static let ButtonTitleColor = Colors.getColor(named: "button_title_color")
    static let Gray1 = Colors.getColor(named: "gray_1")
    static let Gray2 = Colors.getColor(named: "gray_2")
    static let Gray3 = Colors.getColor(named: "gray_3")
    static let Gray4 = Colors.getColor(named: "gray_4")
    static let Gray5 = Colors.getColor(named: "gray_5")
    
    static let Today = Colors.getColor(named: "calendar_today")
    static let Upcoming = Colors.getColor(named: "calendar_upcoming")
    static let Past = Colors.getColor(named: "calendar_past")
    
    static let ToastSuccessFontColor = Colors.getColor(named: "toast_success_font_color")
    static let ToastErrorFontColor = Colors.getColor(named: "toast_error_font_color")
    static let ToastInfoFontColor = Colors.getColor(named: "toast_info_font_color")
    static let ToastWarningFontColor = Colors.getColor(named: "toast_warning_font_color")
    
    static let ToastSuccessBackgroundColor = Colors.getColor(named: "toast_success_background_color")
    static let ToastErrorBackgroundColor = Colors.getColor(named: "toast_error_background_color")
    static let ToastInfoBackgroundColor = Colors.getColor(named: "toast_info_background_color")
    static let ToastWarningBackgroundColor = Colors.getColor(named: "toast_warning_background_color")
    
    /*
    /// Color used for content cards in view controller or dialog base background. Secondary level of content background base.
    static let BackgroundSecondary = Colors.getColor(named: "background_secondary")
    
    /// Colors used for content in dialogs. Third level of content background base.
    static let BackgroundTeritary = Colors.getColor(named: "background_teritary")
    
    
    /// App's primary tint color.
    static let Primary = Colors.getColor(named: "primary")
    
    /// Color that represents warning.
    static let Warning = Colors.getColor(named: "warning")
    
    /// Color that represents danger, error, negative or anything that requires immediate attention.
    static let Danger = Colors.getColor(named: "danger")
    
    /// Color for main text, titles, primary use.
    static let TextPrimary = Colors.getColor(named: "text_primary")
    
    /// Color for sub headers and secondary use.
    static let TextSecondary = Colors.getColor(named: "text_secondary")
    
    /// Color for sub headers and secondary use.
    static let TextTertiary = Colors.getColor(named: "text_tertiary")
    
    /// Color for out of focus text, legend or footnote.
    static let TextMuted = Colors.getColor(named: "text_muted")
    
    static let TextButtonPrimary = Colors.getColor(named: "text_button_primary")
    
    static let TextDisabled = Colors.getColor(named: "text_disabled")
     
     */
    
    static func getColor(named colorName: String) -> UIColor {
        guard let color = UIColor(named: colorName)
        else {
            assertionFailure("Colors not found in Colors.xcassets, please check naming")
            return Colors.Error
        }
        
        return color
    }
     
}
