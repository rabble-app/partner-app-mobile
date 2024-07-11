//
//  RabbleHelper.swift
//  Rabble Hub
//
//  Created by aljon antiola on 7/2/24.
//

import Foundation
import Branch


/// Generates a deep link for a given team's data using the Branch SDK.
/// - Parameters:
///   - teamData: The data of the team for which the deep link is to be generated.
///   - completion: A closure that takes an optional `String` representing the generated URL, or `nil` if there was an error.
func generateDeepLink(for teamData: PartnerTeam, completion: @escaping (String?) -> Void) {
    // Create a BranchUniversalObject
    let branchUniversalObject = BranchUniversalObject()
    branchUniversalObject.canonicalIdentifier = teamData.id 
    branchUniversalObject.title = teamData.name
    branchUniversalObject.imageUrl = teamData.imageUrl
    branchUniversalObject.contentDescription = teamData.description
    branchUniversalObject.keywords = ["team_share"]

    // Create BranchLinkProperties
    let branchLinkProperties = BranchLinkProperties()
    branchLinkProperties.feature = "Share"
    branchLinkProperties.channel = "Rabble app"
    branchLinkProperties.campaign = "Invitation for team."

    // Generate the short URL
    branchUniversalObject.getShortUrl(with: branchLinkProperties) { (url, error) in
        if let error = error {
            print("Error generating short URL: \(error.localizedDescription)")
            completion(nil)
        } else {
            print("Generated deep link: \(url ?? "No URL")")
            completion(url)
        }
    }
}

/// Checks the necessary user data  and delivery information for creating a buying team, and returns a descriptive error message if any required data is missing or invalid.
/// - Parameters:
///   - userData: The user data containing information about the partner and user.
///   - deliveryDay: The optional delivery day information.
///   - deliveryDate: The optional delivery date information.
/// - Returns: An optional `String` representing the error message if any required data is missing or invalid, or `nil` if all data is valid.
func checkBuyingTeamUserData(userData: UserData, deliveryDay: DeliveryDay?, deliveryDate: Date?) -> String? {
    guard let partner = userData.partner else {
        return "Partner data is missing"
    }

//    guard let postalCode = partner.postalCode else {
//        return "Postal code is missing"
//    }

    if partner.id.isEmpty {
        return "Store ID is missing"
    }

    if partner.name.isEmpty {
        return "Partner name is missing"
    }
    
    if userData.id.isEmpty {
        return "User ID is missing"
    }

    guard let deliveryDay = deliveryDay else {
        return "Delivery day is missing"
    }

//    guard let deliveryDayStr = deliveryDay.day else {
//        return "Delivery day string is missing"
//    }

    guard let deliveryDate = deliveryDate else {
        return "Delivery date is missing"
    }

    if deliveryDate.toString().isEmpty {
        return "Delivery date string conversion failed"
    }

    guard let nextCutOffDate = deliveryDay.getCutoffDate(from: deliveryDate) else {
        return "Next cutoff date calculation failed"
    }

    if nextCutOffDate.toString().isEmpty {
        return "Next cutoff date string conversion failed"
    }

    // All checks passed
    return nil
}
