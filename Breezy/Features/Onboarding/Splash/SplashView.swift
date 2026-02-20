//
//  SplashView.swift
//  Breezy
//
//  Created by Mian Usama on 13/10/2025.
//

import SwiftUI

struct SplashView: View {
    let router: AppRouter
    @State private var scale: CGFloat = 0.6
    @State private var iconOpacity: Double = 0.3
    @State private var titleOpacity: Double = 0.0
    @State private var subtitleOpacity: Double = 0.0
    @State private var iconRotation: Double = -5
    
    var body: some View {
        ZStack {
            // Background gradient
            Color.black
                .ignoresSafeArea()
            
            // Centering content vertically
            VStack {
                Spacer()
                VStack(spacing: 10){
                    VStack(spacing: 5){
                        // App name
                        Text("Breezy")
                            .poppinFont(.bold, 36)
                            .foregroundColor(.white)
                            .opacity(titleOpacity)
                            .onAppear {
                                withAnimation(.easeIn(duration: 1.4).delay(0.3)){
                                    self.titleOpacity = 1.0
                                }
                            }
                        
                        // More descriptive tagline
                        Text("Stay ahead of the weather with real-time updates and local forecasts tailored just for you.")
                            .interFont(.regular, 14)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .opacity(subtitleOpacity)
                            .onAppear {
                                withAnimation(.easeIn(duration: 1.4).delay(0.6)){
                                    self.subtitleOpacity = 1.0
                                }
                            }
                    }
                    // Cloud Image with refined glow and subtle rotation animation
                    Image(systemName: "cloud.sun.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .foregroundStyle(.white, .yellow.opacity(0.7))
                        .shadow(color: Color.white.opacity(0.6), radius: 25, x: 0, y: 0)
                        .rotationEffect(.degrees(iconRotation))
                        .scaleEffect(scale)
                        .opacity(iconOpacity)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.2)){
                                self.scale = 1.0
                                self.iconOpacity = 1.0
                            }
                            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)){
                                self.iconRotation = 5
                            }
                        }
                }
                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            // Navigate to next route after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5){
                router.path.append(SplashRoute.locationPermission)
            }
        }
    }
}
