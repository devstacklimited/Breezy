//
//  SplashView.swift
//  Breezy
//
//  Created by Mian Usama on 13/10/2025.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive: Bool = false
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.3
    
    var body: some View {
        if isActive {
            HomeView()
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.cyan]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20){
                    Image(systemName: "cloud.sun.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.2)){
                                self.scale = 1.0
                                self.opacity = 1.0
                            }
                        }
                    
                    Text("Breezy")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.4).delay(0.3)){
                                self.opacity = 1.0
                            }
                        }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
