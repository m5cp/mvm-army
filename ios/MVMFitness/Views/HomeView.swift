import SwiftUI

struct HomeView: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(StoreViewModel.self) private var store
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("timeFormatPreference") private var timeFormatRaw: String = TimeFormatPreference.system.rawValue
    @State private var heroNow: Date = .now

    @State private var showUpgrade: Bool = false
    @State private var showUpgradeFromGate: Bool = false

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
    @State private var showQuickStartSheet: Bool = false
    @State private var showActiveQuickStart: Bool = false
    @State private var showSquadSheet: Bool = false
    @State private var quickStartVM: QuickStartViewModel = QuickStartViewModel()

    private let calendar = Calendar.current
    private let engine = AFTScoringEngine.shared
    @Namespace private var heroTransition

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                heroSection

                VStack(spacing: 24) {
                    readinessPlaque

                    ActivationChecklistCard(
                        onScoreAFT: {
                            toolTapTrigger.toggle()
                            showAFTCalculator = true
                        },
                        onStartWorkout: {
                            toolTapTrigger.toggle()
                            showQuickStartSheet = true
                        },
                        onShare: {
                            if let latestAFT = vm.aftScores.first {
                                ShareCardRenderer.presentShareSheet(cardType: .aft(score: latestAFT, previous: vm.previousAFTScore))
                            } else if let latestWorkout = vm.completedRecords.first {
                                ShareCardRenderer.presentShareSheet(cardType: .completedWorkout(record: latestWorkout))
                            } else {
                                toolTapTrigger.toggle()
                                showAFTCalculator = true
                            }
                        }
                    )

                    quickStartSection

                    todayWorkoutSection
                    todayFunctionalSection
                    planningSection
                    dailyActivitySection
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .coordinateSpace(name: "homeScroll")
        .hidesTabBarOnScroll()
        .background {
            ZStack {
                MVMTheme.screen.ignoresSafeArea()
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
                    if !store.isPremium {
                        Button {
                            showUpgrade = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.caption.weight(.bold))
                                Text("PRO")
                                    .font(.caption2.weight(.heavy))
                                    .tracking(0.5)
                            }
                            .foregroundStyle(MVMTheme.onAmber)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(MVMTheme.amberButtonGradient)
                            .clipShape(Capsule())
                        }
                    }

                    Button {
                        navigateToTrainingCalendar = true
                    } label: {
                        Image(systemName: "calendar")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                    .accessibilityLabel("Training Calendar")

                    Button {
                        toolTapTrigger.toggle()
                        showScanSheet = true
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                    .accessibilityLabel("Scan QR Code")

                    Menu {
                        // Never an empty menu — before a plan exists this button
                        // used to render zero items and felt broken.
                        Button {
                            toolTapTrigger.toggle()
                            vm.pedometer.refreshTodaySteps()
                            vm.syncTodaySteps()
                            vm.ensureTodayHasWorkout()
                            heroNow = .now
                        } label: {
                            Label("Refresh Today", systemImage: "arrow.clockwise")
                        }

                        if vm.currentPlan != nil {
                            Button {
                                vm.generateWeeklyPlan()
                            } label: {
                                Label("Regenerate Week", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
                            }
                            Button {
                                showCalendarSheet = true
                            } label: {
                                Label("Export to Calendar", systemImage: "calendar.badge.plus")
                            }
                        } else {
                            Button {
                                vm.generateWeeklyPlan()
                            } label: {
                                Label("Build Weekly Plan", systemImage: "calendar.badge.plus")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                    .accessibilityLabel("More Options")
                }
            }
        }
        .toolbarBackground(MVMTheme.screen, for: .navigationBar)
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
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
        }
        .sheet(isPresented: $showUpgradeFromGate) {
            UpgradeView()
        }
        .sheet(isPresented: $showSquadSheet) {
            SquadView()
        }
        .sheet(isPresented: $showWODSheet) {
            WODDetailView()
        }
        .sheet(isPresented: $showPTWorkoutSheet) {
            PTWODDetailView()
                .navigationTransition(.zoom(sourceID: "todayPT", in: heroTransition))
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
        .sheet(isPresented: $showQuickStartSheet) {
            QuickStartSelectionView(quickStart: quickStartVM)
        }
        .sheet(item: Binding<QuickStartRecord?>(
            get: { quickStartVM.completedRecord },
            // SwiftUI writes nil on interactive dismissal; swallowing it left
            // completedRecord set, so the sheet could re-present with stale state.
            set: { if $0 == nil { quickStartVM.dismiss() } }
        )) { record in
            QuickStartCompletionView(record: record) {
                quickStartVM.dismiss()
            }
        }
        .navigationDestination(isPresented: $showActiveQuickStart) {
            ActiveQuickStartView(quickStart: quickStartVM)
        }
        .onChange(of: quickStartVM.isActive) { _, isActive in
            if isActive {
                showActiveQuickStart = true
            }
        }
        .onChange(of: quickStartVM.showCompletion) { _, showCompletion in
            if showCompletion {
                showActiveQuickStart = false
            }
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                heroNow = .now
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

    // MARK: - Hero (13a / 13b)

    /// Alternates between the two screened hero photos day-to-day for variety.
    private var heroImageName: String {
        calendar.component(.day, from: .now).isMultiple(of: 2) ? "hero-runner-dusk" : "hero-rucker-night"
    }

    private var hasAFTRecord: Bool {
        !vm.aftScores.isEmpty
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Stretchy header: pulling down grows the photo instead of showing
            // dead space — the same feel as Apple's own headers.
            GeometryReader { geo in
                let minY = geo.frame(in: .named("homeScroll")).minY
                let stretch = max(0, minY)
                GradedPhoto(name: heroImageName, grade: .heroDuotone)
                    .frame(width: geo.size.width, height: geo.size.height + stretch)
                    .offset(y: -stretch)
            }
            .frame(height: hasAFTRecord ? 232 : 280)

            VStack(alignment: .leading, spacing: 6) {
                Text(dateLine)
                    .font(MVMTheme.mono(11))
                    .kerning(2)
                    .foregroundStyle(MVMTheme.amber)
                    .lineLimit(1)
                    .fixedSize()

                Text(hasAFTRecord ? "Me vs Me." : "Start here.")
                    .font(.system(size: 36, weight: .bold))
                    .tracking(-1.2)
                    .foregroundStyle(MVMTheme.text)

                Text(hasAFTRecord ? todaySubtitle : "Five events, one score. Log a test and everything after it compares back to today.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(MVMTheme.textMuted)
                    .frame(maxWidth: 300, alignment: .leading)
                    .lineLimit(2)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity)
        .opacity(animateHero ? 1 : 0)
    }

    private var timeFormatPreference: TimeFormatPreference {
        TimeFormatPreference(rawValue: timeFormatRaw) ?? .system
    }

    private var dateLine: String {
        HeroTimeFormat.dateLine(from: heroNow, preference: timeFormatPreference, separator: MVMTheme.dot)
    }

    private var todaySubtitle: String {
        let count = vm.todayCalendarEntryCount
        if count == 0 { return "No workouts scheduled today" }
        return "\(count) workout\(count == 1 ? "" : "s") today"
    }

    // MARK: - Readiness Plaque (latest AFT record — engine-derived only)

    @ViewBuilder
    private var readinessPlaque: some View {
        if let latest = vm.aftScores.first {
            readinessScoreCard(latest)
        } else {
            noScoreCard
        }
    }

    private func readinessScoreCard(_ latest: AFTScoreRecord) -> some View {
        RaisedCard(radius: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("READINESS")
                                .font(MVMTheme.mono(11))
                                .kerning(1.8)
                                .foregroundStyle(MVMTheme.textMuted)

                            HStack(alignment: .firstTextBaseline, spacing: 7) {
                                CountUpScoreText(value: latest.totalScore, font: MVMTheme.scoreDisplay(64))
                                    .foregroundStyle(MVMTheme.text)
                                    .lineLimit(1)
                                    .fixedSize()
                                Text("/ 500")
                                    .font(MVMTheme.mono(14))
                                    .foregroundStyle(MVMTheme.textFaint)
                                    .lineLimit(1)
                                    .fixedSize()
                            }

                            Text(marginLabel(for: latest))
                                .font(MVMTheme.mono(10))
                                .kerning(0.4)
                                .foregroundStyle(marginColor(for: latest))
                                .lineLimit(1)
                                .fixedSize()
                        }

                        Spacer(minLength: 8)

                        Image(systemName: passedOverall(latest) ? "checkmark.seal.fill" : "exclamationmark.seal.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(passedOverall(latest) ? MVMTheme.success : MVMTheme.warning)
                    }

                    HStack(spacing: 8) {
                        eventStatusChip(.mdl, latest.deadliftPoints, standard: latest.standard)
                        eventStatusChip(.hrp, latest.pushUpPoints, standard: latest.standard)
                        eventStatusChip(.sdc, latest.sdcPoints, standard: latest.standard)
                        eventStatusChip(.plk, latest.plankPoints, standard: latest.standard)
                        eventStatusChip(.run2mi, latest.runPoints, standard: latest.standard)
                    }
                    .accessibilityElement(children: .combine)
                }
                .padding(20)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Readiness, \(latest.totalScore) out of 500, \(passedOverall(latest) ? "go" : "no go"), \(marginLabel(for: latest))")
        }
        .opacity(animateHero ? 1 : 0)
        .offset(y: animateHero ? 0 : 8)
    }

    /// Whole card is one tap target — the Button wraps the RaisedCard so
    /// every point inside the plaque (photo, padding, spacer) opens the
    /// calculator, not just the wording.
    private var noScoreCard: some View {
        Button {
            toolTapTrigger.toggle()
            showAFTCalculator = true
        } label: {
            RaisedCard(radius: 24) {
                HStack(spacing: 14) {
                    CardPhotoThumb(name: "golden-runner-portrait", size: 52, radius: 26, grade: .goldenSilhouette)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("No AFT Score Yet")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(MVMTheme.text)
                        Text("Log a baseline test to start tracking readiness")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(MVMTheme.textMuted)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.textFaint)
                }
                .padding(20)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("Log your first AFT score")
        .opacity(animateHero ? 1 : 0)
        .offset(y: animateHero ? 0 : 8)
    }

    /// Every value below comes straight from `AFTScoringEngine` — no thresholds computed here.
    private func passedOverall(_ record: AFTScoreRecord) -> Bool {
        let minimum = engine.minimumTotal(for: record.standard)
        let eventsPassed = [record.deadliftPoints, record.pushUpPoints, record.sdcPoints, record.plankPoints, record.runPoints]
            .allSatisfy { $0 >= record.standard.minimumPerEvent }
        return eventsPassed && record.totalScore >= minimum
    }

    private func marginLabel(for record: AFTScoreRecord) -> String {
        let minimum = engine.minimumTotal(for: record.standard)
        let margin = record.totalScore - minimum
        return margin >= 0
            ? "+\(margin) OVER MINIMUM \(MVMTheme.dot) \(minimum) REQ"
            : "\(margin) BELOW MINIMUM \(MVMTheme.dot) \(minimum) REQ"
    }

    private func marginColor(for record: AFTScoreRecord) -> Color {
        let minimum = engine.minimumTotal(for: record.standard)
        return record.totalScore - minimum >= 0 ? MVMTheme.success : MVMTheme.danger
    }

    private func eventStatusChip(_ event: AFTEventType, _ points: Int, standard: AFTStandard) -> some View {
        VStack(spacing: 4) {
            Text(event.displayCode)
                .font(MVMTheme.mono(9, weight: .bold))
                .foregroundStyle(MVMTheme.textMuted)
                .lineLimit(1)
                .fixedSize()
            Text("\(points)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(points >= standard.minimumPerEvent ? MVMTheme.success : MVMTheme.danger)
                .lineLimit(1)
                .fixedSize()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(MVMTheme.well)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(event.fullName), \(points) points")
    }

    // MARK: - Today Workout Section — graded session card (lowKeyGym)

    private var todayWorkoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TODAY'S INDIVIDUAL PT")
                .font(MVMTheme.mono(11))
                .kerning(1.2)
                .foregroundStyle(MVMTheme.textFaint)
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
            RaisedCard(radius: 20) {
                ZStack(alignment: .bottomLeading) {
                    GradedPhoto(name: "lowkey-kettlebells", grade: .lowKeyGym)
                        .frame(height: 176)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: workoutIcon(for: workout))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(MVMTheme.onAmber)
                                .frame(width: 26, height: 26)
                                .background(MVMTheme.amber)
                                .clipShape(RoundedRectangle(cornerRadius: 7))

                            if workout.isCompleted {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption2)
                                    Text("DONE")
                                        .font(.caption2.weight(.heavy))
                                        .kerning(0.5)
                                }
                                .foregroundStyle(MVMTheme.success)
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "play.fill")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(MVMTheme.onAmber)
                                .frame(width: 34, height: 34)
                                .background(MVMTheme.amberButtonGradient)
                                .clipShape(Circle())
                        }

                        Text(workout.title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(MVMTheme.text)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 10) {
                            Label("\(workout.exercises.count) exercises", systemImage: "list.bullet")
                            Label(estimatedDuration(workout), systemImage: "clock")
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.textMuted)
                    }
                    .padding(16)
                }
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .matchedTransitionSource(id: "todayPT", in: heroTransition)
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
                    .foregroundStyle(MVMTheme.onAmber)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(MVMTheme.amberButtonGradient)
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
                    .background(MVMTheme.well)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.hairline)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())
            .accessibilityLabel("Share")

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
                    .background(MVMTheme.well)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.hairline)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())
            .accessibilityLabel("Save to Photos")

            Button {
                showTodayQRSheet = true
            } label: {
                Image(systemName: "qrcode")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(MVMTheme.well)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.hairline)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())
            .accessibilityLabel("QR Code")
        }
    }

    // MARK: - Today Functional Section

    private var todayFunctionalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TODAY'S FUNCTIONFITNESS")
                .font(MVMTheme.mono(11))
                .kerning(1.2)
                .foregroundStyle(MVMTheme.textFaint)
                .padding(.leading, 4)

            if let template = vm.todayFunctionalWOD {
                todayFunctionalCardSimple(template)
            } else {
                Button {
                    showFunctionalWODSheet = true
                } label: {
                    RaisedCard(radius: 16) {
                        HStack(spacing: 14) {
                            CardPhotoThumb(name: "corner-boxer", size: 44, radius: 12)

                            VStack(alignment: .leading, spacing: 3) {
                                Text("Generate FunctionFitness Workout")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(MVMTheme.text)
                                Text("Get a FunctionFitness session")
                                    .font(.caption)
                                    .foregroundStyle(MVMTheme.textFaint)
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(MVMTheme.textFaint)
                        }
                        .padding(16)
                    }
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
            RaisedCard(radius: 20) {
                HStack(spacing: 16) {
                    CardPhotoThumb(name: "kettlebell-swing", size: 56, radius: 14)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.heart.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(MVMTheme.onAmber)
                                .frame(width: 28, height: 28)
                                .background(MVMTheme.amber)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text("FUNCTIONFITNESS")
                                .font(.caption2.weight(.heavy))
                                .tracking(0.8)
                                .foregroundStyle(MVMTheme.textMuted)
                        }

                        Text(template.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(MVMTheme.text)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 8) {
                            Label("\(template.movements.count) movements", systemImage: "list.bullet")
                            Label("~\(template.durationMinutes) min", systemImage: "clock")
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.textMuted)
                    }

                    Spacer(minLength: 0)

                    VStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(MVMTheme.onAmber)
                            .frame(width: 48, height: 48)
                            .background(MVMTheme.amberButtonGradient)
                            .clipShape(Circle())

                        Text("View")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(MVMTheme.textFaint)
                    }
                }
                .padding(18)
            }
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
                .foregroundStyle(MVMTheme.onAmber)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(MVMTheme.amberButtonGradient)
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
                    .background(MVMTheme.well)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.hairline)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())
            .accessibilityLabel("Share")

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
                    .background(MVMTheme.well)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.hairline)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())
            .accessibilityLabel("Save to Photos")

            Button {
                showTodayQRSheet = true
            } label: {
                Image(systemName: "qrcode")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(MVMTheme.well)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.hairline)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())
            .accessibilityLabel("QR Code")
        }
    }

    private var todayEmptyCard: some View {
        Button {
            showMyPTPlanSheet = true
        } label: {
            RaisedCard(radius: 16) {
                HStack(spacing: 14) {
                    CardPhotoThumb(name: "golden-runner-wide", size: 44, radius: 12, grade: .goldenSilhouette)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("No Workout Scheduled")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.text)
                        Text("Create a plan to get started")
                            .font(.caption)
                            .foregroundStyle(MVMTheme.textFaint)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.textFaint)
                }
                .padding(16)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Quick Start Section

    private var quickStartSection: some View {
        Button {
            toolTapTrigger.toggle()
            showQuickStartSheet = true
        } label: {
            RaisedCard(radius: 16) {
                HStack(spacing: 14) {
                    CardPhotoThumb(name: "photo-run-silhouette-sunrise", size: 44, radius: 10, grade: .goldenSilhouette)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quick Start")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(MVMTheme.text)
                        Text("Run \(MVMTheme.dot) Bike \(MVMTheme.dot) Hike \(MVMTheme.dot) Fitness")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.textFaint)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "play.circle.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(MVMTheme.amber)
                }
                .padding(14)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("Quick Start an activity")
        .accessibilityHint("Choose from run, bike, hike or functional fitness")
        .opacity(animateHero ? 1 : 0)
        .offset(y: animateHero ? 0 : 8)
    }

    // MARK: - Planning Section

    private var planningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PLANNING")
                .font(MVMTheme.mono(11))
                .kerning(1.2)
                .foregroundStyle(MVMTheme.textFaint)
                .padding(.leading, 4)

            VStack(spacing: 10) {
                planRow(
                    title: "Plan My Individual PT",
                    subtitle: "Build your personal week",
                    photo: "ex-hex-deadlift"
                ) {
                    toolTapTrigger.toggle()
                    showMyPTPlanSheet = true
                }

                planRow(
                    title: "Plan My FunctionFitness",
                    subtitle: "FunctionFitness workouts",
                    photo: "ex-ab-rollout"
                ) {
                    toolTapTrigger.toggle()
                    showWODPlanSheet = true
                }

                planRow(
                    title: "Plan My Unit PT",
                    subtitle: "Formation-level sessions",
                    photo: "photo-ruck-man-coldbreath"
                ) {
                    toolTapTrigger.toggle()
                    if ProGate.isUnlocked(.unitPTBuilder, isPremium: store.isPremium, savedUnitPTPlanCount: vm.unitPTPlans.count) {
                        showUnitPTSheet = true
                    } else {
                        showUpgradeFromGate = true
                    }
                }

                planRow(
                    title: "My Squad",
                    subtitle: "Roster, test days & readiness",
                    photo: "photo-ruck-woman-rimlight"
                ) {
                    toolTapTrigger.toggle()
                    showSquadSheet = true
                }

            }
        }
        .scaleEffect(animateHero ? 1 : 0.96)
        .opacity(animateHero ? 1 : 0)
    }

    private func planRow(title: String, subtitle: String, photo: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            RaisedCard(radius: 14) {
                HStack(spacing: 14) {
                    CardPhotoThumb(name: photo, size: 40, radius: 10)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.text)
                        Text(subtitle)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.textFaint)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(MVMTheme.textFaint)
                }
                .padding(14)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Daily Activity Section

    private var dailyActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DAILY ACTIVITY")
                .font(MVMTheme.mono(11))
                .kerning(1.2)
                .foregroundStyle(MVMTheme.textFaint)
                .padding(.leading, 4)

            RaisedCard(radius: 20) {
                HStack(spacing: 0) {
                    MetricCell(label: "STEPS TODAY", value: formattedSteps, valueColor: MVMTheme.amber)
                    metricDivider
                    MetricCell(label: "THIS WEEK", value: "\(vm.weeklyCompletedCount)/\(vm.weeklyTotalDays)", valueColor: MVMTheme.success)
                    metricDivider
                    MetricCell(label: vm.streak == 1 ? "DAY STREAK" : "DAYS STREAK", value: "\(vm.streak)", valueColor: MVMTheme.warning)
                }
                .padding(.vertical, 8)
            }
        }
        .opacity(animateMetrics ? 1 : 0)
        .offset(y: animateMetrics ? 0 : 12)
    }

    private var metricDivider: some View {
        Rectangle()
            .fill(MVMTheme.hairline)
            .frame(width: 1, height: 32)
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

// MARK: - Count-up score text

/// Animates a score counting up from 0 the first time it appears (and rolls
/// smoothly whenever the value changes) using the numeric-text transition.
struct CountUpScoreText: View {
    let value: Int
    let font: Font
    @State private var shown: Int = 0

    var body: some View {
        Text("\(shown)")
            .font(font)
            .contentTransition(.numericText(value: Double(shown)))
            .onAppear {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.9)) {
                    shown = value
                }
            }
            .onChange(of: value) { _, newValue in
                withAnimation(.spring(response: 0.7, dampingFraction: 0.9)) {
                    shown = newValue
                }
            }
    }
}
