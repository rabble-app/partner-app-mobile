//
//  MarkOrderCollectedResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 6/27/24.
//

import Foundation

struct MarkOrderCollectedResponse: Codable {
    let statusCode: Int
    let message: String
    let data: Bool
}
