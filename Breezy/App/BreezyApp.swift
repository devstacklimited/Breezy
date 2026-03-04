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
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("Appearance") private var selectedAppearance: String = "Light"
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
        .onChange(of: scenePhase){ oldPhase, newPhase in
            switch newPhase {
            case .active:
                applyAppearanceMode(selectedAppearance)
            case .inactive:
                /// Save state when app goes background
                print("App is now in background")
            default:
                break
            }
        }
    }
    
    init(){
        SecretsManager()
    }
    
    private func applyAppearanceMode(_ mode: String){
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            switch mode {
            case "Dark":
                windowScene.windows.first?.overrideUserInterfaceStyle = .dark
            case "Light":
                windowScene.windows.first?.overrideUserInterfaceStyle = .light
            case "System":
                windowScene.windows.first?.overrideUserInterfaceStyle = .unspecified
            default:
                break
            }
        }
    }
}
