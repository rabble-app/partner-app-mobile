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
    
    /**
     Fetches partner teams for a user.
     
     - Parameters:
     - userDataManager: An instance of `UserDataManager` used to retrieve user data.
     - completion: A closure to be executed once the request has finished. The closure takes a `Result` containing either a `GetPartnerTeamsResponse` object or an `Error`.
     
     The function first checks if the user data is valid. If not, it calls the completion handler with an error. If the user is an employee, it uses the employee's partner user ID. Otherwise, it uses the user ID directly to make a network request to fetch the partner teams and handles the response.
     
     - Note:
     If the user data or the relevant user ID is invalid, the function will immediately call the completion handler with an error indicating an invalid user.
     */
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
    
    /**
     Fetches inbound delivery details for a given team ID.
     
     - Parameters:
     - teamId: An optional `String` representing the team ID.
     - completion: A closure to be executed once the request has finished. The closure takes a `Result` containing either an `OrderDetailsResponse` object or an `Error`.
     
     The function first checks if the `teamId` is valid. If not, it calls the completion handler with an error. Otherwise, it makes a network request to fetch the delivery details using the provided team ID and handles the response.
     
     - Note:
     If `teamId` is nil, the function will immediately call the completion handler with an error indicating an invalid team ID.
     */
    func getInboundDeliveryDetails(teamId: String?, completion: @escaping (Result<OrderDetailsResponse, Error>) -> Void) {
        
        guard let id = teamId else {
            completion(.failure(NSError(domain: "Invalid team ID", code: -1, userInfo: nil)))
            return
        }
        
        apiProvider.request(.getInboundDeliveryDetails(id: id)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    
    /**
     Deletes a buying team with the given team ID.

     - Parameters:
        - teamId: A `String` representing the team ID to be deleted.
        - completion: A closure to be executed once the request has finished. The closure takes a `Result` containing either a `DeleteTeamResponse` object or an `Error`.

     The function makes a network request to delete the buying team specified by the team ID and handles the response.
     */
    func deleteBuyingTeam(teamId: String, completion: @escaping (Result<DeleteTeamResponse, Error>) -> Void) {
        
        apiProvider.request(.deleteBuyingTeam(teamId: teamId)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
    

}

extension TeamManager {
    /**
     Handles the response of a network request.
     
     - Parameters:
     - result: A `Result` object containing either a `Response` or a `MoyaError`.
     - completion: A closure to be executed once the response has been handled. The closure takes a `Result` containing either a decoded object of type `T` or an `Error`.
     
     The function decodes the response into the expected type `T`. If decoding fails, it attempts to decode an error message and passes it to the completion handler. If any errors occur during these processes, it passes the error to the completion handler.
     
     - Note:
     The function assumes that the response can be decoded into the expected type `T` or a `StandardResponse` containing an error message.
     */
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
