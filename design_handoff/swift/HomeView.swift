import SwiftUI

/// 13a (returning user) / 13b (first run). Full-bleed silhouette header,
/// date line, statement headline, readiness plaque, graded session card.
struct HomeView: View {
    var hasRecord = true
    var body: some View {
        ZStack(alignment: .top) {
            MVMTheme.screen.ignoresSafeArea()
            GradedPhoto(name: "photo-run-silhouette-sunrise", grade: .goldenSilhouette)
                .frame(height: hasRecord ? 244 : 300)
                .overlay(LinearGradient(stops: [
                    .init(color: MVMTheme.screen.opacity(0.62), location: 0),
                    .init(color: MVMTheme.screen.opacity(0.1), location: 0.32),
                    .init(color: MVMTheme.screen.opacity(0.72), location: 0.76),
                    .init(color: MVMTheme.screen, location: 1)],
                    startPoint: .top, endPoint: .bottom))
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    Text(dateLine)
                        .font(MVMTheme.mono(11)).kerning(2)
                        .foregroundStyle(MVMTheme.amber)
                        .padding(.top, 58)
                        .lineLimit(1).fixedSize()
                    Text(hasRecord ? "Me vs Me." : "Start here.")
                        .font(.system(size: 46, weight: .bold)).tracking(-1.8)
                        .foregroundStyle(MVMTheme.text)
                        .padding(.top, 8)
                    Text(hasRecord ? "One session today — beat yesterday."
                                   : "Five events, one score. Log a test and everything after it compares back to today.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(MVMTheme.textMuted)
                        .padding(.top, 8)
                        .frame(maxWidth: 280, alignment: .leading)
                    readinessPlaque.padding(.top, 20)
                }
                .padding(.horizontal, 22)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 9) {
            Image("mvm-glyph-summit-m").resizable().scaledToFit().frame(width: 24)
            Text("MVM FIT").font(.system(size: 15, weight: .bold)).kerning(1.6)
                .foregroundStyle(MVMTheme.text)
            Spacer()
            // Avatar: SF Symbol default; user photo (on-device) when set.
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(MVMTheme.text.opacity(0.9))
        }
        .padding(.top, 16)
    }

    private var readinessPlaque: some View {
        RaisedCard(radius: 24) {
            ZStack(alignment: .leading) {
                GradedPhoto(name: "photo-ruck-wide-landscape", grade: .lowKeyGym)
                LinearGradient(stops: [
                    .init(color: Color(hex: 0x1A1411), location: 0),
                    .init(color: Color(hex: 0x1A1411).opacity(0.9), location: 0.4),
                    .init(color: Color(hex: 0x1A1411).opacity(0.1), location: 1)],
                    startPoint: .leading, endPoint: .trailing)
                VStack(alignment: .leading, spacing: 4) {
                    Text("READINESS").font(MVMTheme.mono(11)).kerning(1.8)
                        .foregroundStyle(MVMTheme.textMuted)
                    HStack(alignment: .firstTextBaseline, spacing: 7) {
                        Text("452").font(MVMTheme.scoreDisplay(76))   // display face: numerals only
                            .foregroundStyle(MVMTheme.text)
                            .lineLimit(1).fixedSize()
                        Text("/600").font(MVMTheme.mono(14))
                            .foregroundStyle(MVMTheme.textFaint)
                            .lineLimit(1).fixedSize()
                    }
                }
                .padding(20)
            }
            .frame(minHeight: 168)
        }
    }

    private var dateLine: String {
        let f = DateFormatter()
        f.dateFormat = "EEE d MMM " + MVMTheme.dot + " HHmm"
        return f.string(from: .now).uppercased()
    }
}
