import SwiftUI

// MARK: - Surface (the house card style)

/// Layered dark surface: soft vertical gradient + top-edge light hairline + border.
/// This is the ONLY card treatment in the app. No glass, no glow.
struct MVMCardSurface: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [MVMTheme.cardSoft, MVMTheme.card],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .overlay {
                // Top-edge light catch — the detail that makes surfaces feel machined
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.10), .white.opacity(0.03), .clear],
                            startPoint: .top,
                            endPoint: .center
                        ),
                        lineWidth: 1
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(MVMTheme.border, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    func mvmCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(MVMCardSurface(cornerRadius: cornerRadius))
    }
}

// MARK: - Event score ring (AFT signature element)

/// Circular 0–100 progress ring for AFT event points.
/// Color: green when passing (≥ minimum), amber 40–59, red 1–39, dim track at 0.
struct EventScoreRing: View {
    let points: Int
    let minimumToPass: Int

    private var progress: CGFloat { CGFloat(min(max(points, 0), 100)) / 100 }
    private var ringColor: Color {
        if points >= minimumToPass { return MVMTheme.success }
        if points >= 40 { return MVMTheme.warning }
        if points > 0 { return MVMTheme.danger }
        return MVMTheme.tertiaryText.opacity(0.3)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.06), lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            VStack(spacing: 0) {
                Text("\(points)")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(ringColor)
                    .contentTransition(.numericText())
                Text("pts")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
        }
        .frame(width: 58, height: 58)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(points) points")
    }
}

// MARK: - Ghost chart placeholder (empty states)

/// Dimmed sample bars behind a call-to-action — shows what data WILL look like.
struct GhostBars: View {
    private let heights: [CGFloat] = [0.35, 0.55, 0.42, 0.7, 0.5, 0.85, 0.62]

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(heights.enumerated()), id: \.offset) { _, h in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(MVMTheme.accent.opacity(0.18))
                    .frame(height: 64 * h)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 64)
        .overlay(alignment: .topTrailing) {
            Text("SAMPLE")
                .font(.system(size: 8, weight: .heavy))
                .tracking(1)
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Total score gauge (WHOOP-style focal element)

/// Radial gauge for the AFT total (0–500) with a tick mark at the pass threshold.
/// This is the app's screenshot moment — keep it calm: track + arc + numerals only.
struct TotalScoreGauge: View {
    let total: Int // 0...500
    let minimumToPass: Int // 300 (general) or 350 (combat)
    let passed: Bool

    private var progress: CGFloat { CGFloat(min(max(total, 0), 500)) / 500 }
    private var thresholdAngle: CGFloat { CGFloat(minimumToPass) / 500 }
    private var arcColor: Color { passed ? MVMTheme.success : (total > 0 ? MVMTheme.warning : MVMTheme.tertiaryText.opacity(0.3)) }

    var body: some View {
        ZStack {
            // Track (270° arc, open at the bottom)
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.white.opacity(0.07), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(135))

            // Progress arc
            Circle()
                .trim(from: 0, to: 0.75 * progress)
                .stroke(arcColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(135))
                .animation(.spring(response: 0.7, dampingFraction: 0.85), value: progress)

            // Pass-threshold tick
            Rectangle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 2, height: 14)
                .offset(y: -74)
                .rotationEffect(.degrees(135 + 270 * Double(thresholdAngle) + 90))

            VStack(spacing: 2) {
                Text("\(total)")
                    .font(.system(size: 54, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(MVMTheme.primaryText)
                    .contentTransition(.numericText())
                Text("/ 500")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.tertiaryText)
                Text(passed ? "GO" : "MIN \(minimumToPass)")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(1.2)
                    .foregroundStyle(passed ? MVMTheme.success : MVMTheme.tertiaryText)
            }
        }
        .frame(width: 180, height: 180)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Total score \(total) out of 500. \(passed ? "Passing." : "Minimum to pass: \(minimumToPass).")")
    }
}
