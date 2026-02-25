//
//  BreezyApp.swift
//  Breezy
//
//  Created by Mian Usama on 13/10/2025.
//

import SwiftUI

@available(iOS 26.0, *)
@main
struct BreezyApp: App {
    @StateObject private var sessionManager = AppSessionManager()
    @StateObject private var glassManager = GlassManager()
    @StateObject private var homePresenter = HomePresenter(
            interactor: WeatherInteractor(service: WeatherService.shared)
        )
    
    var body: some Scene {
        WindowGroup {
            SessionView()
        }
        .environmentObject(sessionManager)
        .environmentObject(homePresenter)
        .environmentObject(glassManager)
    }
    
    init(){
        SecretsManager()
    }
}
