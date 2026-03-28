import SwiftUI

struct HomeView: View {
    @Environment(AppViewModel.self) private var vm

    @AppStorage("trainingGoal") private var trainingGoalRaw = TrainingGoal.generalFitness.rawValue

    @State private var animateHero = false
    @State private var showWODSheet = false
    @State private var showRandomSheet = false
    @State private var showWorkoutDetail = false
    @State private var wodWorkout: WorkoutDay?
    @State private var randomWorkout: WorkoutDay?

    private let tips = [
        "The only competition is yesterday.",
        "Simple plans get executed.",
        "Consistency compounds faster than motivation.",
        "Show up. Do the work. Repeat.",
        "Progress is built in weeks, not days."
    ]

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    topHeader
                    heroCard
                    todayWorkoutCard
                    quickActions
                    tipCard
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("MVM Fitness")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)
            }
        }
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $showWorkoutDetail) {
            if let today = vm.todayWorkout {
                WorkoutDetailView(dayIndex: today.dayIndex, isStandalone: false)
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

    private var topHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Me vs Me")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)

                Text("Plan. Train. Repeat.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(MVMTheme.primaryText)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(MVMTheme.cardSoft)
                    .frame(width: 48, height: 48)

                Image(systemName: "figure.run")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
            }
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 28)
                .fill(MVMTheme.heroGradient)

            RoundedRectangle(cornerRadius: 28)
                .fill(MVMTheme.subtleGradient)

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("This Week")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.78))

                        Text("\(vm.weeklyCompletedCount)/\(vm.weeklyTotalDays)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        Text(trainingGoalRaw)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.14))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 12) {
                    heroMetric(title: "Steps", value: "\(vm.pedometer.todaySteps)")
                    heroMetric(title: "Streak", value: "\(vm.streak)")
                    heroMetric(title: "Total", value: "\(vm.totalWorkoutsCompleted)")
                }
            }
            .padding(22)
        }
        .frame(height: 230)
        .scaleEffect(animateHero ? 1 : 0.97)
        .opacity(animateHero ? 1 : 0.85)
        .shadow(color: MVMTheme.accent.opacity(0.18), radius: 24, y: 16)
    }

    private var todayWorkoutCard: some View {
        Group {
            if let today = vm.todayWorkout {
                VStack(alignment: .leading, spacing: 14) {
                    sectionLabel(title: "Today's Workout", icon: "bolt.heart")

                    Text(today.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)

                    HStack(spacing: 16) {
                        Label("\(today.exercises.count) exercises", systemImage: "list.bullet")
                            .font(.subheadline)
                            .foregroundStyle(MVMTheme.secondaryText)

                        if today.completedExerciseCount > 0 {
                            Label("\(today.completedExerciseCount)/\(today.exercises.count) done", systemImage: "checkmark.circle")
                                .font(.subheadline)
                                .foregroundStyle(MVMTheme.accent)
                        }

                        if today.isCompleted {
                            Label("Completed", systemImage: "checkmark.circle.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(MVMTheme.success)
                        }
                    }

                    ForEach(today.exercises.prefix(3)) { exercise in
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(exercise.isCompleted ? MVMTheme.success.opacity(0.18) : MVMTheme.accent.opacity(0.18))
                                    .frame(width: 34, height: 34)

                                Image(systemName: exercise.isCompleted ? "checkmark" : exerciseIcon(exercise))
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(exercise.isCompleted ? MVMTheme.success : MVMTheme.accent)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(exercise.name)
                                    .font(.headline)
                                    .foregroundStyle(exercise.isCompleted ? MVMTheme.secondaryText : MVMTheme.primaryText)
                                    .strikethrough(exercise.isCompleted, color: MVMTheme.secondaryText)

                                Text(exercise.displayDetail)
                                    .font(.subheadline)
                                    .foregroundStyle(MVMTheme.secondaryText)
                            }

                            Spacer()
                        }
                    }

                    if today.exercises.count > 3 {
                        Text("+\(today.exercises.count - 3) more")
                            .font(.subheadline)
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }

                    Button {
                        showWorkoutDetail = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil.and.list.clipboard")
                            Text(today.isCompleted ? "View & Edit Workout" : "Start Workout")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 52)
                        .frame(maxWidth: .infinity)
                        .background(today.isCompleted ? AnyShapeStyle(MVMTheme.accent) : AnyShapeStyle(MVMTheme.heroGradient))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
                .padding(20)
                .premiumCard()
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    sectionLabel(title: "Today", icon: "moon.zzz")

                    Text("Rest Day")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)

                    Text("Recovery is part of the plan. Come back tomorrow.")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                }
                .padding(20)
                .premiumCard()
            }
        }
    }

    private var quickActions: some View {
        VStack(spacing: 14) {
            actionButton(
                title: "Workout of the Day",
                subtitle: "Quick session based on your preferences",
                icon: "star.fill",
                gradient: LinearGradient(colors: [MVMTheme.accent, MVMTheme.accent2], startPoint: .leading, endPoint: .trailing),
                action: {
                    wodWorkout = vm.generateWorkoutOfDay()
                    showWODSheet = true
                }
            )

            actionButton(
                title: "Random Workout",
                subtitle: "Surprise me with something different",
                icon: "shuffle",
                gradient: LinearGradient(colors: [Color(hex: "#0EA5E9"), Color(hex: "#6366F1")], startPoint: .leading, endPoint: .trailing),
                action: {
                    randomWorkout = vm.generateRandomWorkout()
                    showRandomSheet = true
                }
            )

            actionButton(
                title: "Regenerate Week",
                subtitle: "Get a fresh weekly plan",
                icon: "arrow.clockwise",
                gradient: LinearGradient(colors: [Color(hex: "#2563EB"), Color(hex: "#3B82F6")], startPoint: .leading, endPoint: .trailing),
                action: {
                    vm.generateWeeklyPlan()
                }
            )
        }
    }

    private var tipCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(title: "Daily Insight", icon: "sparkles")

            Text(tips[Calendar.current.component(.day, from: .now) % tips.count])
                .font(.headline)
                .foregroundStyle(MVMTheme.primaryText)

            Text("Consistency beats intensity.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
        }
        .padding(20)
        .premiumCard()
    }

    private func exerciseIcon(_ exercise: WorkoutExercise) -> String {
        if exercise.isCardio { return exercise.cardioType?.icon ?? "figure.run" }
        if exercise.isTimeBased { return "timer" }
        return "dumbbell.fill"
    }

    private func heroMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.72))
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func actionButton(title: String, subtitle: String, icon: String, gradient: LinearGradient, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(gradient.opacity(0.18))
                        .frame(width: 54, height: 54)

                    Image(systemName: icon)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)
            }
            .padding(18)
            .premiumCardStyle()
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func sectionLabel(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(MVMTheme.accent)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)
        }
    }
}
