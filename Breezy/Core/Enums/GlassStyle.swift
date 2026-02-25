//
//  GlassStyle.swift
//  Breezy
//
//  Created by Mian Usama on 26/02/2026.
//

import SwiftUI

enum GlassStyle: String, CaseIterable {
    case subtle
    case standard
    case immersive
    
    var blurRadius: CGFloat {
        switch self {
        case .subtle: return 8
        case .standard: return 16
        case .immersive: return 28
        }
    }
    
    var tintOpacity: Double {
        switch self {
        case .subtle: return 0.08
        case .standard: return 0.15
        case .immersive: return 0.25
        }
    }
    
    var shadowOpacity: Double {
        switch self {
        case .subtle: return 0.08
        case .standard: return 0.15
        case .immersive: return 0.30
        }
    }
}
