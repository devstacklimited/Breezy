//
//  AppRouter.swift
//  Breezy
//
//  Created by Mian Usama on 16/10/2025.
//

import Foundation

import SwiftUI

@available(iOS 26.0, *)
final class AppRouter {
    @Binding var path: NavigationPath

    init(path: Binding<NavigationPath>){
        self._path = path
    }

    func push(_ route: AppRoute){
        path.append(route)
    }
    
    func popBack(_ count: Int = 1){
        guard !path.isEmpty else { return }
        let removeCount = min(count, path.count)
        path.removeLast(removeCount)
    }
    
    func popToRoot(){
        path = NavigationPath()
    }
}
