//
//  SettingsView.swift
//  Breezy
//
//  Created by Mian Usama on 21/02/2026.
//

import SwiftUI

struct SettingsView: View {
    let router: AppRouter
    @State private var selectedTheme = "System"
    @State private var selectedTemp = "°F"
    @State private var selectedWind = "mph"
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image("background")
                    .resizable()
                    .frame(width: geometry.size.width,
                           height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24){
                    /// HEADER
                    VStack(alignment: .leading, spacing: 6){
                        Text("Settings")
                            .poppinFont(.bold, 28)
                            .foregroundColor(.primary)
                        
                        Text("Tune appearance and units for your forecasts.")
                            .interFont(.regular, 14)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    /// APPEARANCE SECTION
                    settingsCard(title: "Appearance"){
                        settingsRow(
                            icon: "paintbrush.fill",
                            title: "Theme",
                            subtitle: "Match iOS, light, or dark"
                        ){
                            segmentedControl(
                                options: ["System","Light","Dark"],
                                selection: $selectedTheme
                            )
                        }
                        
                        Divider().opacity(0.2)
                        
                        settingsRow(
                            icon: "drop.fill",
                            title: "Liquid glass depth",
                            subtitle: "Adjust blur and reflections"
                        ){
                            Capsule()
                                .fill(Color.white.opacity(0.5))
                                .overlay(
                                    Text("Standard")
                                        .interFont(.medium, 13)
                                        .foregroundColor(.gray)
                                )
                                .frame(width: 100, height: 32)
                        }
                    }
                    /// UNITS SECTION
                    settingsCard(title: "Units"){
                        
                        settingsRow(
                            icon: "thermometer",
                            title: "Temperature",
                            subtitle: "Switch between Celsius and Fahrenheit"
                        ){
                            segmentedControl(
                                options: ["°F","°C"],
                                selection: $selectedTemp
                            )
                        }
                        
                        Divider().opacity(0.2)
                        
                        settingsRow(
                            icon: "wind",
                            title: "Wind speed",
                            subtitle: "Miles per hour or meters per second"
                        ){
                            segmentedControl(
                                options: ["mph","m/s"],
                                selection: $selectedWind
                            )
                        }
                    }
                    /// ABOUT SECTION
                    settingsCard(title: "About"){
                        
                        navigationRow(
                            icon: "bell",
                            title: "Notifications",
                            subtitle: "Rain alerts and daily summaries"
                        )
                        
                        Divider().opacity(0.2)
                        
                        navigationRow(
                            icon: "info.circle",
                            title: "About this app",
                            subtitle: "Version 1.0.0 • Weather data source"
                        )
                    }
                }
                .padding(24)
            }
        }
    }
    
    /// Settings Card
    private func settingsCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16){
            Text(title)
                .interFont(.medium, 14)
                .foregroundColor(.gray)
            
            VStack(spacing: 16){
                content()
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    /// Settings Row
    private func settingsRow<Trailing: View>(
        icon: String,
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: 14){
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4){
                Text(title)
                    .interFont(.medium, 15)
                
                Text(subtitle)
                    .interFont(.regular, 13)
                    .foregroundColor(.gray)
            }
            Spacer()
            trailing()
        }
    }
    
    /// Navigation Row
    private func navigationRow(
        icon: String,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 14){
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .foregroundColor(.blue)
            }
            VStack(alignment: .leading, spacing: 4){
                Text(title)
                    .interFont(.medium, 15)
                
                Text(subtitle)
                    .interFont(.regular, 13)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
    
    /// Segment Control
    private func segmentedControl(
        options: [String],
        selection: Binding<String>
    ) -> some View {
        HStack(spacing: 0){
            ForEach(options, id: \.self){ option in
                Button {
                    selection.wrappedValue = option
                } label: {
                    Text(option)
                        .interFont(.medium, 13)
                        .foregroundColor(
                            selection.wrappedValue == option ? .white : .gray
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            selection.wrappedValue == option ?
                            Color.blue :
                            Color.clear
                        )
                }
            }
        }
        .frame(width: 150, height: 32)
        .background(Color.white.opacity(0.5))
        .clipShape(Capsule())
    }
}
