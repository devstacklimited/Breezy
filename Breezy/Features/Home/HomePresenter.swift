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
/// - Uses only `/weather` (current) and `/forecast` (5-day / 3-hour) endpoints.
/// - Maps forecast list -> hourly (next 24h) and daily (group by date).
@MainActor
final class HomePresenter: ObservableObject {
    // MARK: Published state for the UI
    @Published var cities: [String] = []                         // list of saved city names
    @Published var selectedCityIndex: Int = 0                    // currently visible city index
    @Published var cityWeathers: [CityWeatherViewModel] = []     // cached weather per city
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let interactor: WeatherInteractorDelegate

    init(interactor: WeatherInteractorDelegate){
        self.interactor = interactor
        // Optionally: load persisted cities here (UserDefaults or local DB)
    }

    // MARK: View models
    struct CityWeatherViewModel: Identifiable {
        let id = UUID()
        let city: String
        let temperature: String
        let condition: String
        let highLow: String
        let iconName: String
        let hourly: [HourlyViewModel]
        let daily: [DailyViewModel]
    }

    struct HourlyViewModel: Identifiable {
        let id = UUID()
        let hourLabel: String
        let temp: String
        let iconName: String
    }

    struct DailyViewModel: Identifiable {
        let id = UUID()
        let dayLabel: String
        let min: String
        let max: String
        let iconName: String
    }

    // MARK: Public API

    /// Add a city and load its weather (no duplicate cities allowed)
    func addCity(_ city: String) async {
        let normalized = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        guard !cities.contains(where: { $0.caseInsensitiveCompare(normalized) == .orderedSame }) else { return }

        cities.append(normalized)
        // Immediately load weather for the newly added city
        await loadAndCacheWeatherForCity(normalized)
        // Optionally persist `cities` to disk here
    }

    /// Load weather (current + forecast) for all saved cities (useful on app start)
    func loadAllSavedCities() async {
        guard !cities.isEmpty else { return }
        isLoading = true
        cityWeathers = []
        for city in cities {
            await loadAndCacheWeatherForCity(city)
        }
        isLoading = false
    }

    /// Load and cache (append or replace) CityWeatherViewModel for a city
    func loadAndCacheWeatherForCity(_ cityName: String) async {
        isLoading = true
        errorMessage = nil

        // 1) load current weather
        let currentParams: [String: Any] = [
            "q": cityName,
            // you may prefer to centrally store key in AppConstants.Keys.apiKey
            "appid": AppConstants.Keys.apiKey,
            "units": "metric"
        ]

        do {
            let current: Weather = try await interactor.loadWeather(currentParams)
            // 2) load forecast (by city name or lat/lon)
            // We'll use forecast by city name (q=...) to keep it simple and free
            let forecastParams: [String: Any] = [
                "q": cityName,
                "appid": AppConstants.Keys.apiKey,
                "units": "metric"
            ]
            let forecast: Forecast = try await interactor.loadForecast(forecastParams)
            // map to view model
            let vm = mapToCityWeatherVM(city: cityName, current: current, forecast: forecast)
            // store into cityWeathers: replace if exists, otherwise append
            if let idx = cityWeathers.firstIndex(where: { $0.city.caseInsensitiveCompare(cityName) == .orderedSame }){
                cityWeathers[idx] = vm
            } else {
                cityWeathers.append(vm)
            }
        } catch {
            // capture error for UI; don't crash on single city failure
            errorMessage = error.localizedDescription
            print("HomePresenter.loadAndCacheWeatherForCity error: \(error)")
        }

        isLoading = false
    }

    /// Refresh currently selected city
    func refreshSelectedCity() async {
        guard cities.indices.contains(selectedCityIndex) else { return }
        let city = cities[selectedCityIndex]
        await loadAndCacheWeatherForCity(city)
    }

    // MARK: Mapping helpers (forecast -> hourly/daily)

    /// Map current + forecast to CityWeatherViewModel (uses only forecast data; no OneCall)
    private func mapToCityWeatherVM(city: String, current: Weather, forecast: Forecast) -> CityWeatherViewModel {
        // Hourly: take next 8 items (~24 hours because forecast items are 3-hour steps => 8 * 3 = 24)
        let hourlyItems = Array(forecast.list.prefix(8))
        let hourlyVMs: [HourlyViewModel] = hourlyItems.map { item in
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            return HourlyViewModel(
                hourLabel: hourLabel(for: date),
                temp: "\(Int(item.main.temp))°",
                iconName: mapIconCodeToSFSymbol(item.weather.first?.icon ?? "")
            )
        }

        // Daily: group forecast items by calendar day, compute min/max per day
        let grouped = Dictionary(grouping: forecast.list) { (item: ForecastItem) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            return calendarStartOfDay(for: date)
        }

        // Sort days ascending and pick up to 7 days (or available)
        let sortedDayKeys = grouped.keys.sorted()
        let dailyVMs: [DailyViewModel] = sortedDayKeys.prefix(7).map { day in
            let items = grouped[day] ?? []
            let minTemp = items.map { $0.main.tempMin }.min() ?? 0
            let maxTemp = items.map { $0.main.tempMax }.max() ?? 0
            // choose an icon from the middle of the day items if available
            let icon = items.first?.weather.first?.icon ?? ""
            return DailyViewModel(
                dayLabel: dayLabel(for: day),
                min: "\(Int(minTemp))°",
                max: "\(Int(maxTemp))°",
                iconName: mapIconCodeToSFSymbol(icon)
            )
        }

        // header values prefer current temp but ensure we have fallback from forecast first item
        let headerTemp = current.main.temp.formattedTemperature()
        let headerCondition = current.weather.first?.description.capitalized ?? (forecast.list.first?.weather.first?.description.capitalized ?? "—")
        let headerIcon = mapIconCodeToSFSymbol(current.weather.first?.icon ?? (forecast.list.first?.weather.first?.icon ?? ""))

        let highLow = {
            if let min = current.main.temp_min, let max = current.main.temp_max {
                return "\(Int(min))° / \(Int(max))°"
            } else if let first = forecast.list.first {
                return "\(Int(first.main.tempMin))° / \(Int(first.main.tempMax))°"
            } else {
                return "-- / --"
            }
        }()

        return CityWeatherViewModel(
            city: city,
            temperature: headerTemp,
            condition: headerCondition,
            highLow: highLow,
            iconName: headerIcon,
            hourly: hourlyVMs,
            daily: dailyVMs
        )
    }

    // MARK: Simple date helpers
    private func hourLabel(for date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "ha"         // e.g., 4PM
        return df.string(from: date)
    }

    private func dayLabel(for date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEE"        // Mon, Tue
        return df.string(from: date)
    }

    private func calendarStartOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    // MARK: Icon mapping
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
