//
//  HomePresenter.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import SwiftUI
import Combine

final class HomePresenter: ObservableObject {
    private let weatherIntrector: WeatherInteractorDelegate
    
    @Published var city: String = "London"
    @Published var temperature: String = "--°"
    @Published var condition: String = "Loading..."
    @Published var icon: String = "cloud.fill"
    
    init(
        weatherIntrector: WeatherInteractorDelegate
    ){
        self.weatherIntrector = weatherIntrector
    }
    
    @MainActor
    func loadWeather() async {
        let params = WeatherParams(q: "Sahiwal", appid: "37a84a979191d88254912348b8d7d339").toDictionary()
        do {
            let weather = try await weatherIntrector.loadWeather(params)
            temperature = "\(Int(weather.main.temp))°C"
            condition = weather.weather.first?.description.capitalized ?? "N/A"
            icon = mapIcon(weather.weather.first?.icon ?? "")
        } catch {
            temperature = "--°"
            condition = "Error loading weather"
            icon = "exclamationmark.triangle.fill"
        }
    }
    
    private func mapIcon(_ code: String) -> String {
        /// Simple mapping OpenWeather icon → SF Symbol
        switch code {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "09d", "09n": return "cloud.rain.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }
}
