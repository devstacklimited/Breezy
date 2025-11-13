//
//  HomeFlow.swift
//  Breezy
//
//  Created by Mian Usama on 16/10/2025.
//

import SwiftUI

struct HomeFlow: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path){
            HomeView(router: AppRouter(path: $path))
                .navigationDestination(for: AppRoute.self){ route in
                    switch route {
                    case .cities:
                        CityManagerView(){}
                    }
                }
        }
    }
}
