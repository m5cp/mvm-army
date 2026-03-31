import SwiftUI

struct AllActivitiesView: View {
    @Environment(AppViewModel.self) private var vm

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    stepsCard
                    caloriesCard

                    if vm.healthKit.isLoadingActivities {
                        loadingCard
                    } else if vm.healthKit.activities.isEmpty {
                        emptyCard
                    } else {
                        ForEach(vm.healthKit.activities) { activity in
                            activityCard(activity)
                        }
                    }

                    healthKitNotice
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .adaptiveContainer()
            }
        }
        .navigationTitle("All Activities")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await vm.healthKit.fetchTodayActiveCalories()
            await vm.healthKit.fetchAllActivities()
        }
    }

    private var stepsCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "figure.walk")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.success)
                    .frame(width: 40, height: 40)
                    .background(MVMTheme.success.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("Steps")
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Pedometer + HealthKit")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer()
            }

            HStack(spacing: 0) {
                metricBlock(
                    value: "\(vm.healthKit.todaySteps)",
                    label: "Today",
                    color: MVMTheme.success
                )

                Rectangle()
                    .fill(MVMTheme.border)
                    .frame(width: 1, height: 40)

                metricBlock(
                    value: "\(vm.healthKit.weeklyAvgSteps)",
                    label: "7-Day Avg",
                    color: MVMTheme.accent
                )
            }
        }
        .padding(18)
        .premiumCard()
    }

    private var caloriesCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "flame.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.warning)
                    .frame(width: 40, height: 40)
                    .background(MVMTheme.warning.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("Active Calories")
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("All sources")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(vm.healthKit.todayActiveCalories))")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(MVMTheme.primaryText)
                    .contentTransition(.numericText())
                Text("kcal today")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
                Spacer()
            }
        }
        .padding(18)
        .premiumCard()
    }

    private func activityCard(_ activity: ActivitySummary) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: activity.icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 40, height: 40)
                    .background(MVMTheme.accent.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.name)
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                    if activity.todayCount > 0 {
                        Text("\(activity.todayCount) session\(activity.todayCount == 1 ? "" : "s") today")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.success)
                    } else {
                        Text("No sessions today")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }

                Spacer()
            }

            HStack(spacing: 0) {
                if activity.todayDuration > 0 || activity.weeklyAvgDuration > 0 {
                    VStack(spacing: 6) {
                        Text("Today")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(MVMTheme.secondaryText)
                        Text(formatDuration(activity.todayDuration))
                            .font(.subheadline.weight(.bold).monospacedDigit())
                            .foregroundStyle(MVMTheme.primaryText)
                    }
                    .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(MVMTheme.border)
                        .frame(width: 1, height: 36)

                    VStack(spacing: 6) {
                        Text("7-Day Avg")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(MVMTheme.secondaryText)
                        Text(formatDuration(activity.weeklyAvgDuration))
                            .font(.subheadline.weight(.bold).monospacedDigit())
                            .foregroundStyle(MVMTheme.primaryText)
                    }
                    .frame(maxWidth: .infinity)
                }

                if activity.todayDistance > 0 || activity.weeklyAvgDistance > 0 {
                    Rectangle()
                        .fill(MVMTheme.border)
                        .frame(width: 1, height: 36)

                    VStack(spacing: 6) {
                        Text("Distance")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(MVMTheme.secondaryText)
                        Text(String(format: "%.1f mi", activity.todayDistance))
                            .font(.subheadline.weight(.bold).monospacedDigit())
                            .foregroundStyle(MVMTheme.primaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            if activity.todayCalories > 0 || activity.weeklyAvgCalories > 0 {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(MVMTheme.warning)
                        Text("\(Int(activity.todayCalories)) kcal today")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }

                    Spacer()

                    Text("Avg \(Int(activity.weeklyAvgCalories)) kcal")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(MVMTheme.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(18)
        .premiumCard()
    }

    private var loadingCard: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(MVMTheme.accent)
            Text("Loading activity data...")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MVMTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .premiumCard()
    }

    private var emptyCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "figure.mixed.cardio")
                .font(.system(size: 36))
                .foregroundStyle(MVMTheme.tertiaryText)

            Text("No Workout Activities Found")
                .font(.headline)
                .foregroundStyle(MVMTheme.secondaryText)

            Text("Activities from Apple Health will appear here once you complete workouts tracked by Apple Watch, iPhone, or compatible fitness apps.")
                .font(.caption)
                .foregroundStyle(MVMTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .premiumCard()
    }

    private var healthKitNotice: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                Text("Powered by Apple Health")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            Text("MVM Fitness only displays activities that have recorded data. Your health data stays on-device and is never shared with third parties or used for advertising.")
                .font(.caption2)
                .foregroundStyle(MVMTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding(16)
    }

    private func metricBlock(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(MVMTheme.primaryText)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds) / 60
        if totalMinutes < 60 {
            return "\(totalMinutes)m"
        }
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        return "\(hours)h \(mins)m"
    }
}
