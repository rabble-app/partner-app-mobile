//
//  CreateBuyingTeamResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/22/24.
//

import Foundation

// MARK: - Response Model
struct CreateBuyingTeamResponse: Codable {
    let statusCode: Int
    let message: String
    let data: BuyingTeamData?
}

// MARK: - Buying Team Data Model
struct BuyingTeamData: Codable {
    let id: String?
    let name: String?
    let postalCode: String?
    let producerId: String?
    let hostId: String?
    let frequency: Int?
    let description: String?
    let isPublic: Bool?
    let imageUrl: String?
    let imageKey: String?
    let nextDeliveryDate: String?
    let productLimit: String?
    let deliveryDay: String?
    let createdAt: String?
    let updatedAt: String?
    let partnerId: String?
}
