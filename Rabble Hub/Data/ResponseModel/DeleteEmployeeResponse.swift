//
//  DeleteEmployeeResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 6/20/24.
//

import Foundation

struct DeleteEmployeeResponse: Codable {
    let statusCode: Int
    let message: String
    let data: DeletedEmployee
}

struct DeletedEmployee: Codable {
    let id: String
    let partnerId: String
    let userId: String
    let createdAt: String
    let updatedAt: String
}
