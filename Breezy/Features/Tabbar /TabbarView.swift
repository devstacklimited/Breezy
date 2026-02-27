//
//  TabbarView.swift
//  Breezy
//
//  Created by Mian Usama on 20/02/2026.
//

import SwiftUI

@available(iOS 26.0, *)
struct TabbarView: View {
    private enum Tab {
        case home
        case cities
        case settings
    }
    @State private var selectedTab: Tab = .home
    let router: AppRouter
    
    var body: some View {
        TabView(selection: $selectedTab){
            HomeView(router: router)
                .tabItem {
                    Image(systemName: selectedTab == .home ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(Tab.home)
            
            AddCitiesView(router: router)
                .tabItem {
                    Image(systemName: selectedTab == .cities ? "map.fill" : "map")
                    Text("Cities")
                }
                .tag(Tab.cities)
            
            SettingsView(router: router)
                .tabItem {
                    Image(systemName: selectedTab == .settings ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(Tab.settings)
        }
        .tint(.yellow.opacity(0.6))
    }
}
