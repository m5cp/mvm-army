import SwiftUI

struct HomeView: View {
    @Environment(AppViewModel.self) private var vm

    @AppStorage("trainingFocus") private var trainingFocusRaw = TrainingFocus.generalArmyFitness.rawValue
    @AppStorage("ptMode") private var ptModeRaw = PTMode.both.rawValue
    @AppStorage("dutyType") private var dutyTypeRaw = DutyType.both.rawValue

    @State private var animateHero = false
    @State private var showWODSheet = false
    @State private var showRandomSheet = false
    @State private var showWorkoutDetail = false
    @State private var showUnitPTSheet = false
    @State private var showScanSheet = false
    @State private var showAFTSheet = false
    @State private var showAFTCalculator = false
    @State private var showEditSheet = false
    @State private var wodWorkout: WorkoutDay?
    @State private var randomWorkout: WorkoutDay?

    private let mottos = [
        "You vs You.",
        "Execute.",
        "Train for the standard.",
        "Consistency wins.",
        "Show up. Do the work.",
        "Simple plans get executed.",
        "The only competition is yesterday."
    ]

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    missionHeader
                    missionHeroCard
                    weeklyProgressStrip
                    toolsSection
                    mottoCard
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("MVM Army")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)
            }
        }
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $showWorkoutDetail) {
            if let today = vm.todayWorkout {
                WorkoutDetailView(dayIndex: today.dayIndex, isStandalone: false)
            } else if let recovery = recoveryWorkout {
                WorkoutDetailView(dayIndex: recovery.dayIndex, isStandalone: false)
            }
        }
        .sheet(isPresented: $showWODSheet) {
            if let workout = wodWorkout {
                StandaloneWorkoutSheet(workout: workout, sheetTitle: "Workout of the Day")
            }
        }
        .sheet(isPresented: $showRandomSheet) {
            if let workout = randomWorkout {
                StandaloneWorkoutSheet(workout: workout, sheetTitle: "Random Workout")
            }
        }
        .sheet(isPresented: $showUnitPTSheet) {
            UnitPTBuilderSheet()
        }
        .sheet(isPresented: $showScanSheet) {
            QRScannerSheet()
        }
        .sheet(isPresented: $showAFTSheet) {
            AFTScoreSheet()
        }
        .navigationDestination(isPresented: $showAFTCalculator) {
            AFTCalculatorView()
        }
        .onAppear {
            vm.pedometer.refreshTodaySteps()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                vm.syncTodaySteps()
            }
            if vm.currentPlan == nil {
                vm.generateWeeklyPlan()
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                animateHero = true
            }
        }
    }

    // MARK: - Mission Header

    private var missionHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greetingText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.secondaryText)

                Text("Today's Mission")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(MVMTheme.primaryText)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(MVMTheme.cardSoft)
                    .frame(width: 48, height: 48)

                Image(systemName: "shield.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
            }
        }
    }

    // MARK: - Mission Hero Card

    private var missionHeroCard: some View {
        Group {
            if let today = vm.todayWorkout {
                activeWorkoutHero(today)
            } else {
                noWorkoutHero
            }
        }
        .scaleEffect(animateHero ? 1 : 0.97)
        .opacity(animateHero ? 1 : 0.85)
    }

    private func activeWorkoutHero(_ workout: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(workout.isCompleted ? completedGradient : MVMTheme.heroGradient)

                RoundedRectangle(cornerRadius: 28)
                    .fill(MVMTheme.subtleGradient)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        if workout.isCompleted {
                            Label("Mission Complete", systemImage: "checkmark.seal.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                        } else {
                            Label("Ready to Execute", systemImage: "bolt.heart.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white.opacity(0.9))
                        }

                        Spacer()

                        if !workout.tags.isEmpty {
                            Text(workout.tags.first ?? "")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.14))
                                .clipShape(Capsule())
                        }
                    }

                    Text(workout.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    HStack(spacing: 16) {
                        Label("\(workout.exercises.count) exercises", systemImage: "list.bullet")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.85))

                        if workout.completedExerciseCount > 0 && !workout.isCompleted {
                            Label("\(workout.completedExerciseCount)/\(workout.exercises.count)", systemImage: "checkmark.circle")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }

                    exercisePreview(workout)

                    if workout.isCompleted {
                        Button {
                            showWorkoutDetail = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "eye")
                                Text("Review Workout")
                            }
                            .font(.headline)
                            .foregroundStyle(MVMTheme.accent)
                            .frame(height: 52)
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PressScaleButtonStyle())
                    } else {
                        Button {
                            showWorkoutDetail = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                Text("Start Workout")
                            }
                            .font(.headline.weight(.bold))
                            .foregroundStyle(MVMTheme.accent)
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PressScaleButtonStyle())
                    }
                }
                .padding(22)
            }
            .shadow(color: MVMTheme.accent.opacity(0.2), radius: 24, y: 16)

            if !workout.isCompleted {
                heroSecondaryActions(workout)
            }
        }
    }

    private func exercisePreview(_ workout: WorkoutDay) -> some View {
        VStack(spacing: 8) {
            ForEach(workout.exercises.prefix(3)) { exercise in
                HStack(spacing: 10) {
                    Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(exercise.isCompleted ? .white : .white.opacity(0.5))

                    Text(exercise.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(exercise.isCompleted ? .white.opacity(0.6) : .white.opacity(0.9))
                        .strikethrough(exercise.isCompleted, color: .white.opacity(0.4))
                        .lineLimit(1)

                    Spacer()

                    Text(exercise.displayDetail)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }
            }

            if workout.exercises.count > 3 {
                HStack {
                    Text("+\(workout.exercises.count - 3) more")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func heroSecondaryActions(_ workout: WorkoutDay) -> some View {
        HStack(spacing: 10) {
            Button {
                vm.markDayCompleted(dayIndex: workout.dayIndex)
            } label: {
                Label("Complete", systemImage: "checkmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.success)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(MVMTheme.success.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                showWorkoutDetail = true
            } label: {
                Label("Edit", systemImage: "pencil")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                vm.generateWeeklyPlan()
            } label: {
                Label("New", systemImage: "arrow.clockwise")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(.top, 10)
    }

    private var noWorkoutHero: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(MVMTheme.heroGradient.opacity(0.7))

                RoundedRectangle(cornerRadius: 28)
                    .fill(MVMTheme.subtleGradient)

                VStack(alignment: .leading, spacing: 16) {
                    Label("Recovery Day", systemImage: "leaf.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.9))

                    Text("Active Recovery")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Text("No session planned. Stay loose, stay ready.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))

                    HStack(spacing: 12) {
                        Button {
                            wodWorkout = vm.generateWorkoutOfDay()
                            showWODSheet = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "bolt.fill")
                                Text("Quick Workout")
                            }
                            .font(.headline.weight(.bold))
                            .foregroundStyle(MVMTheme.accent)
                            .frame(height: 52)
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PressScaleButtonStyle())

                        Button {
                            vm.generateWeeklyPlan()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar.badge.plus")
                                Text("Build Plan")
                            }
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(height: 52)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PressScaleButtonStyle())
                    }
                }
                .padding(22)
            }
            .shadow(color: MVMTheme.accent.opacity(0.14), radius: 24, y: 16)
        }
    }

    // MARK: - Weekly Progress Strip

    private var weeklyProgressStrip: some View {
        HStack(spacing: 0) {
            stripMetric(
                icon: "flame.fill",
                value: "\(vm.streak)",
                label: "Streak",
                color: MVMTheme.warning
            )

            stripDivider

            stripMetric(
                icon: "figure.walk",
                value: formattedSteps,
                label: "Steps",
                color: MVMTheme.accent
            )

            stripDivider

            stripMetric(
                icon: "checkmark.circle.fill",
                value: "\(vm.weeklyCompletedCount)/\(vm.weeklyTotalDays)",
                label: "This Week",
                color: MVMTheme.success
            )

            stripDivider

            stripMetric(
                icon: "trophy.fill",
                value: "\(vm.totalWorkoutsCompleted)",
                label: "Total",
                color: MVMTheme.accent2
            )
        }
        .padding(.vertical, 16)
        .premiumCard()
    }

    private var stripDivider: some View {
        Rectangle()
            .fill(MVMTheme.border)
            .frame(width: 1, height: 36)
    }

    private func stripMetric(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(color)
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .contentTransition(.numericText())
            }
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tools Section

    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("TOOLS")
                .font(.caption.weight(.bold))
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                toolTile(
                    title: "AFT Calculator",
                    icon: "shield.checkered",
                    color: Color(hex: "#059669")
                ) { showAFTCalculator = true }

                toolTile(
                    title: "Quick AFT Log",
                    icon: "shield.fill",
                    color: Color(hex: "#047857")
                ) { showAFTSheet = true }

                toolTile(
                    title: "Workout of the Day",
                    icon: "star.fill",
                    color: MVMTheme.accent
                ) {
                    wodWorkout = vm.generateWorkoutOfDay()
                    showWODSheet = true
                }

                toolTile(
                    title: "Random Workout",
                    icon: "shuffle",
                    color: Color(hex: "#6366F1")
                ) {
                    randomWorkout = vm.generateRandomWorkout()
                    showRandomSheet = true
                }

                toolTile(
                    title: "Build Unit PT",
                    icon: "person.3.fill",
                    color: Color(hex: "#2563EB")
                ) { showUnitPTSheet = true }

                toolTile(
                    title: "Scan PT Plan",
                    icon: "qrcode.viewfinder",
                    color: Color(hex: "#7C3AED")
                ) { showScanSheet = true }
            }

            if let score = vm.latestAFTScore {
                aftScoreBanner(score)
            }
        }
    }

    private func toolTile(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.14))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.body.weight(.bold))
                        .foregroundStyle(color)
                }

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .premiumCardStyle()
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func aftScoreBanner(_ score: AFTScoreRecord) -> some View {
        Button {
            showAFTCalculator = true
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latest AFT")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.secondaryText)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(score.totalScore)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(MVMTheme.primaryText)
                            .contentTransition(.numericText())
                        Text("/ 500")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    aftMiniPill("MDL", score.deadliftPoints)
                    aftMiniPill("HRP", score.pushUpPoints)
                    aftMiniPill("SDC", score.sdcPoints)
                    aftMiniPill("PLK", score.plankPoints)
                    aftMiniPill("2MR", score.runPoints)
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .padding(16)
            .premiumCardStyle()
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Motto

    private var mottoCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.fill")
                .font(.title3)
                .foregroundStyle(MVMTheme.accent.opacity(0.6))

            Text(mottos[Calendar.current.component(.hour, from: .now) % mottos.count])
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)

            Spacer()
        }
        .padding(16)
        .premiumCard()
    }

    // MARK: - Helpers

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: .now)
        if hour < 5 { return "Late night grind" }
        if hour < 10 { return "Good morning, soldier" }
        if hour < 14 { return "Drive on" }
        if hour < 18 { return "Afternoon push" }
        return "Evening session"
    }

    private var formattedSteps: String {
        let steps = vm.pedometer.todaySteps
        if steps >= 10000 { return String(format: "%.1fk", Double(steps) / 1000) }
        if steps >= 1000 { return String(format: "%.1fk", Double(steps) / 1000) }
        return "\(steps)"
    }

    private var recoveryWorkout: WorkoutDay? {
        guard let plan = vm.currentPlan else { return nil }
        let today = Calendar.current.startOfDay(for: .now)
        return plan.days.first { Calendar.current.isDate($0.date, inSameDayAs: today) && $0.isRestDay }
    }

    private var completedGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#059669").opacity(0.9), Color(hex: "#10B981").opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func aftMiniPill(_ label: String, _ value: Int) -> some View {
        VStack(spacing: 1) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(MVMTheme.tertiaryText)
            Text("\(value)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(aftPillColor(value))
        }
        .frame(width: 32)
    }

    private func aftPillColor(_ value: Int) -> Color {
        if value >= 80 { return MVMTheme.success }
        if value >= 60 { return MVMTheme.accent }
        if value >= 40 { return MVMTheme.warning }
        return MVMTheme.danger
    }
}
