import SwiftUI

struct WatchStatsView: View {
    @Environment(WatchViewModel.self) private var viewModel

    private var data: WatchData { viewModel.data }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("TODAY'S STATS")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(WatchTheme.accent)
                    .padding(.top, 4)

                statRow(
                    icon: "figure.walk",
                    title: "Steps",
                    value: "\(data.stepsToday)",
                    unit: "steps",
                    color: WatchTheme.accent
                )

                statRow(
                    icon: "flame.fill",
                    title: "Streak",
                    value: "\(data.streak)",
                    unit: data.streak == 1 ? "day" : "days",
                    color: .orange
                )

                if let score = data.aftScore, score > 0 {
                    statRow(
                        icon: "shield.fill",
                        title: "AFT Score",
                        value: "\(score)",
                        unit: "pts",
                        color: data.aftPassed == true ? WatchTheme.success : .red
                    )
                }

                if data.planWeek > 0 && data.planTotalWeeks > 0 {
                    statRow(
                        icon: "calendar",
                        title: "Plan",
                        value: "Wk \(data.planWeek)/\(data.planTotalWeeks)",
                        unit: "",
                        color: .cyan
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func statRow(icon: String, title: String, value: String, unit: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(WatchTheme.subtleText)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(WatchTheme.subtleText)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(WatchTheme.cardBackground)
        .clipShape(.rect(cornerRadius: 10))
    }
}
