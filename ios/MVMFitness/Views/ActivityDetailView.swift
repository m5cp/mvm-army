import SwiftUI
import HealthKit

struct ActivityDetailView: View {
    @Environment(AppViewModel.self) private var vm

    let activity: ActivitySummary

    @State private var weekDetails: [HealthKitManager.DayActivityDetail] = []
    @State private var selectedDate: Date?
    @State private var selectedDayDetail: HealthKitManager.DayActivityDetail?
    @State private var isLoading: Bool = true

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    summaryHeader
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
                .padding(.bottom, 40)
                .adaptiveContainer()
            }
        }
        .navigationTitle(activity.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await loadWeekData()
        }
    }

    // MARK: - Summary Header

    private var summaryHeader: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: activity.icon)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 48, height: 48)
                    .background(MVMTheme.accent.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(activity.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    if activity.todayCount > 0 {
                        Text("\(activity.todayCount) session\(activity.todayCount == 1 ? "" : "s") today")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.success)
                    } else {
                        Text("No sessions today")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }

                Spacer()
            }

            HStack(spacing: 0) {
                statBlock(
                    value: formatDuration(activity.todayDuration),
                    label: "Today",
                    color: MVMTheme.accent
                )

                Rectangle()
                    .fill(MVMTheme.border)
                    .frame(width: 1, height: 40)

                statBlock(
                    value: formatDuration(activity.weeklyAvgDuration),
                    label: "7-Day Avg",
                    color: MVMTheme.slateAccent
                )

                if activity.todayDistance > 0 || activity.weeklyAvgDistance > 0 {
                    Rectangle()
                        .fill(MVMTheme.border)
                        .frame(width: 1, height: 40)

                    statBlock(
                        value: String(format: "%.1f mi", activity.todayDistance),
                        label: "Distance",
                        color: MVMTheme.success
                    )
                }
            }

            if activity.todayCalories > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundStyle(MVMTheme.warning)
                    Text("\(Int(activity.todayCalories)) kcal today")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                    Spacer()
                    Text("Avg \(Int(activity.weeklyAvgCalories)) kcal")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(MVMTheme.cardSoft)
                .clipShape(.rect(cornerRadius: 10))
            }
        }
        .padding(18)
        .premiumCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(activity.name), \(activity.todayCount) sessions today, \(formatDuration(activity.todayDuration)) total duration")
    }

    // MARK: - Week Strip

    private var weekStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LAST 7 DAYS")
                .font(.caption.weight(.heavy))
                .tracking(1.0)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            HStack(spacing: 6) {
                ForEach(weekDetails, id: \.date) { detail in
                    let isSelected = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: detail.date) } ?? false
                    let hasData = !detail.sessions.isEmpty

                    Button {
                        selectedDate = detail.date
                        selectedDayDetail = detail
                    } label: {
                        VStack(spacing: 6) {
                            Text(dayAbbrev(detail.date))
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(isSelected ? MVMTheme.accent : MVMTheme.tertiaryText)

                            ZStack {
                                Circle()
                                    .fill(dayDotColor(isSelected: isSelected, hasData: hasData))
                                    .frame(width: 34, height: 34)

                                if hasData {
                                    Text("\(detail.sessions.count)")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(isSelected ? .white : MVMTheme.primaryText)
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
    }

    // MARK: - Day Detail Card

    private func dayDetailCard(_ detail: HealthKitManager.DayActivityDetail) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text(fullDateString(detail.date))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                Spacer()
                if !detail.sessions.isEmpty {
                    Text("\(detail.sessions.count) session\(detail.sessions.count == 1 ? "" : "s")")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(MVMTheme.accent.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            if detail.sessions.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.title2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                    Text("No \(activity.name.lowercased()) sessions this day")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                HStack(spacing: 0) {
                    dayStat(value: formatDuration(detail.totalDuration), label: "Duration", color: MVMTheme.accent)

                    if detail.totalDistance > 0 {
                        Rectangle().fill(MVMTheme.border).frame(width: 1, height: 36)
                        dayStat(value: String(format: "%.2f mi", detail.totalDistance), label: "Distance", color: MVMTheme.success)
                    }

                    if detail.totalCalories > 0 {
                        Rectangle().fill(MVMTheme.border).frame(width: 1, height: 36)
                        dayStat(value: "\(Int(detail.totalCalories))", label: "Calories", color: MVMTheme.warning)
                    }

                    if detail.totalSteps > 0 {
                        Rectangle().fill(MVMTheme.border).frame(width: 1, height: 36)
                        dayStat(value: "\(detail.totalSteps)", label: "Steps", color: MVMTheme.accent2)
                    }
                }
                .padding(12)
                .background(MVMTheme.cardSoft)
                .clipShape(.rect(cornerRadius: 12))

                ForEach(detail.sessions) { session in
                    sessionRow(session)
                }
            }
        }
        .padding(18)
        .premiumCard()
    }

    private func sessionRow(_ session: HealthKitManager.DaySessionInfo) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(MVMTheme.accent)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 3) {
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
                                .foregroundStyle(MVMTheme.warning)
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
        }
        .padding(12)
        .background(MVMTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 10))
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

    private func statBlock(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(MVMTheme.primaryText)
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    private func dayStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    private func dayDotColor(isSelected: Bool, hasData: Bool) -> Color {
        if isSelected { return MVMTheme.accent }
        if hasData { return MVMTheme.accent.opacity(0.2) }
        return MVMTheme.cardSoft
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
