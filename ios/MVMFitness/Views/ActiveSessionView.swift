import SwiftUI

struct ActiveSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    let dayIndex: Int
    let isStandalone: Bool

    @State private var currentIndex: Int = 0
    @State private var exercises: [WorkoutExercise] = []
    @State private var showCompletion: Bool = false
    @State private var sessionStartDate: Date = .now
    @State private var completionScale: CGFloat = 0.8
    @State private var completionCheckScale: CGFloat = 0.0
    @State private var workoutTimer: WorkoutTimer = WorkoutTimer()
    @State private var timerFinishedTrigger: Bool = false
    @State private var restFinishedTrigger: Bool = false
    @State private var timerStartTrigger: Bool = false
    @State private var restDuration: Int = 60
    @State private var nextExerciseTrigger: Bool = false
    @State private var markDoneTrigger: Bool = false
    @State private var shareItems: [Any] = []
    @State private var showShareSheet: Bool = false
    @State private var showCompletionShareSheet: Bool = false

    private var workout: WorkoutDay? {
        if isStandalone { return nil }
        return vm.currentPlan?.days.first { $0.dayIndex == dayIndex }
    }

    private var workoutTitle: String {
        workout?.title ?? "Workout"
    }

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            if showCompletion {
                completionView
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else if exercises.isEmpty {
                emptyState
            } else if workoutTimer.showRestTimer {
                restTimerOverlay
            } else {
                sessionContent
            }
        }
        .navigationTitle(workoutTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !showCompletion && !exercises.isEmpty {
                    Button("End") {
                        workoutTimer.stopAll()
                        finishSession()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.danger)
                }
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: timerStartTrigger)
        .sensoryFeedback(.success, trigger: timerFinishedTrigger)
        .sensoryFeedback(.warning, trigger: restFinishedTrigger)
        .sensoryFeedback(.selection, trigger: nextExerciseTrigger)
        .sensoryFeedback(.impact(weight: .medium), trigger: markDoneTrigger)
        .sheet(isPresented: $showShareSheet) {
            if !shareItems.isEmpty {
                ShareSheet(items: shareItems)
            }
        }
        .sheet(isPresented: $showCompletionShareSheet) {
            WorkoutCompletionShareSheet(
                title: workoutTitle,
                exerciseCount: exercises.count
            )
        }
        .onAppear {
            if let w = workout {
                exercises = w.exercises
                if let firstIncomplete = exercises.firstIndex(where: { !$0.isCompleted }) {
                    currentIndex = firstIncomplete
                } else {
                    currentIndex = 0
                }
                configureTimerForCurrentExercise()
            }
            sessionStartDate = .now
        }
        .onChange(of: currentIndex) { _, _ in
            configureTimerForCurrentExercise()
        }
        .onChange(of: workoutTimer.timeRemaining) { oldValue, newValue in
            if oldValue > 0 && newValue <= 0 && workoutTimer.hasTimer {
                timerFinishedTrigger.toggle()
                if workoutTimer.autoAdvance && currentIndex < exercises.count - 1 {
                    Task {
                        try? await Task.sleep(for: .milliseconds(500))
                        advanceToNext()
                    }
                }
            }
        }
        .onChange(of: workoutTimer.showRestTimer) { oldValue, newValue in
            if oldValue && !newValue {
                restFinishedTrigger.toggle()
            }
        }
    }

    private func configureTimerForCurrentExercise() {
        guard currentIndex < exercises.count else { return }
        workoutTimer.configure(for: exercises[currentIndex])
    }

    private func advanceToNext() {
        guard currentIndex < exercises.count - 1 else { return }
        nextExerciseTrigger.toggle()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            currentIndex += 1
        }
    }

    private func advanceWithRest() {
        guard currentIndex < exercises.count - 1 else { return }
        workoutTimer.startRest(seconds: restDuration)
    }

    // MARK: - Session Content

    private var sessionContent: some View {
        VStack(spacing: 0) {
            progressHeader
                .padding(.horizontal, 20)
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    exerciseCard
                    if currentIndex < exercises.count && workoutTimer.hasTimer {
                        timerSection
                    }
                    navigationControls
                    exerciseList
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Exercise \(currentIndex + 1) of \(exercises.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)

                Spacer()

                let completed = exercises.filter(\.isCompleted).count
                Text("\(completed) done")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.success)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(MVMTheme.success.opacity(0.12))
                    .clipShape(Capsule())
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(MVMTheme.cardSoft)

                    let progress = exercises.isEmpty ? 0 : Double(currentIndex + 1) / Double(exercises.count)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(MVMTheme.heroGradient)
                        .frame(width: geo.size.width * progress)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Current Exercise Card

    private var exerciseCard: some View {
        guard currentIndex >= 0 && currentIndex < exercises.count else {
            return AnyView(emptyState)
        }
        let exercise = exercises[currentIndex]

        return AnyView(VStack(spacing: 0) {
            VStack(spacing: 20) {
                HStack {
                    categoryBadge(exercise)
                    Spacer()
                    if exercise.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption.weight(.bold))
                            Text("Done")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(MVMTheme.success)
                    }
                }

                VStack(spacing: 10) {
                    Text(exercise.name)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)

                    Text(exercise.displayDetail)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)

                if !exercise.notes.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                        Text(exercise.notes)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(3)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    markDoneTrigger.toggle()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        exercises[currentIndex].isCompleted.toggle()
                        syncExercises()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: exercise.isCompleted ? "arrow.uturn.backward" : "checkmark.circle.fill")
                            .font(.subheadline.weight(.bold))
                        Text(exercise.isCompleted ? "Undo" : "Mark Done")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(exercise.isCompleted ? .white : Color(hex: "#1A1A2E"))
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(exercise.isCompleted ? .white.opacity(0.18) : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())
            }
            .padding(24)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#3B6DE0"),
                                    Color(hex: "#5B4DC7").opacity(0.95),
                                    Color(hex: "#4A3DAF").opacity(0.9)
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
            .shadow(color: MVMTheme.accent.opacity(0.2), radius: 24, y: 16)
        })
    }

    // MARK: - Timer Section

    private var timerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(MVMTheme.cardSoft, lineWidth: 6)

                Circle()
                    .trim(from: 0, to: workoutTimer.progress)
                    .stroke(
                        MVMTheme.heroGradient,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: workoutTimer.progress)

                VStack(spacing: 4) {
                    Text(workoutTimer.formattedTime)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(timerTextColor)
                        .contentTransition(.numericText())
                        .animation(.default, value: workoutTimer.timeRemaining)

                    Text(timerLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .textCase(.uppercase)
                }
            }
            .frame(width: 140, height: 140)

            HStack(spacing: 12) {
                Button {
                    if !workoutTimer.isRunning {
                        timerStartTrigger.toggle()
                    }
                    workoutTimer.startPause()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: workoutTimer.isRunning ? "pause.fill" : "play.fill")
                            .font(.caption.weight(.bold))
                        Text(workoutTimer.isRunning ? "Pause" : "Start")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(workoutTimer.isRunning ? MVMTheme.warning : MVMTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    workoutTimer.reset()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption.weight(.bold))
                        Text("Reset")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(MVMTheme.card)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(MVMTheme.border)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(20)
        .background(MVMTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(MVMTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var timerTextColor: Color {
        if workoutTimer.timeRemaining <= 10 && workoutTimer.timeRemaining > 0 && workoutTimer.isRunning {
            return MVMTheme.warning
        }
        if workoutTimer.timeRemaining <= 0 {
            return MVMTheme.success
        }
        return .white
    }

    private var timerLabel: String {
        if workoutTimer.timeRemaining <= 0 { return "Complete" }
        if workoutTimer.isRunning { return "Running" }
        return "Ready"
    }

    // MARK: - Rest Timer Overlay

    private var restTimerOverlay: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(MVMTheme.accent.opacity(0.6))

                Text("REST")
                    .font(.caption.weight(.heavy))
                    .tracking(2.0)
                    .foregroundStyle(MVMTheme.secondaryText)

                Text(workoutTimer.formattedRestTime)
                    .font(.system(size: 56, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.default, value: workoutTimer.restTimeRemaining)

                if currentIndex < exercises.count - 1 {
                    VStack(spacing: 4) {
                        Text("Up Next")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                        Text(exercises[currentIndex + 1].name)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(MVMTheme.primaryText)
                    }
                    .padding(.top, 8)
                }
            }

            Spacer()

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ForEach([30, 60, 90], id: \.self) { seconds in
                        Button {
                            restDuration = seconds
                            workoutTimer.skipRest()
                            workoutTimer.startRest(seconds: seconds)
                        } label: {
                            Text("\(seconds)s")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(restDuration == seconds ? .white : MVMTheme.secondaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(restDuration == seconds ? MVMTheme.accent.opacity(0.3) : MVMTheme.cardSoft)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    if restDuration == seconds {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(MVMTheme.accent.opacity(0.4))
                                    }
                                }
                        }
                        .buttonStyle(PressScaleButtonStyle())
                    }
                }

                Button {
                    workoutTimer.skipRest()
                    advanceToNext()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "forward.fill")
                            .font(.caption.weight(.bold))
                        Text("Skip Rest")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .sensoryFeedback(.selection, trigger: restFinishedTrigger)
                .buttonStyle(PressScaleButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .onChange(of: workoutTimer.showRestTimer) { _, showing in
            if !showing {
                advanceToNext()
            }
        }
    }

    private func categoryBadge(_ exercise: WorkoutExercise) -> some View {
        let label: String
        let icon: String

        if exercise.isCardio, let ct = exercise.cardioType {
            label = ct.rawValue
            icon = ct.icon
        } else {
            label = exercise.category.rawValue
            icon = exercise.isTimeBased ? "timer" : "dumbbell.fill"
        }

        return HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
            Text(label.uppercased())
                .font(.caption2.weight(.heavy))
                .tracking(0.5)
        }
        .foregroundStyle(.white.opacity(0.7))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.white.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: - Navigation Controls

    private var navigationControls: some View {
        VStack(spacing: 10) {
            if currentIndex < exercises.count && exercises[currentIndex].isTimeBased == false && currentIndex < exercises.count - 1 {
                Button {
                    advanceWithRest()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .font(.caption.weight(.bold))
                        Text("Rest \(restDuration)s → Next")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(MVMTheme.accent.opacity(0.1))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(MVMTheme.accent.opacity(0.25))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(PressScaleButtonStyle())
            }

            HStack(spacing: 12) {
                if currentIndex > 0 {
                    Button {
                        workoutTimer.pause()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            currentIndex -= 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.caption.weight(.bold))
                            Text("Previous")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(MVMTheme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(MVMTheme.card)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(MVMTheme.border)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }

                if currentIndex < exercises.count - 1 {
                    Button {
                        workoutTimer.pause()
                        nextExerciseTrigger.toggle()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            currentIndex += 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Next")
                                .font(.subheadline.weight(.semibold))
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(MVMTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                } else {
                    Button {
                        workoutTimer.stopAll()
                        finishSession()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "flag.checkered")
                                .font(.subheadline.weight(.bold))
                            Text("Complete Workout")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(MVMTheme.success)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
            }
        }
    }

    // MARK: - Exercise List

    private var exerciseList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ALL EXERCISES")
                .font(.caption.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                Button {
                    workoutTimer.pause()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        currentIndex = index
                    }
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(exercise.isCompleted ? MVMTheme.success : (index == currentIndex ? MVMTheme.accent : MVMTheme.cardSoft))
                                .frame(width: 28, height: 28)

                            if exercise.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            } else {
                                Text("\(index + 1)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(index == currentIndex ? .white : MVMTheme.tertiaryText)
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise.name)
                                .font(.subheadline.weight(index == currentIndex ? .semibold : .medium))
                                .foregroundStyle(exercise.isCompleted ? MVMTheme.secondaryText : MVMTheme.primaryText)
                                .strikethrough(exercise.isCompleted, color: MVMTheme.secondaryText)
                                .lineLimit(1)

                            Text(exercise.displayDetail)
                                .font(.caption)
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }

                        Spacer()

                        if exercise.isTimeBased {
                            Image(systemName: "timer")
                                .font(.caption2)
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }

                        if index == currentIndex {
                            Image(systemName: "arrowtriangle.right.fill")
                                .font(.caption2)
                                .foregroundStyle(MVMTheme.accent)
                        }
                    }
                    .padding(12)
                    .background(index == currentIndex ? MVMTheme.accent.opacity(0.08) : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        if index == currentIndex {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(MVMTheme.accent.opacity(0.2))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(MVMTheme.success.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(completionScale)

                    Circle()
                        .fill(MVMTheme.success.opacity(0.2))
                        .frame(width: 90, height: 90)
                        .scaleEffect(completionScale)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(MVMTheme.success)
                        .scaleEffect(completionCheckScale)
                }

                VStack(spacing: 8) {
                    Text("Workout Complete")
                        .font(.title.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)

                    Text(workoutTitle)
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                }

                let completed = exercises.filter(\.isCompleted).count
                HStack(spacing: 32) {
                    VStack(spacing: 6) {
                        Text("\(completed)/\(exercises.count)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(MVMTheme.primaryText)
                            .contentTransition(.numericText())
                        Text("Exercises")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }

                    Rectangle()
                        .fill(MVMTheme.border)
                        .frame(width: 1, height: 40)

                    VStack(spacing: 6) {
                        Text(sessionDuration)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(MVMTheme.primaryText)
                        Text("Duration")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }
                .padding(20)
                .background(MVMTheme.card)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(MVMTheme.border)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    vm.markDayCompleted(dayIndex: dayIndex)
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline.weight(.bold))
                        Text("Save & Done")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: MVMTheme.accent.opacity(0.28), radius: 14, y: 8)
                }
                .sensoryFeedback(.success, trigger: showCompletion)
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    showCompletionShareSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.subheadline.weight(.semibold))
                        Text("Share Workout")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.accent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PressScaleButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                completionScale = 1.0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.55).delay(0.15)) {
                completionCheckScale = 1.0
            }
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "figure.cooldown")
                .font(.system(size: 48))
                .foregroundStyle(MVMTheme.tertiaryText)

            VStack(spacing: 8) {
                Text("No Exercises Found")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("This workout has no exercises to guide through.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Go Back")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressScaleButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Logic

    private func syncExercises() {
        vm.updateDayExercises(dayIndex: dayIndex, exercises: exercises)
    }

    private func finishSession() {
        syncExercises()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showCompletion = true
        }
    }

    private var sessionDuration: String {
        let elapsed = Int(Date.now.timeIntervalSince(sessionStartDate))
        let mins = elapsed / 60
        if mins < 1 { return "<1 min" }
        return "\(mins) min"
    }
}
