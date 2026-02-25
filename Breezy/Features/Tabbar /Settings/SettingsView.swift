//
//  SettingsView.swift
//  Breezy
//
//  Created by Mian Usama on 21/02/2026.
//

import SwiftUI

struct SettingsView: View {
    let router: AppRouter
    @EnvironmentObject private var glassManager: GlassManager
    @State private var selectedTheme = "System"
    @State private var selectedTemp = "°F"
    @State private var selectedWind = "mph"
    
    init(router: AppRouter){
        self.router = router
        UISegmentedControl.appearance().selectedSegmentTintColor = .customTab
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    
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
            
            VStack {
                /// HEADER
                VStack(alignment: .leading, spacing: 6){
                    Text("Settings")
                        .poppinFont(.bold, 28)
                        .foregroundColor(.white)
                    
                    Text("Tune appearance and units for your forecasts.")
                        .interFont(.regular, 14)
                        .foregroundColor(.white)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 20){
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
                            ){ selected in
                                
                            }
                            .frame(width: 190)
                        }
                        
                        Divider()
                        
                        settingsRow(
                            icon: "drop.fill",
                            title: "Liquid glass depth",
                            subtitle: "Adjust blur and reflections"
                        ){
                            Picker("", selection: $glassManager.style){
                                ForEach(GlassStyle.allCases, id: \.self){ style in
                                    Text(style.rawValue.capitalized)
                                        .tag(style)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 220)
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
                            ){ selected in
                                
                            }
                            .frame(width: 80)
                        }
                        
                        Divider()
                        
                        settingsRow(
                            icon: "wind",
                            title: "Wind speed",
                            subtitle: "Miles per hour or meters per second"
                        ){
                            segmentedControl(
                                options: ["mph","m/s"],
                                selection: $selectedWind
                            ){ selected in
                                
                            }
                            .frame(width: 90)
                        }
                    }
                    /// ABOUT SECTION
                    settingsCard(title: "About"){
                        navigationRow(
                            icon: "bell",
                            title: "Notifications",
                            subtitle: "Rain alerts and daily summaries"
                        )
                        
                        Divider()
                        
                        navigationRow(
                            icon: "info.circle",
                            title: "About this app",
                            subtitle: "Version 1.0.0 • Weather data source"
                        )
                    }
                }
                .padding(10)
            }
        }
    }
    
    /// Settings Card
    private func settingsCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        glassContainer(spacing: 16){
            VStack(alignment: .leading, spacing: 16){
                Text(title)
                    .poppinFont(.bold, 18)
                    .foregroundColor(.gray)
                    .padding(.leading, 5)
                
                VStack(spacing: 16){
                    content()
                }
            }
            .padding()
            .liquidGlassEffect(in: RoundedRectangle(cornerRadius: 20))
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
        selection: Binding<String>,
        onSelection: @escaping (String) -> Void
    ) -> some View {
        Picker("", selection: selection){
            ForEach(options, id: \.self){ option in
                Text(option)
                    .tag(option)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: selection.wrappedValue){ oldValue, newValue in
            onSelection(newValue)
        }
    }
}
