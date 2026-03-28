import SwiftUI
import Charts

struct ProgressViewScreen: View {
    @Environment(AppViewModel.self) private var vm

    @State private var showAFTSheet = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    thisWeekSection
                    weekCompletionStrip
                    aftProgressSection
                    activitySection
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

    // MARK: - This Week

    private var thisWeekSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .foregroundStyle(MVMTheme.accent)
                    .font(.subheadline.weight(.semibold))
                Text("This Week")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }

            HStack(spacing: 12) {
                statCell(
                    label: "Individual PT",
                    value: individualPTLabel,
                    icon: "figure.strengthtraining.traditional",
                    color: MVMTheme.accent
                )

                statCell(
                    label: "Unit PT",
                    value: "\(vm.unitPTSessionsCompleted)",
                    icon: "person.3.fill",
                    color: MVMTheme.accent2
                )

                statCell(
                    label: "Streak",
                    value: "\(vm.streak)",
                    icon: "flame.fill",
                    color: MVMTheme.warning
                )
            }
        }
        .padding(18)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private var individualPTLabel: String {
        if let plan = vm.currentPlan {
            let completed = plan.completedCount
            let total = plan.totalWorkoutDays
            return "\(completed)/\(total)"
        }
        return "\(vm.workoutsThisWeek)"
    }

    private func statCell(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
                .contentTransition(.numericText())

            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(MVMTheme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 7-Day Completion Strip

    private var weekCompletionStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7-Day Overview")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)

            if let plan = vm.currentPlan {
                HStack(spacing: 6) {
                    ForEach(plan.days, id: \.dayIndex) { day in
                        VStack(spacing: 6) {
                            Text(dayAbbrev(day.date))
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(
                                    Calendar.current.isDateInToday(day.date) ? MVMTheme.accent : MVMTheme.tertiaryText
                                )

                            ZStack {
                                Circle()
                                    .fill(dayDotColor(day))
                                    .frame(width: 28, height: 28)

                                if day.isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.white)
                                } else if day.isRestDay {
                                    Image(systemName: "moon.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(MVMTheme.tertiaryText)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            } else {
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { i in
                        VStack(spacing: 6) {
                            Text(weekdayAbbrev(offset: i))
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(MVMTheme.tertiaryText)

                            Circle()
                                .fill(MVMTheme.cardSoft)
                                .frame(width: 28, height: 28)
                        }
                        .frame(maxWidth: .infinity)
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

    // MARK: - AFT Progress

    private var aftProgressSection: some View {
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
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Latest")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.secondaryText)
                        Text("\(latest.totalScore)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(MVMTheme.primaryText)
                            .contentTransition(.numericText())
                    }

                    if let previous = vm.previousAFTScore {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Previous")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(MVMTheme.secondaryText)
                            Text("\(previous.totalScore)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
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
                    aftMiniPill("MDL", latest.deadliftPoints)
                    aftMiniPill("HRP", latest.pushUpPoints)
                    aftMiniPill("SDC", latest.sdcPoints)
                    aftMiniPill("PLK", latest.plankPoints)
                    aftMiniPill("2MR", latest.runPoints)
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

                if vm.aftScores.count > 1 {
                    aftMiniTrend
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

    private var aftMiniTrend: some View {
        Chart(vm.aftScores.prefix(8).reversed()) { item in
            AreaMark(
                x: .value("Date", item.date),
                y: .value("Score", item.totalScore)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [MVMTheme.accent.opacity(0.3), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            LineMark(
                x: .value("Date", item.date),
                y: .value("Score", item.totalScore)
            )
            .foregroundStyle(MVMTheme.accent)
            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 80)
        .padding(.top, 4)
    }

    // MARK: - Activity

    private var activitySection: some View {
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

            if !vm.stepHistory.isEmpty {
                Chart(vm.stepHistory.suffix(7)) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Steps", item.steps)
                    )
                    .foregroundStyle(
                        Calendar.current.isDateInToday(item.date) ? MVMTheme.accent : MVMTheme.accent.opacity(0.4)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 7)) { _ in
                        AxisValueLabel()
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }
                .chartYAxis(.hidden)
                .frame(height: 100)
            }
        }
        .padding(18)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    // MARK: - Helpers

    private func aftMiniPill(_ label: String, _ value: Int) -> some View {
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

    private func dayDotColor(_ day: WorkoutDay) -> Color {
        if day.isCompleted { return MVMTheme.success }
        if Calendar.current.isDateInToday(day.date) { return MVMTheme.accent.opacity(0.25) }
        if day.isRestDay { return MVMTheme.cardSoft }
        return MVMTheme.cardSoft
    }

    private func dayAbbrev(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let full = formatter.string(from: date)
        return String(full.prefix(2)).uppercased()
    }

    private func weekdayAbbrev(offset: Int) -> String {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now
        let date = calendar.date(byAdding: .day, value: offset, to: start) ?? .now
        return dayAbbrev(date)
    }
}
