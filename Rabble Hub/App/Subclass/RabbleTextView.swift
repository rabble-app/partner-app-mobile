//
//  RabbleTextView.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/5/24.
//

import UIKit

@IBDesignable
class RabbleTextView: UITextView {
    
    // MARK: - Properties
    
    @IBInspectable var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    @IBInspectable var placeholderColor: UIColor = Colors.Gray4 {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = font
        label.textColor = placeholderColor
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    // MARK: - Configuration
    
    private func configure() {
        
        self.layer.cornerRadius = 12.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = Colors.Gray5.cgColor
        self.layer.backgroundColor = UIColor.white.cgColor
        self.textContainer.size.width = bounds.width - (textContainerInset.left + textContainerInset.right)
        
        addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: textContainerInset.top + 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: textContainerInset.left + 3),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -textContainerInset.right),
            placeholderLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -textContainerInset.bottom)
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
        updatePlaceholderVisibility()
    }
    
    // MARK: - Overrides
    
    override var text: String! {
        didSet {
            updatePlaceholderVisibility()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Adjust contentOffset to move text input to desired position
        contentInset = UIEdgeInsets(top: 8, left: 12, bottom: 16, right: 16)
        updatePlaceholderVisibility()
    }
    
    override var textContainerInset: UIEdgeInsets {
        get {
            return .zero // Set textContainerInset to zero
        }
        set {}
    }
    
    // MARK: - Private Methods
    
    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    // MARK: - Notification
    
    @objc private func textDidChange() {
        updatePlaceholderVisibility()
    }
    
    // MARK: - Deinitialization
    
    deinit {        
        NotificationCenter.default.removeObserver(self)
    }
}
