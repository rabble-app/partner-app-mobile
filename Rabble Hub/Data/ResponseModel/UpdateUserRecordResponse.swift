//
//  UpdateUserRecordResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/18/24.
//

import Foundation

struct UpdateUserRecordResponse: Codable {
    let statusCode: Int
    let message: String
    let data: UserRecord?
}

struct UserRecord: Codable {
    let id: String
    let phone: String
    let email: String?
    let firstName: String
    let lastName: String
    let postalCode: String?
    let stripeCustomerId: String?
    let imageUrl: String?
    let role: String
    let createdAt: String
    let updatedAt: String
    let onboardingStage: Int?
}
