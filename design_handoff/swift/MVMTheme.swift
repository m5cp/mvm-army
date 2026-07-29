import SwiftUI

/// Design tokens for the Golden Hour / spec-sheet redesign.
/// Keep token names stable; views reference these only.
enum MVMTheme {
    // MARK: Colors
    static let base        = Color(hex: 0x0F0D0A)   // app background
    static let screen      = Color(hex: 0x0B0908)   // full-bleed screens
    static let cardTop     = Color(hex: 0x1C1613)   // raised card gradient start
    static let cardBottom  = Color(hex: 0x141010)
    static let well        = Color(hex: 0x0C0908)   // inset value wells
    static let text        = Color(hex: 0xF2EDE4)
    static let textMuted   = Color(hex: 0xF2EDE4).opacity(0.5)
    static let textFaint   = Color(hex: 0xF2EDE4).opacity(0.35)
    static let amber       = Color(hex: 0xE8A33D)
    static let amberBtnTop = Color(hex: 0xF2B358)
    static let amberBtnBot = Color(hex: 0xDD9027)
    static let onAmber     = Color(hex: 0x180F06)   // text on amber fills
    static let duotone     = Color(hex: 0xA84A16)   // hero duotone ground
    static let hairline    = Color.white.opacity(0.07)

    // MARK: Radii
    static let rScreenCard: CGFloat = 26
    static let rCard: CGFloat = 20
    static let rWell: CGFloat = 14
    static let rButton: CGFloat = 18

    // MARK: Gradients
    static var cardGradient: LinearGradient {
        LinearGradient(colors: [cardTop, cardBottom], startPoint: .top, endPoint: .bottom)
    }
    static var amberButtonGradient: LinearGradient {
        LinearGradient(colors: [amberBtnTop, amberBtnBot], startPoint: .top, endPoint: .bottom)
    }

    // MARK: Type
    // UI text: SF Pro at Apple sizes (respect Dynamic Type).
    // Display face is ONLY for score numerals. Bundle Archivo-Bold; fall back to rounded.
    static func scoreDisplay(_ size: CGFloat) -> Font {
        if UIFont(name: "Archivo-Bold", size: size) != nil {
            return .custom("Archivo-Bold", size: size)
        }
        return .system(size: size, weight: .bold, design: .rounded)
    }
    static func mono(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    /// Middle dot separator for compound values — NEVER a hyphen (hyphens wrap).
    static let dot = "·"
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}
