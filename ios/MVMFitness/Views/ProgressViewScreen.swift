import SwiftUI
import Charts

struct ProgressViewScreen: View {
    @Environment(AppViewModel.self) private var vm
    @AppStorage("disclaimerAccepted") private var disclaimerAccepted: Bool = false

    @State private var showAFTSheet: Bool = false
    @State private var appeared: Bool = false
    @State private var showAFTCalculator: Bool = false
    @State private var showCompletedWorkouts: Bool = false
    @State private var selectedAFTScore: AFTScoreRecord?
    @State private var showDayWorkouts: Bool = false
    @State private var selectedDayRecord: CompletedWorkoutRecord?
    @State private var showDayDetail: Bool = false
    @State private var showTrainingCalendar: Bool = false
    @State private var showAllActivities: Bool = false

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if disclaimerAccepted {
                        thisWeekHero
                        interactiveWeekStrip
                        weeklyFrequencyChart
                    }
                    aftCard
                    if !vm.aftScores.isEmpty {
                        aftHistoryCard
                    }
                    if disclaimerAccepted {
                        activityCard
                    } else {
                        progressDisclaimerBanner
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .adaptiveContainer()
            }
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
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
        .navigationDestination(isPresented: $showAllActivities) {
            AllActivitiesView()
        }
        .onAppear {
            vm.pedometer.refreshTodaySteps()
            Task {
                try? await Task.sleep(for: .milliseconds(400))
                vm.syncTodaySteps()
                await vm.healthKit.fetchTodaySteps()
                await vm.healthKit.fetchWeeklyAvgSteps()
                await vm.healthKit.fetchTodayActiveCalories()
                await vm.healthKit.fetchAllActivities()
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
                    label: "Day Streak",
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

    // MARK: - Interactive 7-Day Strip

    private var interactiveWeekStrip: some View {
        Button {
            showTrainingCalendar = true
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("This Week")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("Full Calendar")
                            .font(.caption.weight(.semibold))
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                }

                HStack(spacing: 6) {
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
                                    .frame(width: 32, height: 32)

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
                    .background(MVMTheme.accent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
        .padding(18)
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
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func aftMiniPill(_ value: Int) -> some View {
        Text("\(value)")
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(aftPillColor(value))
            .frame(width: 26, height: 20)
            .background(aftPillColor(value).opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 5))
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
            }

            let weekData = last4WeeksData
            let totalCompleted = weekData.reduce(0) { $0 + $1.count }

            if weekData.allSatisfy({ $0.count == 0 }) {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 32))
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
                .padding(.vertical, 12)
            } else {
                Chart {
                    ForEach(weekData, id: \.label) { week in
                        BarMark(
                            x: .value("Week", week.label),
                            y: .value("Workouts", week.count)
                        )
                        .foregroundStyle(MVMTheme.heroGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
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
                .frame(height: 140)

                if totalCompleted > 0 {
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
                        .frame(height: 36)
                        .background(MVMTheme.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
            }
        }
        .padding(18)
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

                Spacer()

                if !vm.healthKit.permissionDenied {
                    Button {
                        showAllActivities = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("See All")
                                .font(.caption.weight(.semibold))
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.bold))
                        }
                        .foregroundStyle(MVMTheme.accent)
                    }
                }
            }

            if vm.healthKit.permissionDenied && vm.pedometer.permissionDenied {
                VStack(spacing: 12) {
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 32))
                        .foregroundStyle(MVMTheme.tertiaryText)

                    Text("Health Access Needed")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    Text("Enable Health and Motion access in Settings to track your daily steps and fitness activities.")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } else {
                let todaySteps = max(vm.pedometer.todaySteps, vm.healthKit.todaySteps)
                let avgSteps = max(vm.weeklyStepAverage, vm.healthKit.weeklyAvgSteps)

                HStack(spacing: 0) {
                    VStack(spacing: 6) {
                        Image(systemName: "shoeprints.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(MVMTheme.success)
                            .frame(width: 28, height: 28)
                            .background(MVMTheme.success.opacity(0.12))
                            .clipShape(Circle())

                        Text("\(todaySteps)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(MVMTheme.primaryText)
                            .contentTransition(.numericText())

                        Text("Steps Today")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(MVMTheme.border)
                        .frame(width: 1, height: 48)

                    VStack(spacing: 6) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(MVMTheme.accent)
                            .frame(width: 28, height: 28)
                            .background(MVMTheme.accent.opacity(0.12))
                            .clipShape(Circle())

                        Text("\(avgSteps)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(MVMTheme.primaryText)
                            .contentTransition(.numericText())

                        Text("7-Day Avg")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(MVMTheme.border)
                        .frame(width: 1, height: 48)

                    VStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(MVMTheme.warning)
                            .frame(width: 28, height: 28)
                            .background(MVMTheme.warning.opacity(0.12))
                            .clipShape(Circle())

                        Text("\(Int(vm.healthKit.todayActiveCalories))")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(MVMTheme.primaryText)
                            .contentTransition(.numericText())

                        Text("Calories")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }

                if !vm.healthKit.activities.isEmpty {
                    activityPills
                }

                Button {
                    showAllActivities = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.caption.weight(.bold))
                        Text("View All Activities")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(MVMTheme.accent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(18)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private var activityPills: some View {
        let topActivities = Array(vm.healthKit.activities.prefix(3))
        return HStack(spacing: 8) {
            ForEach(topActivities) { activity in
                HStack(spacing: 5) {
                    Image(systemName: activity.icon)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(MVMTheme.accent)
                    Text(activity.name)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                    if activity.todayCount > 0 {
                        Text("\(activity.todayCount)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(MVMTheme.success)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(MVMTheme.cardSoft)
                .clipShape(Capsule())
            }
            Spacer()
        }
    }

    // MARK: - Disclaimer Banner

    private var progressDisclaimerBanner: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.shield.fill")
                .font(.title2)
                .foregroundStyle(MVMTheme.accent)

            Text("Limited Access Mode")
                .font(.headline.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text("Workout tracking, training charts, and activity data require accepting the terms of use. The AFT Calculator and score history remain available.")
                .font(.caption)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            Button {
                disclaimerAccepted = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.subheadline.weight(.bold))
                    Text("Accept Terms & Unlock")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(MVMTheme.heroGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(20)
        .background(MVMTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(MVMTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
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
