//
//  StandardResponse.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/24/24.
//

import Foundation

struct StandardResponse: Codable {
    let statusCode: Int
    let message: [String]
    let error: String
}
