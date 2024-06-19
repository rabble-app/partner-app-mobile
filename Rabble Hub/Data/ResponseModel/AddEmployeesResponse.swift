//
//  AddEmployeesResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 6/20/24.
//

import Foundation

// MARK: - AddEmployeesResponse
struct AddEmployeesResponse: Codable {
    let statusCode: Int
    let message: String
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let user: ReturnedUser
    let employee: NewEmployee
}

// MARK: - User
struct ReturnedUser: Codable {
    let id: String
    let phone: String
    let email: String?
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

// MARK: - Employee
struct NewEmployee: Codable {
    let id: String
    let partnerId: String
    let userId: String
    let createdAt: String
    let updatedAt: String
}
