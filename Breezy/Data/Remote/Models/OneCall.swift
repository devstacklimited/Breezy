//
//  OneCall.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation

// MARK: - OneCall
struct OneCall: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
    let timezoneOffset: Int
    let current: OneCallCurrent
    let hourly: [OneCallHourly]
    let daily: [OneCallDaily]
    
    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone, current, hourly, daily
        case timezoneOffset = "timezone_offset"
    }
}

// MARK: - Current Weather
struct OneCallCurrent: Codable {
    let dt: Int
    let sunrise: Int?
    let sunset: Int?
    let temp: Double
    let feelsLike: Double
    let pressure: Int?
    let humidity: Int
    let windSpeed: Double?
    let windDeg: Int?
    let weather: [WeatherCondition]
    
    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp, pressure, humidity, weather
        case feelsLike = "feels_like"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
    }
}

// MARK: - Hourly Forecast
struct OneCallHourly: Codable, Identifiable {
    var id: Int { dt }
    let dt: Int
    let temp: Double
    let feelsLike: Double?
    let pressure: Int?
    let humidity: Int?
    let windSpeed: Double?
    let weather: [WeatherCondition]
    let pop: Double?  /// probability of precipitation
    
    enum CodingKeys: String, CodingKey {
        case dt, temp, pressure, humidity, weather, pop
        case feelsLike = "feels_like"
        case windSpeed = "wind_speed"
    }
}

// MARK: - Daily Forecast
struct OneCallDaily: Codable, Identifiable {
    var id: Int { dt }
    let dt: Int
    let sunrise: Int?
    let sunset: Int?
    let temp: DailyTemperature
    let feelsLike: DailyFeelsLike?
    let pressure: Int?
    let humidity: Int?
    let weather: [WeatherCondition]
    let pop: Double?
    let uvi: Double?
}

// MARK: - Temperatures for Daily
struct DailyTemperature: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct DailyFeelsLike: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}
