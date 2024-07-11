//
//  RabbleCircleView.swift
//  Rabble Hub
//
//  Created by aljon antiola on 7/6/24.
//

import Foundation
import UIKit

/// A custom UIView representing a circular view with a label in the center.
/// This view displays initials or a count of additional members in a group,
/// with a customizable color for the label text.
class RabbleCircleView: UIView {
    private let label = UILabel()
    
    /// Initializes the RabbleCircleView with a given name and a flag indicating if it's the last view in a series.
    /// - Parameters:
    ///   - name: The name to display initials for, or a string representing the count of additional members.
    ///   - isLast: A boolean indicating if this is the last view, affecting the label text color.
    init(name: String, isLast: Bool = false) {
        super.init(frame: .zero)
        setupView(name: name, isLast: isLast)
    }
    
    /// Required initializer for decoding this view from a nib or storyboard, which throws a fatal error.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Sets up the view's properties, including background color, corner radius, and label properties.
    /// Also adds the label as a subview and sets up Auto Layout constraints.
    /// - Parameters:
    ///   - name: The name to display initials for, or a string representing the count of additional members.
    ///   - isLast: A boolean indicating if this is the last view, affecting the label text color.
    private func setupView(name: String, isLast: Bool) {
        backgroundColor = .black
        layer.cornerRadius = 16  // Half of 32 to make it a circle
        layer.masksToBounds = true
        
        label.text = initials(for: name)
        label.font = UIFont(name: "SFPro-Bold", size: 14)
        label.textColor = isLast ? Colors.greenMembers : .white
        label.textAlignment = .center
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        widthAnchor.constraint(equalToConstant: 32).isActive = true
        heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    /// Generates initials from the given name. Takes the first letter of up to the first two components of the name.
    /// - Parameter name: The full name to generate initials for.
    /// - Returns: A string containing the initials.
    private func initials(for name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.prefix(2).map { String($0.first!) }
        return initials.joined()
    }
}

/// A class responsible for creating a horizontal stack view containing multiple RabbleCircleView instances.
/// This class manages the arrangement and display of circular views representing members in a group.
class RabbleCircleStackView {
    /// Creates a horizontal stack view with RabbleCircleView instances for each name provided.
    /// If more than three names are provided, the last view displays the count of additional members.
    /// - Parameter names: An array of names to display in the stack view.
    /// - Returns: A UIStackView containing the RabbleCircleView instances.
    func createStackView(with names: [String]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = -12  // Adjusted spacing for overlap
        
        for index in 0..<min(names.count, 3) {
            let circleView = RabbleCircleView(name: names[index], isLast: false)
            stackView.addArrangedSubview(circleView)
        }
        
        // If there are more than three names, add a view displaying the count of additional members.
        if names.count > 3 {
            let remainingCount = names.count - 3
            let moreView = RabbleCircleView(name: "+ \(remainingCount)", isLast: true)
            stackView.addArrangedSubview(moreView)
        }
        
        return stackView
    }
}
