//
//  SplashFlow.swift
//  Breezy
//
//  Created by Mian Usama on 14/11/2025.
//

import SwiftUI

struct SplashFlow: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path){
            SplashView(router: AppRouter(path: $path))
                .navigationDestination(for: SplashRoute.self){ route in
                    switch route {
                    case .locationPermission:
                        LocationPermissionView()
                    }
                }
        }
    }
}
