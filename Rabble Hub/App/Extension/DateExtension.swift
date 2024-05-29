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
    
    
    /// Returns the day of the week as a `Weekday` enum for the current `Date` instance.
    ///
    /// - Returns: A `Weekday` enum value representing the day of the week, or `nil` if the conversion fails.
    func getDayOfWeek() -> Weekday? {
        return Weekday.from(date: self)
    }
    
    
    /// Returns the next date for the specified `Weekday`.
    ///
    /// - Parameter weekday: The `Weekday` to find the next date for.
    /// - Returns: The next date corresponding to the specified `Weekday`.
    func next(_ weekday: Weekday) -> Date? {
        let calendar = Calendar.current
        guard let currentWeekday = self.getDayOfWeek() else { return nil }
        
        let daysToAdd: Int
        if let currentWeekdayInt = calendar.weekdaySymbols.firstIndex(of: currentWeekday.rawValue.capitalized),
           let targetWeekdayInt = calendar.weekdaySymbols.firstIndex(of: weekday.rawValue.capitalized) {
            daysToAdd = (targetWeekdayInt - currentWeekdayInt + 7) % 7
        } else {
            return nil
        }
        
        return calendar.date(byAdding: .day, value: daysToAdd == 0 ? 7 : daysToAdd, to: self)
    }
    
    
    /// Converts the `Date` instance to a string in the format "yyyy-MM-dd HH:mm:ss.SSS".
    ///
    /// - Returns: A string representation of the `Date` instance.
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}
