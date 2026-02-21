//
//  WeatherIntrector.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation

// MARK: - Weather Interactor Protocol
/// Defines the contract for fetching weather data at the Interactor layer.
/// - **Interface Segregation Principle (ISP):**
///   Only exposes the operations the Presenter needs (`loadWeather`).
/// - **Dependency Inversion Principle (DIP):**
///   Higher-level modules (e.g., Presenter) depend on this protocol
///   rather than the concrete `WeatherInteractor`.
protocol WeatherInteractorDelegate: AnyObject {
    /// Fetch current weather based on query parameters.
    /// - Parameter params: Encodable query model wrapped in `AnyEncodable`.
    /// - Returns: `WeatherResponse` decoded model.
    func loadWeather(_ params: [String: Any]) async throws -> Weather
    func loadForecast(_ params: [String: Any]) async throws -> Forecast
    func loadOneCall(_ params: [String: Any]) async throws -> OneCall
}

// MARK: - Weather Interactor
/// Acts as the middle layer between the Presenter and Service.
/// - Responsible for fetching data from `WeatherService` (data layer).
/// - Keeps **VIPER** architecture intact by separating business logic from the Presenter.
/// - Conforms to `WeatherInteractorDelegate` for protocol-driven design.
/// - Uses **Dependency Injection** to allow replacing `WeatherService` with a mock in tests.
final class WeatherInteractor: WeatherInteractorDelegate {
    // MARK: - Dependencies
    /// Underlying service to fetch weather data (default: `WeatherService`).
    private var service: WeatherService
    
    // MARK: - Initializer
    /// Initialize with a service dependency (injected for testability).
    init(service: WeatherService){
        self.service = service
    }
    
    // MARK: - Public API
    /// Fetch current weather by delegating to the service layer.
    func loadWeather(_ params: [String: Any]) async throws -> Weather {
        return try await service.loadWeather(params)
    }
    
    func loadForecast(_ params: [String : Any]) async throws -> Forecast {
        return try await service.loadForecast(params)
    }
    
    func loadOneCall(_ params: [String : Any]) async throws -> OneCall {
        return try await service.loadOneCall(params)
    }
}
