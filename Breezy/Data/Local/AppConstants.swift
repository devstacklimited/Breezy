//
//  AppConstants.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation

/// A central place to keep all app-wide constants
struct AppConstants {
    /// Retrieves the app’s Info.plist as a dictionary.
    /// We’ll use this to read environment configuration.
    private static let infoDictionary: [String: Any] = Bundle.main.infoDictionary!
    /// Determines the current app environment (development, staging, production)
    /// based on the `Config` key inside Info.plist.
    static var environment: AppEnvironment {
        /// Get the value of `Config` from Info.plist
        let isProduction = infoDictionary["Config"] as! String
        /// Return correct environment
        if isProduction == "YES" {
            return .production
        } else {
            return .development
        }
    }
    
    /// Nested struct that holds API URLs for different environments.
    struct URLs {
        /// The base URL for the weather API.
        /// Changes automatically depending on the environment (dev, staging, prod).
        static var baseURL: String {
            switch AppConstants.environment {
            case .development:
                /// Development server URL (same for OpenWeatherMap, but could differ in real projects)
                return "https://api.openweathermap.org/data/2.5/"
            case .production:
                /// Production server URL (same for OpenWeatherMap, but could differ in real projects)
                return "https://api.openweathermap.org/data/2.5/"
            case .staging:
                /// Staging server URL (for testing before production release)
                return "https://api.openweathermap.org/data/2.5/"
            }
        }
    }
    
    enum HttpHeaderField: String {
        case contentType = "Content-Type"
        case acceptType = "Accept"
        case authorization = "Authorization"
    }
    
    enum ContentType: String {
        case json = "application/json"
        case encodedURL = "application/x-www-form-urlencoded"
    }
}
