import SwiftUI

struct CalendarDayDetailView: View {
    @Environment(AppViewModel.self) private var vm

    let date: Date

    @State private var showEditSheet: Bool = false
    @State private var editDayIndex: Int = 0
    @State private var showCalendarSync: Bool = false
    @State private var calendarService = CalendarExportService()
    @State private var showExportAlert: Bool = false
    @State private var exportAlertMessage: String = ""
    @State private var actionTrigger: Bool = false

    private let calendar = Calendar.current

    private var allWorkouts: [WorkoutDay] {
        vm.allWorkoutsForDate(date)
    }

    private var completedRecords: [CompletedWorkoutRecord] {
        vm.completedRecordsForDate(date)
    }

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    dayHeader
                    syncBar

                    if allWorkouts.isEmpty && completedRecords.isEmpty {
                        emptyState
                    } else {
                        if !allWorkouts.isEmpty {
                            scheduledSection
                        }
                        if !completedRecords.isEmpty {
                            completedSection
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .navigationTitle(formattedDate)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showCalendarSync = true
                    } label: {
                        Label("Sync to Calendar", systemImage: "calendar.badge.plus")
                    }

                    if let plan = vm.currentPlan,
                       plan.days.contains(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                        Button {
                            if let day = vm.currentPlan?.days.first(where: { calendar.isDate($0.date, inSameDayAs: date) && !$0.isRestDay }) {
                                editDayIndex = day.dayIndex
                                showEditSheet = true
                            }
                        } label: {
                            Label("Edit Workout", systemImage: "pencil")
                        }

                        Button {
                            if let day = vm.currentPlan?.days.first(where: { calendar.isDate($0.date, inSameDayAs: date) && !$0.isRestDay }) {
                                vm.regenerateSingleDay(dayIndex: day.dayIndex)
                                actionTrigger.toggle()
                            }
                        } label: {
                            Label("Regenerate", systemImage: "arrow.clockwise")
                        }

                        Button {
                            if let day = vm.currentPlan?.days.first(where: { calendar.isDate($0.date, inSameDayAs: date) && !$0.isRestDay }) {
                                vm.convertDayToRecovery(dayIndex: day.dayIndex)
                                actionTrigger.toggle()
                            }
                        } label: {
                            Label("Convert to Rest Day", systemImage: "bed.double.fill")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: actionTrigger)
        .sheet(isPresented: $showEditSheet) {
            if let plan = vm.currentPlan,
               let day = plan.days.first(where: { $0.dayIndex == editDayIndex }) {
                EditWorkoutSheet(day: day)
            }
        }
        .sheet(isPresented: $showCalendarSync) {
            calendarSyncSheet
        }
        .alert("Calendar", isPresented: $showExportAlert) {
            Button("OK") {}
        } message: {
            Text(exportAlertMessage)
        }
    }

    private var dayHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dayOfWeekString)
                        .font(.caption.weight(.heavy))
                        .tracking(1.0)
                        .foregroundStyle(MVMTheme.tertiaryText)

