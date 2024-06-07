//
//  OrderDetailsResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 6/8/24.
//

import Foundation

// MARK: - OrderDetailsResponse
struct OrderDetailsResponse: Codable {
    let statusCode: Int
    let message: String
    let data: [OrderDetail]
}

// MARK: - OrderDetail
struct OrderDetail: Codable {
    let id: String
    let productId: String
    let totalQuantity: String
    let name: String
    let measuresPerSubunit: Int
    let unitsOfMeasurePerSubunit: String

    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case totalQuantity = "total_quantity"
        case name
        case measuresPerSubunit = "measures_per_subunit"
        case unitsOfMeasurePerSubunit = "units_of_measure_per_subunit"
    }
}



