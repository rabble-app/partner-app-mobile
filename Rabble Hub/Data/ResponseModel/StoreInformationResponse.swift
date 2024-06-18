//
//  StoreInformationResponse.swift
//  Rabble Hub
//
//  Created by aljon antiola on 6/18/24.
//

struct StoreInformationResponse: Codable {
    let statusCode: Int
    let message: String
    let data: StoreData
}

struct StoreData: Codable {
    let id: String
    let userId: String
    let name: String
    let postalCode: String
    let stripeConnectId: String?
    let city: String?
    let streetAddress: String?
    let direction: String?
    let storeType: String?
    let shelfSpace: String?
    let dryStorageSpace: String?
    let createdAt: String?
    let updatedAt: String?
}
