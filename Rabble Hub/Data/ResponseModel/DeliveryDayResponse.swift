//
//  DeliveryDayResponse.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/26/24.
//

import Foundation

struct DeliveryDaysResponse: Codable {
    let statusCode: Int
    let message: String
    let data: [DeliveryDay]
}

struct DeliveryDay: Codable {
    let id, day, cutOffDay, cutOffTime: String?
}
