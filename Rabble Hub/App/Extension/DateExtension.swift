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
    
    /// Compares the date with another date down to the day level (ignoring time components).
    /// - Parameter otherDate: The other date to compare with.
    /// - Returns: A boolean value indicating whether the two dates are the same at the day level.
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        
        // Extract year, month, and day components from both dates
        let selfComponents = calendar.dateComponents([.year, .month, .day], from: self)
        let otherComponents = calendar.dateComponents([.year, .month, .day], from: otherDate)
        
        // Compare the components
        return selfComponents.year == otherComponents.year &&
        selfComponents.month == otherComponents.month &&
        selfComponents.day == otherComponents.day
    }
}
