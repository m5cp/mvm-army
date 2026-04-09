import SwiftUI

struct WatchHomeView: View {
    @Environment(WatchViewModel.self) private var viewModel

    private var data: WatchData { viewModel.data }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                HStack(spacing: 4) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(WatchTheme.accent)
                    Text("MVM FITNESS")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundStyle(WatchTheme.accent)
                }
                .padding(.top, 4)

                if data.completedToday {
                    completedCard
                } else if let title = data.todayWorkoutTitle, !title.isEmpty {
                    todayWorkoutCard(title: title)
                } else {
                    noWorkoutCard
                }

                HStack(spacing: 8) {
                    StatPill(
                        icon: "flame.fill",
                        value: "\(data.streak)",
                        label: "Streak",
                        color: .orange
                    )
                    StatPill(
                        icon: "figure.walk",
                        value: formatSteps(data.stepsToday),
                        label: "Steps",
                        color: WatchTheme.accent
                    )
                }

                if data.planWeek > 0 && data.planTotalWeeks > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                            .foregroundStyle(WatchTheme.subtleText)
                        Text("Week \(data.planWeek) of \(data.planTotalWeeks)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(WatchTheme.subtleText)
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private var completedCard: some View {
        VStack(spacing: 6) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 28))
                .foregroundStyle(WatchTheme.success)
                .symbolEffect(.bounce, options: .nonRepeating)

            Text("Workout Done")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Great work today!")
                .font(.system(size: 11))
                .foregroundStyle(WatchTheme.subtleText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(WatchTheme.success.opacity(0.15))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func todayWorkoutCard(title: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(WatchTheme.accent)

            Text("Today's PT")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(WatchTheme.subtleText)
                .textCase(.uppercase)

            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if data.todayExerciseCount > 0 {
                Text("\(data.todayExerciseCount) exercises")
                    .font(.system(size: 11))
                    .foregroundStyle(WatchTheme.subtleText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(WatchTheme.cardBackground)
        .clipShape(.rect(cornerRadius: 12))
    }

    private var noWorkoutCard: some View {
        VStack(spacing: 6) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 22))
                .foregroundStyle(WatchTheme.subtleText)

            Text("Rest Day")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Recovery is training")
                .font(.system(size: 11))
                .foregroundStyle(WatchTheme.subtleText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(WatchTheme.cardBackground)
        .clipShape(.rect(cornerRadius: 12))
    }

    private func formatSteps(_ steps: Int) -> String {
        if steps >= 1000 {
            return String(format: "%.1fk", Double(steps) / 1000.0)
        }
        return "\(steps)"
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(WatchTheme.subtleText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(WatchTheme.cardBackground)
        .clipShape(.rect(cornerRadius: 10))
    }
}
