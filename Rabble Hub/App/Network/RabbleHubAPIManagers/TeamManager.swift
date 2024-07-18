//
//  TeamManager.swift
//  Rabble Hub
//
//  Created by aljon antiola on 7/18/24.
//

import Foundation
import Moya

/// A manager class responsible for handling API requests related to partner teams.
class TeamManager {
    private var apiProvider: MoyaProvider<RabbleHubAPI> = APIProvider
    
    /// Fetches partner teams based on user data.
    ///
    /// - Parameters:
    ///   - userDataManager: The user data manager instance to retrieve user data.
    ///   - completion: A completion handler with a result containing either the fetched partner teams response or an error.
    func fetchPartnerTeams(userDataManager: UserDataManager, completion: @escaping (Result<GetPartnerTeamsResponse, Error>) -> Void) {
        guard let userData = userDataManager.getUserData() else {
            completion(.failure(NSError(domain: "Invalid user data", code: -1, userInfo: nil)))
            return
        }
        
        var id = userDataManager.getUserData()?.id
        
        if userDataManager.isUserEmployee() {
            id = userData.employees?.first?.partner.user?.id
        }
        
        guard let storeId = id else {
            completion(.failure(NSError(domain: "Invalid user", code: -1, userInfo: nil)))
            return
        }
        
        apiProvider.request(.getPartnerTeams(storeId: storeId)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    /// Handles the API response and decodes the data.
    ///
    /// - Parameters:
    ///   - result: The result of the API request containing either a response or an error.
    ///   - completion: A completion handler with a result containing either the decoded response or an error.
    private func handleResponse<T: Decodable>(_ result: Result<Response, MoyaError>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let response):
            do {
                let decodedResponse = try response.map(T.self)
                completion(.success(decodedResponse))
            } catch {
                do {
                    let errorResponse = try response.map(StandardResponse.self)
                    completion(.failure(NSError(domain: errorResponse.message, code: response.statusCode, userInfo: nil)))
                } catch {
                    completion(.failure(error))
                }
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
