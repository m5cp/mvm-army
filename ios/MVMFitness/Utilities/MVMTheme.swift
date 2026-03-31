import SwiftUI

enum MVMTheme {
    static let background = Color(hex: "#0C0F0E")
    static let card = Color(hex: "#141917")
    static let cardSoft = Color(hex: "#1A201E")
    static let border = Color.white.opacity(0.08)
    static let accent = Color(hex: "#2E7D52")
    static let accent2 = Color(hex: "#4A7C6B")
    static let success = Color(hex: "#22C55E")
    static let warning = Color(hex: "#D4915E")
    static let danger = Color(hex: "#EF4444")
    static let primaryText = Color.white
    static let secondaryText = Color(hex: "#9CA3AF")
    static let tertiaryText = Color(hex: "#6B7280")

    static let brandGreen = Color(hex: "#1B5E3B")
    static let brandGreenLight = Color(hex: "#2E7D52")
    static let brandGreenDark = Color(hex: "#14442B")
    static let slateAccent = Color(hex: "#5B7A8A")
    static let heroAmber = Color(hex: "#C4833B")

    static let heroGradient = LinearGradient(
        colors: [
            Color(hex: "#1B5E3B").opacity(0.95),
            Color(hex: "#2E7D52").opacity(0.90)
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

    static let aftGradient = LinearGradient(
        colors: [
            Color(hex: "#1B5E3B"),
            Color(hex: "#14442B"),
            Color(hex: "#0F3320")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let ptGradient = LinearGradient(
        colors: [
            Color(hex: "#2E5A7C"),
            Color(hex: "#1E3F5A")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let functionalGradient = LinearGradient(
        colors: [
            Color(hex: "#8B5E34"),
            Color(hex: "#6B4423")
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
