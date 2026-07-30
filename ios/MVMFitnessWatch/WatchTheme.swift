import SwiftUI

/// Golden Hour palette — same token names as before (green family →
/// amber family). `success`/`danger` stay semantic green/red so pass/fail
/// remains instantly readable, matching the phone app's MVMTheme rule.
enum WatchTheme {
    static let accent = Color(hex: "#E8A33D") // was #2E7D52
    static let accentLight = Color(hex: "#F2B358") // was #4A7C6B
    static let success = Color(hex: "#22C55E") // semantic — unchanged
    static let warning = Color(hex: "#C9832E") // was #D4915E
    static let danger = Color(hex: "#EF4444") // semantic — unchanged
    static let cardBackground = Color(hex: "#0C0908").opacity(0.55) // wells tone, was white 8%
    static let subtleText = Color(hex: "#F2EDE4").opacity(0.55) // was white 55%
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
