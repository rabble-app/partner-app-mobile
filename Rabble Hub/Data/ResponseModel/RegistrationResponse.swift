//
//  RegistrationResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/16/24.
//

import Foundation

struct RegistrationResponse: Codable {
    let statusCode: Int
    let message: String
    let data: RegistrationData
}

struct RegistrationData: Codable {
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
    let businessEmail: String
    let token: String
}
