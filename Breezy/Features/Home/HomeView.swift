//
//  HomeView.swift
//  Breezy
//
//  Created by Mian Usama on 13/10/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var presenter = HomePresenter(
        weatherIntrector: WeatherInteractor(service: WeatherService.shared)
    )
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.cyan]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30){
                Text("Breezy")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Image(systemName: presenter.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                
                Text(presenter.temperature)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
                
                Text(presenter.condition)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
            }
            .padding()
        }
        .task {
            await presenter.loadWeather()
        }
    }
}
