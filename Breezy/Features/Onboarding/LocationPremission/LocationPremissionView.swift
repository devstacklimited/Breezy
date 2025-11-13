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

    var body: some View {
        ZStack {
            // MARK: - Background Gradient
            Color.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 10){
                Spacer()
                // MARK: - App Icon
                Image(systemName: "cloud.sun.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.white, .yellow.opacity(0.7))
                    .shadow(color: Color.white.opacity(0.6), radius: 25, x: 0, y: 0)
                    .shadow(radius: 10)

                VStack (spacing: 5){
                    // MARK: - Title
                    Text("Enable Location Access")
                        .poppinFont(.bold, 24)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    // MARK: - Description
                    Text("We use your location to show local weather updates and forecasts around you.")
                        .interFont(.regular, 15)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // MARK: - Instructions for denied/restricted
                if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                    VStack(spacing: 15){
                        VStack(spacing: 5){
                            Text("⚠️ Location Access Disabled")
                                .interFont(.bold, 18)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("Please enable location access to use Breezy and get local weather updates.")
                                .interFont(.regular, 14)
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        
                        Text("Go to Settings > Breezy > Location > Allow While Using App")
                            .interFont(.bold, 15)
                            .foregroundColor(.yellow.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(14)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 20)
                }

                Spacer()

                // MARK: - Allow Location Button
                if locationManager.authorizationStatus != .denied && locationManager.authorizationStatus != .restricted {
                    Button(action: {
                        locationManager.requestLocationAccess()
                    }){
                        Text("Allow Location Access")
                            .poppinFont(.semibold, 18)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#FFD056"))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 32)
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .onReceive(locationManager.$authorizationStatus){ status in
            // If user granted permission, request location updates
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                locationManager.requestLocationAccess()
            }
        }
        .onReceive(locationManager.$userCity){ city in
            if let city = city, !city.isEmpty {
                print("Detected city: \(city)")
                // TODO: Navigate to Home screen when ready
            }
        }
    }
}
