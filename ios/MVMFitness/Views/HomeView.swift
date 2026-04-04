import SwiftUI

struct HomeView: View {
    @Environment(AppViewModel.self) private var vm


    @State private var animateHero: Bool = false
    @State private var animateMetrics: Bool = false
    @State private var showWODSheet: Bool = false
    @State private var showWODPlanSheet: Bool = false
    @State private var showWorkoutDetail: Bool = false
    @State private var showActiveSession: Bool = false
    @State private var showUnitPTSheet: Bool = false
    @State private var showMyPTPlanSheet: Bool = false
    @State private var showScanSheet: Bool = false
    @State private var showAFTCalculator: Bool = false
    @State private var showRecoveryDetail: Bool = false
    @State private var showEditSheet: Bool = false
    @State private var showCalendarSheet: Bool = false
    @State private var showExportAlert: Bool = false
    @State private var exportAlertMessage: String = ""
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
    @State private var showPTWorkoutSheet: Bool = false
    @State private var navigateToCalendarDay: Bool = false
    @State private var calendarDayDate: Date = .now
    @State private var navigateToTrainingCalendar: Bool = false
    @State private var showTodayShareSheet: Bool = false
    @State private var showTodayQRSheet: Bool = false
    @State private var showTodaySavedToast: Bool = false
    @State private var todayCompleteTrigger: Bool = false
    @State private var showFunctionalWODSheet: Bool = false

    private let calendar = Calendar.current

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    greetingHeader

                    aftCalculatorHero

