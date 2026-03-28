import SwiftUI
import Charts

struct ProgressViewScreen: View {
    @Environment(AppViewModel.self) private var vm

    @State private var showAFTSheet: Bool = false
    @State private var appeared: Bool = false

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    thisWeekHero
                    weekStrip
                    aftCard
                    activityCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showAFTSheet) {
            AFTScoreSheet()
        }
        .onAppear {
            vm.pedometer.refreshTodaySteps()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                vm.syncTodaySteps()
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - This Week Hero

    private var thisWeekHero: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .foregroundStyle(MVMTheme.accent)
                    .font(.subheadline.weight(.semibold))
                Text("This Week")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
                Spacer()
            }
            .padding(.bottom, 20)

            HStack(spacing: 0) {
                heroStat(
                    value: individualPTLabel,
                    label: "Individual PT",
                    icon: "figure.strengthtraining.traditional",
                    color: MVMTheme.accent
                )

                Rectangle()
                    .fill(MVMTheme.border)
                    .frame(width: 1, height: 48)

                heroStat(
                    value: "\(vm.unitPTSessionsCompleted)",
                    label: "Unit PT",
                    icon: "person.3.fill",
                    color: MVMTheme.accent2
                )

                Rectangle()
                    .fill(MVMTheme.border)
                    .frame(width: 1, height: 48)

                heroStat(
                    value: "\(vm.streak)",
                    label: vm.streak == 1 ? "Day Streak" : "Day Streak",
                    icon: "flame.fill",
                    color: MVMTheme.warning
                )
            }
        }
        .padding(20)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(MVMTheme.card)
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [MVMTheme.accent.opacity(0.06), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 24)
                    .stroke(MVMTheme.accent.opacity(0.15))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: MVMTheme.accent.opacity(0.08), radius: 20, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func heroStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(MVMTheme.primaryText)
                .contentTransition(.numericText())

            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private var individualPTLabel: String {
        if let plan = vm.currentPlan {
            return "\(plan.completedCount)/\(plan.totalWorkoutDays)"
        }
        return "\(vm.workoutsThisWeek)"
    }

    // MARK: - 7-Day Strip

    private var weekStrip: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Last 7 Days")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)

            if let plan = vm.currentPlan {
                HStack(spacing: 8) {
                    ForEach(plan.days, id: \.dayIndex) { day in
                        dayDot(
                            label: dayAbbrev(day.date),
                            isToday: Calendar.current.isDateInToday(day.date),
                            isCompleted: day.isCompleted,
                            isRest: day.isRestDay
                        )
                    }
                }
            } else {
                HStack(spacing: 8) {
                    ForEach(0..<7, id: \.self) { i in
                        dayDot(
                            label: weekdayAbbrev(offset: i),
                            isToday: false,
                            isCompleted: false,
                            isRest: false
                        )
                    }
                }

                Text("Generate a plan to track your week.")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
        }
        .padding(18)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func dayDot(label: String, isToday: Bool, isCompleted: Bool, isRest: Bool) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(isToday ? MVMTheme.accent : MVMTheme.tertiaryText)

            ZStack {
                Circle()
                    .fill(dotColor(isCompleted: isCompleted, isToday: isToday, isRest: isRest))
                    .frame(width: 30, height: 30)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                } else if isRest {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(MVMTheme.tertiaryText)
                } else if isToday {
                    Circle()
                        .fill(MVMTheme.accent)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func dotColor(isCompleted: Bool, isToday: Bool, isRest: Bool) -> Color {
        if isCompleted { return MVMTheme.success }
        if isToday { return MVMTheme.accent.opacity(0.2) }
        return MVMTheme.cardSoft
    }

    // MARK: - AFT Card

    private var aftCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "shield.fill")
                        .foregroundStyle(MVMTheme.accent)
                        .font(.subheadline.weight(.semibold))
                    Text("AFT Progress")
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                }

                Spacer()

                Button {
                    showAFTSheet = true
                } label: {
                    Text("Log Score")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(MVMTheme.accent.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            if let latest = vm.latestAFTScore {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Latest")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.secondaryText)
                        Text("\(latest.totalScore)")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(MVMTheme.primaryText)
                            .contentTransition(.numericText())
                    }

                    Spacer()

                    if let previous = vm.previousAFTScore {
                        VStack(alignment: .center, spacing: 4) {
                            Text("Previous")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(MVMTheme.secondaryText)
                            Text("\(previous.totalScore)")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }
                    }

                    Spacer()

                    if let diff = vm.aftScoreDifference {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Change")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(MVMTheme.secondaryText)
                            HStack(spacing: 4) {
                                Image(systemName: diff >= 0 ? "arrow.up.right" : "arrow.down.right")
                                    .font(.caption.weight(.bold))
                                Text(diff >= 0 ? "+\(diff)" : "\(diff)")
                                    .font(.title3.weight(.bold).monospacedDigit())
                            }
                            .foregroundStyle(diff >= 0 ? MVMTheme.success : MVMTheme.danger)
                        }
                    }
                }

                HStack(spacing: 5) {
                    aftPill("MDL", latest.deadliftPoints)
                    aftPill("HRP", latest.pushUpPoints)
                    aftPill("SDC", latest.sdcPoints)
                    aftPill("PLK", latest.plankPoints)
                    aftPill("2MR", latest.runPoints)
                }

                if !latest.weakestEvents.isEmpty {
                    HStack(spacing: 5) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(MVMTheme.warning)
                        Text("Focus: \(latest.weakestEvents.joined(separator: ", "))")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(MVMTheme.warning)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.title2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                    Text("No AFT scores yet")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                    Text("Log your first score to track improvement.")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .padding(18)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func aftPill(_ label: String, _ value: Int) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.secondaryText)
            Text("\(value)")
                .font(.caption.weight(.bold))
                .foregroundStyle(aftPillColor(value))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func aftPillColor(_ value: Int) -> Color {
        if value >= 80 { return MVMTheme.success }
        if value >= 60 { return MVMTheme.accent }
        if value >= 40 { return MVMTheme.warning }
        return MVMTheme.danger
    }

    // MARK: - Activity Card

    private var activityCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "figure.walk")
                    .foregroundStyle(MVMTheme.accent)
                    .font(.subheadline.weight(.semibold))
                Text("Activity")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.secondaryText)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(vm.pedometer.todaySteps)")
                            .font(.title2.weight(.bold).monospacedDigit())
                            .foregroundStyle(MVMTheme.primaryText)
                            .contentTransition(.numericText())
                        Text("steps")
                            .font(.caption)
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("7-Day Avg")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.secondaryText)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(vm.weeklyStepAverage)")
                            .font(.title3.weight(.semibold).monospacedDigit())
                            .foregroundStyle(MVMTheme.primaryText)
                            .contentTransition(.numericText())
                        Text("avg")
                            .font(.caption)
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }
            }
        }
        .padding(18)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    // MARK: - Helpers

    private func dayAbbrev(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(2)).uppercased()
    }

    private func weekdayAbbrev(offset: Int) -> String {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now
        let date = calendar.date(byAdding: .day, value: offset, to: start) ?? .now
        return dayAbbrev(date)
    }
}
