//
//  Encodable+Extensions.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation

extension Encodable {
    var queryString: String {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return ""
        }
        return dictionary.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    }
    
    func toDictionary() -> [String: Any]{
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}
