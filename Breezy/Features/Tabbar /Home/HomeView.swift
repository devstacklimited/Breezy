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
    @StateObject private var presenter = HomePresenter(
        interactor: WeatherInteractor(service: WeatherService.shared)
    )

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image("background")
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            if presenter.isLoading && presenter.cityWeathers.isEmpty {
                ProgressView()
                    .tint(.white)
            } else {
                VStack(spacing: 30){
                    // MARK: Horizontal City Pager
                    TabView(selection: $presenter.selectedCityIndex){
                        ForEach(Array(presenter.cityWeathers.enumerated()), id: \.offset){ index, vm in
                            CityWeatherView(vm: vm)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always)) // we use custom dots

                    // MARK: Page Indicator
                    if presenter.cityWeathers.count > 1 {
                        HStack(spacing: 8) {
                            ForEach(0..<presenter.cityWeathers.count, id: \.self){ index in
                                Circle()
                                    .fill(
                                        presenter.selectedCityIndex == index
                                        ? Color.white
                                        : Color.white.opacity(0.4)
                                    )
                                    .frame(width: 8, height: 8)
                                    .animation(.easeInOut(duration: 0.2), value: presenter.selectedCityIndex)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
            }
        }
        .task {
            await presenter.loadAllSavedCities()
        }
        .onReceive(sessionManager.$userCity){ city in
            if let city = city,
               !presenter.cities.contains(where: { $0.caseInsensitiveCompare(city) == .orderedSame }){
                Task {
                    await presenter.addCity(city)
                }
            }
        }
    }
}
