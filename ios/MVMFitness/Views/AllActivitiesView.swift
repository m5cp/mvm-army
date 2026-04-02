import SwiftUI
import HealthKit

struct AllActivitiesView: View {
    @Environment(AppViewModel.self) private var vm

    @State private var selectedActivity: ActivitySummary?
    @State private var showActivityDetail: Bool = false
    @State private var appeared: Bool = false

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    summaryRow
                    stepsCard
                    caloriesCard

                    if vm.healthKit.isLoadingActivities {
                        loadingCard
                    } else if vm.healthKit.activities.isEmpty {
                        emptyCard
                    } else {
                        activitiesSection
                    }

                    healthKitNotice
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .navigationTitle("All Activities")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $showActivityDetail) {
            if let activity = selectedActivity {
                ActivityDetailView(activity: activity)
            }
        }
        .task {
            await vm.healthKit.fetchTodayActiveCalories()
            await vm.healthKit.fetchAllActivities()
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }

    // MARK: - Summary Row

    private var summaryRow: some View {
        HStack(spacing: 10) {
            summaryPill(
                icon: "figure.mixed.cardio",
                value: "\(vm.healthKit.activities.count)",
                label: "Activities",
                color: MVMTheme.accent
            )

            summaryPill(
                icon: "calendar",
                value: "7 Days",
                label: "Tracked",
                color: MVMTheme.slateAccent
            )

            let totalSessions = vm.healthKit.activities.reduce(0) { $0 + $1.todayCount }
            summaryPill(
                icon: "checkmark.circle.fill",
                value: "\(totalSessions)",
                label: "Today",
                color: MVMTheme.success
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private func summaryPill(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(MVMTheme.primaryText)

            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(MVMTheme.card)
        .clipShape(.rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20).stroke(MVMTheme.border)
        }
        .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
    }

    // MARK: - Steps Card

    private var stepsCard: some View {
        Button {
            let stepActivity = ActivitySummary(
                id: "steps-overview",
                activityType: .walking,
                name: "Steps",
                icon: "figure.walk",
                todayDuration: 0,
                todayCalories: 0,
                todayDistance: 0,
                weeklyAvgDuration: 0,
                weeklyAvgCalories: 0,
                weeklyAvgDistance: 0,
                todayCount: 0,
                hasData: true
            )
            selectedActivity = stepActivity
            showActivityDetail = true
        } label: {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "figure.walk")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.success)
                        .frame(width: 44, height: 44)
                        .background(MVMTheme.success.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Steps")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(MVMTheme.primaryText)
                        Text("Pedometer + HealthKit")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                HStack(spacing: 0) {
                    metricBlock(
                        value: vm.healthKit.todaySteps.formatted(),
                        label: "Today",
                        color: MVMTheme.success
                    )

                    Rectangle()
                        .fill(MVMTheme.border)
                        .frame(width: 1, height: 44)

                    metricBlock(
                        value: vm.healthKit.weeklyAvgSteps.formatted(),
                        label: "7-Day Avg",
                        color: MVMTheme.accent
                    )
                }
                .padding(12)
                .background(MVMTheme.cardSoft)
                .clipShape(.rect(cornerRadius: 14))
            }
            .padding(20)
            .premiumCard()
        }
        .buttonStyle(PressScaleButtonStyle())
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .accessibilityLabel("Steps, \(vm.healthKit.todaySteps) today, \(vm.healthKit.weeklyAvgSteps) seven day average")
        .accessibilityHint("Tap to view daily step breakdown")
    }

    // MARK: - Calories Card

    private var caloriesCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color(hex: "#FF6B35"))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "#FF6B35").opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text("Active Calories")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("All sources")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(Int(vm.healthKit.todayActiveCalories))")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(MVMTheme.primaryText)
                    .contentTransition(.numericText())
                Text("kcal today")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
                Spacer()
            }
        }
        .padding(20)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .accessibilityLabel("Active calories, \(Int(vm.healthKit.todayActiveCalories)) kilocalories today")
    }

    // MARK: - Activities Section

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "figure.mixed.cardio")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
                Text("WORKOUT ACTIVITIES")
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .padding(.leading, 4)

            ForEach(vm.healthKit.activities) { activity in
                Button {
                    selectedActivity = activity
                    showActivityDetail = true
                } label: {
                    activityCard(activity)
                }
                .buttonStyle(PressScaleButtonStyle())
                .accessibilityHint("Tap to view daily breakdown for \(activity.name)")
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private func activityCard(_ activity: ActivitySummary) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: activity.icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 44, height: 44)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(activity.name)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    if activity.todayCount > 0 {
                        Text("\(activity.todayCount) session\(activity.todayCount == 1 ? "" : "s") today")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(MVMTheme.success)
                    } else {
                        Text("No sessions today")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            HStack(spacing: 0) {
                if activity.todayDuration > 0 || activity.weeklyAvgDuration > 0 {
                    VStack(spacing: 5) {
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

                    VStack(spacing: 5) {
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

                    VStack(spacing: 5) {
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
            .padding(12)
            .background(MVMTheme.cardSoft)
            .clipShape(.rect(cornerRadius: 14))

            if activity.todayCalories > 0 || activity.weeklyAvgCalories > 0 {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(Color(hex: "#FF6B35"))
                        Text("\(Int(activity.todayCalories)) kcal today")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }

                    Spacer()

                    Text("Avg \(Int(activity.weeklyAvgCalories)) kcal")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(MVMTheme.cardSoft)
                .clipShape(.rect(cornerRadius: 12))
            }
        }
        .padding(20)
        .premiumCard()
    }

    // MARK: - Loading / Empty

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
        VStack(spacing: 16) {
            Image(systemName: "figure.mixed.cardio")
                .font(.system(size: 40))
                .foregroundStyle(MVMTheme.tertiaryText)

            Text("No Workout Activities Found")
                .font(.headline)
                .foregroundStyle(MVMTheme.secondaryText)

            Text("Activities from Apple Health will appear here once you complete workouts tracked by Apple Watch, iPhone, or compatible fitness apps.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .premiumCard()
    }

    // MARK: - Health Notice

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

            Text("MVM Fitness only displays activities that have recorded data. Your health data stays on-device and is never shared with third parties.")
                .font(.caption2)
                .foregroundStyle(MVMTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding(16)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Helpers

    private func metricBlock(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
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
        if totalMinutes == 0 { return "0m" }
        if totalMinutes < 60 { return "\(totalMinutes)m" }
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        return "\(hours)h \(mins)m"
    }
}
