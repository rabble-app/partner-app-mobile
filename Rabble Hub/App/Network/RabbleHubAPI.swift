//
//  RabbleHubAPI.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/20/24.
//

import Foundation
import Moya

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
        case .sendOtp, .verifyOtp, .saveStoreProfile:
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
    
    // MARK: - Helper Function
    public func url(_ route: TargetType) -> String {
        return route.baseURL.appendingPathComponent(route.path).absoluteString
    }
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
