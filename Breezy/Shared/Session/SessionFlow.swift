//
//  SessionFlow.swift
//  Breezy
//
//  Created by Mian Usama on 16/10/2025.
//

import SwiftUI

@available(iOS 26.0, *)
struct SessionFlow: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path){
            SplashView(router: AppRouter(path: $path))
                .navigationDestination(for: AppRoute.self){ route in
                    switch route {
                    case .home:
                        HomeView()
                    case .cities:
                        CityManagerView(presenter: <#T##HomePresenter#>, onDone: <#T##() -> Void#>)
                    }
                }
        }
    }
}
