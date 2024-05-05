//
//  RabbleTextField.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/5/24.
//

import UIKit

/// A custom subclass of UITextField with a predefined style for use in Rabble's user interface.
class RabbleTextField: UITextField {
    
    /// Initializes a new instance of the RabbleTextField class with the specified frame rectangle.
    ///
    /// - Parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it.
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    /// Initializes a new instance of the RabbleTextField class from data in a given decoder.
    ///
    /// - Parameter aDecoder: An unarchiver object.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    /// Configures the appearance and behavior of the RabbleTextField.
    ///
    /// If further configuration is necessary, add a tag on interface builder and create a condition here
    /// Ex
    /// if self.tag == 1001 { configureForTextField2() }
    ///
    func configure() {
        self.borderStyle = .none
        self.layer.cornerRadius = 12.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = Colors.Gray5.cgColor
        self.layer.backgroundColor = UIColor.white.cgColor
    }

    // MARK: - Overrides
    
    /// Returns the drawing rectangle for the text area of the text field.
    ///
    /// - Parameter bounds: The bounds rectangle of the text field.
    /// - Returns: The drawing rectangle for the text area of the text field.
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 10))
    }
    
    /// Returns the drawing rectangle for the placeholder text of the text field.
    ///
    /// - Parameter bounds: The bounds rectangle of the text field.
    /// - Returns: The drawing rectangle for the placeholder text of the text field.
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 10))
    }
    
    /// Returns the drawing rectangle for the editable text area of the text field.
    ///
    /// - Parameter bounds: The bounds rectangle of the text field.
    /// - Returns: The drawing rectangle for the editable text area of the text field.
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 10))
    }
}
