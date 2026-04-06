import SwiftUI

struct WatchAFTView: View {
    @Environment(WatchViewModel.self) private var viewModel

    private var data: WatchData { viewModel.data }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("AFT SCORE")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(WatchTheme.accent)
                    .padding(.top, 4)

                if let score = data.aftScore {
                    scoreCard(score: score)
                } else {
                    noScoreCard
                }

                summaryRow
            }
            .padding(.horizontal, 4)
        }
    }

    private func scoreCard(score: Int) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: Double(score) / 600.0)
                    .stroke(
                        scoreColor(score),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(score)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("/ 600")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(WatchTheme.subtleText)
                }
            }
            .frame(width: 110, height: 110)

            if let passed = data.aftPassed {
                HStack(spacing: 4) {
                    Image(systemName: passed ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                        .font(.system(size: 12))
                    Text(passed ? "PASS" : "NEEDS WORK")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(passed ? WatchTheme.success : WatchTheme.warning)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(WatchTheme.cardBackground)
        .clipShape(.rect(cornerRadius: 12))
    }

    private var noScoreCard: some View {
        VStack(spacing: 6) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 28))
                .foregroundStyle(WatchTheme.subtleText)

            Text("No AFT Score")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Log a score in the app")
                .font(.system(size: 11))
                .foregroundStyle(WatchTheme.subtleText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(WatchTheme.cardBackground)
        .clipShape(.rect(cornerRadius: 12))
    }

    private var summaryRow: some View {
        HStack(spacing: 8) {
            StatPill(
                icon: "flame.fill",
                value: "\(data.streak)",
                label: "Streak",
                color: .orange
            )

            StatPill(
                icon: "trophy.fill",
                value: "\(viewModel.data.planWeek > 0 ? "Wk \(viewModel.data.planWeek)" : "--")",
                label: "Plan",
                color: WatchTheme.accentLight
            )
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 500 { return WatchTheme.success }
        if score >= 360 { return WatchTheme.accent }
        if score >= 300 { return WatchTheme.warning }
        return WatchTheme.danger
    }
}
