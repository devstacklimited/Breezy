//
//  WeatherService.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation
import Alamofire

// MARK: - Weather Service Protocol
/// Defines the contract for weather-related API operations.
/// - **Interface Segregation Principle (ISP):**
///   Only declares methods relevant to weather data fetching,
///   so consumers (e.g., Interactor) don’t depend on unnecessary methods.
/// - **Dependency Inversion Principle (DIP):**
///   Higher layers (Interactor/Presenter) depend on this abstraction,
///   not a concrete `WeatherService` implementation.
/// - Helps in Unit Testing by allowing the use of a mock or stub service.
protocol WeatherServiceDelegate: AnyObject {
    /// Fetch current weather by city name
    /// - Parameter params: Encodable model with query parameters
    /// - Returns: `WeatherResponse` decoded model
    func loadWeather(_ params: Parameters) async throws -> WeatherResponse
}

// MARK: - Weather Service
/// High-level service layer to handle weather-related API calls.
/// - Uses **Facade Pattern** to provide simple functions for the UI/ViewModels.
/// - Depends on `ApiClientProtocol` (DIP) instead of concrete BaseApiClient.
/// - Testable via dependency injection (mock service).
final class WeatherService: WeatherServiceDelegate {
    // MARK: - Singleton
    static let shared = WeatherService()
    
    private init(service: ApiClientProtocol = BaseApiClient.shared){
        self.service = service
    }
    // MARK: - Dependencies
    private var service: ApiClientProtocol
    
    /// Allows overriding the internal service (useful for Unit Tests with mocks).
    public func overrideService(_ service: ApiClientProtocol){
        self.service = service
    }
    
    // MARK: - API Calls
    /// Fetch current weather by city name
    /// - Parameter params: Encodable model with query parameters
    /// - Returns: `WeatherResponse` decoded model
    func loadWeather(_ params: Parameters) async throws -> WeatherResponse {
        return try await service.request(ApiRouter.loadWeather(params))
    }
}
