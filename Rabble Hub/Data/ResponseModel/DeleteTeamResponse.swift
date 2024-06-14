//
//  DeleteTeamResponse.swift
//  Rabble Hub
//
//  Created by aljon antiola on 6/13/24.
//

import Foundation

struct DeleteTeamResponse: Decodable {
    let statusCode: Int
    let message: String
    let data: TeamData
}

struct DeletedTeam: Decodable {
    let id: String
    let name: String
    let postalCode: String
    let producerId: String
    let hostId: String
    let frequency: String
    let description: String
    let isPublic: Bool
    let imageUrl: String?
    let createdAt: String
    let updatedAt: String
}
