//
//  Encodable+Extensions.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation

extension Encodable {
    /// Converts any `Encodable` model into a **URL query string**.
    ///
    /// - Returns: A `String` in the form of `"key1=value1&key2=value2"`.
    /// - If encoding fails, returns an empty string `""`.
    ///
    /// Example:
    /// ```swift
    /// struct WeatherParams: Encodable {
    ///     let q: String
    ///     let appid: String
    /// }
    ///
    /// let params = WeatherParams(q: "London", appid: "123456")
    /// print(params.queryString)
    /// // "q=London&appid=123456"
    /// ```
    ///
    /// ⚠️ **Note**: Values are not percent-encoded.
    /// For example, `"New York"` will output `q=New York` instead of `q=New%20York`.
    /// You may want to add `addingPercentEncoding(withAllowedCharacters:)` for safety.
    var queryString: String {
        /// Encode self into JSON data
        guard let data = try? JSONEncoder().encode(self),
              // Decode JSON back into dictionary
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return ""
        }
        /// Convert dictionary into key=value pairs joined by &
        return dictionary.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    }
    
    /// Converts any `Encodable` model into a **Dictionary representation**.
    ///
    /// - Returns: `[String: Any]` dictionary if encoding is successful,
    ///   otherwise returns an empty dictionary `[:]`.
    ///
    /// Example:
    /// ```swift
    /// struct WeatherParams: Encodable {
    ///     let q: String
    ///     let appid: String
    /// }
    ///
    /// let params = WeatherParams(q: "Paris", appid: "123456")
    /// print(params.toDictionary())
    /// // ["q": "Paris", "appid": "123456"]
    /// ```
    func toDictionary() -> [String: Any]{
        /// Encode self into JSON data
        guard let data = try? JSONEncoder().encode(self),
              /// Decode JSON data back into a dictionary
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}
