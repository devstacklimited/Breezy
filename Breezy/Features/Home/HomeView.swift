//
//  HomeView.swift
//  Breezy
//
//  Created by Mian Usama on 13/10/2025.
//

import SwiftUI

/// HomeView — uses your HomePresenter (unchanged)
/// - Shows centered "Add City" UI when no cities exist
/// - Displays a paging city view when cities are present (swipe between them)
/// - Presents a full-screen CityManager for adding/removing cities
struct HomeView: View {
    let router: AppRouter
    
    @StateObject private var presenter = HomePresenter(interactor: WeatherInteractor(service: WeatherService.shared))
    @State private var showCityManager = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient (dynamic later based on condition)
                backgroundGradient()
                    .ignoresSafeArea()

                // Loading / Error states
                if presenter.isLoading && presenter.cityWeathers.isEmpty {
                    ProgressView("Loading...")
                        .foregroundColor(.white)
                } else if let error = presenter.errorMessage, presenter.cityWeathers.isEmpty {
                    // Show error only when there is no data; otherwise show cached data
                    VStack(spacing: 12) {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Try Add City") { showCityManager = true }
                            .buttonStyle(PrimaryGlassButtonStyle())
                    }
                } else if presenter.cityWeathers.isEmpty {
                    // EMPTY STATE: centered CTA when no cities added
                    EmptyStateView {
                        showCityManager = true
                    }
                } else {
                    // MAIN CONTENT: paged cities
                    VStack(spacing: 8) {
                        // Top header (city + temp for currently selected city)
                        headerBar()
                            .padding(.horizontal)

                        // Paged city views (like Apple Weather)
                        TabView(selection: $presenter.selectedCityIndex) {
                            ForEach(Array(presenter.cityWeathers.enumerated()), id: \.offset){ index, vm in
                                CityContentView(vm: vm)
                                    .tag(index)
                                    .padding(.horizontal)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .indexViewStyle(.page(backgroundDisplayMode: .always))

                        // Manage button below content (non-floating)
                        Button {
                            showCityManager = true
                        } label: {
                            Label("Manage Cities", systemImage: "list.bullet")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 22)
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                                .shadow(radius: 2, y: 1)
                        }
                        .padding(.bottom, 12)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            } // ZStack
            .navigationTitle("Breezy")
            .navigationBarTitleDisplayMode(.inline)
            // present the city manager full screen (not sheet)
            .fullScreenCover(isPresented: $showCityManager) {
                CityManagerView(presenter: presenter) {
                    showCityManager = false
                }
            }
            .task {
                // load saved cities (presenter handles nothing change)
                await presenter.loadAllSavedCities()
            }
        }
    }

    // MARK: Header bar — shows name + temperature for selected city
    @ViewBuilder
    private func headerBar() -> some View {
        if let vm = currentCityVM() {
            VStack(spacing: 8) {
                Text(vm.city.uppercased())
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))

                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(vm.temperature)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        Text(vm.condition)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                    Text(vm.highLow)
                        .foregroundColor(.white.opacity(0.9))
                        .font(.headline)
                }
            }
            .padding(.top, 6)
        }
    }

    // MARK: Helpers
    private func currentCityVM() -> HomePresenter.CityWeatherViewModel? {
        guard presenter.cityWeathers.indices.contains(presenter.selectedCityIndex) else { return nil }
        return presenter.cityWeathers[presenter.selectedCityIndex]
    }

    private func backgroundGradient() -> LinearGradient {
        if let vm = currentCityVM(), vm.iconName.contains("sun") {
            return LinearGradient(colors: [Color("WeatherBlueStart"), Color("WeatherBlueEnd")], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            // night / cloudy fallback
            return LinearGradient(colors: [Color.indigo, Color.black.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - City content view (the big card body for a city)
private struct CityContentView: View {
    let vm: HomePresenter.CityWeatherViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                // Hourly strip (liquid glass cards)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(vm.hourly) { h in
                            VStack(spacing: 8) {
                                Text(h.hourLabel)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.9))
                                Image(systemName: h.iconName)
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                                Text(h.temp)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(10)
                            .frame(width: 72)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .shadow(radius: 2, y: 1)
                        }
                    }
                    .padding(.horizontal, 6)
                }

                // Daily list: modern card rows
                VStack(spacing: 12) {
                    ForEach(vm.daily) { d in
                        HStack {
                            Text(d.dayLabel)
                                .frame(width: 64, alignment: .leading)
                                .foregroundColor(.white.opacity(0.9))

                            Image(systemName: d.iconName)
                                .foregroundColor(.yellow)

                            Spacer()

                            Text(d.min)
                                .foregroundColor(.white.opacity(0.75))
                                .frame(minWidth: 36)

                            // Temperature range bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.white.opacity(0.12))
                                    Capsule()
                                        .fill(LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: max(geo.size.width * 0.5, 10), height: 6)
                                }
                            }
                            .frame(height: 6)
                            .frame(minWidth: 80, maxWidth: 180)

                            Text(d.max)
                                .foregroundColor(.white)
                                .frame(width: 44, alignment: .trailing)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 2, y: 1)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 80)
            }
            .padding(.top, 12)
        }
    }
}

// MARK: - Empty State View (centered CTA)
private struct EmptyStateView: View {
    var onAddTapped: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 72))
                .foregroundStyle(.white.opacity(0.9))
                .padding(.bottom, 6)

            Text("No Cities Added")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)

            Text("Add a city or use your location to see weather forecasts.")
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 40)

            Button(action: onAddTapped) {
                Label("Add City or Use Location", systemImage: "plus.circle.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(14)
                    .padding(.horizontal, 60)
            }
        }
    }
}

// MARK: - Full screen City Manager
/// Accepts the presenter as an ObservedObject so the UI can add/delete cities
struct CityManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var presenter = HomePresenter(interactor: WeatherInteractor(service: WeatherService.shared))
    @State private var newCity: String = ""
    var onDone: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Title
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your Cities")
                        .font(.title2.weight(.bold))
                    Text("Add or remove cities you want to track")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                .padding(.horizontal)

                // Cities list (deletable)
                if presenter.cities.isEmpty {
                    Text("No cities added yet.")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(presenter.cities.enumerated()), id: \.1) { idx, city in
                                HStack {
                                    Text(city)
                                        .font(.headline)
                                    Spacer()
                                    // quick remove button (UI-level)
                                    Button {
                                        // Remove city and its cached weather (UI side)
                                        withAnimation {
                                            presenter.cities.remove(at: idx)
                                            if presenter.cityWeathers.indices.contains(idx) {
                                                presenter.cityWeathers.remove(at: idx)
                                            } else {
                                                // if just city removed, we don't alter other indices
                                            }
                                            // If the selected index is out of range, clamp it
                                            if presenter.selectedCityIndex >= presenter.cities.count {
                                                presenter.selectedCityIndex = max(0, presenter.cities.count - 1)
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 6)
                    }
                }

                // Divider then add field
                Divider().padding(.horizontal)

                VStack(spacing: 12) {
                    TextField("Enter city name (e.g. London)", text: $newCity)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    Button(action: {
                        let trimmed = newCity.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        // call presenter's async addCity
                        Task {
                            await presenter.addCity(trimmed)
                        }
                        newCity = ""
                    }) {
                        Text("Add City")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.top, 10)
            .navigationTitle("Manage Cities")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                        onDone()
                    }
                }
            }
        }
    }
}

// MARK: - Small helpers (button style)
private struct PrimaryGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
