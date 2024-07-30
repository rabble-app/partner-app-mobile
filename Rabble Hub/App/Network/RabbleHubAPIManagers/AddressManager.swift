//
//  AddressManager.swift
//  Rabble Hub
//
//  Created by aljon antiola on 7/24/24.
//

import Foundation
import Moya

/// A manager class responsible for handling API requests related to address fetching.
class AddressManager {
    private var apiProvider: MoyaProvider<GetAddressAPI> = AddressAPIProvider
    
    /**
     Fetches nearby locations for a given postal code.
     
     - Parameters:
     - postalCode: A `String` representing the postal code.
     - completion: A closure to be executed once the request has finished. The closure takes a `Result` containing either a list of `String` addresses or an `Error`.
     
     The function makes a network request to fetch the nearby locations for the provided postal code and handles the response.
     */
    func fetchNearbyLocation(postalCode: String, completion: @escaping (Result<NearestLocationsResponse, Error>) -> Void) {
        apiProvider.request(.getAddress(postalCode: postalCode)) { result in
            self.handleResponse(result, completion: completion)
        }
    }
}


extension AddressManager {
    
    /**
     Handles the response of a network request.
     
     - Parameters:
     - result: A `Result` object containing either a `Response` or a `MoyaError`.
     - completion: A closure to be executed once the response has been handled. The closure takes a `Result` containing either a decoded object of type `T` or an `Error`.
     
     The function attempts to decode the response into the expected type `T`. If decoding fails, it passes the error to the completion handler.
     */
    
    private func handleResponse<T: Decodable>(_ result: Result<Response, MoyaError>, completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let response):
            do {
                let decodedResponse = try response.map(T.self)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
