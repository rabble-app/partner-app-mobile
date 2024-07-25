//
//  GetAddressAPI.swift
//  Rabble Hub
//
//  Created by aljon antiola on 7/24/24.
//

import Foundation
import Moya

let API_KEY = "oh93u09r10uI2D42JSkU1w38759"

enum GetAddressAPI {
    case getAddress(postalCode: String)
}

extension GetAddressAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.getaddress.io/v2/uk")!
    }

    var path: String {
        switch self {
        case .getAddress(let postalCode):
            return "/\(postalCode)"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case .getAddress:
            return .requestParameters(parameters: ["api-key": API_KEY], encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}

let AddressAPIProvider = MoyaProvider<GetAddressAPI>()
