import SwiftUI

// MVM Fit — Golden Hour shared components.
//
// ADAPTED FOR THIS CODEBASE (differences vs design_handoff/swift/Components.swift):
// - The prototype's `enum AFTEvent` is REMOVED. The app already has the
//   authoritative event type: `AFTEventType` (mdl, hrp, sdc, plk, run2mi) in
//   Services/AFTScoringEngine.swift. Never introduce a second event enum.
// - `EventTagChip` therefore takes the app's `AFTEventType` and derives its
//   display code ("MDL" … "2MR") from it.
// - Everything else is verbatim from the design package. Type names verified
//   collision-free against the existing target.

// MARK: - Event display code

extension AFTEventType {
    /// Spec-sheet display code. "2MR" for the run — never "run2mi" in UI.
    var displayCode: String {
        switch self {
        case .mdl: return "MDL"
        case .hrp: return "HRP"
        case .sdc: return "SDC"
        case .plk: return "PLK"
        case .run2mi: return "2MR"
        }
    }

    /// Full spoken event name for VoiceOver — the visible chip only ever shows `displayCode`.
    var fullName: String {
        switch self {
        case .mdl: return "Deadlift"
        case .hrp: return "Hand-release push-up"
        case .sdc: return "Sprint-drag-carry"
        case .plk: return "Plank"
        case .run2mi: return "Two-mile run"
        }
    }
}

// MARK: - Elevation

/// Raised "plaque" surface: gradient fill, hairline border, inner top highlight, deep drop shadow.
struct RaisedCard<Content: View>: View {
    var radius: CGFloat = MVMTheme.rCard
    @ViewBuilder var content: Content
    var body: some View {
        content
            .background(MVMTheme.cardGradient)
            .overlay(RoundedRectangle(cornerRadius: radius).stroke(MVMTheme.hairline, lineWidth: 1))
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: radius)
                    .fill(Color.white.opacity(0.07))
                    .frame(height: 1).padding(.horizontal, radius / 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: radius))
            // Whole-card hit target: without this, taps on padding/spacer areas
            // inside a Button label fall through and only the text is tappable.
            .contentShape(RoundedRectangle(cornerRadius: radius))
            .shadow(color: .black.opacity(0.9), radius: 12, y: 12)
    }
}

// MARK: - Card photo thumbnail

/// Small graded photo thumbnail for list/category cards. Every card carries
/// an image per the design direction; photos are neutral at the source and
/// graded here (thumbnailNeutral) so the amber stays in the UI layer.
struct CardPhotoThumb: View {
    let name: String
    var size: CGFloat = 48
    var radius: CGFloat = 12
    var grade: PhotoGrade = .thumbnailNeutral
    var body: some View {
        GradedPhoto(name: name, grade: grade)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).stroke(MVMTheme.hairline, lineWidth: 1))
    }
}

/// Inset value well (inputs, numeric readouts).
struct InsetWell<Content: View>: View {
    var radius: CGFloat = MVMTheme.rWell
    @ViewBuilder var content: Content
    var body: some View {
        content
            .background(MVMTheme.well)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay( // inner shadow
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Color.black.opacity(0.85), lineWidth: 3)
                    .blur(radius: 3)
                    .offset(y: 2)
                    .clipShape(RoundedRectangle(cornerRadius: radius))
                    .allowsHitTesting(false)
            )
    }
}

// MARK: - Metric cell (typography rules)

/// Label ABOVE value so a long value never squeezes its label.
/// Value is single-line and never truncates or wraps mid-token.
struct MetricCell: View {
    let label: String // e.g. "TEMPO"
    let value: String // e.g. "3·1·1" — middle dots, never hyphens
    var valueColor: Color = MVMTheme.text
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(MVMTheme.mono(10))
                .kerning(1.2)
                .foregroundStyle(MVMTheme.textFaint)
                .lineLimit(1).fixedSize()
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(valueColor)
                .lineLimit(1).fixedSize() // NON-NEGOTIABLE: no wrap, no clip
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12).frame(height: 46)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value)")
    }
}

