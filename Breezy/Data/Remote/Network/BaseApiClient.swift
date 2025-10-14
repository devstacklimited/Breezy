//
//  BaseApiClient.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation
import Alamofire

// MARK: - API Client Protocol (Dependency Inversion)
/// Defines the contract for making API requests.
/// - Uses **Interface Segregation Principle (ISP)**: client classes depend only on this small, specific interface.
/// - Uses **Dependency Inversion Principle (DIP)**: higher-level modules depend on this abstraction, not a concrete class.
protocol ApiClientProtocol {
    func request<T: Decodable>(_ convertible: URLRequestConvertible) async throws -> T
}

// MARK: - Base API Client
/// A reusable API client that handles network requests using Alamofire.
/// - Implements **Single Responsibility Principle (SRP)**: networking is its sole responsibility.
/// - Implements **Open/Closed Principle (OCP)**: can be extended with new functionality without modifying core logic.
/// - Conforms to `APIClientProtocol` so it can be mocked for testing (enables **Dependency Inversion Principle**).
final class BaseApiClient: ApiClientProtocol {
    // MARK: - Singleton
    /// Shared singleton instance.
    static let shared = BaseApiClient()
    private init(){}
    
    // MARK: - Properties
    /// Internal Alamofire session used for requests.
    /// Configured with custom timeouts for request and resource loading.
    private let session: Session = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return Session(configuration: config)
    }()
    
    // MARK: - Request
    /// Executes a network request and decodes the response into the specified model type.
    ///
    /// Example:
    /// ```swift
    /// let weather: WeatherResponse = try await BaseApiClient.shared.request(endpoint)
    /// ```
    ///
    /// - Parameter convertible: An object conforming to `URLRequestConvertible` representing the API request.
    /// - Returns: A decoded model of type `T`.
    /// - Throws: `ApiError` if request fails, decoding fails, or response is invalid.
    func request<T: Decodable>(_ convertible: URLRequestConvertible) async throws -> T {
        do {
            /// Fire the request using Alamofire session
            let dataResponse = await session
                .request(convertible)
                .validate(statusCode: 200..<300) /// ensures only 2xx responses are considered valid
                .serializingData()
                .response
            
            /// Ensure HTTP response is available
            guard let httpResponse = dataResponse.response else {
                throw ApiError(message: "No HTTP response", statusCode: -1)
            }
            /// Ensure response data is available
            guard let data = dataResponse.data else {
                throw ApiError(message: "No response data", statusCode: httpResponse.statusCode)
            }
            /// Debug logging: print full raw JSON response (pretty-printed if possible)
            let requestURL = dataResponse.request?.url?.absoluteString ?? "<Unknown URL>"
            logResponse(
                data: data,
                statusCode: httpResponse.statusCode,
                url: requestURL,
                isError: !(200..<300).contains(httpResponse.statusCode)
            )
            /// If the status code is outside 2xx range, attempt to extract error message
            if !(200..<300).contains(httpResponse.statusCode){
                let serverMessage = extractErrorMessage(from: data) ?? "HTTP Error - Status Code: \(httpResponse.statusCode)"
                throw ApiError(message: serverMessage, statusCode: httpResponse.statusCode)
            }
            /// Decode data into requested model
            return try decodeResponse(data: data, response: httpResponse)
        } catch let error as ApiError {
            /// Handle custom `ApiError` thrown in flow
            logError(error)
            throw error
        } catch {
            /// Handle any other errors and wrap into `ApiError`
            logError(error)
            throw ApiError.defaultError(error: error)
        }
    }
    
    // MARK: - Private Helpers
    /// Attempts to extract an error message from server response data.
    /// - Parameter data: Raw response data
    /// - Returns: A readable error message if available
    private func extractErrorMessage(from data: Data) -> String? {
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
            return jsonObject["message"] as? String ?? jsonObject["error"] as? String
        }
        return nil
    }
    
    /// Handles decoding of response into the specified generic type.
    /// - Parameters:
    ///   - data: Raw response data
    ///   - response: HTTPURLResponse object
    /// - Returns: Decoded model object
    /// - Throws: ApiError if decoding fails
    private func decodeResponse<T: Decodable>(data: Data, response: HTTPURLResponse) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ApiError(message: "Decoding failed: \(error.localizedDescription)", statusCode: response.statusCode)
        }
    }
    
    /// Converts raw response data into a pretty-printed JSON string.
    /// If the data is not valid JSON, falls back to raw string.
    private func prettyJSONString(from data: Data) -> String {
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let string = String(data: prettyData, encoding: .utf8){
            return string
        }
        return String(data: data, encoding: .utf8) ?? "<Non-JSON response>"
    }
    
    /// Logs responses (success or error) with formatted JSON and request URL.
    private func logResponse(data: Data, statusCode: Int, url: String, isError: Bool){
        let formattedJSON = prettyJSONString(from: data)
        let header = isError ? "❌ ERROR Response" : "✅ SUCCESS Response"
        print("""
        ===========================
        \(header)
        URL: \(url)
        Status: \(statusCode)
        Response:
        \(formattedJSON)
        ===========================
        """)
    }
    
    /// Logs thrown errors (non-HTTP or decoding).
    private func logError(_ error: Error){
        print("""
        ===========================
        ⚠️ Thrown Error:
        \(error.localizedDescription)
        ===========================
        """)
    }
}
