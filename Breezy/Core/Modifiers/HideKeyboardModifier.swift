//
//  HideKeyboardModifier.swift
//  Breezy
//
//  Created by Mian Usama on 16/10/2025.
//

import SwiftUI

struct HideKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .gesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
            )
    }
}
