import SwiftUI

struct HomeView: View {
    @Environment(AppViewModel.self) private var vm
    @AppStorage("disclaimerAccepted") private var disclaimerAccepted: Bool = false

    @State private var animateHero: Bool = false
    @State private var animateMetrics: Bool = false
    @State private var showWODSheet: Bool = false
    @State private var showWODPlanSheet: Bool = false
    @State private var showRandomSheet: Bool = false
    @State private var showWorkoutDetail: Bool = false
    @State private var showActiveSession: Bool = false
    @State private var showUnitPTSheet: Bool = false
    @State private var showMyPTPlanSheet: Bool = false
    @State private var showScanSheet: Bool = false
    @State private var showAFTCalculator: Bool = false
    @State private var showResources: Bool = false
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

    @State private var selectedDate: Date = Calendar.current.startOfDay(for: .now)
    @State private var selectedDayIndex: Int?
    @State private var navigateToPlanDetail: Bool = false
    @State private var planDetailDayIndex: Int = 0
    @State private var navigateToPlanSession: Bool = false
    @State private var planSessionDayIndex: Int = 0
    @State private var navigateToUnitPTDetail: Bool = false
    @State private var selectedUnitPTDay: WorkoutDay?
    @State private var calendarService = CalendarExportService()
    @State private var showCompletionShare: Bool = false
    @State private var completedWorkoutTitle: String = ""
    @State private var completedExerciseCount: Int = 0
    @State private var showPTWODSheet: Bool = false
    @State private var navigateToCalendarDay: Bool = false
    @State private var calendarDayDate: Date = .now

    private let calendar = Calendar.current

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                if disclaimerAccepted {
                    weekCalendarStrip
                    selectedDayWorkoutCards
                }

