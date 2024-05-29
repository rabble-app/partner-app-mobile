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
        guard let day = self.day, let deliveryDayEnum = Weekday(rawValue: day.uppercased()) else {
            return nil
        }
        return Date().next(deliveryDayEnum)
    }
    
    /// Function to get the next cutoff date including the cutoff time.
    /// - Returns: The next cutoff date as a `Date` object.
    func getNextCutoffDate() -> Date? {
        guard let day = self.cutOffDay, let cutoffDayEnum = Weekday(rawValue: day.uppercased()) else {
            return nil
        }
        guard let nextCutoffDate = Date().next(cutoffDayEnum) else {
            return nil
        }
        
        // If cutOffTime is provided, adjust the time components
        if let cutOffTime = self.cutOffTime {
            let timeComponents = cutOffTime.split(separator: ":").map { Int($0) }
            if timeComponents.count == 2, let hour = timeComponents[0], let minute = timeComponents[1] {
                let calendar = Calendar.current
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: nextCutoffDate)
                dateComponents.hour = hour
                dateComponents.minute = minute
                dateComponents.second = 0
                dateComponents.nanosecond = 0
                
                return calendar.date(from: dateComponents)
            }
        }
        
        return nextCutoffDate
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
