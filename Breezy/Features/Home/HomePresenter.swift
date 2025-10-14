//
//  HomePresenter.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation
import SwiftUI
import Combine

/// Presenter for Home screen
/// - Uses `/weather` (current) and `/forecast` (5-day / 3-hour).
/// - Maps forecast list -> hourly (next 24h) and daily (group by date).
@MainActor
final class HomePresenter: ObservableObject {
    // MARK: Published state for the UI
    @Published var cities: [String] = []                         // Saved city names
    @Published var selectedCityIndex: Int = 0                    // Currently visible city index
    @Published var cityWeathers: [CityWeatherViewModel] = []     // Cached weather data
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let interactor: WeatherInteractorDelegate

    init(interactor: WeatherInteractorDelegate){
        self.interactor = interactor
        // Optionally: load persisted cities here (UserDefaults / DB)
    }

    // MARK: View models used by HomeView
    struct CityWeatherViewModel: Identifiable {
        let id = UUID()
        let city: String
        let temperature: String     // current temp
        let condition: String       // description, e.g. "Cloudy"
        let highLow: String         // daily high / low
        let iconName: String        // SF Symbol
        let hourly: [HourlyViewModel]
        let daily: [DailyViewModel]
    }

    struct HourlyViewModel: Identifiable {
        let id = UUID()
        let hourLabel: String   // "2PM"
        let temp: String        // "23°"
        let iconName: String
    }

    struct DailyViewModel: Identifiable {
        let id = UUID()
        let dayLabel: String    // "Mon"
        let min: String         // "12°"
        let max: String         // "25°"
        let iconName: String
    }

    // MARK: Public API

    /// Add a new city (skip duplicates) and load weather
    func addCity(_ city: String) async {
        let normalized = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        guard !cities.contains(where: { $0.caseInsensitiveCompare(normalized) == .orderedSame }) else { return }

        cities.append(normalized)
        await loadAndCacheWeatherForCity(normalized)
    }

    /// Load weather for all saved cities (startup use)
    func loadAllSavedCities() async {
        guard !cities.isEmpty else { return }
        isLoading = true
        cityWeathers = []
        for city in cities {
            await loadAndCacheWeatherForCity(city)
        }
        isLoading = false
    }

    /// Load + cache weather for one city
    func loadAndCacheWeatherForCity(_ cityName: String) async {
        isLoading = true
        errorMessage = nil

        let currentParams = [
            "q": cityName,
            "appid": AppConstants.Keys.apiKey,
            "units": "metric"
        ]

        do {
            let current: Weather = try await interactor.loadWeather(currentParams)
            let forecastParams = [
                "q": cityName,
                "appid": AppConstants.Keys.apiKey,
                "units": "metric"
            ]
            let forecast: Forecast = try await interactor.loadForecast(forecastParams)

            let vm = mapToCityWeatherVM(city: cityName, current: current, forecast: forecast)

            if let idx = cityWeathers.firstIndex(where: { $0.city.caseInsensitiveCompare(cityName) == .orderedSame }) {
                cityWeathers[idx] = vm
            } else {
                cityWeathers.append(vm)
            }
        } catch {
            errorMessage = error.localizedDescription
            print("❌ HomePresenter error:", error)
        }

        isLoading = false
    }

    /// Refresh currently selected city
    func refreshSelectedCity() async {
        guard cities.indices.contains(selectedCityIndex) else { return }
        await loadAndCacheWeatherForCity(cities[selectedCityIndex])
    }

    // MARK: Mapping

    private func mapToCityWeatherVM(city: String, current: Weather, forecast: Forecast) -> CityWeatherViewModel {
        // Hourly (8 steps = 24h)
        let hourlyVMs = forecast.list.prefix(8).map { item in
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            return HourlyViewModel(
                hourLabel: hourLabel(for: date),
                temp: "\(Int(item.main.temp))°",
                iconName: mapIconCodeToSFSymbol(item.weather.first?.icon ?? "")
            )
        }

        // Daily (group forecast by day)
        let grouped = Dictionary(grouping: forecast.list) { item in
            calendarStartOfDay(for: Date(timeIntervalSince1970: TimeInterval(item.dt)))
        }

        let dailyVMs = grouped.keys.sorted().prefix(7).map { day in
            let items = grouped[day] ?? []
            let minTemp = items.map { $0.main.tempMin }.min() ?? 0
            let maxTemp = items.map { $0.main.tempMax }.max() ?? 0
            let icon = items.first?.weather.first?.icon ?? ""
            return DailyViewModel(
                dayLabel: dayLabel(for: day),
                min: "\(Int(minTemp))°",
                max: "\(Int(maxTemp))°",
                iconName: mapIconCodeToSFSymbol(icon)
            )
        }

        // Header values (current weather preferred)
        let headerTemp = "\(Int(current.main.temp))°"
        let headerCondition = current.weather.first?.description.capitalized
            ?? forecast.list.first?.weather.first?.description.capitalized
            ?? "—"
        let headerIcon = mapIconCodeToSFSymbol(
            current.weather.first?.icon ?? (forecast.list.first?.weather.first?.icon ?? "")
        )

        let highLow: String = {
            if let min = current.main.temp_min, let max = current.main.temp_max {
                return "\(Int(min))° / \(Int(max))°"
            } else if let first = forecast.list.first {
                return "\(Int(first.main.tempMin))° / \(Int(first.main.tempMax))°"
            }
            return "-- / --"
        }()

        return CityWeatherViewModel(
            city: city,
            temperature: headerTemp,
            condition: headerCondition,
            highLow: highLow,
            iconName: headerIcon,
            hourly: Array(hourlyVMs),
            daily: Array(dailyVMs)
        )
    }

    // MARK: Helpers

    private func hourLabel(for date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "ha"
        return df.string(from: date)
    }

    private func dayLabel(for date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEE"
        return df.string(from: date)
    }

    private func calendarStartOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    private func mapIconCodeToSFSymbol(_ code: String) -> String {
        switch code {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d", "10n": return "cloud.rain.fill"
        case "11d", "11n": return "cloud.bolt.rain.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }
}
