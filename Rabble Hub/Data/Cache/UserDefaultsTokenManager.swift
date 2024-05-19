//
//  UserDefaultsTokenManager.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/16/24.
//

import Foundation

protocol TokenManager {
    func getToken() -> String?
    func saveToken(_ token: String)
    func removeToken()
}

class UserDefaultsTokenManager: TokenManager {
    private let tokenKey = "AuthToken"

    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }

    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    func removeToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
