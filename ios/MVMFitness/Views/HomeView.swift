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
                    greetingHeader
                    workoutLaunchers
                    metricsStrip
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

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greetingText)
                .font(.title2.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text("What's the move?")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(animateHero ? 1 : 0)
        .offset(y: animateHero ? 0 : 8)
    }

    private var selectedDayWorkout: WorkoutDay? {
        guard let plan = vm.currentPlan else { return nil }
        return plan.days.first { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }

    // MARK: - Workout Launchers

    private var workoutLaunchers: some View {
        VStack(spacing: 12) {
            todayPlanLauncher

            HStack(spacing: 10) {
                launcherCard(
                    title: "WOD",
                    subtitle: "Workout of the Day",
                    icon: "bolt.fill",
                    gradient: [Color(hex: "#F59E0B"), Color(hex: "#D97706")]
                ) {
                    toolTapTrigger.toggle()
                    showWODSheet = true
                }

                launcherCard(
                    title: "Random",
                    subtitle: "Surprise me",
                    icon: "shuffle",
                    gradient: [Color(hex: "#6366F1"), Color(hex: "#4F46E5")]
                ) {
                    toolTapTrigger.toggle()
                    randomWorkout = vm.generateRandomWorkout()
                    showRandomSheet = true
                }
            }

            HStack(spacing: 10) {
                launcherCard(
                    title: "Unit PT",
                    subtitle: "Build for your team",
                    icon: "person.3.fill",
                    gradient: [Color(hex: "#2563EB"), Color(hex: "#1D4ED8")]
                ) {
                    toolTapTrigger.toggle()
                    showUnitPTSheet = true
                }

                launcherCard(
                    title: "Scan QR",
                    subtitle: "Load shared PT",
                    icon: "qrcode.viewfinder",
                    gradient: [Color(hex: "#7C3AED"), Color(hex: "#6D28D9")]
                ) {
                    toolTapTrigger.toggle()
                    showScanSheet = true
                }
            }
        }
        .scaleEffect(animateHero ? 1 : 0.96)
        .opacity(animateHero ? 1 : 0)
    }

    @ViewBuilder
    private var todayPlanLauncher: some View {
        if let selectedDay = selectedDayWorkout {
            if selectedDay.isCompleted {
                completedPlanCard(selectedDay)
            } else if selectedDay.isRestDay {
                recoveryPlanCard(selectedDay)
            } else {
                activePlanCard(selectedDay)
            }
        } else {
            buildPlanCard
        }
    }

    private func activePlanCard(_ workout: WorkoutDay) -> some View {
        Button {
            startWorkoutTrigger.toggle()
            if calendar.isDateInToday(workout.date) {
                showActiveSession = true
            } else {
                planSessionDayIndex = workout.dayIndex
                navigateToPlanSession = true
            }
        } label: {
            HStack(spacing: 16) {
                VStack(spacing: 6) {
                    Image(systemName: "figure.run")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Image(systemName: "play.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(width: 52, height: 52)
                .background(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(heroLabel(for: workout).uppercased())
                        .font(.caption2.weight(.heavy))
                        .tracking(0.8)
                        .foregroundStyle(.white.opacity(0.7))

                    Text(workout.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    HStack(spacing: 10) {
                        Label("\(workout.exercises.count)", systemImage: "list.bullet")
                        Label(estimatedDuration(workout), systemImage: "clock")
                        if let tag = workout.tags.first {
                            Text(tag)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.white.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(18)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(heroCardGradient)
                    heroShimmerOverlay
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: MVMTheme.accent.opacity(0.2), radius: 20, y: 12)
        }
        .buttonStyle(PressScaleButtonStyle())
        .contextMenu {
            Button {
                if calendar.isDateInToday(workout.date) {
                    showWorkoutDetail = true
                } else {
                    planDetailDayIndex = workout.dayIndex
                    navigateToPlanDetail = true
                }
            } label: {
                Label("View Details", systemImage: "eye")
            }

            Button {
                completeWorkoutTrigger.toggle()
                vm.markDayCompleted(dayIndex: workout.dayIndex)
            } label: {
                Label("Mark Complete", systemImage: "checkmark.circle")
            }

            Button {
                shareItems = ShareCardRenderer.shareItems(
                    cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                )
                showShareSheet = true
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
    }

    private func completedPlanCard(_ workout: WorkoutDay) -> some View {
        Button {
            if calendar.isDateInToday(workout.date) {
                showWorkoutDetail = true
            } else {
                planDetailDayIndex = workout.dayIndex
                navigateToPlanDetail = true
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.white.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text("MISSION COMPLETE")
                        .font(.caption2.weight(.heavy))
                        .tracking(0.8)
                        .foregroundStyle(.white.opacity(0.7))

                    Text(workout.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text("\(workout.exercises.count) exercises done")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(18)
            .background {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#059669"), Color(hex: "#10B981").opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: Color(hex: "#059669").opacity(0.15), radius: 16, y: 10)
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func recoveryPlanCard(_ day: WorkoutDay) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text("RECOVERY DAY")
                    .font(.caption2.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.7))

                Text("Rest & Mobility")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                Button {
                    let session = vm.generateRecoverySession()
                    recoverySession = session
                    showRecoveryDetail = true
                } label: {
                    Text("Start")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(hex: "#1A1A2E"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    vm.replaceRestDayWithWorkout(dayIndex: day.dayIndex)
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(18)
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
        .shadow(color: Color(hex: "#1E3A5F").opacity(0.15), radius: 16, y: 10)
    }

    private var buildPlanCard: some View {
        Button {
            vm.generateWeeklyPlan()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "calendar.badge.plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text("MY PLAN")
                        .font(.caption2.weight(.heavy))
                        .tracking(0.8)
                        .foregroundStyle(.white.opacity(0.7))

                    Text("Build Your Week")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Generate a personalized PT plan")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer(minLength: 0)

                Image(systemName: "plus")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(18)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(heroCardGradient)
                    heroShimmerOverlay
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: MVMTheme.accent.opacity(0.2), radius: 20, y: 12)
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func launcherCard(title: String, subtitle: String, icon: String, gradient: [Color], action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 11))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func heroLabel(for workout: WorkoutDay) -> String {
        if calendar.isDateInToday(workout.date) { return "Today's PT" }
        if calendar.isDateInTomorrow(workout.date) { return "Tomorrow's PT" }
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return "\(f.string(from: workout.date))'s PT"
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

                    ForEach(unitPTForDate(day.date), id: \.id) { unitDay in
                        unitPTRow(unitDay)
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


    private func unitPTRow(_ day: WorkoutDay) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "person.3.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(hex: "#2563EB"))
                .frame(width: 36, height: 36)
                .background(Color(hex: "#2563EB").opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(day.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(day.isCompleted ? MVMTheme.secondaryText : MVMTheme.primaryText)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text("Unit PT")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color(hex: "#2563EB"))

                    if let start = day.startTime {
                        Text(start.formatted(date: .omitted, time: .shortened))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
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
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .frame(width: 32, height: 32)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(hex: "#2563EB").opacity(0.04))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#2563EB").opacity(0.15))
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
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
