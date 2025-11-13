//
//  Font+Extensions.swift
//  Breezy
//
//  Created by Mian Usama on 14/11/2025.
//

import SwiftUI

extension Font {
    static let poppinFont: (PoppinFontWeight, CGFloat) -> Font = { fontType, size in
        switch fontType {
        case .light:
            Font.custom("Poppins-Light", size: size)
        case .regular:
            Font.custom("Poppins-Regular", size: size)
        case .medium:
            Font.custom("Poppins-Medium", size: size)
        case .semibold:
            Font.custom("Poppins-SemiBold", size: size)
        case .bold:
            Font.custom("Poppins-Bold", size: size)
        case .black:
            Font.custom("Poppins-Black", size: size)
        }
    }
    
    static let interFont: (InterFontWeight, CGFloat) -> Font = { fontType, size in
        switch fontType {
        case .thin:
            return Font.custom("Inter-Thin", size: size)
        case .extraLight:
            return Font.custom("Inter-ExtraLight", size: size)
        case .light:
            return Font.custom("Inter-Light", size: size)
        case .regular:
            return Font.custom("Inter-Regular", size: size)
        case .medium:
            return Font.custom("Inter-Medium", size: size)
        case .semibold:
            return Font.custom("Inter-SemiBold", size: size)
        case .bold:
            return Font.custom("Inter-Bold", size: size)
        case .extraBold:
            return Font.custom("Inter-ExtraBold", size: size)
        case .black:
            return Font.custom("Inter-Black", size: size)
        }
    }
}
