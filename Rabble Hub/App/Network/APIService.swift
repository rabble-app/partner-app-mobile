//
//  APIService.swift
//  Rabble Hub
//
//  Created by aljon antiola on 5/20/24.
//

import Foundation
import Moya

// MARK: - Provider Setup
private func jsonResponseDataFormatter(_ data: Data) -> String {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
    } catch {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

let environment: Environment = .development // or .production
let tokenManager = UserDefaultsTokenManager()
let APIProvider = MoyaProvider<RabbleHubAPI>(plugins: [
    NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: jsonResponseDataFormatter), logOptions: .verbose)),
    AuthPlugin(tokenManager: tokenManager)
])

// MARK: - Auth Plugin
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
