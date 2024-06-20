//
//  GetEmployeesResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 6/20/24.
//

import Foundation

// MARK: - ResponseData
struct GetEmployeesResponse: Codable {
    let statusCode: Int
    let message: String
    let data: [Employee]
}

// MARK: - Employee
struct Employee: Codable {
    let id: String
    let user: User
}

// MARK: - User
struct User: Codable {
    let firstName: String
    let lastName: String
    let phone: String
}

