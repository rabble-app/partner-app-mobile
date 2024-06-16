//
//  GetSuppliersResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/16/24.
//

import Foundation

struct GetSuppliersResponse: Codable {
    let statusCode: Int
    let message: String
    let data: [Supplier]?
}

struct Supplier: Codable {
    let id: String
    let stripeConnectId: String?
    let businessName: String
    let businessAddress: String
    let accountsEmail: String?
    let description: String?
    let vat: String?
    let paymentTerm: Int
    let updatedAt: String
    let categories: [SupplierCategory]
    let imageUrl: String
    let isVerified: Bool
    let userId: String
    let salesEmail: String?
    let minimumTreshold: String
    let count: BuyingTeamCount
    let imageKey: String?
    let website: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, businessName, businessAddress, accountsEmail, description, vat, paymentTerm, updatedAt, categories, imageUrl, isVerified, userId, salesEmail, minimumTreshold, imageKey, website, createdAt
        case stripeConnectId = "stripeConnectId"
        case count = "_count"
    }
    
    struct BuyingTeamCount: Codable {
        let buyingteams: Int
    }
    
    struct SupplierCategory: Codable {
        let producerCategoryOptionId: String
        let id: String
        let producerId: String
        let category: Category
        let createdAt: String
        let updatedAt: String
    }
    
    struct Category: Codable {
        let id: String
        let name: String
        let createdAt: String
        let updatedAt: String
    }
}
