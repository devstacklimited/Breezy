//
//  HomeView.swift
//  Breezy
//
//  Created by Mian Usama on 13/10/2025.
//

import SwiftUI

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
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
            
            // MARK: LOADING / ERROR
            if presenter.isLoading && presenter.cityWeathers.isEmpty {
                ProgressView()
                    .foregroundColor(.white)
            } else {
                VStack(spacing: 10){
                    TabView(selection: $presenter.selectedCityIndex){
                        ForEach(Array(presenter.cityWeathers.enumerated()), id: \.offset){ index, vm in
                            CityWeatherView(vm: vm)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    
                    /// Show dots for other cities (limit 3)
                    ForEach(Array(presenter.cityWeathers.enumerated().dropFirst().prefix(3)), id: \.offset){ index, _ in
                        Circle()
                            .fill(presenter.selectedCityIndex == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 6, height: 6)
                    }
                }
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
}
