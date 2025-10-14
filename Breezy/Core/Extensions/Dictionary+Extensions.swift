//
//  Dictionary+Extensions.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation

extension Dictionary {
    /// Converts the dictionary into a JSON string representation.
    ///
    /// - Parameter prettify: Pass `true` if you want the output to be human-readable
    ///   with line breaks and indentation. Default is `false` (compact JSON).
    /// - Returns: A `String` containing the JSON, or `nil` if the dictionary
    ///   cannot be converted into valid JSON.
    ///
    /// Example:
    /// ```swift
    /// let dict = ["city": "London", "temp": 20] as [String : Any]
    /// print(dict.jsonString(prettify: true))
    /// ```
    func jsonString(prettify: Bool = false) -> String? {
        // Ensure the dictionary can actually be serialized into JSON
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        /// Select output style: compact vs pretty-printed
        let options = prettify ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions()
        /// Try to convert dictionary → JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: options) else { return nil }
        /// Convert JSON data → String
        return String(data: jsonData, encoding: .utf8)
    }
    
    /// Builds a URL query string (`key=value&key2=value2`) from the dictionary.
    ///
    /// - Returns: A `String` containing query parameters.
    ///
    /// Example:
    /// ```swift
    /// let params = ["q": "London", "appid": "123456"]
    /// print(params.queryString)
    /// // Output: "q=London&appid=123456"
    /// ```
    ///
    /// ⚠️ Note: This implementation does not URL-encode special characters.
    /// If your values contain spaces or special symbols, consider using
    /// `addingPercentEncoding` for safer URLs.
    var queryString: String {
        var output: String = ""
        /// Iterate through all key-value pairs
        for (key, value) in self {
            output += "\(key)=\(value)&"
        }
        /// Remove the last "&" for a valid query string
        output = String(output.dropLast())
        return output
    }
}
