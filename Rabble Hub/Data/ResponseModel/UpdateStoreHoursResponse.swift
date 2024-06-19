//
//  UpdateStoreHoursResponse.swift
//  Rabble Hub
//
//  Created by aljon antiola on 6/19/24.
//

import Foundation

// MARK: - Response
struct UpdateStoreHoursResponse: Decodable {
    let message: String
    let statusCode: Int
    let data: UpdateStoreHoursData
}

// MARK: - DataClass
struct UpdateStoreHoursData: Decodable {
    let id: String
    let partnerId: String
    let type: String
    let updatedAt: String
    let createdAt: String
}
