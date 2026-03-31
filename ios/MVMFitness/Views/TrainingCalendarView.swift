import SwiftUI

struct TrainingCalendarView: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    @State private var displayedMonth: Date = Calendar.current.startOfDay(for: .now)
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: .now)
    @State private var calendarService = CalendarExportService()
    @State private var showExportAlert: Bool = false
    @State private var exportAlertMessage: String = ""
    @State private var syncTrigger: Bool = false
    @State private var navigateToCalendarDay: Bool = false

    private let calendar = Calendar.current
    private let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    calendarSyncCard
                    monthGrid
                    selectedDateWorkouts
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .navigationTitle("Training Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $navigateToCalendarDay) {
            CalendarDayDetailView(date: selectedDate)
        }
        .sensoryFeedback(.selection, trigger: syncTrigger)
        .alert("Calendar", isPresented: $showExportAlert) {
            Button("OK") {}
        } message: {
            Text(exportAlertMessage)
        }
    }

    // MARK: - Sync Card

    private var calendarSyncCard: some View {
        HStack(spacing: 14) {
            Image(systemName: vm.isCalendarSyncEnabled ? "calendar.badge.checkmark" : "calendar")
                .font(.title3.weight(.semibold))
                .foregroundStyle(vm.isCalendarSyncEnabled ? MVMTheme.success : MVMTheme.accent)
                .frame(width: 44, height: 44)
                .background((vm.isCalendarSyncEnabled ? MVMTheme.success : MVMTheme.accent).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text("Sync to Phone Calendar")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text(vm.isCalendarSyncEnabled ? "Workouts auto-sync to iOS Calendar" : "Off — workouts stay in-app only")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            Spacer(minLength: 0)

            Toggle("", isOn: Binding(
                get: { vm.isCalendarSyncEnabled },
                set: { newValue in
                    vm.isCalendarSyncEnabled = newValue
                    syncTrigger.toggle()
                    if newValue {
                        syncAllWorkouts()
                    }
                }
            ))
            .labelsHidden()
            .tint(MVMTheme.accent)
        }
        .padding(16)
        .premiumCard()
    }

    // MARK: - Month Grid

    private var monthGrid: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                        .frame(width: 36, height: 36)
                        .background(MVMTheme.cardSoft)
                        .clipShape(Circle())
                }

                Spacer()

                Text(monthYearLabel)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                        .frame(width: 36, height: 36)
                        .background(MVMTheme.cardSoft)
                        .clipShape(Circle())
                }
            }

            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .frame(maxWidth: .infinity)
                }
            }

            let dates = monthDates
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(dates, id: \.self) { date in
                    if let date {
                        dayCell(date)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    let today = calendar.startOfDay(for: .now)
                    displayedMonth = today
                    selectedDate = today
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.caption.weight(.bold))
                    Text("Today")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(MVMTheme.accent)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(MVMTheme.accent.opacity(0.12))
                .clipShape(Capsule())
            }
        }
        .padding(18)
        .premiumCard()
    }

    private func dayCell(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let status = vm.calendarDateStatus(date)
        let isCurrentMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: isSelected || isToday ? .bold : .medium, design: .rounded))
                    .foregroundStyle(
                        isSelected ? .white :
                        !isCurrentMonth ? MVMTheme.tertiaryText.opacity(0.4) :
                        isToday ? MVMTheme.accent :
                        MVMTheme.primaryText
                    )

                statusIndicator(status, isSelected: isSelected)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(MVMTheme.heroGradient)
                        .shadow(color: MVMTheme.accent.opacity(0.3), radius: 6, y: 3)
                } else if isToday {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(MVMTheme.accent.opacity(0.4), lineWidth: 1)
                }
            }
        }
    }

    @ViewBuilder
    private func statusIndicator(_ status: AppViewModel.CalendarWorkoutStatus?, isSelected: Bool) -> some View {
        switch status {
        case .completed:
            Image(systemName: "checkmark")
                .font(.system(size: 7, weight: .black))
                .foregroundStyle(isSelected ? .white : MVMTheme.success)
        case .planned:
            Circle()
                .fill(isSelected ? .white.opacity(0.7) : MVMTheme.accent)
                .frame(width: 5, height: 5)
        case .missed:
            Circle()
                .fill(isSelected ? .white.opacity(0.4) : MVMTheme.tertiaryText.opacity(0.4))
                .frame(width: 5, height: 5)
        case nil:
            Color.clear.frame(width: 5, height: 5)
        }
    }

    // MARK: - Selected Date Workouts

    private var selectedDateWorkouts: some View {
        let entries = vm.allCalendarEntriesForDate(selectedDate)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(selectedDateLabel)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)

                    Text(selectedDateRelative)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer()

                Button {
                    navigateToCalendarDay = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Details")
                            .font(.caption.weight(.semibold))
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(Capsule())
                }
            }

            if entries.isEmpty {
                emptyDateState
            } else {
                ForEach(entries) { entry in
                    workoutEntryCard(entry)
                }
            }
        }
        .padding(18)
        .premiumCard()
    }

    private func workoutEntryCard(_ entry: AppViewModel.CalendarWorkoutEntry) -> some View {
        HStack(spacing: 14) {
            statusIcon(entry.status)
                .frame(width: 40, height: 40)
                .background(statusColor(entry.status).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(entry.status == .missed ? MVMTheme.tertiaryText : MVMTheme.primaryText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(entry.type)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(sourceColor(entry.source))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(sourceColor(entry.source).opacity(0.12))
                        .clipShape(Capsule())

                    if entry.duration > 0 {
                        Text("~\(entry.duration) min")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }

                    Text("\(entry.exerciseCount) exercises")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            }

            Spacer(minLength: 0)

            statusBadge(entry.status)
        }
        .padding(14)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private func statusIcon(_ status: AppViewModel.CalendarWorkoutStatus) -> some View {
        switch status {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .font(.body.weight(.semibold))
                .foregroundStyle(MVMTheme.success)
        case .planned:
            Image(systemName: "clock.fill")
                .font(.body.weight(.semibold))
                .foregroundStyle(MVMTheme.accent)
        case .missed:
            Image(systemName: "xmark.circle")
                .font(.body.weight(.semibold))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
    }

    @ViewBuilder
    private func statusBadge(_ status: AppViewModel.CalendarWorkoutStatus) -> some View {
        switch status {
        case .completed:
            Text("Done")
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.success)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(MVMTheme.success.opacity(0.12))
                .clipShape(Capsule())
        case .planned:
            Text("Planned")
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(MVMTheme.accent.opacity(0.12))
                .clipShape(Capsule())
        case .missed:
            Text("Missed")
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(MVMTheme.cardSoft)
                .clipShape(Capsule())
        }
    }

    private var emptyDateState: some View {
        VStack(spacing: 14) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 32))
                .foregroundStyle(MVMTheme.accent.opacity(0.3))

            Text("No workouts scheduled")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)

            Text("Build a PT or WOD plan to fill your calendar.")
                .font(.caption)
                .foregroundStyle(MVMTheme.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - Helpers

    private func statusColor(_ status: AppViewModel.CalendarWorkoutStatus) -> Color {
        switch status {
        case .completed: return MVMTheme.success
        case .planned: return MVMTheme.accent
        case .missed: return MVMTheme.tertiaryText
        }
    }

    private func sourceColor(_ source: WorkoutSource) -> Color {
        switch source {
        case .individual: return MVMTheme.accent
        case .unit: return Color(hex: "#2563EB")
        case .wod: return Color(hex: "#F59E0B")
        case .random: return Color(hex: "#6366F1")
        case .imported: return Color(hex: "#059669")
        }
    }

    private var monthYearLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: displayedMonth)
    }

    private var selectedDateLabel: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: selectedDate)
    }

    private var selectedDateRelative: String {
        if calendar.isDateInToday(selectedDate) { return "Today" }
        if calendar.isDateInYesterday(selectedDate) { return "Yesterday" }
        if calendar.isDateInTomorrow(selectedDate) { return "Tomorrow" }
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: .now), to: calendar.startOfDay(for: selectedDate)).day ?? 0
        if days > 0 { return "In \(days) day\(days == 1 ? "" : "s")" }
        return "\(abs(days)) day\(abs(days) == 1 ? "" : "s") ago"
    }

    private var monthDates: [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmpty = firstWeekday - 1

        var dates: [Date?] = Array(repeating: nil, count: leadingEmpty)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                dates.append(date)
            }
        }

        let trailing = (7 - (dates.count % 7)) % 7
        dates += Array(repeating: nil as Date?, count: trailing)

        return dates
    }

    private func syncAllWorkouts() {
        Task {
            if let plan = vm.currentPlan {
                let result = await calendarService.exportWeeklyPlan(plan)
                handleExportResult(result)
            }
        }
    }

    private func handleExportResult(_ result: CalendarExportService.ExportResult) {
        switch result {
        case .success(let count):
            exportAlertMessage = "\(count) workout\(count == 1 ? "" : "s") synced to calendar."
        case .partial(let exported, let failed):
            exportAlertMessage = "\(exported) exported, \(failed) failed."
        case .denied:
            exportAlertMessage = "Calendar access denied. Go to Settings to enable."
        case .error(let message):
            exportAlertMessage = "Sync failed: \(message)"
        }
        showExportAlert = true
    }
}
