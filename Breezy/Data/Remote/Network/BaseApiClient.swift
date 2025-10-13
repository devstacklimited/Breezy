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
            let dataResponse = await session
                .request(convertible)
                .validate(statusCode: 200..<300)
                .serializingData()
                .response
            
            guard let httpResponse = dataResponse.response else {
                throw ApiError(message: "No HTTP response", statusCode: -1)
            }
            guard let data = dataResponse.data else {
                throw ApiError(message: "No response data", statusCode: httpResponse.statusCode)
            }
            /// If the status code is outside 2xx range, attempt to extract error message
            if !(200..<300).contains(httpResponse.statusCode){
                let serverMessage = extractErrorMessage(from: data) ?? "HTTP Error - Status Code: \(httpResponse.statusCode)"
                throw ApiError(message: serverMessage, statusCode: httpResponse.statusCode)
            }
            return try decodeResponse(data: data, response: httpResponse)
        } catch let error as ApiError {
            throw error
        } catch {
            throw ApiError.defaultError(error: error)
        }
    }
    
    // MARK: - Private Helpers
    /// Attempts to extract an error message from server response data.
    private func extractErrorMessage(from data: Data) -> String? {
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
            return jsonObject["message"] as? String ?? jsonObject["error"] as? String
        }
        return nil
    }
    
    /// Handles decoding of response into the specified generic type.
    private func decodeResponse<T: Decodable>(data: Data, response: HTTPURLResponse) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ApiError(message: "Decoding failed: \(error.localizedDescription)", statusCode: response.statusCode)
        }
    }
}
