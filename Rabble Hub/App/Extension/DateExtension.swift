//
//  DateExtension.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/27/24.
//

import Foundation

extension Date {
    
    /// Checks if the date is the current date (today).
    /// - Returns: A boolean value indicating whether the date is today.
    func isToday() -> Bool {
        let calendar = Calendar.current
        
        // Extract year, month, and day components from both dates
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let givenComponents = calendar.dateComponents([.year, .month, .day], from: self)
        
        // Compare the components
        return currentComponents.year == givenComponents.year &&
        currentComponents.month == givenComponents.month &&
        currentComponents.day == givenComponents.day
    }
    
    /// Checks if the date is in the current month.
    /// - Returns: A boolean value indicating whether the date is in the current month.
    func isThisMonth() -> Bool {
        let calendar = Calendar.current
        
        // Extract year and month components from both dates
        let currentComponents = calendar.dateComponents([.year, .month], from: Date())
        let givenComponents = calendar.dateComponents([.year, .month], from: self)
        
        // Compare the components
        return currentComponents.year == givenComponents.year &&
        currentComponents.month == givenComponents.month
    }
}
