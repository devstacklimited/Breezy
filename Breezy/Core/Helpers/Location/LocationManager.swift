//
//  LocationManager.swift
//  Breezy
//
//  Created by Mian Usama on 14/11/2025.
//

import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    
    @Published var userCity: String?
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init(){
        super.init()
        manager.delegate = self
    }

    /// Step 1: Ask for permission
    func requestLocationAccess(){
        manager.requestWhenInUseAuthorization()
    }

    /// Step 2: Called when user makes a choice
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    /// Step 3: When location is received
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let location = locations.first else { return }
        self.userLocation = location
        fetchCity(from: location)
    }

    /// Step 4: Reverse-geocode city name
    private func fetchCity(from location: CLLocation){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location){[weak self] places, _ in
            guard let self = self else { return }
            guard let city = places?.first?.locality else { return }
            Task { @MainActor in
                self.userCity = city
                print("📍User's city: \(city)")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Location error:", error.localizedDescription)
    }
}
