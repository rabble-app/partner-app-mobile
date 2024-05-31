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
    
    /// Calculates the cutoff date based on the provided date and the cutoff day and time.
    /// - Parameter date: The selected date.
    /// - Returns: The cutoff date as a `Date` object, or `nil` if calculation fails.
    func getCutoffDate(from date: Date) -> Date? {
        guard let cutOffDayString = cutOffDay,
              let cutOffDay = Weekday(rawValue: cutOffDayString.uppercased()),
              let cutOffTime = cutOffTime else { return nil }
        
        let calendar = Calendar.current
        guard let selectedWeekday = Weekday.from(date: date) else { return nil }
        
        let targetWeekdayIndex = cutOffDay.weekdayIndex()
        let currentWeekdayIndex = selectedWeekday.weekdayIndex()
        
        var dayDifference = targetWeekdayIndex - currentWeekdayIndex
        if dayDifference >= 0 {
            dayDifference -= 7
        }
        
        guard let cutoffDate = calendar.date(byAdding: .day, value: dayDifference, to: date) else { return nil }
        
        let timeComponents = cutOffTime.split(separator: ":").compactMap { Int($0) }
        guard timeComponents.count == 2 else { return nil }
        
        let hour = timeComponents[0]
        let minute = timeComponents[1]
        
        var cutoffDateComponents = calendar.dateComponents([.year, .month, .day], from: cutoffDate)
        cutoffDateComponents.hour = hour
        cutoffDateComponents.minute = minute
        
        return calendar.date(from: cutoffDateComponents)
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
    
    /// Returns the index of the weekday (Sunday = 1, Monday = 2, ..., Saturday = 7)
    func weekdayIndex() -> Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
}
