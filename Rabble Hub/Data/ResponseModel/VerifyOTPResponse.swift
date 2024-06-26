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
    var phone: String
    var email: String?
    let password: String?
    var firstName: String?
    var lastName: String?
    var stripeCustomerId: String?
    let stripeDefaultPaymentMethodId: String?
    let cardLastFourDigits: String?
    let imageUrl: String?
    let imageKey: String?
    let role: String
    let createdAt: Date
    let updatedAt: Date
    let notificationToken: String?
    let producer: String?
    var partner: PartnerData?
    let token: String
    var onboardingStage: Int
    var employeeCount: Count?
    var employees: [EmployeeData]?
}

struct PartnerData: Codable {
    var id: String
    var openHours: OpenHours?
    var name: String
    var postalCode: String?
}

struct EmployeeData: Codable {
    var partner: PartnerData
}

struct OpenHours: Codable {
    var type: String
}

struct Count: Codable {
    var employee: Int
}

extension UserData {
    private enum CodingKeys: String, CodingKey {
        case id, phone, email, password, firstName, lastName, stripeCustomerId, stripeDefaultPaymentMethodId, cardLastFourDigits, imageUrl, imageKey, role, notificationToken, producer, partner, token, onboardingStage, employeeCount, employees
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case _count
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        phone = try container.decode(String.self, forKey: .phone)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        stripeCustomerId = try container.decodeIfPresent(String.self, forKey: .stripeCustomerId)
        stripeDefaultPaymentMethodId = try container.decodeIfPresent(String.self, forKey: .stripeDefaultPaymentMethodId)
        cardLastFourDigits = try container.decodeIfPresent(String.self, forKey: .cardLastFourDigits)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        imageKey = try container.decodeIfPresent(String.self, forKey: .imageKey)
        role = try container.decode(String.self, forKey: .role)
        notificationToken = try container.decodeIfPresent(String.self, forKey: .notificationToken)
        producer = try container.decodeIfPresent(String.self, forKey: .producer)
        partner = try container.decodeIfPresent(PartnerData.self, forKey: .partner)
        token = try container.decode(String.self, forKey: .token)
        onboardingStage = try container.decode(Int.self, forKey: .onboardingStage)
        employeeCount = try container.decodeIfPresent(Count.self, forKey: ._count)
        employees = try container.decodeIfPresent([EmployeeData].self, forKey: .employees)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        
        let formatter = ISO8601DateFormatter()
        createdAt = formatter.date(from: createdAtString) ?? Date()
        updatedAt = formatter.date(from: updatedAtString) ?? Date()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(phone, forKey: .phone)
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(stripeCustomerId, forKey: .stripeCustomerId)
        try container.encode(stripeDefaultPaymentMethodId, forKey: .stripeDefaultPaymentMethodId)
        try container.encode(cardLastFourDigits, forKey: .cardLastFourDigits)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(imageKey, forKey: .imageKey)
        try container.encode(role, forKey: .role)
        try container.encode(notificationToken, forKey: .notificationToken)
        try container.encode(producer, forKey: .producer)
        try container.encode(partner, forKey: .partner)
        try container.encode(token, forKey: .token)
        try container.encode(onboardingStage, forKey: .onboardingStage)
        try container.encode(employeeCount, forKey: ._count)
        
        let formatter = ISO8601DateFormatter()
        let createdAtString = formatter.string(from: createdAt)
        let updatedAtString = formatter.string(from: updatedAt)
        
        try container.encode(createdAtString, forKey: .createdAt)
        try container.encode(updatedAtString, forKey: .updatedAt)
    }
}
