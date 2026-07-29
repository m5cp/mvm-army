import SwiftUI

/// 10c / 10d — plaque total, margin-over-minimum table, delta vs previous
/// record (baseline treatment on first test). No percentile claims anywhere.
struct ResultView: View {
    let total: Int
    let previous: Int?          // nil = first recorded test (10d)
    let margins: [(AFTEvent, Int)]   // points over the 60-pt minimum

    var body: some View {
        ZStack {
            MVMTheme.screen.ignoresSafeArea()
            RadialGradient(stops: [
                .init(color: MVMTheme.amber.opacity(0.2), location: 0),
                .init(color: .clear, location: 0.66)],
                center: .init(x: 0.5, y: -0.08), startRadius: 0, endRadius: 420)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RaisedCard(radius: 26) {
                        VStack(spacing: 6) {
                            Text("TOTAL").font(MVMTheme.mono(11)).kerning(2)
                                .foregroundStyle(MVMTheme.textMuted)
                            Text("\(total)")
                                .font(MVMTheme.scoreDisplay(64))
                                .foregroundStyle(MVMTheme.text)
                                .lineLimit(1).fixedSize()
                            if let previous {
                                Text((total >= previous ? "+" : "−") + "\(abs(total - previous)) VS LAST")
                                    .font(MVMTheme.mono(11)).kerning(1)
                                    .foregroundStyle(total >= previous ? MVMTheme.amber : MVMTheme.textMuted)
                                    .lineLimit(1).fixedSize()
                            } else {
                                Text("BASELINE " + MVMTheme.dot + " EVERYTHING COMPARES BACK TO TODAY")
                                    .font(MVMTheme.mono(10)).kerning(1)
                                    .foregroundStyle(MVMTheme.textMuted)
                                    .lineLimit(1).fixedSize()
                            }
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 24)
                    }
                    RaisedCard {
                        VStack(spacing: 0) {
                            ForEach(margins, id: \.0) { event, margin in
                                HStack {
                                    EventTagChip(event: event)
                                    Text("OVER MINIMUM")
                                        .font(MVMTheme.mono(10)).kerning(1.2)
                                        .foregroundStyle(MVMTheme.textFaint)
                                    Spacer()
                                    Text("+\(margin)")
                                        .font(MVMTheme.scoreDisplay(22))
                                        .foregroundStyle(MVMTheme.amber)
                                        .lineLimit(1).fixedSize()
                                }
                                .padding(.horizontal, 14).frame(height: 62)
                                if event != margins.last?.0 { Divider().overlay(MVMTheme.hairline) }
                            }
                        }
                    }
                }
                .padding(.horizontal, 22).padding(.top, 12)
            }
        }
    }
}
