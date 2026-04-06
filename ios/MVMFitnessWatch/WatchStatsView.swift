import SwiftUI

struct WatchStatsView: View {
    @Environment(WatchViewModel.self) private var viewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("TODAY'S STATS")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(WatchTheme.accent)
                    .padding(.top, 4)

                healthRing(
                    icon: "flame.fill",
                    title: "Active Cal",
                    value: String(format: "%.0f", viewModel.todayCalories),
                    unit: "kcal",
                    color: .red
                )

                healthRing(
                    icon: "figure.walk",
                    title: "Steps",
                    value: "\(viewModel.todaySteps)",
                    unit: "steps",
                    color: WatchTheme.accent
                )

                healthRing(
                    icon: "map.fill",
                    title: "Distance",
                    value: String(format: "%.1f", viewModel.todayDistance),
                    unit: "mi",
                    color: .cyan
                )

                if viewModel.heartRate > 0 {
                    healthRing(
                        icon: "heart.fill",
                        title: "Heart Rate",
                        value: String(format: "%.0f", viewModel.heartRate),
                        unit: "bpm",
                        color: .pink
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func healthRing(icon: String, title: String, value: String, unit: String, color: Color) -> some View {
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

                    Text(unit)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(WatchTheme.subtleText)
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
