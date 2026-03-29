import SwiftUI

struct HomeView: View {
    @Environment(AppViewModel.self) private var vm

    @State private var animateHero: Bool = false
    @State private var animateMetrics: Bool = false
    @State private var showWODSheet: Bool = false
    @State private var showRandomSheet: Bool = false
    @State private var showWorkoutDetail: Bool = false
    @State private var showActiveSession: Bool = false
    @State private var showUnitPTSheet: Bool = false
    @State private var showScanSheet: Bool = false
    @State private var showAFTCalculator: Bool = false
    @State private var showRecoveryDetail: Bool = false
    @State private var showEditSheet: Bool = false
    @State private var showCalendarSheet: Bool = false
    @State private var showExportAlert: Bool = false
    @State private var exportAlertMessage: String = ""
    @State private var randomWorkout: WorkoutDay?
    @State private var recoverySession: WorkoutDay?
    @State private var startWorkoutTrigger: Bool = false
    @State private var completeWorkoutTrigger: Bool = false
    @State private var toolTapTrigger: Bool = false
    @State private var shareItems: [Any] = []
    @State private var showShareSheet: Bool = false
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: .now)
    @State private var selectedDayIndex: Int?
    @State private var navigateToPlanDetail: Bool = false
    @State private var planDetailDayIndex: Int = 0
    @State private var navigateToPlanSession: Bool = false
    @State private var planSessionDayIndex: Int = 0
    @State private var calendarService = CalendarExportService()

    private let calendar = Calendar.current

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                weekCalendarStrip

                VStack(spacing: 24) {
                    heroSection
                    metricsStrip
                    toolsGrid
                    aftCalculatorButton
                    weekPlanSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .background {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                backgroundAmbience
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
        .navigationDestination(isPresented: $showWorkoutDetail) {
            if let today = vm.todayWorkout {
                WorkoutDetailView(dayIndex: today.dayIndex, isStandalone: false)
            } else {
                UnavailableFallbackView(title: "Workout Unavailable", message: "No workout found for today.", action: "Return Home") {
                    showWorkoutDetail = false
                }
            }
        }
        .navigationDestination(isPresented: $showActiveSession) {
            if let today = vm.todayWorkout {
                ActiveSessionView(dayIndex: today.dayIndex, isStandalone: false)
            } else {
                UnavailableFallbackView(title: "Session Unavailable", message: "No workout found to start.", action: "Return Home") {
                    showActiveSession = false
                }
            }
        }
        .navigationDestination(isPresented: $showRecoveryDetail) {
            if let session = recoverySession {
                WorkoutDetailView(dayIndex: session.dayIndex, isStandalone: false)
            } else {
                UnavailableFallbackView(title: "Recovery Unavailable", message: "Unable to load recovery session.", action: "Return Home") {
                    showRecoveryDetail = false
                }
            }
        }
        .navigationDestination(isPresented: $navigateToPlanDetail) {
            if vm.currentPlan?.days.contains(where: { $0.dayIndex == planDetailDayIndex }) == true {
                WorkoutDetailView(dayIndex: planDetailDayIndex, isStandalone: false)
            } else {
                UnavailableFallbackView(title: "Workout Unavailable", message: "This workout could not be loaded.", action: "Go Back") {
                    navigateToPlanDetail = false
                }
            }
        }
        .navigationDestination(isPresented: $navigateToPlanSession) {
            if vm.currentPlan?.days.contains(where: { $0.dayIndex == planSessionDayIndex }) == true {
                ActiveSessionView(dayIndex: planSessionDayIndex, isStandalone: false)
            } else {
                UnavailableFallbackView(title: "Session Unavailable", message: "This workout session could not be loaded.", action: "Go Back") {
                    navigateToPlanSession = false
                }
            }
        }
        .navigationDestination(isPresented: $showAFTCalculator) {
            AFTCalculatorView()
        }
        .sheet(isPresented: $showWODSheet) {
            WODDetailView()
        }
        .sheet(isPresented: $showRandomSheet) {
            if let workout = randomWorkout {
                StandaloneWorkoutSheet(workout: workout, sheetTitle: "Random Workout")
            } else {
                NavigationStack {
                    UnavailableFallbackView(title: "Workout Unavailable", message: "Unable to generate a random workout.", action: "Dismiss") {
                        showRandomSheet = false
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showRandomSheet = false }
                                .foregroundStyle(MVMTheme.primaryText)
                        }
                    }
                    .toolbarBackground(MVMTheme.background, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                }
            }
        }
        .sheet(isPresented: $showUnitPTSheet) {
            UnitPTBuilderSheet()
        }
        .sheet(isPresented: $showScanSheet) {
            QRScannerSheet()
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
                                .foregroundStyle(MVMTheme.primaryText)
                        }
                    }
                    .toolbarBackground(MVMTheme.background, for: .navigationBar)
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
        .sensoryFeedback(.impact(weight: .medium), trigger: startWorkoutTrigger)
        .sensoryFeedback(.success, trigger: completeWorkoutTrigger)
        .sensoryFeedback(.selection, trigger: toolTapTrigger)
        .sheet(isPresented: $showShareSheet) {
            if !shareItems.isEmpty {
                ShareSheet(items: shareItems)
            }
        }
        .onAppear {
            vm.pedometer.refreshTodaySteps()
            Task {
                try? await Task.sleep(for: .milliseconds(400))
                vm.syncTodaySteps()
            }
            vm.ensureTodayHasWorkout()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) {
                animateHero = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
                animateMetrics = true
            }
        }
    }

    // MARK: - Background Ambience

    private var backgroundAmbience: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [MVMTheme.accent.opacity(0.08), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .offset(y: -200)
                .blur(radius: 80)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [MVMTheme.accent2.opacity(0.05), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 120, y: 100)
                .blur(radius: 60)
        }
        .ignoresSafeArea()
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

    // MARK: - Hero Section

    private var heroSection: some View {
        Group {
            if let selectedDay = selectedDayWorkout {
                if selectedDay.isRestDay {
                    recoveryHero(selectedDay)
                } else if selectedDay.isCompleted {
                    completedHero(selectedDay)
                } else {
                    activeHero(selectedDay)
                }
            } else {
                emptyHero
            }
        }
        .scaleEffect(animateHero ? 1 : 0.96)
        .opacity(animateHero ? 1 : 0)
    }

    private var selectedDayWorkout: WorkoutDay? {
        guard let plan = vm.currentPlan else { return nil }
        return plan.days.first { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private func activeHero(_ workout: WorkoutDay) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.heart.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.9))

                    Text(heroLabel(for: workout).uppercased())
                        .font(.caption2.weight(.heavy))
                        .tracking(1.0)
                        .foregroundStyle(.white.opacity(0.8))

                    Spacer()

                    if let tag = workout.tags.first {
                        Text(tag)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.title)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    HStack(spacing: 14) {
                        Label("\(workout.exercises.count) exercises", systemImage: "list.bullet")
                        Label(estimatedDuration(workout), systemImage: "clock")
                        if workout.completedExerciseCount > 0 {
                            Label("\(workout.completedExerciseCount)/\(workout.exercises.count)", systemImage: "checkmark.circle")
                        }
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                }

                exerciseGlance(workout)

                Button {
                    startWorkoutTrigger.toggle()
                    if calendar.isDateInToday(workout.date) {
                        showActiveSession = true
                    } else {
                        planSessionDayIndex = workout.dayIndex
                        navigateToPlanSession = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.subheadline.weight(.bold))
                        Text("Start Workout")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .white.opacity(0.15), radius: 12, y: 4)
                }
                .buttonStyle(PressScaleButtonStyle())
            }
            .padding(24)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(heroCardGradient)
                    RoundedRectangle(cornerRadius: 28)
                        .fill(MVMTheme.subtleGradient)
                    heroShimmerOverlay
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: MVMTheme.accent.opacity(0.25), radius: 32, y: 20)

            activeSecondaryActions(workout)
        }
    }

    private func heroLabel(for workout: WorkoutDay) -> String {
        if calendar.isDateInToday(workout.date) { return "Today's PT" }
        if calendar.isDateInTomorrow(workout.date) { return "Tomorrow's PT" }
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return "\(f.string(from: workout.date))'s PT"
    }

    private func exerciseGlance(_ workout: WorkoutDay) -> some View {
        VStack(spacing: 6) {
            ForEach(workout.exercises.prefix(3)) { exercise in
                HStack(spacing: 10) {
                    Circle()
                        .fill(exercise.isCompleted ? .white : .white.opacity(0.3))
                        .frame(width: 6, height: 6)

                    Text(exercise.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(exercise.isCompleted ? .white.opacity(0.5) : .white.opacity(0.85))
                        .strikethrough(exercise.isCompleted, color: .white.opacity(0.3))
                        .lineLimit(1)

                    Spacer()

                    Text(exercise.displayDetail)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }

            if workout.exercises.count > 3 {
                HStack {
                    Text("+\(workout.exercises.count - 3) more")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.4))
                    Spacer()
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func activeSecondaryActions(_ workout: WorkoutDay) -> some View {
        HStack(spacing: 10) {
            Button {
                if calendar.isDateInToday(workout.date) {
                    showWorkoutDetail = true
                } else {
                    planDetailDayIndex = workout.dayIndex
                    navigateToPlanDetail = true
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.caption.weight(.bold))
                    Text("Log")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(MVMTheme.secondaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(MVMTheme.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                completeWorkoutTrigger.toggle()
                vm.markDayCompleted(dayIndex: workout.dayIndex)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                    Text("Complete")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(MVMTheme.success)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(MVMTheme.success.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                shareItems = ShareCardRenderer.shareItems(
                    cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                )
                showShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(width: 44, height: 44)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(.top, 12)
    }

    private func completedHero(_ workout: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)

                Text("MISSION COMPLETE")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(workout.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text("\(workout.exercises.count) exercises completed")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Button {
                if calendar.isDateInToday(workout.date) {
                    showWorkoutDetail = true
                } else {
                    planDetailDayIndex = workout.dayIndex
                    navigateToPlanDetail = true
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "eye")
                        .font(.subheadline.weight(.semibold))
                    Text("Review Workout")
                        .font(.headline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#059669"), Color(hex: "#10B981").opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color(hex: "#059669").opacity(0.2), radius: 24, y: 16)
    }

    private func recoveryHero(_ day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))

                Text("RECOVERY DAY")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                Text("Active Rest")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Recovery & Mobility")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)

                Text("Light movement keeps the plan moving forward.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }

            HStack(spacing: 12) {
                Button {
                    let session = vm.generateRecoverySession()
                    recoverySession = session
                    showRecoveryDetail = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "figure.cooldown")
                            .font(.subheadline.weight(.bold))
                        Text("Start Recovery")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    vm.replaceRestDayWithWorkout(dayIndex: day.dayIndex)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.subheadline.weight(.bold))
                        Text("Swap")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(24)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#1E3A5F").opacity(0.9),
                                Color(hex: "#2D4A6F").opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 28)
                    .fill(MVMTheme.subtleGradient)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color(hex: "#1E3A5F").opacity(0.2), radius: 24, y: 16)
    }

    private var emptyHero: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))

                Text("NO PT BUILT YET")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Build Today's PT")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)

                Text("Generate a workout and get moving.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }

            HStack(spacing: 12) {
                Button {
                    vm.generateWeeklyPlan()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.subheadline.weight(.bold))
                        Text("Build Plan")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .white.opacity(0.12), radius: 10, y: 4)
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    showWODSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.subheadline.weight(.bold))
                        Text("Quick WOD")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(24)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(heroCardGradient)
                RoundedRectangle(cornerRadius: 28)
                    .fill(MVMTheme.subtleGradient)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: MVMTheme.accent.opacity(0.2), radius: 24, y: 16)
    }

    // MARK: - Metrics Strip

    private var metricsStrip: some View {
        HStack(spacing: 0) {
            metricPill(
                icon: "figure.walk",
                value: formattedSteps,
                label: "Steps",
                color: MVMTheme.accent
            )

            metricDivider

            metricPill(
                icon: "checkmark.circle.fill",
                value: "\(vm.weeklyCompletedCount)/\(vm.weeklyTotalDays)",
                label: "This Week",
                color: MVMTheme.success
            )

            metricDivider

            metricPill(
                icon: "flame.fill",
                value: "\(vm.streak)",
                label: vm.streak == 1 ? "Day" : "Days",
                color: MVMTheme.warning
            )
        }
        .padding(.vertical, 18)
        .background(MVMTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(MVMTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .opacity(animateMetrics ? 1 : 0)
        .offset(y: animateMetrics ? 0 : 12)
    }

    private var metricDivider: some View {
        Rectangle()
            .fill(MVMTheme.border)
            .frame(width: 1, height: 32)
    }

    private func metricPill(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .contentTransition(.numericText())
            }
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tools Grid (4 items)

    private var toolsGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("TOOLS")
                .font(.caption.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ],
                spacing: 10
            ) {
                compactTool(
                    title: "WOD",
                    icon: "star.fill",
                    color: Color(hex: "#F59E0B")
                ) {
                    showWODSheet = true
                }

                compactTool(
                    title: "Random",
                    icon: "shuffle",
                    color: Color(hex: "#6366F1")
                ) {
                    randomWorkout = vm.generateRandomWorkout()
                    showRandomSheet = true
                }

                compactTool(
                    title: "Unit PT",
                    icon: "person.3.fill",
                    color: Color(hex: "#2563EB")
                ) { showUnitPTSheet = true }

                compactTool(
                    title: "Scan QR",
                    icon: "qrcode.viewfinder",
                    color: Color(hex: "#7C3AED")
                ) { showScanSheet = true }
            }
        }
    }

    // MARK: - AFT Calculator Button

    private var aftCalculatorButton: some View {
        Button {
            toolTapTrigger.toggle()
            showAFTCalculator = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "shield.checkered")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color(hex: "#059669"))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "#059669").opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text("AFT Calculator")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Full AFT scoring with soldier info")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .padding(16)
            .background(MVMTheme.card)
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(MVMTheme.border)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Week Plan Section

    @ViewBuilder
    private var weekPlanSection: some View {
        if let plan = vm.currentPlan {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("THIS WEEK")
                        .font(.caption.weight(.bold))
                        .tracking(1.0)
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .padding(.leading, 4)

                    Spacer()

                    weekProgressPill(plan)
                }

                ForEach(Array(plan.days.enumerated()), id: \.element.id) { offset, day in
                    if day.isRestDay {
                        weekRecoveryRow(day)
                    } else {
                        weekWorkoutRow(day)
                    }
                }
            }
        }
    }

    private func weekProgressPill(_ plan: WeeklyPlan) -> some View {
        let total = plan.totalWorkoutDays
        let completed = plan.completedCount
        let progress: Int = total > 0 ? Int(Double(completed) / Double(total) * 100) : 0

        return Text("\(completed)/\(total) · \(progress)%")
            .font(.caption2.weight(.bold))
            .foregroundStyle(MVMTheme.accent)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(MVMTheme.accent.opacity(0.1))
            .clipShape(Capsule())
    }

    private func weekWorkoutRow(_ day: WorkoutDay) -> some View {
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
    }

    private func weekRecoveryRow(_ day: WorkoutDay) -> some View {
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
    }

    private func compactTool(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            toolTapTrigger.toggle()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body.weight(.bold))
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .padding(14)
            .background(MVMTheme.card)
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(MVMTheme.border)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(PressScaleButtonStyle())
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

                Text("Add your PT plan to your iOS Calendar.")
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

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: .now)
        if hour < 5 { return "Late night" }
        if hour < 10 { return "Good morning" }
        if hour < 14 { return "Drive on" }
        if hour < 18 { return "Afternoon" }
        return "Evening"
    }

    private var formattedSteps: String {
        let steps = vm.pedometer.todaySteps
        if steps >= 1000 { return String(format: "%.1fk", Double(steps) / 1000) }
        return "\(steps)"
    }

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

    private func estimatedDuration(_ workout: WorkoutDay) -> String {
        let mins = max(workout.exercises.count * 4, 15)
        return "~\(mins) min"
    }

    private var heroCardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#3B6DE0"),
                Color(hex: "#5B4DC7").opacity(0.95),
                Color(hex: "#4A3DAF").opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var heroShimmerOverlay: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.04),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
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
