//
//  DeliveryDaysResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/16/24.
//

import Foundation


struct DeliveryDaysResponse: Codable {
    let data: [DeliveryDay]  // Assuming it's an array of DeliveryDay objects
    let message: String
    let statusCode: Int
}

struct DeliveryDay: Codable {
    // Define properties for DeliveryDay object
    // For example:
    // let day: String
    // let timeSlot: String
    // let available: Bool
}
