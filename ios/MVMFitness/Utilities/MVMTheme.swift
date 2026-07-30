import SwiftUI
import UIKit
import CoreText

/// MVM Fit — Golden Hour / spec-sheet theme.
///
/// MERGE STRATEGY (do not deviate):
/// - Every legacy token NAME is preserved so the app's ~2,300 existing
///   `MVMTheme.` references keep compiling untouched. Only VALUES changed
///   (green family → Golden Hour amber family).
/// - New Golden Hour tokens are ADDED below the legacy block. New/redesigned
///   views should use the new tokens; legacy views keep their names.
/// - Categorical colors kept distinct on purpose: `success`/`danger` stay
///   semantic green/red (AFT pass–fail must remain instantly readable),
///   `ptGradient` (slate) and `lifetimeGradient` (navy) remain categorical
///   surfaces — they harmonize with the warm base.
enum MVMTheme {

    // MARK: - Legacy palette (names unchanged — DO NOT RENAME; values re-mapped to Golden Hour)
    static let background = Color(hex: "#0F0D0A") // was #0C0F0E
    static let card = Color(hex: "#181310") // was #141917
    static let cardSoft = Color(hex: "#1C1613") // was #1A201E
    static let border = Color.white.opacity(0.07) // hairline spec
    static let accent = Color(hex: "#E8A33D") // was green #2E7D52
    static let accent2 = Color(hex: "#C98F3A") // was #4A7C6B
    static let success = Color(hex: "#22C55E") // semantic — unchanged
    static let warning = Color(hex: "#E8A33D") // was #D4915E
    static let danger = Color(hex: "#EF4444") // semantic — unchanged
    static let primaryText = Color(hex: "#F2EDE4") // was .white
    static let secondaryText = Color(hex: "#F2EDE4").opacity(0.55)
    // Contrast note: keep tertiary legible on #0F0D0A (predecessor was tuned for WCAG AA)
    static let tertiaryText = Color(hex: "#F2EDE4").opacity(0.45)

    static let brandGreen = Color(hex: "#B87718") // brand family now amber
    static let brandGreenLight = Color(hex: "#E8A33D")
    static let brandGreenDark = Color(hex: "#8A5A12")
    static let slateAccent = Color(hex: "#5B7A8A") // categorical — unchanged
    static let heroAmber = Color(hex: "#E8A33D")

    // MARK: - Promoted tokens (legacy names)
    static let functionalAmber = Color(hex: "#E8A33D") // was #F59E0B
    static let functionalAmberDark = Color(hex: "#DD9027") // was #D97706
    static let emeraldAccent = Color(hex: "#D99A33") // was emerald #059669
    static let emeraldAccentDark = Color(hex: "#B87718") // was #047857
    static let lifetimeNavy1 = Color(hex: "#1A1A2E") // categorical — unchanged
    static let lifetimeNavy2 = Color(hex: "#16213E")
    static let lifetimeNavy3 = Color(hex: "#0F3460")

    // MARK: - Spacing scale (unchanged)
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: - Corner radius scale (unchanged names; always .continuous)
    enum Radius {
        static let control: CGFloat = 12
        static let card: CGFloat = 16
        static let hero: CGFloat = 20
    }

    // MARK: - Legacy gradients (names unchanged; values re-mapped)
    static let heroGradient = LinearGradient(
        colors: [
            Color(hex: "#A06A1B").opacity(0.95),
            Color(hex: "#7A4E10").opacity(0.90)
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
            Color(hex: "#B87718"),
            Color(hex: "#8A5A12"),
            Color(hex: "#5E3C0B")
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

    // ═════════════════════════════════════════════════════════════════════
    // MARK: - Golden Hour tokens (NEW — redesigned screens reference these)
    // ═════════════════════════════════════════════════════════════════════

    static let base = Color(hex: 0x0F0D0A) // app background
    static let screen = Color(hex: 0x0B0908) // full-bleed screens
    static let cardTop = Color(hex: 0x1C1613) // raised card gradient start
    static let cardBottom = Color(hex: 0x141010)
    static let well = Color(hex: 0x0C0908) // inset value wells
    static let text = Color(hex: 0xF2EDE4)
    static let textMuted = Color(hex: 0xF2EDE4).opacity(0.5)
    static let textFaint = Color(hex: 0xF2EDE4).opacity(0.35)
    static let amber = Color(hex: 0xE8A33D)
    static let amberBtnTop = Color(hex: 0xF2B358)
    static let amberBtnBot = Color(hex: 0xDD9027)
    static let onAmber = Color(hex: 0x180F06) // text on amber fills
    static let duotone = Color(hex: 0xA84A16) // hero duotone ground
    static let hairline = Color.white.opacity(0.07)

    // MARK: Golden Hour radii
    static let rScreenCard: CGFloat = 26
    static let rCard: CGFloat = 20
    static let rWell: CGFloat = 14
    static let rButton: CGFloat = 18

    // MARK: Golden Hour gradients
    static var cardGradient: LinearGradient {
        LinearGradient(colors: [cardTop, cardBottom], startPoint: .top, endPoint: .bottom)
    }
    static var amberButtonGradient: LinearGradient {
        LinearGradient(colors: [amberBtnTop, amberBtnBot], startPoint: .top, endPoint: .bottom)
    }

    // MARK: Type
    // UI text: SF Pro at Apple sizes (respect Dynamic Type).
    // Display face is ONLY for score numerals (76pt readiness, 64pt plaque totals).
    // Archivo-Bold.ttf ships in Resources/ and is registered at runtime below —
    // no Info.plist / UIAppFonts entry required (project uses a generated Info.plist).
    private static let displayFontRegistered: Bool = {
        if UIFont(name: "Archivo-Bold", size: 12) != nil { return true }
        guard let url = Bundle.main.url(forResource: "Archivo-Bold", withExtension: "ttf") else {
            return false
        }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        return UIFont(name: "Archivo-Bold", size: 12) != nil
    }()

    static func scoreDisplay(_ size: CGFloat) -> Font {
        if displayFontRegistered {
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
    /// Legacy string initializer — used throughout the app. Unchanged.
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

    /// Golden Hour numeric initializer (new). Overloads — does not replace — the
    /// string version above.
    init(hex: UInt32) {
        self.init(.sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255)
    }
}
