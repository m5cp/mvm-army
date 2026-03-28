import SwiftUI

struct PlanView: View {
    @Environment(AppViewModel.self) private var vm

    @State private var selectedDate: Date = Calendar.current.startOfDay(for: .now)
    @State private var showEditSheet: Bool = false
    @State private var selectedDayIndex: Int?
    @State private var navigateToDetail: Bool = false
    @State private var detailDayIndex: Int = 0
    @State private var animateCards: Bool = false
    @State private var calendarService = CalendarExportService()
    @State private var showCalendarSheet: Bool = false
    @State private var showExportAlert: Bool = false
    @State private var exportAlertMessage: String = ""

    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                weekCalendarStrip
                    .padding(.bottom, 6)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        weekProgressBar
                            .padding(.horizontal, 20)

                        if let plan = vm.currentPlan {
                            dayTimeline(plan)
                                .padding(.horizontal, 20)
                        } else {
                            emptyState
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("MVM ARMY")
                    .font(.caption.weight(.heavy))
                    .tracking(2.4)
                    .foregroundStyle(MVMTheme.secondaryText)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if vm.currentPlan != nil {
                        Button {
                            vm.generateWeeklyPlan()
                        } label: {
                            Label("Regenerate Week", systemImage: "arrow.clockwise")
                        }

                        Button {
                            showCalendarSheet = true
                        } label: {
                            Label("Export to Calendar", systemImage: "calendar.badge.plus")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }
        }
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $navigateToDetail) {
            WorkoutDetailView(dayIndex: detailDayIndex, isStandalone: false)
        }
        .sheet(isPresented: $showEditSheet) {
            if let dayIndex = selectedDayIndex,
               let plan = vm.currentPlan,
               let day = plan.days.first(where: { $0.dayIndex == dayIndex }) {
                EditWorkoutSheet(day: day)
            }
        }
        .sheet(isPresented: $showCalendarSheet) {
            calendarExportSheet
        }
        .alert("Calendar Export", isPresented: $showExportAlert) {
            Button("OK") {}
        } message: {
            Text(exportAlertMessage)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.15)) {
                animateCards = true
            }
        }
    }

    // MARK: - Week Calendar Strip

    private var weekCalendarStrip: some View {
        let weekDates = currentWeekDates

        return VStack(spacing: 12) {
            HStack {
                Text(monthYearString)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Spacer()

                Text(weekRangeString)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .padding(.horizontal, 20)

            HStack(spacing: 0) {
                ForEach(weekDates, id: \.self) { date in
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let isToday = calendar.isDateInToday(date)
                    let dayData = workoutDay(for: date)
                    let hasWorkout = dayData != nil && !(dayData?.isRestDay ?? true)
                    let isCompleted = dayData?.isCompleted ?? false

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedDate = date
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(shortDayName(date))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(
                                    isSelected ? .white :
                                    isToday ? MVMTheme.accent :
                                    MVMTheme.tertiaryText
                                )

                            Text(dayNumber(date))
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    isSelected ? .white :
                                    isCompleted ? MVMTheme.success :
                                    isToday ? MVMTheme.accent :
                                    MVMTheme.primaryText
                                )

                            Circle()
                                .fill(
                                    isCompleted ? MVMTheme.success :
                                    hasWorkout ? MVMTheme.accent.opacity(0.6) :
                                    Color.clear
                                )
                                .frame(width: 5, height: 5)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: [MVMTheme.accent, MVMTheme.accent2],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: MVMTheme.accent.opacity(0.3), radius: 8, y: 4)
                            } else if isToday {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(MVMTheme.accent.opacity(0.3), lineWidth: 1)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 12)
        .background(MVMTheme.card)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(MVMTheme.border)
                .frame(height: 1)
        }
    }

    // MARK: - Week Progress Bar

    @ViewBuilder
    private var weekProgressBar: some View {
        if let plan = vm.currentPlan {
            let total = plan.totalWorkoutDays
            let completed = plan.completedCount
            let progress: Double = total > 0 ? Double(completed) / Double(total) : 0

            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(completed) of \(total) complete")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(MVMTheme.cardSoft)
                                .frame(height: 5)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [MVMTheme.accent, MVMTheme.accent2],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(geo.size.width * progress, progress > 0 ? 5 : 0), height: 5)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: completed)
                        }
                    }
                    .frame(height: 5)
                }

                Text("\(Int(progress * 100))%")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                    .contentTransition(.numericText())
                    .frame(width: 50, alignment: .trailing)
            }
            .padding(16)
            .background(MVMTheme.card)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(MVMTheme.border)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Day Timeline

    private func dayTimeline(_ plan: WeeklyPlan) -> some View {
        let selectedDay = plan.days.first { calendar.isDate($0.date, inSameDayAs: selectedDate) }

        return VStack(spacing: 12) {
            if let day = selectedDay {
                selectedDayCard(day)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("THIS WEEK")
                    .font(.caption.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .padding(.leading, 4)
                    .padding(.top, 8)

                ForEach(Array(plan.days.enumerated()), id: \.element.id) { offset, day in
                    if day.isRestDay {
                        recoveryRow(day, offset: offset)
                    } else {
                        workoutRow(day, offset: offset)
                    }
                }
            }
        }
    }

    // MARK: - Selected Day Card

    private func selectedDayCard(_ day: WorkoutDay) -> some View {
        Group {
            if day.isRestDay {
                selectedRecoveryCard(day)
            } else {
                selectedWorkoutCard(day)
            }
        }
    }

    private func selectedWorkoutCard(_ day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text(dayLabel(day).uppercased())
                    .font(.caption2.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(
                        calendar.isDateInToday(day.date) ? .white.opacity(0.9) : .white.opacity(0.7)
                    )

                Spacer()

                if day.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2.weight(.bold))
                        Text("DONE")
                            .font(.caption2.weight(.heavy))
                            .tracking(0.5)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
                } else if let tag = day.tags.first {
                    Text(tag)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(day.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 12) {
                    Label("\(day.exercises.count) exercises", systemImage: "list.bullet")
                    Label(estimatedDuration(day), systemImage: "clock")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.7))
            }

            HStack(spacing: 10) {
                if day.isCompleted {
                    Button {
                        detailDayIndex = day.dayIndex
                        navigateToDetail = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "eye")
                                .font(.subheadline.weight(.semibold))
                            Text("Review")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundStyle(Color(hex: "#1A1A2E"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                } else {
                    Button {
                        detailDayIndex = day.dayIndex
                        navigateToDetail = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption.weight(.bold))
                            Text("Log")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundStyle(Color(hex: "#1A1A2E"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PressScaleButtonStyle())

                    Button {
                        vm.markDayCompleted(dayIndex: day.dayIndex)
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .sensoryFeedback(.success, trigger: day.isCompleted)

                    Menu {
                        Button {
                            selectedDayIndex = day.dayIndex
                            showEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button {
                            Task {
                                let result = await calendarService.exportWorkout(day)
                                handleExportResult(result)
                            }
                        } label: {
                            Label("Add to Calendar", systemImage: "calendar.badge.plus")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(20)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        day.isCompleted ?
                        LinearGradient(
                            colors: [Color(hex: "#059669"), Color(hex: "#10B981").opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color(hex: "#3B6DE0"), Color(hex: "#5B4DC7").opacity(0.95), Color(hex: "#4A3DAF").opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 22)
                    .fill(MVMTheme.subtleGradient)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: (day.isCompleted ? Color(hex: "#059669") : MVMTheme.accent).opacity(0.2), radius: 20, y: 12)
    }

    private func selectedRecoveryCard(_ day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.8))

                Text(dayLabel(day).uppercased())
                    .font(.caption2.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()

                Text("Active Rest")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Recovery & Mobility")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)

                Text("Light movement keeps the plan moving forward.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#1E3A5F").opacity(0.9), Color(hex: "#2D4A6F").opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    // MARK: - Workout Row

    private func workoutRow(_ day: WorkoutDay, offset: Int) -> some View {
        let isSelected = calendar.isDate(day.date, inSameDayAs: selectedDate)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedDate = calendar.startOfDay(for: day.date)
            }
        } label: {
            HStack(spacing: 14) {
                VStack(spacing: 2) {
                    Text(shortDayName(day.date))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(MVMTheme.tertiaryText)

                    Text(dayNumber(day.date))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            day.isCompleted ? MVMTheme.success :
                            calendar.isDateInToday(day.date) ? MVMTheme.accent :
                            MVMTheme.secondaryText
                        )
                }
                .frame(width: 36)

                VStack(alignment: .leading, spacing: 3) {
                    Text(day.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(day.isCompleted ? MVMTheme.secondaryText : MVMTheme.primaryText)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        if let tag = day.tags.first {
                            Text(tag)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(MVMTheme.accent)
                        }
                        Text(estimatedDuration(day))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }

                Spacer(minLength: 0)

                if day.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(MVMTheme.success)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                isSelected ? MVMTheme.accent.opacity(0.08) :
                MVMTheme.card.opacity(day.isCompleted ? 0.5 : 1)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? MVMTheme.accent.opacity(0.2) :
                        day.isCompleted ? MVMTheme.success.opacity(0.1) :
                        MVMTheme.border
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(PressScaleButtonStyle())
        .contextMenu {
            if !day.isCompleted {
                Button {
                    vm.markDayCompleted(dayIndex: day.dayIndex)
                } label: {
                    Label("Mark Complete", systemImage: "checkmark.circle")
                }
            } else {
                Button {
                    vm.markDayIncomplete(dayIndex: day.dayIndex)
                } label: {
                    Label("Mark Incomplete", systemImage: "arrow.uturn.backward")
                }
            }

            Button {
                selectedDayIndex = day.dayIndex
                showEditSheet = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button {
                vm.regenerateSingleDay(dayIndex: day.dayIndex)
            } label: {
                Label("Regenerate", systemImage: "arrow.clockwise")
            }

            if !day.isCompleted {
                Button {
                    vm.convertDayToRecovery(dayIndex: day.dayIndex)
                } label: {
                    Label("Make Recovery Day", systemImage: "leaf")
                }
            }

            Button {
                Task {
                    let result = await calendarService.exportWorkout(day)
                    handleExportResult(result)
                }
            } label: {
                Label("Add to Calendar", systemImage: "calendar.badge.plus")
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 10)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(offset) * 0.03),
            value: animateCards
        )
    }

    // MARK: - Recovery Row

    private func recoveryRow(_ day: WorkoutDay, offset: Int) -> some View {
        let isSelected = calendar.isDate(day.date, inSameDayAs: selectedDate)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedDate = calendar.startOfDay(for: day.date)
            }
        } label: {
            HStack(spacing: 14) {
                VStack(spacing: 2) {
                    Text(shortDayName(day.date))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(MVMTheme.tertiaryText)

                    Text(dayNumber(day.date))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                .frame(width: 36)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Recovery & Mobility")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.secondaryText)

                    Text("Active rest · Light movement")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(Color(hex: "#1E3A5F").opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                isSelected ? MVMTheme.accent.opacity(0.05) : MVMTheme.card.opacity(0.4)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? MVMTheme.accent.opacity(0.15) : MVMTheme.border.opacity(0.5)
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(PressScaleButtonStyle())
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 10)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(offset) * 0.03),
            value: animateCards
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 44))
                    .foregroundStyle(MVMTheme.accent.opacity(0.5))

                Text("No Plan Yet")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Build your week and stay ready.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            VStack(spacing: 10) {
                Button {
                    vm.generateWeeklyPlan()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.subheadline.weight(.bold))
                        Text("Build Weekly Plan")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [MVMTheme.accent, MVMTheme.accent2],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: MVMTheme.accent.opacity(0.3), radius: 12, y: 6)
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    vm.generateWeeklyPlan()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.subheadline.weight(.bold))
                        Text("Quick Start")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(MVMTheme.border)
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 8)
    }

    // MARK: - Calendar Export Sheet

    private var calendarExportSheet: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40))
                    .foregroundStyle(MVMTheme.accent)
                    .padding(.top, 8)

                Text("Export to Calendar")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Add your PT plan to your iOS Calendar so workouts appear alongside your schedule.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 12) {
                if let plan = vm.currentPlan {
                    Button {
                        Task {
                            let result = await calendarService.exportWeeklyPlan(plan)
                            handleExportResult(result)
                            showCalendarSheet = false
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if calendarService.isExporting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.subheadline.weight(.bold))
                            }
                            Text("Export Full Week")
                                .font(.headline.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [MVMTheme.accent, MVMTheme.accent2],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(calendarService.isExporting)
                    .buttonStyle(PressScaleButtonStyle())

                    if let selectedDay = plan.days.first(where: { calendar.isDate($0.date, inSameDayAs: selectedDate) && !$0.isRestDay }) {
                        Button {
                            Task {
                                let result = await calendarService.exportWorkout(selectedDay)
                                handleExportResult(result)
                                showCalendarSheet = false
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle")
                                    .font(.subheadline.weight(.bold))
                                Text("Export Selected Day Only")
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundStyle(MVMTheme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(MVMTheme.cardSoft)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(MVMTheme.border)
                            }
                        }
                        .disabled(calendarService.isExporting)
                        .buttonStyle(PressScaleButtonStyle())
                    }
                }

                Button {
                    showCalendarSheet = false
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

    // MARK: - Helpers

    private var currentWeekDates: [Date] {
        guard let plan = vm.currentPlan else {
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
        }
        return plan.days.map { calendar.startOfDay(for: $0.date) }
    }

    private func workoutDay(for date: Date) -> WorkoutDay? {
        vm.currentPlan?.days.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private var monthYearString: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: selectedDate)
    }

    private var weekRangeString: String {
        let dates = currentWeekDates
        guard let first = dates.first, let last = dates.last else { return "This Week" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: first)) – \(f.string(from: last))"
    }

    private func shortDayName(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }

    private func dayNumber(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }

    private func dayLabel(_ day: WorkoutDay) -> String {
        if calendar.isDateInToday(day.date) { return "Today" }
        if calendar.isDateInTomorrow(day.date) { return "Tomorrow" }
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: day.date)
    }

    private func estimatedDuration(_ day: WorkoutDay) -> String {
        let mins = max(day.exercises.count * 4, 15)
        return "~\(mins) min"
    }

    private func handleExportResult(_ result: CalendarExportService.ExportResult) {
        switch result {
        case .success(let count):
            exportAlertMessage = "\(count) workout\(count == 1 ? "" : "s") added to your calendar."
        case .partial(let exported, let failed):
            exportAlertMessage = "\(exported) exported, \(failed) failed. Try again for remaining."
        case .denied:
            exportAlertMessage = "Calendar access denied. Go to Settings → MVM Army → Calendars to enable."
        case .error(let message):
            exportAlertMessage = "Export failed: \(message)"
        }
        showExportAlert = true
    }
}
