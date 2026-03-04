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
        case .subtle: return 0
        case .standard: return 8
        case .immersive: return 8
        }
    }
    
    var tintOpacity: Double {
        switch self {
        case .subtle: return 0.0
        case .standard: return 0.08
        case .immersive: return 0.16
        }
    }
    
    var shadowOpacity: Double {
        switch self {
        case .subtle: return 0.08
        case .standard: return 0.08
        case .immersive: return 0.30
        }
    }
}