                VStack(spacing: 20) {
                    greetingHeader
                    aftCalculatorHero

                    if disclaimerAccepted {
                        wodDualCards
                        quickActionsGrid
                        metricsStrip
                    } else {
                        disclaimerBanner
                    }
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
        .navigationDestination(isPresented: $showResources) {
            ResourcesView()
        }
        .navigationDestination(isPresented: $navigateToUnitPTDetail) {
            if let unitDay = selectedUnitPTDay {
                StandaloneWorkoutDetailView(workout: unitDay)
            } else {
                UnavailableFallbackView(title: "Unit PT Unavailable", message: "Could not load unit PT details.", action: "Go Back") {
                    navigateToUnitPTDetail = false
                }
            }
        }
        .navigationDestination(isPresented: $navigateToCalendarDay) {
            CalendarDayDetailView(date: calendarDayDate)
        }
        .sheet(isPresented: $showWODSheet) {
            WODDetailView()
        }
        .sheet(isPresented: $showPTWODSheet) {
            PTWODDetailView()
        }
        .sheet(isPresented: $showWODPlanSheet) {
            WODPlanSheet()
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
        .sheet(isPresented: $showMyPTPlanSheet) {
            MyPTPlanSheet()
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
        .sheet(isPresented: $showCompletionShare) {
            WorkoutCompletionShareSheet(
                title: completedWorkoutTitle,
                exerciseCount: completedExerciseCount
            )
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

    // MARK: - Disclaimer Banner

    private var disclaimerBanner: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.shield.fill")
                .font(.title2)
                .foregroundStyle(MVMTheme.accent)

            Text("Limited Access Mode")
                .font(.headline.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text("Accept the terms of use to unlock workout planning, logging, progress tracking, and all training features.")
                .font(.caption)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            Button {
                disclaimerAccepted = true
                vm.generateWeeklyPlan()
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
                    let hasUnit = hasUnitPT(for: date)

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

                            HStack(spacing: 3) {
                                Circle()
                                    .fill(
                                        isCompleted ? MVMTheme.success :
                                        hasWorkout ? MVMTheme.accent.opacity(0.6) :
                                        Color.clear
                                    )
                                    .frame(width: 5, height: 5)
                                if hasUnit {
                                    Circle()
                                        .fill(Color(hex: "#2563EB").opacity(0.8))
                                        .frame(width: 5, height: 5)
                                }
                            }
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

    // MARK: - Selected Day Workout Cards

    private var selectedDayWorkoutCards: some View {
        let workouts = allWorkoutsForSelectedDate

        return VStack(spacing: 0) {
            Button {
                calendarDayDate = selectedDate
                navigateToCalendarDay = true
            } label: {
                if workouts.isEmpty {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(MVMTheme.accent)
                            .frame(width: 36, height: 36)
                            .background(MVMTheme.accent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("No workouts")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(MVMTheme.primaryText)
                            Text("Tap to view day details")
                                .font(.caption)
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                    .padding(14)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(workouts.enumerated()), id: \.element.id) { index, workout in
                            if index > 0 {
                                Rectangle()
                                    .fill(MVMTheme.border)
                                    .frame(height: 1)
                                    .padding(.leading, 62)
                            }

                            HStack(spacing: 12) {
                                Image(systemName: workout.isRestDay ? "bed.double.fill" : workoutIcon(for: workout))
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(workout.isCompleted ? MVMTheme.success : MVMTheme.accent)
                                    .frame(width: 36, height: 36)
                                    .background((workout.isCompleted ? MVMTheme.success : MVMTheme.accent).opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(workout.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(MVMTheme.primaryText)
                                        .lineLimit(1)

                                    HStack(spacing: 8) {
                                        if workout.isRestDay {
                                            Text("Rest Day")
                                                .font(.caption)
                                                .foregroundStyle(MVMTheme.tertiaryText)
                                        } else {
                                            Text("\(workout.exercises.count) exercises")
                                                .font(.caption)
                                                .foregroundStyle(MVMTheme.tertiaryText)
                                            Text(estimatedDuration(workout))
                                                .font(.caption)
                                                .foregroundStyle(MVMTheme.tertiaryText)
                                        }

                                        if workout.isCompleted {
                                            HStack(spacing: 3) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 10))
                                                Text("Done")
                                                    .font(.caption.weight(.semibold))
                                            }
                                            .foregroundStyle(MVMTheme.success)
                                        }
                                    }
                                }

                                Spacer(minLength: 0)

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(MVMTheme.tertiaryText)
                            }
                            .padding(14)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .background(MVMTheme.card)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(MVMTheme.border)
                .frame(height: 1)
        }
    }

    private func workoutIcon(for workout: WorkoutDay) -> String {
        let title = workout.title.lowercased()
        if title.contains("run") || title.contains("cardio") || title.contains("endurance") { return "figure.run" }
        if title.contains("strength") || title.contains("push") || title.contains("pull") { return "figure.strengthtraining.traditional" }
        if title.contains("recovery") || title.contains("stretch") || title.contains("mobility") { return "figure.cooldown" }
        if title.contains("unit") || title.contains("formation") { return "person.3.fill" }
        return "figure.mixed.cardio"
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greetingText)
                .font(.title2.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text(selectedDaySubtitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(animateHero ? 1 : 0)
        .offset(y: animateHero ? 0 : 8)
    }

    private var selectedDaySubtitle: String {
        let allWorkouts = allWorkoutsForSelectedDate
        if allWorkouts.isEmpty { return "No workouts scheduled" }
        let count = allWorkouts.count
        return "\(count) workout\(count == 1 ? "" : "s") scheduled"
    }

    private var selectedDayWorkout: WorkoutDay? {
        guard let plan = vm.currentPlan else { return nil }
        return plan.days.first { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var allWorkoutsForSelectedDate: [WorkoutDay] {
        vm.allWorkoutsForDate(selectedDate)
    }

    // MARK: - Dual WOD Cards (CrossFit WOD + PT Workout of the Day)

    private var wodDualCards: some View {
        HStack(spacing: 10) {
            ptWorkoutCard
            crossfitWODCard
        }
        .opacity(animateHero ? 1 : 0)
        .offset(y: animateHero ? 0 : 8)
    }

    private var ptWorkoutCard: some View {
        Button {
            toolTapTrigger.toggle()
            if vm.todayPTWorkout != nil {
                showPTWODSheet = true
            } else {
                showMyPTPlanSheet = true
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: "figure.run")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Spacer(minLength: 0)

                    Button {
                        toolTapTrigger.toggle()
                        if vm.currentPlan != nil {
                            if let today = vm.todayWorkout {
                                vm.regenerateSingleDay(dayIndex: today.dayIndex)
                            }
                        } else {
                            vm.generateWeeklyPlan()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(width: 24, height: 24)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 10)

                Text("PT WOD")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(0.6)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 4)

                if let ptDay = vm.todayPTWorkout, !ptDay.isRestDay {
                    Text(ptDay.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 4)

                    HStack(spacing: 6) {
                        Label("\(ptDay.exercises.count)", systemImage: "list.bullet")
                        Label(estimatedDuration(ptDay), systemImage: "clock")
                    }
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                } else {
                    Text("No PT Plan")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer(minLength: 4)

                    Text("Tap to create")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 150)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#3B6DE0"),
                                Color(hex: "#5B4DC7").opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: MVMTheme.accent.opacity(0.15), radius: 12, y: 8)
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var crossfitWODCard: some View {
        Button {
            toolTapTrigger.toggle()
            showWODSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Spacer(minLength: 0)

                    Button {
                        toolTapTrigger.toggle()
                        vm.regenerateCrossFitWOD()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(width: 24, height: 24)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 10)

                Text("CROSSFIT WOD")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(0.6)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 4)

                if let wod = vm.todayCrossFitWOD {
                    Text(wod.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 4)

                    HStack(spacing: 6) {
                        Text(wod.format.rawValue)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(.white.opacity(0.12))
                            .clipShape(Capsule())
                        Text("~\(wod.durationMinutes) min")
                    }
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                } else {
                    Text("Generating...")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer(minLength: 4)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 150)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#F59E0B"),
                                Color(hex: "#D97706").opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color(hex: "#F59E0B").opacity(0.15), radius: 12, y: 8)
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Quick Actions Grid (3x2)

    private var quickActionsGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                launcherCard(
                    title: "My PT Plan",
                    subtitle: "Build your week",
                    icon: "figure.strengthtraining.traditional",
                    gradient: [Color(hex: "#3B82F6"), Color(hex: "#2563EB")]
                ) {
                    toolTapTrigger.toggle()
                    showMyPTPlanSheet = true
                }

                launcherCard(
                    title: "WOD Plan",
                    subtitle: "CrossFit week",
                    icon: "bolt.heart.fill",
                    gradient: [Color(hex: "#F59E0B"), Color(hex: "#D97706")]
                ) {
                    toolTapTrigger.toggle()
                    showWODPlanSheet = true
                }

                launcherCard(
                    title: "Unit PT",
                    subtitle: "Team plan",
                    icon: "person.3.fill",
                    gradient: [Color(hex: "#2563EB"), Color(hex: "#1D4ED8")]
                ) {
                    toolTapTrigger.toggle()
                    showUnitPTSheet = true
                }
            }

            HStack(spacing: 10) {
                randomPTCard

                launcherCard(
                    title: "Scan QR",
                    subtitle: "Load shared",
                    icon: "qrcode.viewfinder",
                    gradient: [Color(hex: "#7C3AED"), Color(hex: "#6D28D9")]
                ) {
                    toolTapTrigger.toggle()
                    showScanSheet = true
                }

                launcherCard(
                    title: "Resources",
                    subtitle: "Army regs",
                    icon: "book.fill",
                    gradient: [Color(hex: "#059669"), Color(hex: "#047857")]
                ) {
                    toolTapTrigger.toggle()
                    showResources = true
                }
            }
        }
        .scaleEffect(animateHero ? 1 : 0.96)
        .opacity(animateHero ? 1 : 0)
    }

    private var randomPTCard: some View {
        Button {
            toolTapTrigger.toggle()
            randomWorkout = vm.generateRandomWorkout()
            showRandomSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "shuffle")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 9))

                    Spacer(minLength: 0)

                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                }

                Spacer(minLength: 0)

                Text("Random PT")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)

                Text("Surprise me")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 110)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#6366F1"), Color(hex: "#4F46E5")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func launcherCard(title: String, subtitle: String, icon: String, gradient: [Color], action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: icon)
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 9))

                Spacer(minLength: 0)

                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 110)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PressScaleButtonStyle())
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

