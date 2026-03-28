import SwiftUI

enum MVMTheme {
    static let background = Color(hex: "#09090B")
    static let card = Color(hex: "#121317")
    static let cardSoft = Color(hex: "#171A20")
    static let border = Color.white.opacity(0.08)
    static let accent = Color(hex: "#4F8CFF")
    static let accent2 = Color(hex: "#7C5CFF")
    static let success = Color(hex: "#22C55E")
    static let warning = Color(hex: "#F59E0B")
    static let danger = Color(hex: "#EF4444")
    static let primaryText = Color.white
    static let secondaryText = Color(hex: "#9CA3AF")
    static let tertiaryText = Color(hex: "#6B7280")

    static let heroGradient = LinearGradient(
        colors: [
            Color(hex: "#4F8CFF").opacity(0.95),
            Color(hex: "#7C5CFF").opacity(0.90)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let subtleGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.08),
            Color.clear
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (255, 255, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
