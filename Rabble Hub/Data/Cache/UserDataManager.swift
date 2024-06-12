//
//  UserDataManager.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 6/3/24.
//

import Foundation

//MARK: from verify OTP
import Foundation

class UserDataManager {

    private let userDefaults = UserDefaults.standard
    private let userDataKey = "UserData"

    func saveUserData(_ userData: UserData) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(userData)
            userDefaults.set(data, forKey: userDataKey)
        } catch {
            print("Failed to encode UserData: \(error)")
        }
    }

    func getUserData() -> UserData? {
        guard let data = userDefaults.data(forKey: userDataKey) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let userData = try decoder.decode(UserData.self, from: data)
            return userData
        } catch {
            print("Failed to decode UserData: \(error)")
            return nil
        }
    }

    func clearUserData() {
        userDefaults.removeObject(forKey: userDataKey)
    }

    func isUserDataEmpty() -> Bool {
        return userDefaults.data(forKey: userDataKey) == nil
    }
    
    func logoutUser() {
        clearUserData()
        UserDefaultsTokenManager().removeToken()
        StoreManager().removeStore()
    }
}
