//
//  DeliveryDaysResponseTests.swift
//  Rabble HubTests
//
//  Created by aljon antiola on 5/31/24.
//

import XCTest
@testable import Rabble_Hub

class DeliveryDaysResponseTests: XCTestCase {
    
    func testGetCutoffDate() {
        // Define a test delivery day with a cutoff day and time
        let deliveryDay = DeliveryDay(id: "1", day: "TUESDAY", cutOffDay: "MONDAY", cutOffTime: "14:00")
        
        // Define a test date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        guard let testDate = dateFormatter.date(from: "2024/05/28 10:00") else {
            XCTFail("Failed to create test date.")
            return
        }
        
        // Calculate the cutoff date
        guard let cutoffDate = deliveryDay.getCutoffDate(from: testDate) else {
            XCTFail("Failed to get cutoff date.")
            return
        }
        
        // Define the expected cutoff date
        guard let expectedCutoffDate = dateFormatter.date(from: "2024/05/27 14:00") else {
            XCTFail("Failed to create expected cutoff date.")
            return
        }
        
        // Assert the cutoff date is as expected
        XCTAssertEqual(cutoffDate, expectedCutoffDate, "The cutoff date is incorrect.")
    }
    
    func testGetDeliveryDay() {
        // Define test delivery days
        let deliveryDays = [
            DeliveryDay(id: "1", day: "MONDAY", cutOffDay: "SUNDAY", cutOffTime: "12:00"),
            DeliveryDay(id: "2", day: "WEDNESDAY", cutOffDay: "TUESDAY", cutOffTime: "16:00"),
            DeliveryDay(id: "3", day: "FRIDAY", cutOffDay: "THURSDAY", cutOffTime: "18:00")
        ]
        
        // Define a test date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        guard let testDate = dateFormatter.date(from: "2024/05/31") else {
            XCTFail("Failed to create test date.")
            return
        }
        
        // Get the delivery day for the test date
        guard let deliveryDay = getDeliveryDay(for: testDate, deliveryDays: deliveryDays) else {
            XCTFail("Failed to get delivery day.")
            return
        }
        
        // Assert the delivery day is as expected
        XCTAssertEqual(deliveryDay.id, "3", "The delivery day ID is incorrect.")
        XCTAssertEqual(deliveryDay.day, "FRIDAY", "The delivery day is incorrect.")
    }
    
    func testWeekdayFromDate() {
        // Define a test date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        guard let testDate = dateFormatter.date(from: "2024/05/28") else {
            XCTFail("Failed to create test date.")
            return
        }
        
        // Get the weekday from the date
        guard let weekday = Weekday.from(date: testDate) else {
            XCTFail("Failed to get weekday from date.")
            return
        }
        
        // Assert the weekday is as expected
        XCTAssertEqual(weekday, .tuesday, "The weekday is incorrect.")
    }
    
    func testWeekdayIndex() {
        // Assert the weekday index is correct for each day
        XCTAssertEqual(Weekday.sunday.weekdayIndex(), 1, "Sunday index is incorrect.")
        XCTAssertEqual(Weekday.monday.weekdayIndex(), 2, "Monday index is incorrect.")
        XCTAssertEqual(Weekday.tuesday.weekdayIndex(), 3, "Tuesday index is incorrect.")
        XCTAssertEqual(Weekday.wednesday.weekdayIndex(), 4, "Wednesday index is incorrect.")
        XCTAssertEqual(Weekday.thursday.weekdayIndex(), 5, "Thursday index is incorrect.")
        XCTAssertEqual(Weekday.friday.weekdayIndex(), 6, "Friday index is incorrect.")
        XCTAssertEqual(Weekday.saturday.weekdayIndex(), 7, "Saturday index is incorrect.")
    }
}
