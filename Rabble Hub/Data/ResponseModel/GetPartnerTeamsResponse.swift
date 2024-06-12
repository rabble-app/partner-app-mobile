//
//  GetPartnerTeamsResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 6/10/24.
//

import Foundation

// MARK: - GetPartnerTeamsResponse
struct GetPartnerTeamsResponse: Codable {
    let statusCode: Int
    let message: String
    let data: [PartnerTeam]
}

struct GetPartnerTeamResponse: Codable {
    let statusCode: Int
    let message: String
    let data: PartnerTeam
}

// MARK: - Team
struct PartnerTeam: Codable {
    let id: String
    let name: String
    let postalCode: String
    let producerId: String
    let hostId: String
    var frequency: Int
    let description: String?
    let isPublic: Bool
    let imageUrl: String
    let imageKey: String?
    let nextDeliveryDate: String
    var productLimit: String
    var deliveryDay: String
    let createdAt: String
    let updatedAt: String
    let partnerId: String?
    let members: [Member]
    let producer: PartnerTeamsProducer
    let host: Host
}

// MARK: - Member
struct Member: Codable {
    let id: String
    let user: PartnerUser
}

// MARK: - PartnerUser
struct PartnerUser: Codable {
    let firstName: String?
    let lastName: String?
}

// MARK: - Producer
struct PartnerTeamsProducer: Codable {
    let id: String
    let userId: String
    let stripeConnectId: String?
    let isVerified: Bool
    let imageUrl: String
    let imageKey: String?
    let businessName: String
    let businessAddress: String
    let accountsEmail: String?
    let salesEmail: String?
    let minimumTreshold: String
    let website: String?
    let description: String?
    let vat: String?
    let paymentTerm: Int
    let createdAt: String
    let updatedAt: String
    let user: PartnerUser
    let categories: [PartnerTeamsCategoryContainer]
}

// MARK: - CategoryContainer
struct PartnerTeamsCategoryContainer: Codable {
    let id: String
    let producerId: String
    let producerCategoryOptionId: String
    let createdAt: String
    let updatedAt: String
    let category: PartnerTeamsCategory
}

// MARK: - Category
struct PartnerTeamsCategory: Codable {
    let id: String
    let name: String
    let createdAt: String
    let updatedAt: String
}

// MARK: - Host
struct Host: Codable {
    let id: String
    let phone: String
    let email: String
    let password: String?
    let firstName: String
    let lastName: String
    let postalCode: String?
    let stripeCustomerId: String?
    let stripeDefaultPaymentMethodId: String?
    let cardLastFourDigits: String?
    let imageUrl: String?
    let imageKey: String?
    let role: String
    let createdAt: String
    let updatedAt: String
    let notificationToken: String?
    let onboardingStage: Int
}
