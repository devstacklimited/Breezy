//
//  CityWeatherView.swift
//  Breezy
//
//  Created by Mian Usama on 25/11/2025.
//

import SwiftUI

@available(iOS 26.0, *)
struct CityWeatherView: View {
    let vm: HomePresenter.CityWeatherViewModel

    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(alignment: .center, spacing: 10){
                VStack(spacing: 5){
                    Text("MY LOCATION")
                        .poppinFont(.regular, 14)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Text(vm.city)
                        .poppinFont(.semibold, 20)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 5){
                        Text(vm.temperature)
                            .poppinFont(.light, 80)
                            .foregroundColor(.white)
                        Text(vm.condition)
                            .foregroundColor(.white.opacity(0.8))
                            .poppinFont(.medium, 14)
                        
                        HStack(spacing: 10){
                            Text("H:\(vm.high)")
                                .foregroundColor(.white.opacity(0.9))
                                .poppinFont(.semibold, 15)
                            
                            Text("L:\(vm.low)")
                                .foregroundColor(.white.opacity(0.9))
                                .poppinFont(.semibold, 15)
                            
                        }
                    }
                }
                .padding(.top, 10)
                
                VStack(spacing: 15){
                    hourlyCard(vm)
                    dailyCard(vm)
                }
                .padding(.top, 60)
            }
        }
    }
    
    // MARK: HOURLY FORECAST CARD
    private func hourlyCard(_ vm: HomePresenter.CityWeatherViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8){
            Text("Clear conditions tonight with lows around 12°. Tomorrow expect warmer temperatures with mostly sunny skies.")
                .poppinFont(.regular, 14)
                .foregroundColor(.white)
                .padding(.horizontal, 15)
                .padding(.top, 10)
            
            Divider()
                .background(Color.white)
                .frame(height: 1)
                .padding(.horizontal, 15)
            
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 15){
                    ForEach(vm.hourly){ h in
                        VStack(spacing: 10){
                            Text(h.hourLabel)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Image(systemName: h.iconName)
                                .font(.title2)
                                .foregroundColor(.white)
                            Text(h.temp)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(width: 60)
                    }
                }
                .padding(.horizontal, 2)
            }
            .padding(10)
        }
        .glassEffect(.clear.interactive(), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 15)
    }
    
    // MARK: DAILY FORECAST CARD
    private func dailyCard(_ vm: HomePresenter.CityWeatherViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12){
            VStack(alignment: .leading, spacing: 5){
                HStack {
                    Image(systemName: "calendar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(.white)
                        .padding(.leading, 5)
                    
                    Text("5-Day Forecast")
                        .poppinFont(.semibold, 14)
                        .foregroundColor(.white)
                }
                Divider()
                    .background(Color.white.opacity(0.5))
            }
            .padding(15)
            
            VStack(spacing: 0){
                ForEach(Array(vm.daily.enumerated()), id: \.offset){ index, d in
                    VStack(spacing: 0){
                        HStack {
                            Text(d.dayLabel)
                                .foregroundColor(.white.opacity(0.9))
                                .frame(width: 60, alignment: .leading)

                            Image(systemName: d.iconName)
                                .foregroundColor(.white)

                            Spacer()

                            Text(d.min)
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 30)

                            Capsule()
                                .fill(Color.white.opacity(0.4))
                                .frame(width: 80, height: 6)

                            Text(d.max)
                                .foregroundColor(.white)
                                .frame(width: 30)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 12)
                        
                        if index < vm.daily.count - 1 {
                            Divider()
                                .background(Color.white.opacity(0.5))
                                .padding(.horizontal, 15)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .glassEffect(.clear.interactive(), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 15)
    }
    
    private func currentTime() -> String {
        let fmt = DateFormatter()
        fmt.timeStyle = .short
        return fmt.string(from: Date())
    }
}
