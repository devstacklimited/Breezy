//
//  GlassManager.swift
//  Breezy
//
//  Created by Mian Usama on 26/02/2026.
//

import SwiftUI
import Combine

final class GlassManager: ObservableObject {
    @AppStorage("selectedGlassStyle")
    private var storedStyle: String = GlassStyle.standard.rawValue
    
    @Published var style: GlassStyle = .standard {
        didSet {
            storedStyle = style.rawValue
        }
    }
    
    init(){
        style = GlassStyle(rawValue: storedStyle) ?? .standard
    }
}
