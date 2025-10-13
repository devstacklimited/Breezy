//
//  ApiError.swift
//  Breezy
//
//  Created by Mian Usama on 13/10/2025.
//

import Foundation
import Alamofire

// MARK: - API Error Model
/// Represents an error returned from the API or during decoding.
/// - Uses **Single Responsibility Principle (SRP)**: this struct only handles error representation.
/// - Conforms to `Codable` so it can decode server error responses when structured as JSON.
struct ApiError: Error, Codable {
    let message: String
    let statusCode: Int
    
    /// Initializes an `ApiError` with a message and optional status code.
    init(message: String, statusCode: Int = -1){
        self.message = message
        self.statusCode = statusCode
    }
    
    /// Decodes error from server responses that return only a message.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.message = (try? container.decode(String.self)) ?? "An unknown error occurred."
        self.statusCode = -1
    }
    
    /// Factory for converting any generic `Error` into `ApiError`.
    static func defaultError(error: Error) -> ApiError {
        return ApiError(message: error.localizedDescription, statusCode: -1)
    }
}
