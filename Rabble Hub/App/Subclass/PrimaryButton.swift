//
//  RabbleButton.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/5/24.
//

import UIKit

/// A custom subclass of UIButton with a predefined style for use in Rabble's user interface.
class PrimaryButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    /// Set the default background colors for enabled and disabled states
    private let enabledBackgroundColor: UIColor = Colors.ButtonPrimary
    private let disabledBackgroundColor: UIColor = Colors.ButtonTertiary
    
    /// Initializes a new instance of the RabbleButton class with the specified frame rectangle.
    ///
    /// - Parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it.
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    /// Initializes a new instance of the RabbleButton class from data in a given decoder.
    ///
    /// - Parameter aDecoder: An unarchiver object.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    /// Configures the appearance and behavior of the RabbleButton.
    ///
    /// If further configuration is necessary, add a tag on interface builder and create a condition here
    /// Ex
    /// if self.tag == 1001 { configureForButton2() }
    private func configure() {
        self.backgroundColor = Colors.ButtonPrimary
        self.layer.cornerRadius = 12
        self.setTitleColor(Colors.ButtonTitleColor, for: .normal)
        //  self.titleLabel?.font = UIFont(name: Properties.Font.GOSHANSANS_BOLD, size: 16)
        self.clipsToBounds = true
    }
    
    private func updateBackgroundColor() {
        self.backgroundColor = isEnabled ? enabledBackgroundColor : disabledBackgroundColor
    }
    
    // MARK: - Overrides
    
    /// Called to update the layout of the button.
    override func layoutSubviews() {
        super.layoutSubviews()
        // Additional layout customization can be performed here if needed.
    }
}
