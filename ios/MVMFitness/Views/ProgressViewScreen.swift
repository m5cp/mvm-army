import SwiftUI
import Charts

struct ProgressViewScreen: View {
    @Environment(AppViewModel.self) private var vm

    @State private var showAFTSheet: Bool = false
    @State private var appeared: Bool = false
    @State private var showAFTCalculator: Bool = false
    @State private var showCompletedWorkouts: Bool = false
    @State private var selectedAFTScore: AFTScoreRecord?
    @State private var showDayWorkouts: Bool = false
    @State private var selectedDayRecord: CompletedWorkoutRecord?
    @State private var showDayDetail: Bool = false
    @State private var showTrainingCalendar: Bool = false


    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    topSummaryHeader
                    primaryMetricsRow
                    thisWeekHero
                    interactiveWeekStrip
                    localActivitySection
                    if !vm.quickStartRecords.isEmpty {
                        quickStartHistoryCard
                    }
                    weeklyFrequencyChart
                    aftCard
                    if !vm.aftScores.isEmpty {
                        aftHistoryCard
                    }
                    AIInsightsCard()
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)

                    PerformanceHighlightsView(
                        highlights: vm.performanceHighlights,
                        showEmptyState: vm.performanceHighlights.isEmpty
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showAFTSheet) {
            AFTScoreSheet()
        }
        .sheet(item: $selectedAFTScore) { score in
            AFTShareSheet(score: score, previous: vm.previousAFTScore)
        }
        .navigationDestination(isPresented: $showAFTCalculator) {
            AFTCalculatorView()
        }
        .navigationDestination(isPresented: $showCompletedWorkouts) {
            CompletedWorkoutsListView()
        }
        .navigationDestination(isPresented: $showDayDetail) {
            if let record = selectedDayRecord {
                CompletedWorkoutDetailView(record: record)
            }
        }
        .navigationDestination(isPresented: $showTrainingCalendar) {
            TrainingCalendarView()
        }
        .onAppear {
            vm.pedometer.refreshTodaySteps()
            Task {
                try? await Task.sleep(for: .milliseconds(400))
                vm.syncTodaySteps()
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.05)) {
                appeared = true
            }
        }
    }

    // MARK: - Top Summary Header

    private var topSummaryHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(todayDateString)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            Spacer()

            if vm.streak > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.warning)
                    Text("\(vm.streak)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                        .contentTransition(.numericText())
                    Text("day streak")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(MVMTheme.warning.opacity(0.1))
                .clipShape(Capsule())
                .overlay {
                    Capsule().stroke(MVMTheme.warning.opacity(0.2), lineWidth: 0.5)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private var todayDateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: .now)
    }

    // MARK: - Primary Metrics Row

    private var primaryMetricsRow: some View {
        let todaySteps = vm.pedometer.todaySteps

        return HStack(spacing: 10) {
            primaryMetricCard(
                icon: "figure.walk",
                iconColor: MVMTheme.success,
                value: todaySteps.formatted(),
                label: "Steps",
                sublabel: "Today"
            )

            primaryMetricCard(
                icon: "checkmark.seal.fill",
                iconColor: MVMTheme.accent,
                value: "\(vm.totalWorkoutsCompleted)",
                label: "Workouts",
                sublabel: "Total"
            )

            primaryMetricCard(
                icon: "flame.fill",
                iconColor: Color(hex: "#FF6B35"),
                value: "\(vm.workoutsThisWeek)",
                label: "This Week",
                sublabel: "Sessions"
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func primaryMetricCard(icon: String, iconColor: Color, value: String, label: String, sublabel: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.12))
                .clipShape(Circle())

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(MVMTheme.primaryText)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            VStack(spacing: 1) {
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)
                Text(sublabel)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(MVMTheme.card)
        .clipShape(.rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(MVMTheme.border)
        }
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value) \(sublabel)")
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
            .padding(.bottom, 18)

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
                    value: "\(vm.totalWorkoutsCompleted)",
                    label: "Total",
                    icon: "checkmark.seal.fill",
                    color: MVMTheme.success
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
        .shadow(color: MVMTheme.accent.opacity(0.06), radius: 20, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func heroStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
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

    // MARK: - Interactive 7-Day Strip

    private var interactiveWeekStrip: some View {
        Button {
            showTrainingCalendar = true
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Training Week")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("Calendar")
                            .font(.caption.weight(.semibold))
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                }

                HStack(spacing: 5) {
                    ForEach(weekDates, id: \.self) { date in
                        let status = vm.calendarDateStatus(date)
                        let isToday = Calendar.current.isDateInToday(date)

                        VStack(spacing: 6) {
                            Text(dayAbbrev(date))
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(isToday ? MVMTheme.accent : MVMTheme.tertiaryText)

                            ZStack {
                                Circle()
                                    .fill(weekDotFill(status: status, isToday: isToday))
                                    .frame(width: 34, height: 34)

                                weekDotIcon(status: status, isToday: isToday)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(18)
            .premiumCard()
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private var weekDates: [Date] {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    private func weekDotFill(status: AppViewModel.CalendarWorkoutStatus?, isToday: Bool) -> Color {
        switch status {
        case .completed: return MVMTheme.success
        case .planned: return isToday ? MVMTheme.accent.opacity(0.25) : MVMTheme.accent.opacity(0.15)
        case .missed: return MVMTheme.tertiaryText.opacity(0.15)
        case nil: return isToday ? MVMTheme.accent.opacity(0.12) : MVMTheme.cardSoft
        }
    }

    @ViewBuilder
    private func weekDotIcon(status: AppViewModel.CalendarWorkoutStatus?, isToday: Bool) -> some View {
        switch status {
        case .completed:
            Image(systemName: "checkmark")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
        case .planned:
            Circle()
                .fill(MVMTheme.accent)
                .frame(width: 6, height: 6)
        case .missed:
            Image(systemName: "minus")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(MVMTheme.tertiaryText)
        case nil:
            if isToday {
                Circle()
                    .fill(MVMTheme.accent)
                    .frame(width: 6, height: 6)
            } else {
                EmptyView()
            }
        }
    }

    // MARK: - Activity Cards Section

    private var localActivitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(MVMTheme.accent)
                    .font(.subheadline.weight(.semibold))
                Text("Activity")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
                Spacer()
            }
            .padding(.horizontal, 4)

            HStack(spacing: 10) {
                localMetricTile(
                    icon: "figure.walk",
                    name: "Steps",
                    value: vm.pedometer.todaySteps.formatted(),
                    sublabel: "Today",
                    color: MVMTheme.success
                )

                localMetricTile(
                    icon: "calendar",
                    name: "Streak",
                    value: "\(vm.streak)",
                    sublabel: vm.streak == 1 ? "day" : "days",
                    color: MVMTheme.warning
                )
            }

            HStack(spacing: 10) {
                localMetricTile(
                    icon: "dumbbell.fill",
                    name: "Completed",
                    value: "\(vm.totalWorkoutsCompleted)",
                    sublabel: "All time",
                    color: MVMTheme.slateAccent
                )

                localMetricTile(
                    icon: "chart.line.uptrend.xyaxis",
                    name: "Avg Steps",
                    value: vm.weeklyStepAverage.formatted(),
                    sublabel: "7-day avg",
                    color: MVMTheme.accent
                )
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func localMetricTile(icon: String, name: String, value: String, sublabel: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)

                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(MVMTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .contentTransition(.numericText())

                Text(sublabel)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 100)
        .background(MVMTheme.card)
        .clipShape(.rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20).stroke(MVMTheme.border)
        }
        .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
    }

    // MARK: - Weekly Frequency Chart

    private var weeklyFrequencyChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(MVMTheme.accent)
                    .font(.subheadline.weight(.semibold))
                Text("4-Week Training")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)

                Spacer()

                let totalCompleted = last4WeeksData.reduce(0) { $0 + $1.count }
                if totalCompleted > 0 {
                    Text("\(totalCompleted) total")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            }

            let weekData = last4WeeksData

            if weekData.allSatisfy({ $0.count == 0 }) {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 28))
                        .foregroundStyle(MVMTheme.tertiaryText)

                    Text("No Training Data Yet")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    Text("Complete workouts to see your training frequency.")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                Chart {
                    ForEach(weekData, id: \.label) { week in
                        BarMark(
                            x: .value("Week", week.label),
                            y: .value("Workouts", week.count)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [MVMTheme.accent, MVMTheme.accent.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(MVMTheme.border)
                        AxisValueLabel()
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                }
                .frame(height: 150)

                Button {
                    showCompletedWorkouts = true
                } label: {
                    HStack(spacing: 6) {
                        Text("View Completed Workouts")
                            .font(.caption.weight(.semibold))
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(MVMTheme.accent.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(20)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private struct WeekFrequency {
        let label: String
        let count: Int
    }

    private var last4WeeksData: [WeekFrequency] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        return (0..<4).reversed().map { weeksAgo in
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: today).flatMap {
                calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: $0))
            } ?? today
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? today

            let count = vm.completedRecords.filter { $0.date >= weekStart && $0.date < weekEnd }.count

            let label: String
            if weeksAgo == 0 {
                label = "This"
            } else if weeksAgo == 1 {
                label = "Last"
            } else {
                label = "\(weeksAgo)w ago"
            }

            return WeekFrequency(label: label, count: count)
        }
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

                Button {
                    showAFTCalculator = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption.weight(.bold))
                        Text("New AFT Score")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(MVMTheme.accent.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 32))
                        .foregroundStyle(MVMTheme.tertiaryText)

                    Text("No AFT Scores Yet")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    Text("Log your first score to track improvement.")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.tertiaryText)

                    Button {
                        showAFTSheet = true
                    } label: {
                        Text("Log First Score")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.accent)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(MVMTheme.accent.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .padding(20)
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
        .padding(.vertical, 8)
        .background(MVMTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 12))
    }

    private func aftPillColor(_ value: Int) -> Color {
        if value >= 80 { return MVMTheme.success }
        if value >= 60 { return MVMTheme.accent }
        if value >= 40 { return MVMTheme.warning }
        return MVMTheme.danger
    }

    // MARK: - AFT History Card

    private var aftHistoryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.rectangle.portrait")
                    .foregroundStyle(MVMTheme.accent)
                    .font(.subheadline.weight(.semibold))
                Text("AFT History")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)

                Spacer()

                Text("\(vm.aftScores.count) records")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            ForEach(vm.aftScores.prefix(5)) { score in
                aftHistoryRow(score)
            }

            if vm.aftScores.count > 5 {
                Text("\(vm.aftScores.count - 5) more scores")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func aftHistoryRow(_ score: AFTScoreRecord) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(score.totalScore)")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(aftHistoryScoreColor(score.totalScore))

                Text(aftHistoryDateString(score.date))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            Spacer()

            HStack(spacing: 4) {
                aftMiniPill(score.deadliftPoints)
                aftMiniPill(score.pushUpPoints)
                aftMiniPill(score.sdcPoints)
                aftMiniPill(score.plankPoints)
                aftMiniPill(score.runPoints)
            }

            Button {
                selectedAFTScore = score
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 30, height: 30)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(12)
        .background(MVMTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 14))
    }

    private func aftMiniPill(_ value: Int) -> some View {
        Text("\(value)")
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(aftPillColor(value))
            .frame(width: 26, height: 20)
            .background(aftPillColor(value).opacity(0.12))
            .clipShape(.rect(cornerRadius: 5))
    }

    private func aftHistoryScoreColor(_ total: Int) -> Color {
        if total >= 400 { return MVMTheme.success }
        if total >= 300 { return MVMTheme.accent }
        if total >= 200 { return MVMTheme.warning }
        return MVMTheme.danger
    }

    private func aftHistoryDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: date)
    }

    // MARK: - Quick Start History

    private var quickStartHistoryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(Color(hex: "#059669"))
                    .font(.subheadline.weight(.semibold))
                Text("Quick Start")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)

                Spacer()

                Text("\(vm.quickStartRecords.count) sessions")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            ForEach(vm.quickStartRecords.prefix(5)) { record in
                quickStartRow(record)
            }

            if vm.quickStartRecords.count > 5 {
                Text("\(vm.quickStartRecords.count - 5) more sessions")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func quickStartRow(_ record: QuickStartRecord) -> some View {
        HStack(spacing: 12) {
            Image(systemName: record.activity.icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(hex: record.activity.gradientHex.0))
                .frame(width: 32, height: 32)
                .background(Color(hex: record.activity.gradientHex.0).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(record.activity.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)
                Text(quickStartDateString(record.startDate))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(record.formattedDuration)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                if record.activity.usesGPS {
                    Text(record.formattedDistance)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            }
        }
        .padding(12)
        .background(MVMTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 14))
    }

    private func quickStartDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, h:mm a"
        return f.string(from: date)
    }

    // MARK: - Helpers

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds) / 60
        if totalMinutes == 0 { return "0m" }
        if totalMinutes < 60 { return "\(totalMinutes)m" }
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        return "\(hours)h \(mins)m"
    }

    private func dayAbbrev(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(2)).uppercased()
    }
}
