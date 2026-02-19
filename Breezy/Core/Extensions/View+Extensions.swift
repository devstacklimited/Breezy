//
//  View+Extensions.swift
//  Breezy
//
//  Created by Mian Usama on 14/11/2025.
//

import SwiftUI

extension View {
    func poppinFont(_ fontWeight: PoppinFontWeight? = .regular, _ size: CGFloat? = nil) -> some View {
        self.font(.poppinFont(fontWeight ?? .regular, size ?? 16))
    }
    
    func interFont(_ fontWeight: InterFontWeight? = .regular, _ size: CGFloat? = nil) -> some View {
        self.font(.interFont(fontWeight ?? .regular, size ?? 16))
    }
    
    func hideKeyboard() -> some View {
        self.modifier(HideKeyboardModifier())
    }
    
    @ViewBuilder
    func liquidGlassEffect<S: Shape>(
        in shape: S,
        tint: Color? = nil,
        interactive: Bool = false
    ) -> some View {
        if #available(iOS 26, *) {
            self
                .glassEffect(
                    .clear
                        .tint(tint ?? .white.opacity(0.08))
                        .interactive(interactive),
                    in: shape
                )
                .overlay {
                    shape
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .blendMode(.overlay)
                }
                .shadow(color: .black.opacity(0.7), radius: 15, y: 10)
                .clipShape(shape)
        } else {
            self
                .background {
                    shape
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    shape
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
                .clipShape(shape)
        }
    }
    
    @ViewBuilder
    func glassContainer(
        spacing: CGFloat = 12,
        content: () -> some View
    ) -> some View {
        if #available(iOS 26, *){
            GlassEffectContainer(spacing: spacing){
                content()
            }
        } else {
            content()
        }
    }
}
