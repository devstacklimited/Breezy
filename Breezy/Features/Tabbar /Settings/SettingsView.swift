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
    @AppStorage("Appearance") private var selectedAppearance: String = "Light"
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
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity, alignment: .leading)

                ScrollView(showsIndicators: false){
                    VStack(spacing: 10){
                        /// APPEARANCE SECTION
                        settingsCard(title: "Appearance"){
                            settingsRow(icon: "paintbrush.fill", title: "Theme", subtitle: "Adjust app theme"){
                                Picker("Appearance", selection: $selectedAppearance){
                                    Text("Light").tag("Light")
                                    Text("Dark").tag("Dark")
                                    Text("System").tag("System")
                                }
                                .pickerStyle(.segmented)
                                .onChange(of: selectedAppearance){ _, newValue in
                                    updateAppearanceMode(newValue)
                                }
                            }
                            
                            Divider()
                            
                            settingsRow(icon: "drop.fill", title: "Glass depth", subtitle: "Adjusts glass effect"){
                                Picker("", selection: $glassManager.style){
                                    ForEach(GlassStyle.allCases, id: \.self){ style in
                                        Text(style.rawValue.capitalized).tag(style)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        
                        /// UNITS SECTION
                        settingsCard(title: "Units"){
                            settingsRow(icon: "thermometer", title: "Temperature", subtitle: "Adjust Temperature scale"){
                                Picker("", selection: $selectedTemp){
                                    Text("°F").tag("°F")
                                    Text("°C").tag("°C")
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            Divider()
                            
                            settingsRow(icon: "wind", title: "Wind speed", subtitle: "Adjust wind speed units"){
                                Picker("", selection: $selectedWind){
                                    Text("mph").tag("mph")
                                    Text("m/s").tag("m/s")
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        /// ABOUT SECTION
                        settingsCard(title: "About"){
                            navigationRow(icon: "bell", title: "Notifications", subtitle: "Rain alerts and daily summaries")
                            Divider()
                            navigationRow(icon: "info.circle", title: "About this app", subtitle: "Version 1.0.0 • Weather data source")
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 30)
                }
            }
        }
    }
    
    // MARK: - Components
    /// Settings Card - SECTION TITLE INSIDE
    private func settingsCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10){
            Text(title)
                .poppinFont(.bold, 18)
                .foregroundColor(.white)
                .padding(.leading, 5)
            
            VStack(spacing: 10){
                content()
            }
        }
        .padding()
        .liquidGlassEffect(in: RoundedRectangle(cornerRadius: 20))
    }
    
    /// Settings Row - VERTICAL STYLE FOR BREATHING ROOM
    private func settingsRow<Control: View>(
        icon: String,
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> Control
    ) -> some View {
        VStack(alignment: .leading, spacing: 14){
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
                        .poppinFont(.bold, 15)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(subtitle)
                        .interFont(.regular, 13)
                        .foregroundStyle(.white)
                }
            }
            trailing() /// The Picker sits here with full width
        }
    }
    
    private func navigationRow(icon: String, title: String, subtitle: String) -> some View {
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
                    .poppinFont(.bold, 15)
                    .foregroundStyle(.white.opacity(0.7))
                Text(subtitle)
                    .interFont(.regular, 13)
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
        }
    }
    
    private func updateAppearanceMode(_ mode: String){
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let style: UIUserInterfaceStyle = (mode == "Dark") ? .dark : (mode == "Light" ? .light : .unspecified)
            windowScene.windows.first?.overrideUserInterfaceStyle = style
        }
    }
}
