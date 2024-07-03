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
