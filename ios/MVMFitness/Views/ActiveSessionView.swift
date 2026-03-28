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
            } else if exercises.isEmpty {
                emptyState
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
                        finishSession()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.danger)
                }
            }
        }
        .onAppear {
            if let w = workout {
                exercises = w.exercises
                if let firstIncomplete = exercises.firstIndex(where: { !$0.isCompleted }) {
                    currentIndex = firstIncomplete
                } else {
                    currentIndex = 0
                }
            }
            sessionStartDate = .now
        }
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
                    navigationControls
                    exerciseList
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 48)
            }
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
        let exercise = exercises[currentIndex]

        return VStack(spacing: 0) {
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
                .sensoryFeedback(.impact(weight: .medium), trigger: exercise.isCompleted)
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
        HStack(spacing: 12) {
            if currentIndex > 0 {
                Button {
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
                .sensoryFeedback(.selection, trigger: currentIndex)
                .buttonStyle(PressScaleButtonStyle())
            } else {
                Button {
                    finishSession()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "flag.checkered")
                            .font(.subheadline.weight(.bold))
                        Text("Finish Workout")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(MVMTheme.success)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .sensoryFeedback(.success, trigger: showCompletion)
                .buttonStyle(PressScaleButtonStyle())
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
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(MVMTheme.success.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(MVMTheme.success)
                }
                .scaleEffect(completionScale)

                Text("Workout Complete")
                    .font(.title.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text(workoutTitle)
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)

                let completed = exercises.filter(\.isCompleted).count
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(completed)/\(exercises.count)")
                            .font(.title2.weight(.bold).monospacedDigit())
                            .foregroundStyle(MVMTheme.primaryText)
                        Text("Exercises")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }

                    Rectangle()
                        .fill(MVMTheme.border)
                        .frame(width: 1, height: 36)

                    VStack(spacing: 4) {
                        Text(sessionDuration)
                            .font(.title2.weight(.bold).monospacedDigit())
                            .foregroundStyle(MVMTheme.primaryText)
                        Text("Duration")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }
                .padding(.top, 8)
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
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                completionScale = 1.0
            }
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "figure.cooldown")
                .font(.system(size: 48))
                .foregroundStyle(MVMTheme.tertiaryText)
            Text("No exercises found")
                .font(.headline)
                .foregroundStyle(MVMTheme.secondaryText)
            Text("This workout has no exercises to guide through.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.tertiaryText)
                .multilineTextAlignment(.center)
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
