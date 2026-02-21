//
//  Color+Extensions.swift
//  Breezy
//
//  Created by Mian Usama on 14/11/2025.
//

import SwiftUI

extension Color {
    init(hex: String){
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 0.23, green: 0.55, blue: 0.92), location: 0.0),   // blue
                .init(color: Color(red: 0.45, green: 0.70, blue: 0.78), location: 0.5),   // teal blend
                .init(color: Color(red: 0.95, green: 0.78, blue: 0.35), location: 1.0)    // warm yellow
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
