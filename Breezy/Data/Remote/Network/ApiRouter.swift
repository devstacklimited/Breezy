//
//  ApiRouter.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation
import Alamofire

/// `ApiRouter` is an enum that defines **all API endpoints** in a type-safe way.
/// It conforms to `URLRequestConvertible` (from Alamofire),
/// meaning each case can be converted into a `URLRequest`.
///
/// This approach centralizes all API-related logic:
/// - Base URL
/// - Endpoints (paths)
/// - HTTP methods
/// - Parameters
/// - Headers
///
/// Benefits:
/// - Easy to scale (just add more cases for new endpoints)
/// - Reduces duplication
/// - Keeps API requests consistent across the app
enum ApiRouter: URLRequestConvertible {
    /// Case representing an API call to fetch weather data.
    /// - Parameter p: Dictionary of query parameters (e.g. `["lat": 30.0, "lon": 70.0]`).
    /// These parameters will be turned into a query string and appended to the endpoint.
    ///
    case loadWeather(_ p: Parameters)
    
    // MARK: - Convert to URLRequest
    /// This function builds a complete `URLRequest` that Alamofire can use.
    /// It does the following:
    /// 1. Creates the full URL by combining `baseURL` + endpoint `path`
    /// 2. Sets HTTP method (GET/POST/etc.)
    /// 3. Attaches common headers (e.g. Content-Type, Accept)
    /// 4. Encodes any parameters using the right encoding (query/body)
    func asURLRequest() throws -> URLRequest {
        // Step 1: Get base URL (e.g. "https://api.openweathermap.org/data/2.5/")
        let baseURL = AppConstants.URLs.baseURL
        // Step 2: Append endpoint path to base URL
        let url = baseURL + path
        // Step 3: Ensure final URL is valid
        guard let completeURL = URL(string: url) else {
            fatalError("Invalid URL: \(url)")
        }
        // Step 4: Create an empty request object for this URL
        var urlRequest = URLRequest(url: completeURL)
        // Step 5: Set HTTP method (GET, POST, etc.)
        urlRequest.httpMethod = method.rawValue
        // Step 6: Add required headers
        /// These are constants we defined in AppConstants
        urlRequest.setValue(
            AppConstants.ContentType.json.rawValue,
            forHTTPHeaderField: AppConstants.HttpHeaderField.contentType.rawValue
        )
        urlRequest.setValue(
            AppConstants.ContentType.json.rawValue,
            forHTTPHeaderField: AppConstants.HttpHeaderField.acceptType.rawValue
        )
        // Step 7: Pick the correct encoding strategy depending on HTTP method
        /// - GET/DELETE → URL query string (?lat=30&lon=70)
        /// - POST/PATCH → JSON in request body
        let encoding: ParameterEncoding = {
            switch method {
            case .get:
                return URLEncoding.default
            case .post, .patch:
                return JSONEncoding.default
            case .delete:
                return URLEncoding.default
            default:
                return JSONEncoding.default
            }
        }()
        // Step 8: Apply encoding (attach parameters if any)
        let encodedURL = try encoding.encode(urlRequest, with: parameters)
        /// Final URLRequest ready to be sent
        return encodedURL
    }
    
    // MARK: - Endpoint Path
    /// Defines the endpoint path for each case.
    /// For `loadWeather`, parameters are appended as query string
    /// Example output: "weather?lat=30&lon=70"
    var path: String {
        switch self {
        case .loadWeather(let p):
            return "weather?" + p.queryString
        }
    }
    
    // MARK: - HTTP Method
    /// Defines the HTTP method for each API call.
    private var method: HTTPMethod {
        switch self {
        case .loadWeather:
            return .get
        }
    }
    
    // MARK: - Parameters
    /// Defines body/query parameters for each API call.
    ///
    /// - In `loadWeather`, we return `nil` here because we already
    ///   append parameters directly to the `path` as a query string.
    /// - For POST/PUT endpoints, you would return parameters here
    ///   and they would be encoded into the request body.
    private var parameters: Parameters? {
        switch self {
        case .loadWeather:
            return nil
        }
    }
}