                    Text(formattedDateLong)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                }

                Spacer()

                if calendar.isDateInToday(date) {
                    Text("TODAY")
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(0.5)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(MVMTheme.accent)
                        .clipShape(Capsule())
                }
            }

            let workoutCount = allWorkouts.filter { !$0.isRestDay }.count
            let completedCount = allWorkouts.filter(\.isCompleted).count
            HStack(spacing: 16) {
                Label("\(workoutCount) workout\(workoutCount == 1 ? "" : "s")", systemImage: "figure.mixed.cardio")
                Label("\(completedCount) done", systemImage: "checkmark.circle")
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(MVMTheme.tertiaryText)
        }
        .padding(18)
        .premiumCard()
    }

    private var syncBar: some View {
        HStack(spacing: 12) {
            Button {
                showCalendarSync = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.caption.weight(.bold))
                    Text("Sync Day")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(MVMTheme.accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(MVMTheme.accent.opacity(0.12))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()

            if let day = allWorkouts.first(where: { !$0.isRestDay && !$0.isCompleted }) {
                Button {
                    editDayIndex = day.dayIndex
                    showEditSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                            .font(.caption.weight(.bold))
                        Text("Edit")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.secondaryText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(MVMTheme.cardSoft)
                    .clipShape(Capsule())
                    .overlay { Capsule().stroke(MVMTheme.border) }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var scheduledSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SCHEDULED")
                .font(.caption.weight(.heavy))
                .tracking(1.0)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            ForEach(allWorkouts, id: \.id) { workout in
                workoutRow(workout)
            }
        }
    }

    private func workoutRow(_ workout: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: workout.isRestDay ? "bed.double.fill" : workoutIcon(for: workout))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(workout.isCompleted ? MVMTheme.success : MVMTheme.accent)
                    .frame(width: 40, height: 40)
                    .background((workout.isCompleted ? MVMTheme.success : MVMTheme.accent).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text(workout.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)

                    HStack(spacing: 8) {
                        Text(workout.source.rawValue)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(MVMTheme.accent)

                        if !workout.isRestDay {
                            Text("\(workout.exercises.count) exercises")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }
                    }
                }

                Spacer()

                if workout.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(MVMTheme.success)
                }
            }

            if !workout.isRestDay && !workout.exercises.isEmpty {
                VStack(spacing: 0) {
                    ForEach(workout.exercises.prefix(5)) { exercise in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(exercise.isCompleted ? MVMTheme.success.opacity(0.6) : MVMTheme.accent.opacity(0.3))
                                .frame(width: 6, height: 6)

                            Text(exercise.name)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(exercise.isCompleted ? MVMTheme.secondaryText : MVMTheme.primaryText)
                                .strikethrough(exercise.isCompleted)

                            Spacer()

                            Text(exercise.displayDetail)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }
                        .padding(.vertical, 6)

                        if exercise.id != workout.exercises.prefix(5).last?.id {
                            Rectangle()
                                .fill(MVMTheme.border)
                                .frame(height: 0.5)
                                .padding(.leading, 16)
                        }
                    }

                    if workout.exercises.count > 5 {
                        Text("+\(workout.exercises.count - 5) more")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                            .padding(.top, 6)
                    }
                }
                .padding(12)
                .background(MVMTheme.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .premiumCard()
    }

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("COMPLETED")
                .font(.caption.weight(.heavy))
                .tracking(1.0)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            ForEach(completedRecords, id: \.id) { record in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(MVMTheme.success)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(record.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.primaryText)
                        Text("\(record.exerciseCount) exercises · \(record.source.rawValue)")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }

                    Spacer()
                }
                .padding(14)
                .premiumCard()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundStyle(MVMTheme.accent.opacity(0.4))

            Text("No workouts scheduled")
                .font(.headline.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text("Create a PT plan or schedule a workout for this day.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    private var calendarSyncSheet: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40))
                    .foregroundStyle(MVMTheme.accent)
                    .padding(.top, 8)

                Text("Sync to Calendar")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Export this day's workouts to your iOS Calendar.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                ForEach(allWorkouts.filter { !$0.isRestDay }, id: \.id) { workout in
                    Button {
                        Task {
                            let result = await calendarService.exportWorkout(workout)
                            handleExportResult(result)
                            showCalendarSync = false
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if calendarService.isExporting {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.subheadline.weight(.bold))
                            }
                            Text("Export: \(workout.title)")
                                .font(.subheadline.weight(.bold))
                                .lineLimit(1)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(MVMTheme.heroGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(calendarService.isExporting)
                    .buttonStyle(PressScaleButtonStyle())
                }

                Button {
                    showCalendarSync = false
                } label: {
                    Text("Cancel")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(MVMTheme.background)
    }

    private func workoutIcon(for workout: WorkoutDay) -> String {
        let title = workout.title.lowercased()
        if title.contains("run") || title.contains("cardio") || title.contains("endurance") { return "figure.run" }
        if title.contains("strength") || title.contains("push") || title.contains("pull") { return "figure.strengthtraining.traditional" }
        if title.contains("recovery") || title.contains("stretch") || title.contains("mobility") { return "figure.cooldown" }
        if title.contains("unit") || title.contains("formation") { return "person.3.fill" }
        return "figure.mixed.cardio"
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }

    private var formattedDateLong: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy"
        return f.string(from: date)
    }

    private var dayOfWeekString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: date).uppercased()
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
