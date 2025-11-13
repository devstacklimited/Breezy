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
    
    var body: some Scene {
        WindowGroup {
            SessionView()
        }
        .environmentObject(sessionManager)
    }
    
    init(){
        SecretsManager()
    }
}
