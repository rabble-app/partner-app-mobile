//
//  InboundDeliveryResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 6/5/24.
//

import Foundation

// MARK: - InboundDeliveryResponse
struct InboundDeliveryResponse: Codable {
    let statusCode: Int
    let message: String
    let data: [InboundDelivery]
}

// MARK: - InboundDelivery
struct InboundDelivery: Codable {
    let id: String
    let accumulatedAmount: String
    let deliveryDate: String
    let createdAt: String
    let deadline: String
    let status: String
    let minimumTreshold: String
    let team: InboundDeliveryTeam

    enum CodingKeys: String, CodingKey {
        case id, accumulatedAmount, deliveryDate, createdAt, deadline, status, team
        case minimumTreshold = "minimumTreshold" // Fixed typo here
    }
}

// MARK: - InboundDeliveryTeam
struct InboundDeliveryTeam: Codable {
    let id: String
    let name: String
    let description: String
    let producer: InboundDeliveryProducer
}

// MARK: - InboundDeliveryProducer
struct InboundDeliveryProducer: Codable {
    let businessName: String
    let id: String
    let categories: [InboundDeliveryCategory]
}

// MARK: - InboundDeliveryCategory
struct InboundDeliveryCategory: Codable {
    let category: CategoryDetail
}

// MARK: - CategoryDetail
struct CategoryDetail: Codable {
    let name: String
}