                    todayWorkoutSection
                    todayFunctionalSection
                    planningSection
                    dailyActivitySection
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
                Text("MVM FITNESS")
                    .font(.caption.weight(.heavy))
                    .tracking(2.4)
                    .foregroundStyle(MVMTheme.secondaryText)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        navigateToTrainingCalendar = true
                    } label: {
                        Image(systemName: "calendar")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }

                    Button {
                        toolTapTrigger.toggle()
                        showScanSheet = true
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }

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
        .navigationDestination(isPresented: $navigateToTrainingCalendar) {
            TrainingCalendarView()
        }
        .sheet(isPresented: $showWODSheet) {
            WODDetailView()
        }
        .sheet(isPresented: $showPTWorkoutSheet) {
            PTWODDetailView()
        }
        .sheet(isPresented: $showWODPlanSheet) {
            WODPlanSheet()
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
        .sheet(isPresented: $showFunctionalWODSheet) {
            if let template = vm.todayFunctionalWOD {
                WODDetailView(template: template)
            } else {
                WODDetailView()
            }
        }
        .sheet(isPresented: $showTodayShareSheet) {
            if let today = vm.todayWorkout {
                PTWODShareSheet(workout: today)
            }
        }
        .sheet(isPresented: $showTodayQRSheet) {
            if let today = vm.todayWorkout {
                WorkoutQRSheet(workout: today, workoutType: "Individual PT")
            } else if let template = vm.todayFunctionalWOD {
                let workout = WODService.convertToWorkoutDay(template)
                WorkoutQRSheet(workout: workout, workoutType: "FunctionFitness")
            }
        }
        .overlay {
            if showTodaySavedToast {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(MVMTheme.success)
                        Text("Saved to Photos")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showTodaySavedToast)
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
                        colors: [MVMTheme.brandGreen.opacity(0.1), .clear],
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
                        colors: [MVMTheme.slateAccent.opacity(0.04), .clear],
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

            Text(todaySubtitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(animateHero ? 1 : 0)
        .offset(y: animateHero ? 0 : 8)
    }

    private var todaySubtitle: String {
        let count = vm.todayCalendarEntryCount
        if count == 0 { return "No workouts scheduled today" }
        return "\(count) workout\(count == 1 ? "" : "s") today"
    }

    // MARK: - AFT Calculator Hero (PRIORITY 1)

    private var aftCalculatorHero: some View {
        Button {
            toolTapTrigger.toggle()
            showAFTCalculator = true
        } label: {
            VStack(spacing: 18) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AFT CALCULATOR")
                            .font(.caption.weight(.heavy))
                            .tracking(1.4)
                            .foregroundStyle(.white.opacity(0.7))

                        Text("Score Your\nFitness Test")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .lineSpacing(2)

                        Text("Fast scoring for graders and test takers")
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


            }
            .padding(22)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(MVMTheme.aftGradient)
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.04), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: MVMTheme.brandGreen.opacity(0.3), radius: 24, y: 14)
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("AFT Calculator")
        .accessibilityHint("Open the Army Fitness Test score calculator")
        .scaleEffect(animateHero ? 1 : 0.96)
        .opacity(animateHero ? 1 : 0)
    }

    // MARK: - Today Workout Section (PRIORITY 2)

    private var todayWorkoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TODAY'S INDIVIDUAL PT")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            if let today = vm.todayWorkout, !today.isRestDay {
                todayWorkoutCard(today)
            } else {
                todayEmptyCard
            }
        }
        .opacity(animateHero ? 1 : 0)
        .offset(y: animateHero ? 0 : 8)
    }

    private func todayWorkoutCard(_ workout: WorkoutDay) -> some View {
        Button {
            startWorkoutTrigger.toggle()
            showPTWorkoutSheet = true
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: workoutIcon(for: workout))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        if workout.isCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)
                                Text("DONE")
                                    .font(.caption2.weight(.heavy))
                                    .tracking(0.5)
                            }
                            .foregroundStyle(MVMTheme.success)
                        }
                    }

                    Text(workout.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        Label("\(workout.exercises.count) exercises", systemImage: "list.bullet")
                        Label(estimatedDuration(workout), systemImage: "clock")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
                }

                Spacer(minLength: 0)

                VStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(.white.opacity(0.15))
                        .clipShape(Circle())

                    Text("Start")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(18)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(MVMTheme.ptGradient)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color(hex: "#2E5A7C").opacity(0.2), radius: 16, y: 10)
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("Today's Individual PT: \(workout.title), \(workout.exercises.count) exercises")
        .accessibilityHint("Tap to view workout details")
    }

    private func todayWorkoutActions(_ workout: WorkoutDay) -> some View {
        HStack(spacing: 8) {
            if !workout.isCompleted {
                Button {
                    todayCompleteTrigger.toggle()
                    vm.markDayCompleted(dayIndex: workout.dayIndex)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption.weight(.bold))
                        Text("Log Complete")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .sensoryFeedback(.success, trigger: todayCompleteTrigger)
                .buttonStyle(PressScaleButtonStyle())
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                    Text("Logged")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(MVMTheme.success)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(MVMTheme.success.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(MVMTheme.success.opacity(0.3))
                }
            }

            Button {
                ShareCardRenderer.presentShareSheet(
                    cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                )
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.border)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                let saved = ShareCardRenderer.saveToPhotos(
                    cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                )
                if saved {
                    showTodaySavedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showTodaySavedToast = false
                    }
                }
            } label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.border)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                showTodayQRSheet = true
            } label: {
                Image(systemName: "qrcode")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.border)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    // MARK: - Today Functional Section

    private var todayFunctionalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TODAY'S FUNCTIONFITNESS")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            if let template = vm.todayFunctionalWOD {
                todayFunctionalCardSimple(template)
            } else {
                Button {
                    showFunctionalWODSheet = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "bolt.heart.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(MVMTheme.heroAmber)
                            .frame(width: 44, height: 44)
                            .background(MVMTheme.heroAmber.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Generate FunctionFitness Workout")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(MVMTheme.primaryText)
                            Text("Get a FunctionFitness session")
                                .font(.caption)
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                    .padding(16)
                    .premiumCard()
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .opacity(animateHero ? 1 : 0)
        .offset(y: animateHero ? 0 : 8)
    }

    private func todayFunctionalCardSimple(_ template: WODTemplate) -> some View {
        return Button {
            showFunctionalWODSheet = true
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.heart.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text("FUNCTIONFITNESS")
                            .font(.caption2.weight(.heavy))
                            .tracking(0.8)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Text(template.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        Label("\(template.movements.count) movements", systemImage: "list.bullet")
                        Label("~\(template.durationMinutes) min", systemImage: "clock")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
                }

                Spacer(minLength: 0)

                VStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(.white.opacity(0.15))
                        .clipShape(Circle())

                    Text("View")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(18)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706").opacity(0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color(hex: "#F59E0B").opacity(0.2), radius: 16, y: 10)
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("Today's FunctionFitness: \(template.title), \(template.movements.count) movements")
        .accessibilityHint("Tap to view workout details")
    }

    private func todayFunctionalActions(_ template: WODTemplate) -> some View {
        let workout = WODService.convertToWorkoutDay(template)

        return HStack(spacing: 8) {
            Button {
                todayCompleteTrigger.toggle()
                var wodWorkout = workout
                wodWorkout.source = .wod
                vm.completeStandaloneWorkout(wodWorkout)
                completedWorkoutTitle = workout.title
                completedExerciseCount = workout.exercises.count
                showCompletionShare = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                    Text("Log Complete")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .sensoryFeedback(.success, trigger: todayCompleteTrigger)
            .buttonStyle(PressScaleButtonStyle())

            Button {
                ShareCardRenderer.presentShareSheet(
                    cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                )
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.border)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                let saved = ShareCardRenderer.saveToPhotos(
                    cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                )
                if saved {
                    showTodaySavedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showTodaySavedToast = false
                    }
                }
            } label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.border)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                showTodayQRSheet = true
            } label: {
                Image(systemName: "qrcode")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.border)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    private var todayEmptyCard: some View {
        Button {
            showMyPTPlanSheet = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "calendar.badge.plus")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 44, height: 44)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text("No Workout Scheduled")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Create a plan to get started")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .padding(16)
            .premiumCard()
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Planning Section (PRIORITY 3)

    private var planningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PLANNING")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                planRow(
                    title: "Plan My Individual PT",
                    subtitle: "Build your personal week",
                    icon: "figure.strengthtraining.traditional",
                    color: MVMTheme.slateAccent
                ) {
                    toolTapTrigger.toggle()
                    showMyPTPlanSheet = true
                }

                planRow(
                    title: "Plan My FunctionFitness",
                    subtitle: "FunctionFitness workouts",
                    icon: "bolt.heart.fill",
                    color: MVMTheme.heroAmber
                ) {
                    toolTapTrigger.toggle()
                    showWODPlanSheet = true
                }

                planRow(
                    title: "Plan My Unit PT",
                    subtitle: "Formation-level sessions",
                    icon: "person.3.fill",
                    color: MVMTheme.accent
                ) {
                    toolTapTrigger.toggle()
                    showUnitPTSheet = true
                }
            }
        }
        .scaleEffect(animateHero ? 1 : 0.96)
        .opacity(animateHero ? 1 : 0)
    }

    private func planRow(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text(subtitle)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .padding(14)
            .background(MVMTheme.card)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(MVMTheme.border)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Daily Activity Section (PRIORITY 4)

    private var dailyActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DAILY ACTIVITY")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            HStack(spacing: 0) {
                metricPill(
                    icon: "figure.walk",
                    value: formattedSteps,
                    label: "Steps Today",
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
        }
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
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
                        .background(MVMTheme.heroGradient)
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
        if hour < 12 { return "Good morning" }
        if hour < 17 { return "Drive on" }
        return "Good evening"
    }

    private var formattedSteps: String {
        let steps = vm.pedometer.todaySteps
        if steps >= 1000 { return String(format: "%.1fk", Double(steps) / 1000) }
        return "\(steps)"
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
            exportAlertMessage = "Calendar access denied. Go to Settings → MVM Fitness → Calendars to enable."
        case .error(let message):
            exportAlertMessage = "Export failed: \(message)"
        }
        showExportAlert = true
    }
}
