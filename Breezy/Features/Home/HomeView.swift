//
//  HomeView.swift
//  Breezy
//
//  Created by Mian Usama on 13/10/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var presenter: HomePresenter

    init(){
        /// create presenter with interactor that uses WeatherService.shared
        let interactor = WeatherInteractor(service: WeatherService.shared)
        _presenter = StateObject(wrappedValue: HomePresenter(interactor: interactor))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // dynamic background depending on condition/time - simple gradient
                LinearGradient(gradient: Gradient(colors: gradientColors()),
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

                VStack {
                    // Header
                    VStack(spacing: 6) {
                        Text(presenter.city)
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                        HStack(alignment: .center, spacing: 16) {
                            Image(systemName: presenter.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white.opacity(0.95))
                            VStack(alignment: .leading) {
                                Text(presenter.temperature)
                                    .font(.system(size: 56, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(presenter.condition)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            Spacer()
                            Text(presenter.highLow)
                                .foregroundColor(.white.opacity(0.9))
                                .font(.headline)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Hourly Scroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(presenter.hourly) { hour in
                                VStack {
                                    Text(hour.hourLabel)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                    Image(systemName: hour.icon)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    Text(hour.temp)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)

                    // Daily List
                    List {
                        ForEach(presenter.daily){ day in
                            HStack {
                                Text(day.dayLabel)
                                Spacer()
                                Image(systemName: day.icon)
                                Spacer()
                                Text("\(day.max)")
                                Text("\(day.min)")
                                    .foregroundColor(.secondary)
                            }
                            .listRowBackground(Color.clear)
                            .foregroundColor(.white)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.clear)
                }
                .refreshable {
                    await refresh()
                }
            }
            .navigationTitle("Breezy")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // default city or use user location
                await presenter.loadWeatherForCity("Sahiwal") // replace with desired city
            }
            .onDisappear {
                presenter.stopAutoRefresh()
            }
        }
    }

    // pull-to-refresh wrapper calling presenter
    private func refresh() async {
        await presenter.loadWeatherForCity(presenter.city)
    }

    private func gradientColors() -> [Color]{
        // simple mapping by condition - can be more sophisticated
        if presenter.iconName.contains("sun"){
            return [Color.blue, Color.cyan]
        } else {
            return [Color.gray, Color.blue.opacity(0.7)]
        }
    }
}
