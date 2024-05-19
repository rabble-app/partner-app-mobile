//
//  VerifyOTPResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/16/24.
//

import Foundation

struct VerifyOTPResponse: Codable {
    let statusCode: Int
    let message: String
    let data: UserData?
}

struct UserData: Codable {
    let id: String
    let phone: String
    let email: String?
    let password: String?
    let firstName: String?
    let lastName: String?
    let postalCode: String?
    let stripeCustomerId: String
    let stripeDefaultPaymentMethodId: String?
    let cardLastFourDigits: String?
    let imageUrl: String?
    let imageKey: String?
    let role: String
    let createdAt: Date // Change the type to Date
    let updatedAt: Date
    let notificationToken: String?
    let token: String
}

extension UserData {
    // Custom date decoding strategy
    private enum CodingKeys: String, CodingKey {
        case id, phone, email, password, firstName, lastName, postalCode, stripeCustomerId, stripeDefaultPaymentMethodId, cardLastFourDigits, imageUrl, imageKey, role, notificationToken, token
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        phone = try container.decode(String.self, forKey: .phone)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        postalCode = try container.decodeIfPresent(String.self, forKey: .postalCode)
        stripeCustomerId = try container.decode(String.self, forKey: .stripeCustomerId)
        stripeDefaultPaymentMethodId = try container.decodeIfPresent(String.self, forKey: .stripeDefaultPaymentMethodId)
        cardLastFourDigits = try container.decodeIfPresent(String.self, forKey: .cardLastFourDigits)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        imageKey = try container.decodeIfPresent(String.self, forKey: .imageKey)
        role = try container.decode(String.self, forKey: .role)
        notificationToken = try container.decodeIfPresent(String.self, forKey: .notificationToken)
        token = try container.decode(String.self, forKey: .token)
        
        // Custom date decoding for createdAt and updatedAt
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        createdAt = formatter.date(from: createdAtString) ?? Date()
        updatedAt = formatter.date(from: updatedAtString) ?? Date()
    }
}
