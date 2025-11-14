//
//  SessionView.swift
//  Breezy
//
//  Created by Mian Usama on 14/11/2025.
//

import SwiftUI

@available(iOS 26, *)
struct SessionView: View {
    @EnvironmentObject var sessionManager: AppSessionManager
    
    var body: some View {
        Group {
            switch sessionManager.sessionState {
            case .permissionRequired:
                SplashFlow()
            case .home:
                HomeFlow()
            }
        }
    }
}
