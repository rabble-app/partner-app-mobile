//
//  NearestLocationsResponse.swift
//  Rabble Hub
//
//  Created by aljon antiola on 7/24/24.
//

import Foundation

struct NearestLocationsResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let addresses: [Address]

    enum CodingKeys: String, CodingKey {
        case latitude = "Latitude"
        case longitude = "Longitude"
        case addresses = "Addresses"
    }

    struct Address: Decodable {
        let street: String
        let city: String

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let fullAddress = try container.decode(String.self)
            let components = fullAddress.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

            let nonEmptyComponents = components.filter { !$0.isEmpty }

            if nonEmptyComponents.count >= 2 {
                self.city = nonEmptyComponents.last!
                self.street = nonEmptyComponents.dropLast().joined(separator: ", ")
            } else {
                self.street = fullAddress
                self.city = ""
            }
        }
        
        var asString: String {
            return "\(street), \(city)"
        }
    }
    
    var combinedAddresses: [String] {
        return addresses.map { "\($0.street), \($0.city)" }
    }
    
    func address(for combinedAddress: String) -> Address? {
        return addresses.first { "\($0.street), \($0.city)" == combinedAddress }
    }
}
