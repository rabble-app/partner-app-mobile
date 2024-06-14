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
    case getSuppliers(offset: Int, postalId: String)
    case createBuyingTeam(name: String, postalCode: String, producerId: String, hostId: String, partnerId: String, frequency: Int, description: String, productLimit: Int, deliveryDay: String, nextDeliveryDate: String, orderCutOffDate: String)
    case addStoreHours(customOpenHoursModel: CustomOpenHoursModel?)
    case getDeliveryDays(supplierId: String?, postalCode: String?)
    case getCustomerCollection(storeId: String, offset: Int, period: String, search: String)
    case getInboundDelivery(storeId: String, offset: Int, period: String, search: String)
    case getInboundDeliveryDetails(id: String)
    case confirmOrderReceipt(storeId: String, orderId: String, products: [Dictionary<String, Any>], note: String?, file: Data?)
    case getPartnerTeams(storeId: String)
    case deleteMember(id: String)
    case updateUserOnboardingRecord
    case updateBuyingTeam(teamId: String, name: String, frequency: Int, deliveryDay: String, productLimit: Int)
    case deleteBuyingTeam(teamId: String)
    case updateUserProfile(firstName: String, lastName: String, email: String, phone: String)
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
        case .updateUserRecord, .updateUserOnboardingRecord, .updateUserProfile:
            return URLConfig.updateUserRecord
        case .getSuppliers:
            return URLConfig.getSuppliers
        case .createBuyingTeam:
            return URLConfig.createBuyingTeams
        case .addStoreHours:
            return URLConfig.addStoreHours
        case .getDeliveryDays(let supplierId, let postalCode):
            return "\(URLConfig.getDaysOfDelivery)/\(supplierId!)/\(postalCode!)"
        case .getCustomerCollection(let storeId, _, _, _):
            return "\(URLConfig.getCustomerCollection)/\(storeId)/collections"
        case .getInboundDelivery(let storeId, _, _, _):
            return "\(URLConfig.getInboundelivery)/\(storeId)/deliveries"
        case .getInboundDeliveryDetails(let id):
            print("\(URLConfig.getInboundeliveryDetails)/\(id)/order-details")
            return "\(URLConfig.getInboundeliveryDetails)/\(id)/order-details"
        case .confirmOrderReceipt(let storeId, _, _, _, _):
            let url = "store/" + "\(storeId)\(URLConfig.confirmOrderReceipt)"
            return url
        case .getPartnerTeams(let storeId):
            return "\(URLConfig.getPartnerTeams)/\(storeId)"
        case .deleteMember(let id):
            return "\(URLConfig.deleteMember)/\(id)"
        case .updateBuyingTeam(let teamId, _, _, _, _):
            return "\(URLConfig.updateBuyingTeam)/\(teamId)"
        case .deleteBuyingTeam(let teamId):
            return "\(URLConfig.deleteBuyingTeam)/\(teamId)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .sendOtp, .verifyOtp, .saveStoreProfile, .createBuyingTeam, .confirmOrderReceipt:
            return .post
        case .updateUserRecord, .addStoreHours, .updateUserOnboardingRecord, .updateBuyingTeam, .updateUserProfile:
            return .patch
        case .getSuppliers, .getDeliveryDays, .getCustomerCollection, .getInboundDelivery, .getInboundDeliveryDetails, .getPartnerTeams:
            return .get
        case .deleteMember, .deleteBuyingTeam:
            return .delete
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
        case .updateUserOnboardingRecord:
            let parameters: [String: Any] = [
                "onboardingStage": 4
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getSuppliers(let offset, let postalId):
            let parameters: [String: Any] = [
                "offset": offset,
                "postalCode": postalId
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .createBuyingTeam(name: let name, postalCode: let postalCode, producerId: let producerId, hostId: let hostId, partnerId: let partnerId, frequency: let frequency, description: let description, productLimit: let productLimit, deliveryDay: let deliveryDay, nextDeliveryDate: let nextDeliveryDate, orderCutOffDate: let orderCutOffDate):
            let parameters: [String: Any] = [
                "name": name,
                "postalCode": postalCode,
                "producerId": producerId,
                "hostId": hostId,
                "partnerId": partnerId,
                "frequency": frequency,
                "description": description,
                "productLimit": productLimit,
                "deliveryDay": deliveryDay,
                "nextDeliveryDate": nextDeliveryDate,
                "orderCutOffDate": orderCutOffDate
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .addStoreHours(let customOpenHoursModel):
            return .requestParameters(parameters: (customOpenHoursModel?.asDictionary())!, encoding: JSONEncoding.default)
        case .getDeliveryDays:
            return .requestPlain
        case .getCustomerCollection(_, let offset, let period, let search):
            var parameters: [String: Any] = [:]
            parameters["offset"] = offset
            parameters["period"] = period
            if !search.isEmpty {
                parameters["search"] = search
            }
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .getInboundDelivery(_, let offset, let period, let search):
            var parameters: [String: Any] = [:]
            parameters["offset"] = offset
            parameters["period"] = period
            if !search.isEmpty {
                parameters["search"] = search
            }
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .getInboundDeliveryDetails(let id):
            var parameters: [String: Any] = [:]
            parameters["id"] = id
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .confirmOrderReceipt(_, let orderId, let products, let note, let file):
            var parameters: [String: Any] = [:]
            parameters["orderId"] = orderId
            parameters["products"] = products
            parameters["note"] = note
            
            var formData: [MultipartFormData] = []
            
            // Convert and Add additional parameters to form-data type
            for (key, value) in parameters {
                let paramData: Data
                if let stringValue = value as? String {
                    paramData = stringValue.data(using: .utf8) ?? Data()
                } else if let intValue = value as? Int {
                    paramData = String(intValue).data(using: .utf8) ?? Data()
                } else if let arrayValue = value as? [Any] {
                    let arrayData = try? JSONSerialization.data(withJSONObject: arrayValue, options: [])
                    paramData = arrayData ?? Data()
                } else {
                    continue // Skip this parameter if it can't be converted
                }
                let paramPart = MultipartFormData(provider: .data(paramData), name: key)
                formData.append(paramPart)
            }
            
            // Ensure file is not nil
            guard let imageDataUnwrapped = file else {
                return .uploadMultipart(formData)
            }
            
            // Add image part
            let imagePart = MultipartFormData(provider: .data(imageDataUnwrapped), name: "file", fileName: "item_image", mimeType: "image/jpg")
            formData.append(imagePart)
            
            return .uploadMultipart(formData)
        case .getPartnerTeams:
            return .requestPlain
        case .deleteMember:
            return .requestPlain
        case .updateBuyingTeam(_, let name, let frequency, let deliveryDay, let productLimit):
            var parameters: [String: Any] = [:]
            parameters["name"] = name
            parameters["frequency"] = frequency
            parameters["deliveryDay"] = deliveryDay
            parameters["productLimit"] = productLimit
            
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .deleteBuyingTeam:
            return .requestPlain
        case .updateUserProfile(let firstName, let lastName, let email, let phone):
            let parameters: [String: Any] = [
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "phone": phone
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
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
