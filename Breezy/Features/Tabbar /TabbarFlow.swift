//
//  TabbarFlow.swift
//  Breezy
//
//  Created by Mian Usama on 16/10/2025.
//

import SwiftUI

struct TabbarFlow: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack {
            TabbarView(router: AppRouter(path: $path))
                .navigationDestination(for: AppRoute.self){ route in
                    switch route {
                    case .city:
                        CityView(route: AppRouter(path: $path))
                    }
                }
        }
    }
}
