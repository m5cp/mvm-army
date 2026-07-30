import SwiftUI

struct PlanView: View {
    @Environment(AppViewModel.self) private var vm

    @State private var selectedDate: Date = Calendar.current.startOfDay(for: .now)
    @State private var showEditSheet: Bool = false
    @State private var selectedDayIndex: Int?
    @State private var navigateToDetail: Bool = false
    @State private var detailDayIndex: Int = 0
    @State private var navigateToSession: Bool = false
    @State private var sessionDayIndex: Int = 0
    @State private var animateCards: Bool = false
    @State private var calendarService = CalendarExportService()
    @State private var showCalendarSheet: Bool = false
    @State private var showExportAlert: Bool = false
    @State private var exportAlertMessage: String = ""
    @State private var completeTrigger: Bool = false
    @State private var startTrigger: Bool = false

    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            MVMTheme.screen.ignoresSafeArea()

            VStack(spacing: 0) {
                weekCalendarStrip
                    .padding(.bottom, 6)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
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
                    .padding(.top, 12)
                    .padding(.bottom, 48)
                    .adaptiveContainer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("TRAIN")
                    .font(MVMTheme.mono(12))
                    .kerning(2.2)
                    .foregroundStyle(MVMTheme.textMuted)
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
                        .foregroundStyle(MVMTheme.textMuted)
                }
            }
        }
        .toolbarBackground(MVMTheme.screen, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $navigateToDetail) {
            if vm.currentPlan?.days.contains(where: { $0.dayIndex == detailDayIndex }) == true {
                WorkoutDetailView(dayIndex: detailDayIndex, isStandalone: false)
            } else {
                UnavailableFallbackView(title: "Workout Unavailable", message: "This workout could not be loaded.", action: "Go Back") {
                    navigateToDetail = false
                }
            }
        }
        .navigationDestination(isPresented: $navigateToSession) {
            if vm.currentPlan?.days.contains(where: { $0.dayIndex == sessionDayIndex }) == true {
                ActiveSessionView(dayIndex: sessionDayIndex, isStandalone: false)
            } else {
                UnavailableFallbackView(title: "Session Unavailable", message: "This workout session could not be loaded.", action: "Go Back") {
                    navigateToSession = false
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let dayIndex = selectedDayIndex,
               let plan = vm.currentPlan,
               let day = plan.days.first(where: { $0.dayIndex == dayIndex }) {
                EditWorkoutSheet(day: day)
            } else {
                NavigationStack {
                    UnavailableFallbackView(title: "Edit Unavailable", message: "This workout could not be loaded for editing.", action: "Dismiss") {
                        showEditSheet = false
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showEditSheet = false }
                                .foregroundStyle(MVMTheme.text)
                        }
                    }
                    .toolbarBackground(MVMTheme.screen, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                }
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
                    .foregroundStyle(MVMTheme.text)

                Spacer()

                Text(weekRangeString)
                    .font(MVMTheme.mono(11))
                    .foregroundStyle(MVMTheme.textFaint)
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.horizontal, 20)

            HStack(spacing: 0) {
                ForEach(weekDates, id: \.self) { date in
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let isToday = calendar.isDateInToday(date)
                    let dayData = workoutDay(for: date)
                    let hasWorkout = dayData != nil && !(dayData?.isRestDay ?? true)
                    let isCompleted = dayData?.isCompleted ?? false
                    let hasUnit = !vm.scheduledUnitPT.filter { calendar.isDate($0.date, inSameDayAs: date) }.isEmpty

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedDate = date
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(shortDayName(date))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(
                                    isSelected ? MVMTheme.onAmber :
                                    isToday ? MVMTheme.amber :
                                    MVMTheme.textFaint
                                )

                            Text(dayNumber(date))
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    isSelected ? MVMTheme.onAmber :
                                    isCompleted ? MVMTheme.success :
                                    isToday ? MVMTheme.amber :
                                    MVMTheme.text
                                )

                            HStack(spacing: 3) {
                                Circle()
                                    .fill(
                                        isCompleted ? MVMTheme.success :
                                        hasWorkout ? (isSelected ? MVMTheme.onAmber.opacity(0.6) : MVMTheme.amber.opacity(0.6)) :
                                        Color.clear
                                    )
                                    .frame(width: 5, height: 5)
                                if hasUnit {
                                    Circle()
                                        .fill(MVMTheme.slateAccent.opacity(0.85))
                                        .frame(width: 5, height: 5)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(MVMTheme.amberButtonGradient)
                                    .shadow(color: MVMTheme.amberBtnBot.opacity(0.4), radius: 8, y: 4)
                            } else if isToday {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(MVMTheme.amber.opacity(0.35), lineWidth: 1)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 12)
        .background(MVMTheme.cardGradient)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(MVMTheme.hairline)
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

            RaisedCard(radius: 16) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(completed) OF \(total) COMPLETE")
                            .font(MVMTheme.mono(10.5)).kerning(1)
                            .foregroundStyle(MVMTheme.textMuted)
                            .lineLimit(1).fixedSize()

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(MVMTheme.well)
                                    .frame(height: 5)

                                Capsule()
                                    .fill(MVMTheme.amberButtonGradient)
                                    .frame(width: max(geo.size.width * progress, progress > 0 ? 5 : 0), height: 5)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: completed)
                            }
                        }
                        .frame(height: 5)
                    }

                    Text("\(Int(progress * 100))%")
                        .font(MVMTheme.scoreDisplay(22))
                        .foregroundStyle(MVMTheme.amber)
                        .contentTransition(.numericText())
                        .frame(width: 54, alignment: .trailing)
                        .lineLimit(1).fixedSize()
                }
                .padding(16)
            }
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
                    .font(MVMTheme.mono(11)).kerning(1.4)
                    .foregroundStyle(MVMTheme.textFaint)
                    .padding(.leading, 4)
                    .padding(.top, 8)

                ForEach(Array(plan.days.enumerated()), id: \.element.id) { offset, day in
                    if day.isRestDay {
                        recoveryRow(day, offset: offset)
                    } else {
                        workoutRow(day, offset: offset)
                    }

                    ForEach(unitPTForDate(day.date), id: \.id) { unitDay in
                        unitPTRow(unitDay)
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

    /// First structured AFT event tag found among a day's exercises, if any.
    private func primaryEventTag(_ day: WorkoutDay) -> AFTEventType? {
        day.exercises.compactMap(\.eventTag).first
    }

    private func selectedWorkoutCard(_ day: WorkoutDay) -> some View {
        RaisedCard(radius: 22) {
            ZStack(alignment: .topLeading) {
                GradedPhoto(name: day.isCompleted ? "photo-founders-trail-run" : "photo-ruck-wide-landscape", grade: .lowKeyGym)

                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Text(dayLabel(day).uppercased())
                            .font(MVMTheme.mono(10.5)).kerning(1.2)
                            .foregroundStyle(MVMTheme.amber)
                            .lineLimit(1).fixedSize()

                        Spacer()

                        if day.isCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2.weight(.bold))
                                Text("DONE")
                                    .font(.caption2.weight(.heavy))
                                    .tracking(0.5)
                            }
                            .foregroundStyle(MVMTheme.text)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(MVMTheme.success.opacity(0.22))
                            .clipShape(Capsule())
                        } else if let tag = primaryEventTag(day) {
                            EventTagChip(event: tag)
                                .scaleEffect(0.72)
                                .frame(width: 32, height: 32)
                        } else if let tag = day.tags.first {
                            Text(tag)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(MVMTheme.text)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(day.title)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(MVMTheme.text)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 12) {
                            Label("\(day.exercises.count) exercises", systemImage: "list.bullet")
                            Label(estimatedDuration(day), systemImage: "clock")
                        }
                        .font(MVMTheme.mono(11.5))
                        .foregroundStyle(MVMTheme.textMuted)
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
                                .foregroundStyle(MVMTheme.onAmber)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(MVMTheme.amberButtonGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(PressScaleButtonStyle())
                        } else {
                            Button {
                                startTrigger.toggle()
                                sessionDayIndex = day.dayIndex
                                navigateToSession = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "play.fill")
                                        .font(.caption.weight(.bold))
                                    Text("Start Workout")
                                        .font(.subheadline.weight(.bold))
                                }
                                .foregroundStyle(MVMTheme.onAmber)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(MVMTheme.amberButtonGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .sensoryFeedback(.impact(weight: .medium), trigger: startTrigger)
                            .buttonStyle(PressScaleButtonStyle())

                            Button {
                                detailDayIndex = day.dayIndex
                                navigateToDetail = true
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(MVMTheme.text)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white.opacity(0.14))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(PressScaleButtonStyle())

                            Button {
                                completeTrigger.toggle()
                                vm.markDayCompleted(dayIndex: day.dayIndex)
                            } label: {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(MVMTheme.text)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white.opacity(0.14))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .sensoryFeedback(.success, trigger: completeTrigger)

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
                                    .foregroundStyle(MVMTheme.text)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white.opacity(0.14))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(MVMTheme.amber.opacity(0.28), lineWidth: 1))
        .shadow(color: (day.isCompleted ? MVMTheme.success : MVMTheme.amber).opacity(0.16), radius: 20, y: 12)
    }

    private func selectedRecoveryCard(_ day: WorkoutDay) -> some View {
        RaisedCard(radius: 22) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.textMuted)

                    Text(dayLabel(day).uppercased())
                        .font(MVMTheme.mono(10.5)).kerning(1.2)
                        .foregroundStyle(MVMTheme.textFaint)

                    Spacer()

                    Text("ACTIVE REST")
                        .font(MVMTheme.mono(10))
                        .foregroundStyle(MVMTheme.textMuted)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(MVMTheme.well)
                        .clipShape(Capsule())
                        .lineLimit(1).fixedSize()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Recovery & Mobility")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.text)

                    Text("Light movement keeps the plan moving forward.")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.textMuted)
                }
            }
            .padding(20)
        }
    }

    // MARK: - Workout Row

    private func workoutRow(_ day: WorkoutDay, offset: Int) -> some View {
        let isSelected = calendar.isDate(day.date, inSameDayAs: selectedDate)
        let rowFill: AnyShapeStyle = isSelected
            ? AnyShapeStyle(MVMTheme.amber.opacity(0.09))
            : AnyShapeStyle(MVMTheme.cardGradient.opacity(day.isCompleted ? 0.5 : 1))
        let rowStroke: Color = isSelected
            ? MVMTheme.amber.opacity(0.3)
            : (day.isCompleted ? MVMTheme.success.opacity(0.14) : MVMTheme.hairline)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedDate = calendar.startOfDay(for: day.date)
            }
        } label: {
            HStack(spacing: 14) {
                InsetWell(radius: 11) {
                    VStack(spacing: 2) {
                        Text(shortDayName(day.date))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(MVMTheme.textFaint)

                        Text(dayNumber(day.date))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                day.isCompleted ? MVMTheme.success :
                                calendar.isDateInToday(day.date) ? MVMTheme.amber :
                                MVMTheme.textMuted
                            )
                    }
                    .frame(width: 36, height: 36)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(day.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(day.isCompleted ? MVMTheme.textMuted : MVMTheme.text)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        if let tag = primaryEventTag(day) {
                            Text(tag.displayCode)
                                .font(MVMTheme.mono(9.5, weight: .bold))
                                .foregroundStyle(MVMTheme.amber)
                                .lineLimit(1).fixedSize()
                        } else if let tag = day.tags.first {
                            Text(tag)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(MVMTheme.amber)
                        }
                        Text(estimatedDuration(day))
                            .font(MVMTheme.mono(10.5))
                            .foregroundStyle(MVMTheme.textFaint)
                            .lineLimit(1).fixedSize()
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
                        .foregroundStyle(MVMTheme.textFaint)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(rowFill)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(rowStroke)
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
                        .foregroundStyle(MVMTheme.textFaint)

                    Text(dayNumber(day.date))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(MVMTheme.textFaint)
                }
                .frame(width: 36)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Recovery & Mobility")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.textMuted)

                    Text("Active rest \(MVMTheme.dot) Light movement")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.textFaint)
                }

                Spacer(minLength: 0)

                Image(systemName: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.textFaint)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                isSelected ? MVMTheme.amber.opacity(0.06) : MVMTheme.well.opacity(0.4)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? MVMTheme.amber.opacity(0.16) : MVMTheme.hairline
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
                    .foregroundStyle(MVMTheme.amber.opacity(0.6))

                Text("No Plan Yet")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.text)

                Text("Build your weekly plan to stay on track.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.textMuted)
            }

            VStack(spacing: 10) {
                AmberButton(title: "Build Weekly Plan") {
                    vm.generateWeeklyPlan()
                }

                Button {
                    vm.generateWeeklyPlan()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.subheadline.weight(.bold))
                        Text("Quick Start")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.textMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(MVMTheme.amber.opacity(0.35), style: .init(lineWidth: 1.5, dash: [6, 5]))
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
                    .foregroundStyle(MVMTheme.amber)
                    .padding(.top, 8)

                Text("Export to Calendar")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.text)

                Text("Add your PT plan to your iOS Calendar so workouts appear alongside your schedule.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.textMuted)
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
                                    .tint(MVMTheme.onAmber)
                            } else {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.subheadline.weight(.bold))
                            }
                            Text("Export Full Week")
                                .font(.headline.weight(.bold))
                        }
                        .foregroundStyle(MVMTheme.onAmber)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(MVMTheme.amberButtonGradient)
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
                            .foregroundStyle(MVMTheme.textMuted)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(MVMTheme.well)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(MVMTheme.hairline)
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
                        .foregroundStyle(MVMTheme.textFaint)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(MVMTheme.screen)
    }

    // MARK: - Unit PT Helpers

    private func unitPTForDate(_ date: Date) -> [WorkoutDay] {
        vm.scheduledUnitPT.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func unitPTRow(_ day: WorkoutDay) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "person.3.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(MVMTheme.slateAccent)
                .frame(width: 36, height: 36)
                .background(MVMTheme.slateAccent.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(day.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(day.isCompleted ? MVMTheme.textMuted : MVMTheme.text)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text("Unit PT")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(MVMTheme.slateAccent)

                    if let start = day.startTime {
                        Text(start.formatted(date: .omitted, time: .shortened))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.textFaint)
                    }
                }
            }

            Spacer(minLength: 0)

            if day.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.body)
                    .foregroundStyle(MVMTheme.success)
            } else {
                Menu {
                    Button {
                        vm.markUnitPTCompleted(id: day.id)
                    } label: {
                        Label("Mark Complete", systemImage: "checkmark.circle")
                    }
                    Button(role: .destructive) {
                        vm.removeUnitPTFromCalendar(id: day.id)
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.textFaint)
                        .frame(width: 32, height: 32)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(MVMTheme.slateAccent.opacity(0.06))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(MVMTheme.slateAccent.opacity(0.2))
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
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
        return "\(f.string(from: first)) \(MVMTheme.dot) \(f.string(from: last))"
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
            exportAlertMessage = "Calendar access denied. Go to Settings → MVM Fitness → Calendars to enable."
        case .error(let message):
            exportAlertMessage = "Export failed: \(message)"
        }
        showExportAlert = true
    }
}
