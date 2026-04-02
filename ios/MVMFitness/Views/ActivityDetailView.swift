import SwiftUI
import Charts
import HealthKit

struct ActivityDetailView: View {
    @Environment(AppViewModel.self) private var vm

    let activity: ActivitySummary

    @State private var weekDetails: [HealthKitManager.DayActivityDetail] = []
    @State private var selectedDate: Date?
    @State private var selectedDayDetail: HealthKitManager.DayActivityDetail?
    @State private var isLoading: Bool = true
    @State private var appeared: Bool = false

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    heroHeader
                    weeklyTrendChart
                    weekStrip
                    if let detail = selectedDayDetail {
                        dayDetailCard(detail)
                    } else if isLoading {
                        loadingCard
                    } else {
                        emptyDayCard
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .navigationTitle(activity.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await loadWeekData()
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(spacing: 20) {
            HStack(spacing: 14) {
                Image(systemName: activity.icon)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(
                            colors: [MVMTheme.accent, MVMTheme.accent2],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: MVMTheme.accent.opacity(0.3), radius: 10, y: 4)

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    if activity.todayCount > 0 {
                        Text("\(activity.todayCount) session\(activity.todayCount == 1 ? "" : "s") today")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(MVMTheme.success)
                    } else {
                        Text("No sessions today")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }

                Spacer()
            }

            HStack(spacing: 8) {
                heroMetricPill(
                    icon: "clock.fill",
                    value: formatDuration(activity.todayDuration),
                    label: "Today",
                    color: MVMTheme.accent
                )

                heroMetricPill(
                    icon: "chart.line.uptrend.xyaxis",
                    value: formatDuration(activity.weeklyAvgDuration),
                    label: "7-Day Avg",
                    color: MVMTheme.slateAccent
                )

                if activity.todayDistance > 0 || activity.weeklyAvgDistance > 0 {
                    heroMetricPill(
                        icon: "map.fill",
                        value: String(format: "%.1f mi", activity.todayDistance),
                        label: "Distance",
                        color: MVMTheme.success
                    )
                }
            }

            if activity.todayCalories > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color(hex: "#FF6B35"))
                    Text("\(Int(activity.todayCalories)) kcal today")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                    Spacer()
                    if activity.weeklyAvgCalories > 0 {
                        Text("Avg \(Int(activity.weeklyAvgCalories)) kcal")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(MVMTheme.cardSoft)
                .clipShape(.rect(cornerRadius: 12))
            }
        }
        .padding(20)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(activity.name), \(activity.todayCount) sessions today, \(formatDuration(activity.todayDuration)) total duration")
    }

