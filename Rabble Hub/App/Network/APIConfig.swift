//
//  APIConfig.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/20/24.
//

import Foundation

struct APIConfig {
    static let developmentBaseURL = "https://api.dev.rabble.market"
    static let productionBaseURL = "https://api.rabble.market"
}

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

struct URLConfig {
    static let sendOtp = "/auth/send-otp"
    static let verifyOtp = "/auth/verify-otp"
    static let saveStoreProfile = "/store/create"
    static let updateUserRecord = "/users/update"
    static let getSuppliers = "/users/producers"
    static let createBuyingTeams = "/teams/create"
    static let addStoreHours = "/store/open-hours"
    static let getDaysOfDelivery = "/postal-code/producer/days-of-delivery"
    static let getCustomerCollection = "/store"
    static let getInboundelivery = "/store"
    static let getInboundeliveryDetails = "/store"
    static let confirmOrderReceipt = "/confirm-order-receipt"
    static let getPartnerTeams = "/users/my-teams"
    static let deleteMember = "/teams/quit"
    static let updateBuyingTeam = "/teams"
    static let deleteBuyingTeam = "/teams"
    static let getStoreInformation = "/store/profile"
    static let getStoreOpenHours = "/store/open-hours"
    static let updateStoreHours = "/store"
    static let updateStoreProfile = "/store"
    static let getEmployees = "/store"
}
