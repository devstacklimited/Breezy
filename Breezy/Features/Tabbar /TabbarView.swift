//
//  TabbarView.swift
//  Breezy
//
//  Created by Mian Usama on 20/02/2026.
//

import SwiftUI

struct TabbarView: View {
    let router: AppRouter
    
    var body: some View {
        TabView {
            HomeView(router: router)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            AddCitiesView(router: router)
                .tabItem {
                    Label("Cities", systemImage: "map")
                }
            
            SettingsView(router: router)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(.yellow.opacity(0.8))
    }
}
