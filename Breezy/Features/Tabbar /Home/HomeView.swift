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
    @EnvironmentObject var presenter: HomePresenter
    
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.001))
                    .ignoresSafeArea(edges: .bottom)
                
            } else {
                VStack(spacing: 30){
                    // MARK: Horizontal City Pager
                    TabView(selection: $presenter.selectedCityIndex){
                        ForEach(Array(presenter.cityWeathers.enumerated()), id: \.offset){ index, vm in
                            CityWeatherView(vm: vm)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never)) /// we use custom dots

                    /// Indicator
                    if presenter.cityWeathers.count > 1 {
                        HStack(spacing: 8){
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
                        .padding(.bottom, 5)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
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
