//
//  SaveStoreProfileResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/18/24.
//

import Foundation

struct SaveStoreProfileResponse: Codable {
    let statusCode: Int
    let message: String
    let data: Store?
}

struct Store: Codable {
    let id: String
    let userId: String
    let name: String
    let postalCode: String
    let stripeConnectId: String?
    let city: String
    let streetAddress: String
    let direction: String
    let storeType: String
    let shelfSpace: String
    let dryStorageSpace: String
    let createdAt: String
    let updatedAt: String
}

