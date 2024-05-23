//
//  AddStoreHoursResponse.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/20/24.
//

import Foundation

struct AddStoreHoursResponse: Codable {
    let statusCode: Int
    let message: String
    let data: StoreHours
}

struct StoreHours: Codable {
    let id: String
    let partnerId: String
    let type: String
    let createdAt: String
    let updatedAt: String
}