// MARK: - Event photo asset

extension AFTEventType {
    /// Bundled exercise photo for each event (graded neutral in the UI layer).
    var photoAsset: String {
        switch self {
        case .mdl: return "ex-hex-deadlift"
        case .hrp: return "ex-hand-release-pushup"
        case .sdc: return "ex-farmer-carry"
        case .plk: return "ex-plank-weighted"
        case .run2mi: return "golden-runner-portrait"
        }
    }
}

/// Event chip with the exercise photo behind the display code — used on the
/// calculator event rows so every card carries an image. The code sits on a
/// dark scrim so the photo never fights the text.
struct EventPhotoChip: View {
    let event: AFTEventType
    var body: some View {
        ZStack {
            GradedPhoto(name: event.photoAsset, grade: .thumbnailNeutral)
            LinearGradient(
                colors: [Color.black.opacity(0.15), Color.black.opacity(0.62)],
                startPoint: .top, endPoint: .bottom
            )
            Text(event.displayCode)
                .font(MVMTheme.mono(10.5, weight: .bold))
                .foregroundStyle(MVMTheme.amber)
                .lineLimit(1).fixedSize()
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(MVMTheme.hairline, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(event.fullName)
    }
}

// MARK: - Event tag chip

struct EventTagChip: View {
    let event: AFTEventType
    var body: some View {
        Text(event.displayCode)
            .font(MVMTheme.mono(10.5, weight: .bold))
            .foregroundStyle(MVMTheme.amber)
            .lineLimit(1).fixedSize()
            .frame(width: 44, height: 44)
            .background(MVMTheme.well)
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(event.fullName)
    }
}

// MARK: - Amber CTA

struct AmberButton: View {
    let title: String
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16.5, weight: .bold))
                .foregroundStyle(MVMTheme.onAmber)
                .frame(maxWidth: .infinity).frame(minHeight: 54)
        }
        .background(MVMTheme.amberButtonGradient)
        .clipShape(RoundedRectangle(cornerRadius: MVMTheme.rButton))
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: MVMTheme.rButton)
                .fill(Color.white.opacity(0.45)).frame(height: 1).padding(.horizontal, 9)
        }
        .shadow(color: MVMTheme.amberBtnBot.opacity(0.5), radius: 14, y: 10)
    }
}

// MARK: - Photo grades

enum PhotoGrade { case heroDuotone, lowKeyGym, goldenSilhouette, thumbnailNeutral }

