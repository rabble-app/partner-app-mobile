//
//  API.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/15/24.
//

import Foundation
import Moya

// MARK: - Provider setup
private func JSONResponseDataFormatter(_ data: Data) -> String {
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
    NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: JSONResponseDataFormatter), logOptions: .verbose)),
    AuthPlugin(tokenManager: tokenManager)
])


// Define the Environment enum
enum Environment {
    case development
    case production
    
    var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "https://api.dev.rabble.market")!
        case .production:
            return URL(string: "https://api.rabble.market")!
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
    case sendOtp(phone: String, baseURL: URL)
    case verifyOtp(phone: String, sid: String, code: String, baseURL: URL)
    case register(phone: String, email: String, password: String, businessName: String, businessAddress: String, baseURL: URL)
    case deliveryDays(baseURL: URL)
}


extension RabbleHubAPI: TargetType {
    
    public var baseURL: URL {
        switch self {
        case .sendOtp(_, let baseURL), .verifyOtp(_, _, _, let baseURL), .register(_, _, _, _, _, let baseURL), .deliveryDays(let baseURL):
            return baseURL
        }
    }
    
    public var path: String {
         switch self {
         case .sendOtp:
             return "/auth/send-otp"
         case .verifyOtp:
             return "/auth/verify-otp"
         case .register:
             return "/auth/register"
         case .deliveryDays:
             return "postal-code/producer/delivery-days"
        
         }
     }
    
    public var method: Moya.Method {
        switch self {
        case .sendOtp:
            return .post
        case .verifyOtp:
            return .post
        case .register:
            return .post
        case .deliveryDays:
            return .get
            }
    }
    
    public var task: Task {
        switch self {
        case .sendOtp(let phone, _):
            let parameters: [String: Any] = [
                "phone": phone
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .verifyOtp(let phone, let sid, let code, _):
            let parameters: [String: Any] = [
                "phone": phone,
                "sid": sid,
                "code": code
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .register(let phone, let email, let password, let businessName, let businessAddress, _):
            let parameters: [String: Any] = [
                "phone": phone,
                "email": email,
                "password": password,
                "businessName": businessName,
                "businessAddress": businessAddress
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .deliveryDays:
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
