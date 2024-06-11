//
//  DeleteMemberResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 6/11/24.
//

import Foundation


struct DeleteMemberResponse: Codable {
    let statusCode: Int
    let message: String
    let data: DeletedMember
}

struct DeletedMember: Codable {
    let id: String
    let teamId: String
    let userId: String
    let status: String
    let role: String
    let skipNextDelivery: Bool
    let createdAt: String
    let updatedAt: String
}
