//
//  SendOTPResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/16/24.
//

import Foundation

struct SendOTPResponse: Codable {
    let statusCode: Int
    let message: String
    let data: SendOTPData?
}

struct SendOTPData: Codable {
    let sid: String
}
