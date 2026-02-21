//
//  CityWeatherView.swift
//  Breezy
//
//  Created by Mian Usama on 25/11/2025.
//

import SwiftUI

struct CityWeatherView: View {
    let vm: HomePresenter.CityWeatherViewModel
    
    var body: some View {
        VStack(spacing: 20){
            /// HEADER
            headerSection
            /// WEATHER DETAILS CARD (dummy metrics for now)
            metricsCard
            /// DAILY FORECAST
            dailyCard(vm)
        }
        .padding(.top, 5)
        .padding(.horizontal, 10)
    }
}

//MARK: - Header
private extension CityWeatherView {
    var headerSection: some View {
        VStack(spacing: 0){
            HStack(alignment: .top){
                VStack(alignment: .leading, spacing: 4){
                    Text(vm.city)
                        .poppinFont(.semibold, 28)
                        .foregroundColor(.white)
                    
                    Text("Mon, Oct 24")
                        .poppinFont(.regular, 16)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text("LIVE")
                    .poppinFont(.light, 12)
                    .foregroundStyle(.white)
                    .padding(10)
                    .liquidGlassEffect(in: Capsule())
                
            }
            VStack(spacing: 0){
                Image(systemName: vm.iconName)
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 70))
                
                Text(vm.temperature)
                    .poppinFont(.light, 100)
                    .foregroundColor(.white)
                
                Text(vm.condition)
                    .poppinFont(.medium, 18)
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(.top, -15)
        }
    }
}

//MARK: - Metrics Card
private extension CityWeatherView {
    var metricsCard: some View {
        HStack {
            metricItem(icon: "wind", value: "\(String(format: "%.1f", vm.windSpeed)) mph", title: "Wind")
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            metricItem(icon: "drop.fill", value: "\(vm.humidity) %", title: "Humidity")
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            metricItem(icon: "cloud.rain.fill", value: "\(vm.rain) %", title: "Rain")
        }
        .padding()
        .frame(height: 90)
        .liquidGlassEffect(in: RoundedRectangle(cornerRadius: 25, style: .continuous))
    }
    
    func metricItem(icon: String, value: String, title: String) -> some View {
        VStack(spacing: 6){
            Image(systemName: icon)
                .foregroundColor(.white)
            
            Text(value)
                .poppinFont(.semibold, 16)
                .foregroundColor(.white)
            
            Text(title)
                .poppinFont(.regular, 13)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

//MARK: - Daily Card
private extension CityWeatherView {
    func dailyCard(_ vm: HomePresenter.CityWeatherViewModel) -> some View {
        VStack(alignment: .leading, spacing: 10){
            HStack {
                Text("5-Day Forecast")
                    .poppinFont(.semibold, 16)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    // TODO: Add navigation or action here
                } label: {
                    HStack(spacing: 4){
                        Text("See More")
                            .poppinFont(.regular, 14)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.85))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            
            VStack {
                ForEach(Array(vm.daily.enumerated()), id: \.offset){ index, d in
                    HStack {
                        Text(d.dayLabel)
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 60, alignment: .leading)
                        
                        Image(systemName: d.iconName)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(d.min)
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 35)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 90, height: 6)
                        
                        Text(d.max)
                            .foregroundColor(.white)
                            .frame(width: 35)
                    }
                    .padding(.vertical, 3)
                    
                    if index < vm.daily.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.2))
                    }
                }
            }
            .padding()
            .liquidGlassEffect(in: RoundedRectangle(cornerRadius: 25, style: .continuous))
        }
    }
}
