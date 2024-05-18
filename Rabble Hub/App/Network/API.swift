//
//  API.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/15/24.
//

import Foundation
import Moya

struct APIConfig {
    static let developmentBaseURL = "https://api.dev.rabble.market"
    static let productionBaseURL = "https://api.rabble.market"
}

struct URLConfig {
    static let sendOtp = "/auth/send-otp"
    static let verifyOtp = "/auth/verify-otp"
    static let saveStoreProfile = "/store/create"
    static let updateUserRecord = "/users/update"
    static let getSuppliers = "/users/producers"
}

// MARK: - Provider setup
private func jsonResponseDataFormatter(_ data: Data) -> String {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
    } catch {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

let environment = Environment.development // or .production
let tokenManager = UserDefaultsTokenManager()
let apiprovider = MoyaProvider<RabbleHubAPI>(plugins: [
    NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: jsonResponseDataFormatter), logOptions: .verbose)),
    AuthPlugin(tokenManager: tokenManager)
])

// Define the Environment enum
enum Environment {
    case development
    case production
    
    var baseURL: URL {
        switch self {
        case .development:
            return URL(string: APIConfig.developmentBaseURL)!
        case .production:
            return URL(string: APIConfig.productionBaseURL)!
        }
    }
}

// Define the AuthPlugin struct
struct AuthPlugin: PluginType {
    let tokenManager: TokenManager
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        if let token = tokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

// MARK: - Provider support
private extension String {
    var urlEscaped: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

public enum RabbleHubAPI {
    case sendOtp(phone: String)
    case verifyOtp(phone: String, sid: String, code: String)
    case saveStoreProfile(name: String, postalCode: String, city: String, streetAddress: String, direction: String, storeType: String, shelfSpace: String, dryStorageSpace: String)
    case updateUserRecord(firstName: String, lastName: String, email: String)
    case getSuppliers
}

extension RabbleHubAPI: TargetType {
    public var baseURL: URL {
        return environment.baseURL
    }
    
    public var path: String {
        switch self {
        case .sendOtp:
            return URLConfig.sendOtp
        case .verifyOtp:
            return URLConfig.verifyOtp
        case .saveStoreProfile:
            return URLConfig.saveStoreProfile
        case .updateUserRecord:
            return URLConfig.updateUserRecord
        case .getSuppliers:
            return URLConfig.getSuppliers
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .sendOtp:
            return .post
        case .verifyOtp:
            return .post
        case .saveStoreProfile:
            return .post
        case .updateUserRecord:
            return .patch
        case .getSuppliers:
            return .get
        }
    }
    
    public var task: Task {
        switch self {
        case .sendOtp(let phone):
            let parameters: [String: Any] = [
                "phone": phone
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .verifyOtp(let phone, let sid, let code):
            let parameters: [String: Any] = [
                "phone": phone,
                "sid": sid,
                "code": code,
                "role": "PARTNER"
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .saveStoreProfile(let name, let postalCode, let city, let streetAddress, let direction, let storeType, let shelfSpace, let dryStorageSpace):
            let parameters: [String: Any] = [
                "name": name,
                "postalCode": postalCode,
                "city": city,
                "streetAddress": streetAddress,
                "direction": direction,
                "storeType": storeType,
                "shelfSpace": shelfSpace,
                "dryStorageSpace": dryStorageSpace
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .updateUserRecord(let firstName, let lastName, let email):
            let parameters: [String: Any] = [
                "firstName": firstName,
                "lastName": lastName,
                "email": email
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getSuppliers:
            return .requestPlain
        }
    }
    
    public var validationType: ValidationType {
        return .none
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}

public func url(_ route: TargetType) -> String {
    route.baseURL.appendingPathComponent(route.path).absoluteString
}

// MARK: - Response Handlers

extension Moya.Response {
    func mapNSArray() throws -> NSArray {
        let any = try self.mapJSON()
        guard let array = any as? NSArray else {
            throw MoyaError.jsonMapping(self)
        }
        return array
    }
}
