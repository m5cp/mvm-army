import SwiftUI

enum MVMTheme {
    // MARK: - Core palette (names unchanged — do not rename)
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
    // WCAG AA: 5.15:1 on background (#0C0F0E); previous #6B7280 was 3.98:1
    static let tertiaryText = Color(hex: "#7C8590")

    static let brandGreen = Color(hex: "#1B5E3B")
    static let brandGreenLight = Color(hex: "#2E7D52")
    static let brandGreenDark = Color(hex: "#14442B")
    static let slateAccent = Color(hex: "#5B7A8A")
    static let heroAmber = Color(hex: "#C4833B")

    // MARK: - Promoted tokens (were inline hex literals in Views)
    static let functionalAmber = Color(hex: "#F59E0B")
    static let functionalAmberDark = Color(hex: "#D97706")
    static let emeraldAccent = Color(hex: "#059669")
    static let emeraldAccentDark = Color(hex: "#047857")
    static let lifetimeNavy1 = Color(hex: "#1A1A2E")
    static let lifetimeNavy2 = Color(hex: "#16213E")
    static let lifetimeNavy3 = Color(hex: "#0F3460")

    // MARK: - Spacing scale (use instead of magic numbers going forward)
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: - Corner radius scale (always .continuous)
    enum Radius {
        static let control: CGFloat = 12
        static let card: CGFloat = 16
        static let hero: CGFloat = 20
    }

    // MARK: - Gradients (names unchanged)
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

    static let lifetimeGradient = LinearGradient(
        colors: [lifetimeNavy1, lifetimeNavy2, lifetimeNavy3.opacity(0.8)],
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
