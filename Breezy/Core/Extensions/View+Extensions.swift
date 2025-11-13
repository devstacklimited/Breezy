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
}