/// Applies the four grade recipes. The amber comes from THIS layer, never the photo
/// (golden silhouettes are the one exception — original color survives).
/// Always purely decorative background art, so it's hidden from VoiceOver;
/// any meaningful text/controls are layered on top by the caller and remain reachable.
struct GradedPhoto: View {
    let name: String // asset name (imagesets committed to Assets.xcassets)
    let grade: PhotoGrade
    var body: some View {
        GeometryReader { geo in
            let img = Image(name).resizable().scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height).clipped()
            switch grade {
            case .heroDuotone:
                ZStack {
                    MVMTheme.duotone
                    img.saturation(0).contrast(1.25).blendMode(.luminosity)
                    LinearGradient(stops: [
                        .init(color: MVMTheme.duotone.opacity(0.5), location: 0),
                        .init(color: MVMTheme.screen.opacity(0.25), location: 0.46),
                        .init(color: MVMTheme.screen, location: 0.98)],
                        startPoint: .top, endPoint: .bottom)
                }
            case .lowKeyGym:
                ZStack {
                    img.brightness(-0.18).saturation(0.62).contrast(1.08)
                    MVMTheme.amber.opacity(0.09)
                    LinearGradient(stops: [
                        .init(color: .clear, location: 0.34),
                        .init(color: Color(hex: 0x141010).opacity(0.92), location: 1)],
                        startPoint: .top, endPoint: .bottom)
                }
            case .goldenSilhouette:
                ZStack {
                    img.contrast(1.16).saturation(1.08)
                    RadialGradient(stops: [
                        .init(color: .clear, location: 0.4),
                        .init(color: MVMTheme.screen.opacity(0.72), location: 1)],
                        center: .init(x: 0.5, y: 0.3), startRadius: 0,
                        endRadius: max(geo.size.width, geo.size.height))
                }
            case .thumbnailNeutral:
                img.saturation(0.28).brightness(-0.08) // no overlay, no scrim
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Badge coin (screen 15a)

/// Badge artwork: either a bundled 3D coin PNG (reward art) or an SF Symbol
/// rendered as a coin for badges without dedicated PNG art.
enum BadgeArt: Hashable {
    case png(String)     // icon3d-* asset name
    case symbol(String)  // SF Symbol name
}

struct BadgeCoin: View {
    let art: BadgeArt
    let name: String
    /// Optional "how to earn" line shown under the name. Empty keeps the
    /// original two-line layout for existing call sites.
    var how: String = ""
    let status: String // "JUL 12" / "ACTIVE" / "LOCKED"
    let earned: Bool
    /// True only for the brief window right after a badge flips locked -> earned.
    /// Drives a one-time celebratory scale-up; never affects layout or earn logic.
    var isNewlyEarned: Bool = false

    /// Legacy convenience — existing call sites pass the PNG asset name.
    init(asset: String, name: String, how: String = "", status: String, earned: Bool, isNewlyEarned: Bool = false) {
        self.art = .png(asset)
        self.name = name
        self.how = how
        self.status = status
        self.earned = earned
        self.isNewlyEarned = isNewlyEarned
    }

    init(art: BadgeArt, name: String, how: String = "", status: String, earned: Bool, isNewlyEarned: Bool = false) {
        self.art = art
        self.name = name
        self.how = how
        self.status = status
        self.earned = earned
        self.isNewlyEarned = isNewlyEarned
    }

    @State private var coinScale: CGFloat = 1
    @State private var ringOpacity: Double = 0

    @ViewBuilder
    private var artView: some View {
        switch art {
        case .png(let asset):
            Image(asset).resizable().scaledToFill()
                .scaleEffect(1.3)
        case .symbol(let symbol):
            ZStack {
                MVMTheme.well
                Image(systemName: symbol)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(earned ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(MVMTheme.textFaint))
            }
        }
    }

    var body: some View {
        VStack(spacing: 7) {
            artView
                .saturation(earned ? 1 : 0)
                .brightness(earned ? 0 : -0.38)
                .frame(width: 62, height: 62)
                .clipShape(Circle())
                .overlay(Circle().stroke(earned ? MVMTheme.amber : Color.white.opacity(0.13), lineWidth: 2))
                .overlay(Circle().stroke(MVMTheme.amber, lineWidth: 2.5).scaleEffect(1.3).opacity(ringOpacity))
                .shadow(color: earned ? MVMTheme.amberBtnBot.opacity(0.55) : .clear, radius: 9, y: 8)
                .scaleEffect(coinScale)
            Text(name)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(earned ? MVMTheme.text : MVMTheme.textMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            if !how.isEmpty {
                Text(how)
                    .font(.system(size: 9))
                    .foregroundStyle(MVMTheme.textFaint)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            Text(status)
                .font(MVMTheme.mono(9)).kerning(1)
                .foregroundStyle(earned ? MVMTheme.amber : MVMTheme.textFaint)
                .lineLimit(1).fixedSize()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13).padding(.horizontal, 8)
        .background(MVMTheme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(MVMTheme.hairline, lineWidth: 1))
        .onAppear { if isNewlyEarned { playEarnAnimation() } }
        .onChange(of: isNewlyEarned) { _, newValue in if newValue { playEarnAnimation() } }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(name), \(earned ? "earned \(status)" : "locked")")
    }

    private func playEarnAnimation() {
        coinScale = 1
        ringOpacity = 0
        withAnimation(.spring(response: 0.32, dampingFraction: 0.45)) {
            coinScale = 1.28
            ringOpacity = 0.9
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.22)) {
            coinScale = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            ringOpacity = 0
        }
    }
}
