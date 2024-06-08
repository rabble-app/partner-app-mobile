//
//  OrderDetailsResponse.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 6/8/24.
//

import Foundation

// MARK: - OrderDetailsResponse
struct OrderDetailsResponse: Decodable {
    let statusCode: Int
    let message: String
    let data: [OrderDetail]
}

// MARK: - OrderDetail
struct OrderDetail: Decodable {
    let id: String
    let productId: String
    let totalQuantity: String
    var quantity: String?
    let name: String
    let measuresPerSubunit: Int
    let unitsOfMeasurePerSubunit: String

    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case totalQuantity = "total_quantity"
        case quantity
        case name
        case measuresPerSubunit = "measures_per_subunit"
        case unitsOfMeasurePerSubunit = "units_of_measure_per_subunit"
    }
}


// MARK: - OrderDetailsProcessor
/// A processor for handling order details.
class OrderDetailsProcessor {
    /// Returns an array of dictionaries containing product IDs and their corresponding quantities.
    ///
    /// - Parameter orderDetails: An optional array of `OrderDetail` objects. Defaults to an empty array if `nil`.
    /// - Returns: An array of dictionaries where each dictionary has keys "productId" and "quantity".
    static func getProductIdsAndQuantities(from orderDetails: [OrderDetail]) -> [[String: String]] {
        return orderDetails.compactMap { orderDetail in
            guard let quantity = orderDetail.quantity else {
                return nil
            }
            return ["productId": orderDetail.productId, "quantity": quantity]
        }
    }
    
    /// Calculates the total quantity from an array of `OrderDetail` objects.
    ///
    /// - Parameter orderDetails: An optional array of `OrderDetail` objects. Defaults to an empty array if `nil`.
    /// - Returns: The total quantity as an integer.
    static func getTotalQuantity(from orderDetails: [OrderDetail]? = nil) -> Int {
        let details = orderDetails ?? []
        return details.compactMap { orderDetail in
            guard let quantity = orderDetail.quantity, let quantityInt = Int(quantity) else {
                return nil
            }
            return quantityInt
        }.reduce(0, +)
    }
}
