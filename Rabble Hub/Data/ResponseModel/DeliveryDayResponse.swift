//
//  DeliveryDayResponse.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/26/24.
//

import Foundation

/// Struct representing the response containing delivery days.
struct DeliveryDaysResponse: Codable {
    let statusCode: Int
    let message: String
    let data: [DeliveryDay]
}

/// Struct representing a single delivery day.
struct DeliveryDay: Codable {
    let id: String?
    let day: String?
    let cutOffDay: String?
    let cutOffTime: String?
    
    /// Function to get the next delivery date.
    /// - Returns: The next delivery date as a `Date` object.
    func getNextDeliveryDate() -> Date? {
        return getNextDate(for: self.day, at: "10:00")
    }
    
    /// Function to get the next cutoff date including the cutoff time.
    /// - Returns: The next cutoff date as a `Date` object.
    func getNextCutoffDate() -> Date? {
        return getNextDate(for: self.cutOffDay, at: self.cutOffTime)
    }
    
    /// Function to get the next date based on the given day and time.
    /// - Parameters:
    ///   - day: The day as a string.
    ///   - time: The time as a string in "HH:mm" format.
    /// - Returns: The next date as a `Date` object.
    private func getNextDate(for day: String?, at time: String? = nil) -> Date? {
        guard let day = day, let dayEnum = Weekday(rawValue: day.uppercased()) else {
            return nil
        }
        
        guard let nextDate = Date().next(dayEnum) else {
            return nil
        }
        
        if let time = time {
            let timeComponents = time.split(separator: ":").map { Int($0) }
            if timeComponents.count == 2, let hour = timeComponents[0], let minute = timeComponents[1] {
                let calendar = Calendar.current
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: nextDate)
                dateComponents.hour = hour
                dateComponents.minute = minute
                dateComponents.second = 0
                dateComponents.nanosecond = 0
                
                return calendar.date(from: dateComponents)
            }
        }
        
        return nextDate
    }
}

/// Function to get the `DeliveryDay` object for a specific date.
/// - Parameters:
///   - date: The date to check.
///   - deliveryDays: The array of `DeliveryDay` objects to compare against.
/// - Returns: The matching `DeliveryDay` object if found, otherwise `nil`.
func getDeliveryDay(for date: Date, deliveryDays: [DeliveryDay]) -> DeliveryDay? {
    guard let weekday = date.getDayOfWeek() else { return nil }
    for deliveryDay in deliveryDays {
        if let day = deliveryDay.day, let deliveryDayEnum = Weekday(rawValue: day.uppercased()), deliveryDayEnum == weekday {
            return deliveryDay
        }
    }
    return nil
}

/// Enum representing the days of the week.
enum Weekday: String {
    case sunday = "SUNDAY"
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    
    /// Converts a `Date` object to a `Weekday` enum value.
    /// - Parameter date: The `Date` object to convert.
    /// - Returns: A `Weekday` enum value representing the day of the week, or `nil` if the conversion fails.
    static func from(date: Date) -> Weekday? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        guard let weekday = components.weekday else { return nil }
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return nil
        }
    }
}
