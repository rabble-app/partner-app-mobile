//
//  UpdateTeamResponse.swift
//  Rabble Hub
//
//  Created by aljon antiola on 6/12/24.
//

import Foundation

// MARK: - Response
struct UpdateTeamResponse: Decodable {
    let statusCode: Int
    let message: String
    let data: TeamData
}

// MARK: - TeamData
struct TeamData: Decodable {
    let id: String
    let name: String
    let postalCode: String
    let producerId: String
    let hostId: String
    let frequency: Int
    let description: String
    let isPublic: Bool
    let imageUrl: String
    let imageKey: String?
    let nextDeliveryDate: String
    let productLimit: String
    let deliveryDay: String
    let createdAt: String
    let updatedAt: String
    let partnerId: String
}
