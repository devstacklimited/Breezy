//
//  AppCache.swift
//  Breezy
//
//  Created by Mian Usama on 16/10/2025.
//

import SwiftUI

final class AppCache: NSObject {
    // MARK: - Singleton
    static let shared = AppCache()
    private override init(){
        super.init()
    }
    
    // MARK: - User Model
    var cities: [String]{
        get {
            return UserDefaults.standard.stringArray(forKey: Keys.AppCache.cities) ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.AppCache.cities)
        }
    }
    
    // MARK: - Clear All
    func removeCacheData(){
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
    }
}
