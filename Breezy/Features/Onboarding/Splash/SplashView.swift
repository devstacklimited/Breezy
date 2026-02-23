//
//  SplashView.swift
//  Breezy
//
//  Created by Mian Usama on 13/10/2025.
//

import SwiftUI

struct SplashView: View {
    let router: AppRouter
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @State private var floatOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            /// Background
            Color.backgroundGradient
                .ignoresSafeArea()
            
            /// Soft radial highlight
            RadialGradient(
                gradient: Gradient(colors: [
                    .white.opacity(0.15),
                    .clear
                ]),
                center: .center,
                startRadius: 20,
                endRadius: 300
            )
            .ignoresSafeArea()
            
            VStack(spacing: 10){
                Spacer()
                /// Cloud Icon (Main Focus)
                Image("cloudIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(color: .white.opacity(0.35), radius: 30)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .offset(y: floatOffset)
                
                /// Branding
                VStack(spacing: 6){
                    Text("Breezy")
                        .poppinFont(.bold, 38)
                        .foregroundColor(.white)
                    
                    Text("Real-time weather. Beautifully simple.")
                        .interFont(.regular, 14)
                        .foregroundColor(.white.opacity(0.75))
                }
                .opacity(opacity)
                
                Spacer()
                
                /// Minimal bottom branding feel
                Text("Powered by precision forecasts")
                    .interFont(.regular, 12)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 40)
                    .opacity(opacity)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            /// Unified smooth entrance
            withAnimation(.easeOut(duration: 1.2)){
                scale = 1.0
                opacity = 1.0
            }
            /// Subtle floating animation (more premium than rotation)
            withAnimation(.easeInOut(duration: 3)
                .repeatForever(autoreverses: true)){
                    floatOffset = -10
                }
            /// Navigation
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                router.path.append(SplashRoute.locationPermission)
            }
        }
    }
}
