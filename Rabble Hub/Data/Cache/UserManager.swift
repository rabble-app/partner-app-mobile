//
//  UserManager.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/18/24.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    
    private let userDefaultsKey = "storedUser"
    
    private init() {
        //nothing to do
    }
    
    var user: User? {
        get {
            guard let savedData = UserDefaults.standard.data(forKey: userDefaultsKey) else { return nil }
            let decoder = JSONDecoder()
            return try? decoder.decode(User.self, from: savedData)
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            }
        }
    }
    
    func logoutUser() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaultsTokenManager().removeToken()
        StoreManager().removeStore()
        UserDataManager().clearUserData()
    }
}
