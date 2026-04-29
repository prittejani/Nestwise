// NWColors.swift
// Netwise
//
//  Created by Prit  on 12/04/26.
//

import SwiftUI

enum NWColors {

    // MARK: - Semantic Colors
    static let accent          = Color("AccentColor")          // purple-blue brand color
    static let accentLight     = Color("AccentLight")          // accent at ~12% opacity surface

    static let background      = Color("Background")           // page background
    static let surface         = Color("Surface")              // card / input background
    static let surfaceSecondary = Color("SurfaceSecondary")    // pressed states, dividers

    static let primaryText     = Color("PrimaryText")
    static let secondaryText   = Color("SecondaryText")
    static let tertiaryText    = Color("TertiaryText")

    // MARK: - Fallback (in-code) — used until Asset Catalog colors are added
    // These adaptive colors work in both light and dark mode without Asset Catalog entries.
    // Once you add named colors in Assets.xcassets, the above names take over.

    static var accentFallback: Color { Color(light: Color(hex: "#6C63FF"), dark: Color(hex: "#9F97FF")) }
    static var backgroundFallback: Color { Color(light: .white, dark: Color(hex: "#111113")) }
    static var surfaceFallback: Color { Color(light: Color(hex: "#F5F5F7"), dark: Color(hex: "#1C1C1E")) }
}

// MARK: - Color Hex Init
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }

    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}
