//
//  StoreOpenHoursResponse.swift
//  Rabble Hub
//
//  Created by aljon antiola on 6/18/24.
//

import Foundation

struct StoreOpenHourResponse: Decodable {
    let statusCode: Int
    let message: String
    let data: StoreOpenHourData
}

struct StoreOpenHourData: Decodable {
    let id: String
    let partnerId: String
    let type: String
    let createdAt: String
    let updatedAt: String
    let customOpenHours: [StoreCustomOpenHour]?

    enum CodingKeys: String, CodingKey {
        case id
        case partnerId
        case type
        case createdAt
        case updatedAt
        case customOpenHours = "CustomOpenHours"
    }
}

struct StoreCustomOpenHour: Decodable {
    let id: String
    let openHourId: String
    let day: String
    let startTime: String
    let endTime: String
    let createdAt: String
    let updatedAt: String
}
