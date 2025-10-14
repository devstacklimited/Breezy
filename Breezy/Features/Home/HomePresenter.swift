//
//  HomePresenter.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import SwiftUI
import Combine
import Foundation

final class HomePresenter: ObservableObject {
    /// Published properties bound to UI
    @Published var city: String = "—"
    @Published var temperature: String = "--°"
    @Published var highLow: String = "-- / --"
    @Published var condition: String = "—"
    @Published var iconName: String = "cloud.fill" /// SF Symbol mapped later
    @Published var hourly: [HourlyViewModel] = []
    @Published var daily: [DailyViewModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let interactor: WeatherInteractorDelegate
    private var refreshTimerTask: Task<Void, Never>? = nil
    // store last coordinates to call onecall
    private var lastCoord: Coord?

    init(interactor: WeatherInteractorDelegate){
        self.interactor = interactor
    }

    // MARK: - ViewModels
    struct HourlyViewModel: Identifiable {
        let id = UUID()
        let hourLabel: String
        let temp: String
        let icon: String
        let pop: Double? /// precipitation probability
    }

    struct DailyViewModel: Identifiable {
        let id = UUID()
        let dayLabel: String
        let min: String
        let max: String
        let icon: String
        let pop: Double?
    }

    // NOTE: coordinates or city - here we support both; for iOS Weather app you'd typically use location
    func loadWeatherForCity(_ cityName: String) async {
        isLoading = true
        errorMessage = nil
        // 1) Current weather (by city name)
        let currentParams: [String: Any] = [
            "q": cityName,
            "appid" : "37a84a979191d88254912348b8d7d339"
        ] /// ApiRouter will append appid & units
        do {
            let current: Weather = try await interactor.loadWeather(currentParams)
            mapCurrent(current)
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            return
        }
        // 2) For hourly/daily prefer OneCall -> need lat/lon. get from current response if available
        // If current didn't provide coords, you can geocode or fallback to city.
        do {
            // assume previous current mapping stored coord
            guard let lat = lastCoord?.lat, let lon = lastCoord?.lon else {
                self.isLoading = false
                return
            }
            let onecallParams: [String: Any] = [
                "lat": lat,
                "lon": lon,
                "exclude": "minutely,alerts",
                "appid" : "37a84a979191d88254912348b8d7d339"
            ]
            let onecall: OneCall = try await interactor.loadOneCall(onecallParams)
            mapOneCall(onecall)
            /// start periodic refresh
            startAutoRefresh(lat: lat, lon: lon)
        } catch {
            self.errorMessage = error.localizedDescription
            print("error: \(error.localizedDescription)")
        }
        isLoading = false
    }

    // MARK: - Mapping helpers
    private func mapCurrent(_ model: Weather){
        self.city = model.name
        self.temperature = model.main.temp.formattedTemperature()
        self.condition = model.weather.first?.description.capitalized ?? ""
        self.iconName = mapIconCodeToSFSymbol(model.weather.first?.icon ?? "")
        self.lastCoord = model.coord
        if let min = model.main.temp_min, let max = model.main.temp_max {
            self.highLow = "\(Int(min))° / \(Int(max))°"
        }
    }

    private func mapOneCall(_ model: OneCall){
        // Hourly: next 24 hours
        self.hourly = model.hourly.prefix(24).map { h in
            let date = Date(timeIntervalSince1970: TimeInterval(h.dt))
            let hourLabel = date.hourString()
            return HourlyViewModel(hourLabel: hourLabel,
                                   temp: Int(h.temp).description + "°",
                                   icon: mapIconCodeToSFSymbol(h.weather.first?.icon ?? ""),
                                   pop: h.pop)
        }
        // Daily: next 7 days
        self.daily = model.daily.map { d in
            let date = Date(timeIntervalSince1970: TimeInterval(d.dt))
            return DailyViewModel(dayLabel: date.weekdayString(),
                                   min: Int(d.temp.min).description + "°",
                                   max: Int(d.temp.max).description + "°",
                                   icon: mapIconCodeToSFSymbol(d.weather.first?.icon ?? ""),
                                   pop: d.pop)
        }
        // update header current values from onecall.current
        self.temperature = Int(model.current.temp).description + "°"
        self.condition = model.current.weather.first?.description.capitalized ?? ""
        self.iconName = mapIconCodeToSFSymbol(model.current.weather.first?.icon ?? "")
    }

    // convert OWM icon code -> SF Symbol mapping (simple)
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

    // MARK: - Auto refresh
    private func startAutoRefresh(lat: Double, lon: Double){
        // cancel previous
        refreshTimerTask?.cancel()
        refreshTimerTask = Task.detached {[weak self] in
            guard let self = self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 60 * 1_000_000_000) /// refresh every 60s (adjust as needed)
                Task {
                    do {
                        let params: [String: Any] = [
                            "lat": lat,
                            "lon": lon,
                            "appid" : "37a84a979191d88254912348b8d7d339",
                            "exclude": "minutely,alerts"
                        ]
                        let onecall: OneCall = try await self.interactor.loadOneCall(params)
                        await self.mapOneCall(onecall)
                    } catch {
                        /// ignore transient errors
                        print("Error fetching weather data: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func stopAutoRefresh() {
        refreshTimerTask?.cancel()
        refreshTimerTask = nil
    }

    // Simple date helpers (can be moved to extension)
    private func formattedHour(from unix: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unix))
        let df = DateFormatter()
        df.dateFormat = "ha"
        return df.string(from: date)
    }
}
