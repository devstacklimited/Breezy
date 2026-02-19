//
//  HomeView.swift
//  Breezy
//
//  Created by Mian Usama on 13/10/2025.
//

import SwiftUI

@available(iOS 26.0, *)
struct HomeView: View {
    let router: AppRouter
    @EnvironmentObject var sessionManager: AppSessionManager
    @StateObject private var presenter = HomePresenter(interactor: WeatherInteractor(service: WeatherService.shared))
    @State private var showCityManager = false

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
            
            // MARK: LOADING / ERROR
            if presenter.isLoading && presenter.cityWeathers.isEmpty {
                ProgressView()
                    .foregroundColor(.white)
            } else {
                TabView(selection: $presenter.selectedCityIndex){
                    ForEach(Array(presenter.cityWeathers.enumerated()), id: \.offset){ index, vm in
                        CityWeatherView(vm: vm)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
            }
        }
        .task {
            await presenter.loadAllSavedCities()
        }
        .onReceive(sessionManager.$userCity){ city in
            if let city = city, !presenter.cities.contains(city){
                presenter.cities.append(city)
            }
        }
    }
    // MARK: - BOTTOM CONTROLS
    private var bottomControls: some View {
        HStack {
            // MAP BUTTON (Leading)
            Button {
                //TODO: Map View
            } label: {
                Image(systemName: "map")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .glassEffect(.regular.interactive())
                    )
            }

            Spacer()

            HStack(spacing: 6){
                Image(systemName: "location.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.white)
                    .padding(10)

                /// Show dots for other cities (limit 3)
                ForEach(Array(presenter.cityWeathers.enumerated().dropFirst().prefix(3)), id: \.offset){ index, _ in
                    Circle()
                        .fill(presenter.selectedCityIndex == index ? Color.white : Color.white.opacity(0.4))
                        .frame(width: 6, height: 6)
                }
            }
            .background(
                Capsule()
                    .glassEffect(.regular.interactive())
            )
            

            Spacer()

            // MANAGE CITIES (Trailing)
            Button {
                //Home View
            } label: {
                Image(systemName: "list.bullet")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .glassEffect(.regular.interactive())
                    )
            }
        }
        .padding(.horizontal, 25)
        .padding(.bottom, 5)
    }
}

// MARK: Button Style (unchanged)
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
