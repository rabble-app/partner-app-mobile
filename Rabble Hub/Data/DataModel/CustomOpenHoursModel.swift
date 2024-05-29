//
//  CustomOpenHoursModel.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/21/24.
//

import Foundation

public class CustomOpenHoursModel {
    var storeId: String
    var type: StoreHoursType
    var customOpenHours: [CustomOpenHour]

    // Empty initializer
    init() {
        self.storeId = ""
        self.type = .custom
        self.customOpenHours = []
    }
    
    init(storeId: String, type: StoreHoursType, customOpenHours: [CustomOpenHour] = []) {
        self.storeId = storeId
        self.type = type
        self.customOpenHours = customOpenHours
    }

    func asDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [
            "storeId": storeId,
            "type": type.rawValue
        ]
        
        if type != .allTheTime {
            let enabledCustomOpenHours = customOpenHours.filter { $0.enabled }
            dictionary["customOpenHours"] = enabledCustomOpenHours.map { $0.asDictionary() }
        }
        
        return dictionary
    }
    
    func addCustomOpenHour(_ customOpenHour: CustomOpenHour) {
        customOpenHours.append(customOpenHour)
    }
    
    func removeCustomOpenHour(for day: Day) {
        customOpenHours.removeAll { $0.scheduleDay == day }
    }
    
    func updateCustomOpenHour(_ customOpenHour: CustomOpenHour) {
        if let index = customOpenHours.firstIndex(where: { $0.scheduleDay == customOpenHour.scheduleDay }) {
            customOpenHours[index] = customOpenHour
        } else {
            customOpenHours.append(customOpenHour)
        }
    }
    
    func resetExpandedProperties() {
        for i in 0..<customOpenHours.count {
            customOpenHours[i].startTimeExpanded = false
            customOpenHours[i].endTimeExpanded = false
        }
    }
    
    func allCustomOpenHoursDisabled() -> Bool {
         return customOpenHours.allSatisfy { !$0.enabled }
     }
    
    func populateCustomOpenHours() {
        let initialStartTime = "9:00 AM"
        let initialEndTime = "10:00 PM"
        
        switch type {
        case .custom:
            customOpenHours = [
                CustomOpenHour(scheduleDay: .monday, startTime: initialStartTime, endTime: initialEndTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false),
                CustomOpenHour(scheduleDay: .tuesday, startTime: initialStartTime, endTime: initialEndTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false),
                CustomOpenHour(scheduleDay: .wednesday, startTime: initialStartTime, endTime: initialEndTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false),
                CustomOpenHour(scheduleDay: .thursday, startTime: initialStartTime, endTime: initialEndTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false),
                CustomOpenHour(scheduleDay: .friday, startTime: initialStartTime, endTime: initialEndTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false),
                CustomOpenHour(scheduleDay: .saturday, startTime: initialStartTime, endTime: initialEndTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false),
                CustomOpenHour(scheduleDay: .sunday, startTime: initialStartTime, endTime: initialEndTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false),
            ]
        case .allTheTime:
            break
        case .monToFri:
            customOpenHours = [
                CustomOpenHour(scheduleDay: .monday, startTime: initialStartTime, endTime: initialEndTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false),
                CustomOpenHour(scheduleDay: .tuesday, startTime: initialStartTime, endTime: initialEndTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false),
                CustomOpenHour(scheduleDay: .wednesday, startTime: initialStartTime, endTime: initialEndTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false),
                CustomOpenHour(scheduleDay: .thursday, startTime: initialStartTime, endTime: initialEndTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false),
                CustomOpenHour(scheduleDay: .friday, startTime: initialStartTime, endTime: initialEndTime, enabled: true, startTimeExpanded: false, endTimeExpanded: false),
            ]
        }
    }
}

public struct CustomOpenHour {
    var scheduleDay: Day
    var startTime: String
    var endTime: String
    var enabled: Bool
    var startTimeExpanded: Bool
    var endTimeExpanded: Bool
    var open24Hours: Bool?
    
    func asDictionary() -> [String: Any] {
        return [
            "day": scheduleDay.rawValue,
            "startTime": startTime,
            "endTime": endTime
        ]
    }
}

public enum Day: String, Codable {
    case sunday = "SUNDAY"
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
}