    // MARK: - AFT Calculator Hero

    private var aftCalculatorHero: some View {
        Button {
            toolTapTrigger.toggle()
            showAFTCalculator = true
        } label: {
            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ACFT CALCULATOR")
                            .font(.caption.weight(.heavy))
                            .tracking(1.2)
                            .foregroundStyle(.white.opacity(0.7))

                        Text("Score Your\nFitness Test")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .lineSpacing(2)

                        Text("Full scoring with DA 705 export")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.white.opacity(0.55))
                    }

                    Spacer(minLength: 0)

                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 80, height: 80)
                        Circle()
                            .fill(.white.opacity(0.06))
                            .frame(width: 60, height: 60)
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                HStack(spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.caption.weight(.bold))
                        Text("Calculate Score")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(20)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#059669"),
                                    Color(hex: "#047857"),
                                    Color(hex: "#065F46")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.05), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color(hex: "#059669").opacity(0.25), radius: 24, y: 14)
        }
        .buttonStyle(PressScaleButtonStyle())
        .scaleEffect(animateHero ? 1 : 0.96)
        .opacity(animateHero ? 1 : 0)
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

    private func unitPTForDate(_ date: Date) -> [WorkoutDay] {
        vm.scheduledUnitPT.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func hasUnitPT(for date: Date) -> Bool {
        !unitPTForDate(date).isEmpty
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
