//
//  Forecast.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation

// MARK: - ForecastResponse
/// Represents the 5-day / 3-hour forecast response from OpenWeatherMap API
struct Forecast: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ForecastItem]
    let city: ForecastCity
}

// MARK: - ForecastItem
/// Each forecast entry (3-hour step)
struct ForecastItem: Codable, Identifiable {
    var id: Int { dt }  // dt is unique enough to be an ID
    let dt: Int
    let main: ForecastMain
    let weather: [WeatherCondition]
    let clouds: ForecastClouds
    let wind: ForecastWind
    let dtTxt: String
    let pop : Int?
    
    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, pop
        case dtTxt = "dt_txt"
    }
}

// MARK: - ForecastMain
struct ForecastMain: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - ForecastWeatherCondition (reuse same as current WeatherResponse if you want)
struct WeatherCondition: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

// MARK: - Clouds
struct ForecastClouds: Codable {
    let all: Int
}

// MARK: - Wind
struct ForecastWind: Codable {
    let speed: Double
    let deg: Int
}

// MARK: - City
struct ForecastCity: Codable {
    let id: Int
    let name: String
    let coord: ForecastCoord
    let country: String
    let population: Int?
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

// MARK: - Coordinates
struct ForecastCoord: Codable {
    let lat: Double
    let lon: Double
}
