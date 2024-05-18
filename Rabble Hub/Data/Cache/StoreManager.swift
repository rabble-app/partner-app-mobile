//
//  StoreManager.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 5/18/24.
//

import Foundation

class StoreManager {
    static let shared = StoreManager()
    
    private let userDefaultsKey = "storedStore"
    
    private init() { }
    
    var store: Store? {
        get {
            guard let savedData = UserDefaults.standard.data(forKey: userDefaultsKey) else { return nil }
            let decoder = JSONDecoder()
            return try? decoder.decode(Store.self, from: savedData)
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
}