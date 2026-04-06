import SwiftUI

enum WatchTheme {
    static let accent = Color(hex: "#2E7D52")
    static let accentLight = Color(hex: "#4A7C6B")
    static let success = Color(hex: "#22C55E")
    static let warning = Color(hex: "#D4915E")
    static let danger = Color(hex: "#EF4444")
    static let cardBackground = Color.white.opacity(0.08)
    static let subtleText = Color.white.opacity(0.55)
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
