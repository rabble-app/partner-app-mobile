//
//  CustomerCollectionResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 6/3/24.
//

import Foundation

struct CustomerCollectionResponse: Codable {
    let statusCode: Int
    let message: String
    let data: [CollectionData]
}

struct CollectionData: Codable {
    let id: String
    let user: CollectionUser
    let order: Order
    let dateOfCollection: String
    let status: String
    let items: [Item]
    let createdAt: String
}

struct CollectionUser: Codable {
    let id: String
    let firstName: String
    let lastName: String
}

struct Order: Codable {
    let team: Team
}

struct Team: Codable {
    let id: String
    let name: String
    let producer: Producer
}

struct Producer: Codable {
    let categories: [CategoryContainer]
}

struct CategoryContainer: Codable {
    let category: Category
}

struct Category: Codable {
    let name: String
}

struct Item: Codable {
    let id: String
    let amount: String
    let product: Product
}

struct Product: Codable {
    let name: String
    let measuresPerSubUnit: Int
    let unitsOfMeasurePerSubUnit: String
}
