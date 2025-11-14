//
//  AppSessionManager.swift
//  Breezy
//
//  Created by Mian Usama on 14/11/2025.
//

import SwiftUI
import Combine
import CoreLocation

@MainActor
final class AppSessionManager: ObservableObject {
    @Published var sessionState: SessionState = .permissionRequired
    @Published var userCity: String?
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        observeLocationPermission()
    }
    
    func setHomeIfCityAvailable(city: String?){
        guard let city = city, !city.isEmpty else { return }
        self.userCity = city
        self.sessionState = .home
    }
    
    private func observeLocationPermission(){
        LocationManager.shared.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink {[weak self] status in
                guard let self = self else { return }
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    break
                case .notDetermined:
                    self.sessionState = .permissionRequired
                case .denied, .restricted:
                    self.sessionState = .permissionRequired
                @unknown default:
                    self.sessionState = .permissionRequired
                }
            }
            .store(in: &cancellables)
    }
}
