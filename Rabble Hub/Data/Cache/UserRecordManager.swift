//
//  UserManager.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/18/24.
//

import Foundation

//class UserRecordManager {
//    let shared = UserRecordManager()
//    let userDefaults = UserDefaults.standard
//    let userDefaultsKey = "storedUser"
//    
//    init() {
//        //nothing to do
//    }
//    
//    var user: UserRecord? {
//        get {
//            guard let savedData = UserDefaults.standard.data(forKey: userDefaultsKey) else { return nil }
//            let decoder = JSONDecoder()
//            return try? decoder.decode(UserRecord.self, from: savedData)
//        }
//        set {
//            let encoder = JSONEncoder()
//            if let encoded = try? encoder.encode(newValue) {
//                UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
//            } else {
//                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
//            }
//        }
//    }
//    
//    func logoutUser() {
//        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
//        UserDefaultsTokenManager().removeToken()
//        StoreManager().removeStore()
//        UserDataManager().clearUserData()
//    }
//    
//    func getUserRecord() -> UserRecord? {
//        guard let data = userDefaults.data(forKey: userDefaultsKey) else {
//            return nil
//        }
//        do {
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .iso8601
//            let userData = try decoder.decode(UserRecord.self, from: data)
//            return userData
//        } catch {
//            print("Failed to decode UserData: \(error)")
//            return nil
//        }
//    }
//}
