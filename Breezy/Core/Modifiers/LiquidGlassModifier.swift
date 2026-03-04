//
//  LiquidGlassModifier.swift
//  Breezy
//
//  Created by Mian Usama on 26/02/2026.
//

import SwiftUI

struct LiquidGlassModifier<S: Shape>: ViewModifier {
    @EnvironmentObject private var glassManager: GlassManager
    let shape: S
    let tint: Color?
    let interactive: Bool
    
    func body(content: Content) -> some View {
        let style = glassManager.style
        if #available(iOS 26, *){
            content
                .glassEffect(
                    .clear
                        .tint((tint ?? .blue).opacity(style.tintOpacity))
                        .interactive(interactive),
                    in: shape
                )
                .clipShape(shape)
                .shadow(
                    color: .black.opacity(style.shadowOpacity),
                    radius: style.blurRadius
                )
        } else {
            content
                .background(
                    shape
                        .fill(.ultraThinMaterial)
                        .overlay(
                            shape
                                .fill((tint ?? .white).opacity(style.tintOpacity))
                        )
                )
                .clipShape(shape)
                .shadow(
                    color: .black.opacity(style.shadowOpacity),
                    radius: style.blurRadius
                )
        }
    }
}
