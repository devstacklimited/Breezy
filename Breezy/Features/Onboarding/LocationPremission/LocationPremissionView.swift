//
//  LocationPremissionView.swift
//  Breezy
//
//  Created by Mian Usama on 14/11/2025.
//

import SwiftUI
import CoreLocation

struct LocationPermissionView: View {
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var sessionManager: AppSessionManager

    var body: some View {
        ZStack {
            // MARK: - Background Gradient
            GeometryReader { geometry in
                Image("background")
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
            
            if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
                ProgressView("Loading...")
                    .foregroundColor(.white)
            } else {
                VStack(spacing: 25){
                    Spacer()
                    Image(systemName: "location")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .padding(20)
                        .liquidGlassEffect(in: Circle(), tint: .blue.opacity(0.7))
                    
                    VStack(spacing: 10){
                        Text("Enable Location Access")
                            .poppinFont(.bold, 26)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Allow Breezy to access your location to show accurate local weather and forecasts.")
                            .interFont(.regular, 15)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 15){
                        Button {
                            locationManager.requestLocationAccess()
                        } label: {
                            Text("Allow Location")
                                .poppinFont(.semibold, 17)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .liquidGlassEffect(in: Capsule())
                        }
                        .padding(.horizontal, 30)
                        
                        /// Show Settings Button if denied
                        if locationManager.authorizationStatus == .denied ||
                            locationManager.authorizationStatus == .restricted {
                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString){
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text("Open Settings")
                                    .poppinFont(.medium, 16)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onReceive(locationManager.$userCity){ city in
            if let city = city, !city.isEmpty {
                sessionManager.setHomeIfCityAvailable(city: city)
            }
        }
    }
}