    private func heroMetricPill(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(MVMTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(MVMTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Weekly Trend Chart

    private var weeklyTrendChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(MVMTheme.accent)
                    .font(.caption.weight(.bold))
                Text("7-Day Trend")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                Spacer()
                Text("Duration (min)")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            if weekDetails.isEmpty {
                ProgressView()
                    .tint(MVMTheme.accent)
                    .frame(maxWidth: .infinity, minHeight: 140)
            } else {
                let hasAnyData = weekDetails.contains { !$0.sessions.isEmpty }

                if hasAnyData {
                    Chart {
                        ForEach(weekDetails, id: \.date) { day in
                            let isSelected = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: day.date) } ?? false
                            let minutes = Int(day.totalDuration) / 60

                            BarMark(
                                x: .value("Day", dayChartLabel(day.date)),
                                y: .value("Duration", minutes)
                            )
                            .foregroundStyle(
                                isSelected
                                    ? AnyShapeStyle(LinearGradient(colors: [MVMTheme.accent, MVMTheme.accent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                                    : AnyShapeStyle(MVMTheme.accent.opacity(0.35))
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 5))

                            if isSelected && minutes > 0 {
                                PointMark(
                                    x: .value("Day", dayChartLabel(day.date)),
                                    y: .value("Duration", minutes)
                                )
                                .annotation(position: .top, spacing: 4) {
                                    Text("\(minutes)m")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(MVMTheme.accent)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(MVMTheme.cardSoft)
                                        .clipShape(.rect(cornerRadius: 6))
                                }
                                .symbolSize(0)
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic(desiredCount: 3)) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(MVMTheme.border)
                            AxisValueLabel()
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }
                    }
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                                .foregroundStyle(MVMTheme.secondaryText)
                        }
                    }
                    .frame(height: 160)
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "chart.bar")
                            .font(.title2)
                            .foregroundStyle(MVMTheme.tertiaryText)
                        Text("No data this week")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                }
            }
        }
        .padding(20)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    // MARK: - Week Strip

    private var weekStrip: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("LAST 7 DAYS")
                .font(.caption.weight(.heavy))
                .tracking(1.0)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            HStack(spacing: 5) {
                ForEach(weekDetails, id: \.date) { detail in
                    let isSelected = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: detail.date) } ?? false
                    let hasData = !detail.sessions.isEmpty
                    let isToday = Calendar.current.isDateInToday(detail.date)

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedDate = detail.date
                            selectedDayDetail = detail
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(dayAbbrev(detail.date))
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(isSelected ? MVMTheme.accent : (isToday ? MVMTheme.accent.opacity(0.7) : MVMTheme.tertiaryText))

                            ZStack {
                                Circle()
                                    .fill(dayDotColor(isSelected: isSelected, hasData: hasData))
                                    .frame(width: 38, height: 38)

                                if hasData {
                                    Text("\(detail.sessions.count)")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(isSelected ? .white : MVMTheme.primaryText)
                                } else if isToday {
                                    Circle()
                                        .fill(MVMTheme.accent.opacity(0.5))
                                        .frame(width: 6, height: 6)
                                }
                            }

                            Text(dayNumber(detail.date))
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(isSelected ? MVMTheme.accent : MVMTheme.tertiaryText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(fullDayLabel(detail.date)), \(detail.sessions.count) sessions")
                }
            }
            .padding(14)
            .premiumCard()
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    // MARK: - Day Detail Card

    private func dayDetailCard(_ detail: HealthKitManager.DayActivityDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(fullDateString(detail.date))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    if Calendar.current.isDateInToday(detail.date) {
                        Text("Today")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(MVMTheme.accent)
                    }
                }
                Spacer()
                if !detail.sessions.isEmpty {
                    Text("\(detail.sessions.count) session\(detail.sessions.count == 1 ? "" : "s")")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(MVMTheme.accent.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            if detail.sessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.title2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                    Text("No \(activity.name.lowercased()) sessions this day")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                dayStatsRow(detail)

                VStack(spacing: 8) {
                    ForEach(detail.sessions) { session in
                        sessionRow(session)
                    }
                }
            }
        }
        .padding(20)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func dayStatsRow(_ detail: HealthKitManager.DayActivityDetail) -> some View {
        HStack(spacing: 0) {
            dayStat(
                icon: "clock.fill",
                value: formatDuration(detail.totalDuration),
                label: "Duration",
                color: MVMTheme.accent
            )

            if detail.totalDistance > 0 {
                Rectangle().fill(MVMTheme.border).frame(width: 1, height: 44)
                dayStat(
                    icon: "map.fill",
                    value: String(format: "%.2f mi", detail.totalDistance),
                    label: "Distance",
                    color: MVMTheme.success
                )
            }

            if detail.totalCalories > 0 {
                Rectangle().fill(MVMTheme.border).frame(width: 1, height: 44)
                dayStat(
                    icon: "flame.fill",
                    value: "\(Int(detail.totalCalories))",
                    label: "Calories",
                    color: Color(hex: "#FF6B35")
                )
            }

            if detail.totalSteps > 0 {
                Rectangle().fill(MVMTheme.border).frame(width: 1, height: 44)
                dayStat(
                    icon: "shoeprints.fill",
                    value: detail.totalSteps.formatted(),
                    label: "Steps",
                    color: MVMTheme.accent2
                )
            }
        }
        .padding(14)
        .background(MVMTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 16))
    }

    private func dayStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(color)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private func sessionRow(_ session: HealthKitManager.DaySessionInfo) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [MVMTheme.accent, MVMTheme.accent.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(timeString(session.startDate))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)

                HStack(spacing: 8) {
                    Text(formatDuration(session.duration))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.secondaryText)

                    if session.distance > 0 {
                        Text(String(format: "%.2f mi", session.distance))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }

                    if session.calories > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(Color(hex: "#FF6B35"))
                            Text("\(Int(session.calories)) kcal")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(MVMTheme.secondaryText)
                        }
                    }
                }
            }

            Spacer()

            Text(session.sourceName)
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
                .lineLimit(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(MVMTheme.cardSoft)
                .clipShape(Capsule())
        }
        .padding(14)
        .background(MVMTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Session at \(timeString(session.startDate)), \(formatDuration(session.duration)), from \(session.sourceName)")
    }

    // MARK: - Loading / Empty

    private var loadingCard: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(MVMTheme.accent)
            Text("Loading activity details...")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MVMTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .premiumCard()
    }

    private var emptyDayCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.title2)
                .foregroundStyle(MVMTheme.tertiaryText)
            Text("Select a day to view details")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MVMTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .premiumCard()
    }

    // MARK: - Helpers

    private func loadWeekData() async {
        isLoading = true
        weekDetails = await vm.healthKit.fetchWeekDayDetails(for: activity.activityType)
        if let today = weekDetails.last {
            selectedDate = today.date
            selectedDayDetail = today
        }
        isLoading = false
    }

    private func dayDotColor(isSelected: Bool, hasData: Bool) -> Color {
        if isSelected { return MVMTheme.accent }
        if hasData { return MVMTheme.accent.opacity(0.2) }
        return MVMTheme.cardSoft
    }

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

    private func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func dayChartLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(3))
    }

    private func fullDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    private func fullDayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
