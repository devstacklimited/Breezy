//
//  SecretsManager.swift
//  Breezy
//
//  Created by Mian Usama on 16/10/2025.
//

import Foundation
import Security

struct Credentials: Codable {
    var appid: String
}

class SecretsManager {
    private let service = "com.devstack.Breezy.auth" /// Unique identifier for app
    private let account = "secretCredentials"       /// Fixed account key
    static private(set) var shared: SecretsManager!
    private(set) var credentials: Credentials?
    
    @discardableResult
    init(){
        SecretsManager.shared = self
        if let stored = getCredentials(){
            self.credentials = stored
            print("✅ Credentials loaded from Keychain")
        } else {
            let defaultCreds = Credentials(appid: "37a84a979191d88254912348b8d7d339")
            saveCredentials(data: defaultCreds)
            self.credentials = defaultCreds
            print("✅ Default credentials saved and loaded")
        }
    }
    
    /// Save credentials in Keychain
    private func saveCredentials(data: Credentials){
        if let encodedData = try? JSONEncoder().encode(data){
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: encodedData,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            SecItemDelete(query as CFDictionary)
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                print("⚠️ Keychain Save Failed: \(status)")
            }
        }
    }
    
    /// Retrieve credentials from Keychain
    private func getCredentials() -> Credentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, let data = item as? Data {
            return try? JSONDecoder().decode(Credentials.self, from: data)
        }
        return nil
    }
    
    /// Delete credentials from Keychain
    func deleteCredentials(){
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
        self.credentials = nil
    }
}
