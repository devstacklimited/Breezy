//
//  WeatherParams.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation

/// Parameters for fetching weather by city name
/// Encapsulates query values for OpenWeatherMap's `weather` endpoint.
/// Example URL: https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_API_KEY
struct WeatherParams: Encodable {
    /// City name (e.g., "London", "Paris", "Tokyo")
    let q: String
    /// OpenWeatherMap API key
    let appid: String
    /// (Optional) Units for temperature (default is Kelvin)
    /// - "metric" → Celsius
    /// - "imperial" → Fahrenheit
    /// - leave empty or omit for Kelvin
    let units: String?
    
    init(q: String, appid: String, units: String? = "metric"){
        self.q = q
        self.appid = appid
        self.units = units
    }
}
