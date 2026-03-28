import SwiftUI
import Charts

struct ProgressViewScreen: View {
    @Environment(AppViewModel.self) private var vm

    @State private var showAFTSheet = false

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    topMetrics
                    weeklyCompletionCard

                    if !vm.aftScores.isEmpty {
                        aftScoreCard
                        aftTrendChart
                    }

                    if !vm.stepHistory.isEmpty {
                        stepsChart
                    }

                    recentWorkoutsCard
                }
                .padding(20)
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
        }
    }

    private var topMetrics: some View {
        HStack(spacing: 12) {
            progressMetric(title: "Streak", value: "\(vm.streak)", icon: "flame.fill", color: MVMTheme.warning)
            progressMetric(title: "This Week", value: "\(vm.workoutsThisWeek)", icon: "calendar", color: MVMTheme.accent)
            progressMetric(title: "Total", value: "\(vm.totalWorkoutsCompleted)", icon: "checkmark.circle.fill", color: MVMTheme.success)
        }
    }

    private var weeklyCompletionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(MVMTheme.accent)
                Text("Weekly Progress")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }

            if let plan = vm.currentPlan {
                let completed = plan.completedCount
                let total = plan.totalWorkoutDays
                let progress: Double = total > 0 ? Double(completed) / Double(total) : 0

                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(MVMTheme.cardSoft, lineWidth: 8)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(MVMTheme.accent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.6), value: progress)

                        VStack(spacing: 2) {
                            Text("\(Int(progress * 100))%")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(MVMTheme.primaryText)
                        }
                    }
                    .frame(width: 80, height: 80)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(completed) of \(total) workouts done")
                            .font(.headline)
                            .foregroundStyle(MVMTheme.primaryText)

                        Text(completionMessage(completed: completed, total: total))
                            .font(.subheadline)
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                }

                HStack(spacing: 4) {
                    ForEach(plan.days, id: \.dayIndex) { day in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(dayBarColor(day))
                            .frame(height: 6)
                    }
                }
                .padding(.top, 4)
            } else {
                Text("Generate a weekly plan to track progress.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
            }
        }
        .padding(18)
        .premiumCard()
    }

    private var aftScoreCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "shield.fill")
                        .foregroundStyle(MVMTheme.accent)
                    Text("AFT Score History")
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                }

                Spacer()

                Button {
                    showAFTSheet = true
                } label: {
                    Text("Log New")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(MVMTheme.accent.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            if let latest = vm.latestAFTScore {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Latest")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.secondaryText)
                        Text("\(latest.totalScore)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(MVMTheme.primaryText)
                            .contentTransition(.numericText())
                    }

                    Spacer()

                    if vm.aftScores.count > 1 {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Average")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(MVMTheme.secondaryText)
                            Text("\(vm.averageAFTScore)")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(MVMTheme.primaryText)
                        }
                    }
                }

                HStack(spacing: 6) {
                    aftEventPill("MDL", latest.deadliftPoints)
                    aftEventPill("HRP", latest.pushUpPoints)
                    aftEventPill("SDC", latest.sdcPoints)
                    aftEventPill("PLK", latest.plankPoints)
                    aftEventPill("2MR", latest.runPoints)
                }

                if !latest.weakestEvents.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(MVMTheme.warning)
                        Text("Focus: \(latest.weakestEvents.joined(separator: ", "))")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(MVMTheme.warning)
                    }
                }
            }

            ForEach(vm.aftScores.prefix(5)) { record in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.primaryText)

                        Text("Weakest: \(record.weakestEvents.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundStyle(MVMTheme.secondaryText)
                    }

                    Spacer()

                    Text("\(record.totalScore)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                }

                if record.id != vm.aftScores.prefix(5).last?.id {
                    Divider()
                        .overlay(MVMTheme.border)
                }
            }
        }
        .padding(18)
        .premiumCard()
    }

    private var aftTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(MVMTheme.accent)
                Text("AFT Score Trend")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }

            Chart(vm.aftScores.prefix(10).reversed()) { item in
                AreaMark(
                    x: .value("Date", item.date),
                    y: .value("Score", item.totalScore)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [MVMTheme.accent.opacity(0.35), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Score", item.totalScore)
                )
                .foregroundStyle(MVMTheme.accent)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))

                PointMark(
                    x: .value("Date", item.date),
                    y: .value("Score", item.totalScore)
                )
                .foregroundStyle(MVMTheme.accent2)
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                        .foregroundStyle(MVMTheme.border)
                    AxisTick()
                        .foregroundStyle(MVMTheme.border)
                    AxisValueLabel()
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                        .foregroundStyle(MVMTheme.border)
                    AxisValueLabel()
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }
            .frame(height: 200)
        }
        .padding(18)
        .premiumCard()
    }

    private var stepsChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "figure.walk")
                    .foregroundStyle(MVMTheme.accent)
                Text("Step History")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)

                Spacer()

                Text("Avg: \(vm.averageSteps)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            Chart(vm.stepHistory.suffix(10)) { item in
                BarMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Steps", item.steps)
                )
                .foregroundStyle(MVMTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisValueLabel()
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }
            .frame(height: 200)
        }
        .padding(18)
        .premiumCard()
    }

    private var recentWorkoutsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(MVMTheme.accent)
                Text("Recent Workouts")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }

            if vm.completedRecords.isEmpty {
                Text("No workouts completed yet. Start from your weekly plan.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
            } else {
                ForEach(vm.completedRecords.prefix(8)) { record in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(MVMTheme.primaryText)

                            Text(record.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(MVMTheme.secondaryText)
                        }

                        Spacer()

                        Text("\(record.exerciseCount) ex")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(MVMTheme.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(MVMTheme.accent.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    if record.id != vm.completedRecords.prefix(8).last?.id {
                        Divider()
                            .overlay(MVMTheme.border)
                    }
                }
            }
        }
        .padding(18)
        .premiumCard()
    }

    private func progressMetric(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
                .contentTransition(.numericText())

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(MVMTheme.secondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCardStyle()
    }

    private func aftEventPill(_ label: String, _ value: Int) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.secondaryText)
            Text("\(value)")
                .font(.caption.weight(.bold))
                .foregroundStyle(aftPillColor(value))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func aftPillColor(_ value: Int) -> Color {
        if value >= 80 { return MVMTheme.success }
        if value >= 60 { return MVMTheme.accent }
        if value >= 40 { return MVMTheme.warning }
        return MVMTheme.danger
    }

    private func dayBarColor(_ day: WorkoutDay) -> Color {
        if day.isCompleted { return MVMTheme.success }
        if day.isRestDay { return MVMTheme.cardSoft }
        return MVMTheme.accent.opacity(0.2)
    }

    private func completionMessage(completed: Int, total: Int) -> String {
        guard total > 0 else { return "Set up your plan first." }
        let pct = Double(completed) / Double(total)
        if pct >= 1.0 { return "Week complete. Outstanding." }
        if pct >= 0.75 { return "Almost there. Keep pushing." }
        if pct >= 0.5 { return "Halfway through. Stay consistent." }
        if completed > 0 { return "Good start. Keep showing up." }
        return "Time to get after it."
    }
}
