import SwiftUI

struct WorkoutDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    let dayIndex: Int
    let isStandalone: Bool

    @State private var exercises: [WorkoutExercise] = []
    @State private var editingExerciseID: UUID?
    @State private var hasChanges = false
    @State private var didComplete = false
    @State private var saveTrigger: Bool = false
    @State private var completeTrigger: Bool = false
    @State private var showQRSheet = false


    private var workout: WorkoutDay? {
        if isStandalone { return nil }
        return vm.currentPlan?.days.first { $0.dayIndex == dayIndex }
    }

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerCard
                    progressBar

                    ForEach(Array(exercises.enumerated()), id: \.element.id) { index, _ in
                        exerciseCard(index: index)
                    }

                    actionButtons
                }
                .padding(20)
                .padding(.bottom, 40)
                .adaptiveContainer()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle(workout?.title ?? "Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    if hasChanges {
                        Button("Save") {
                            saveChanges()
                        }
                        .foregroundStyle(MVMTheme.accent)
                        .fontWeight(.semibold)
                    }

                    Menu {
                        Button {
                            showQRSheet = true
                        } label: {
                            Label("Share QR", systemImage: "qrcode")
                        }
                        Button {
                            if let w = workout {
                                ShareCardRenderer.presentShareSheet(
                                    cardType: .workout(title: w.title, exercises: w.exercises, tags: w.tags)
                                )
                            }
                        } label: {
                            Label("Share Card", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                }
            }
        }
        .sheet(isPresented: $showQRSheet) {
            if let w = workout {
                WorkoutQRSheet(workout: w, workoutType: "Individual PT")
            }
        }
        .onAppear {
            if let w = workout {
                exercises = w.exercises
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout?.title ?? "Workout")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)

                    Text("\(exercises.count) exercises")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                }

                Spacer()

                if workout?.isCompleted == true || didComplete {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(MVMTheme.success)
                }
            }

            if vm.pedometer.todaySteps > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                        .foregroundStyle(MVMTheme.accent)
                    Text("\(vm.pedometer.todaySteps) steps today")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.secondaryText)
                }
                .padding(.top, 4)
            }
        }
        .padding(18)
        .premiumCard()
    }

    private var progressBar: some View {
        let completed = exercises.filter(\.isCompleted).count
        let total = exercises.count
        let progress: Double = total > 0 ? Double(completed) / Double(total) : 0

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(completed) of \(total) completed")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(MVMTheme.cardSoft)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(MVMTheme.heroGradient)
                        .frame(width: geo.size.width * progress)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .premiumCard()
    }

    private func exerciseCard(index: Int) -> some View {
        let exercise = exercises[index]
        let isEditing = editingExerciseID == exercise.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    if isEditing {
                        editingExerciseID = nil
                    } else {
                        editingExerciseID = exercise.id
                    }
                }
            } label: {
                HStack(spacing: 14) {
                    Button {
                        exercises[index].isCompleted.toggle()
                        hasChanges = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(exercise.isCompleted ? MVMTheme.success : MVMTheme.cardSoft)
                                .frame(width: 36, height: 36)

                            if exercise.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            if exercise.isCardio, let ct = exercise.cardioType {
                                Image(systemName: ct.icon)
                                    .font(.caption)
                                    .foregroundStyle(MVMTheme.accent)
                            }
                            Text(exercise.name)
                                .font(.headline)
                                .foregroundStyle(exercise.isCompleted ? MVMTheme.secondaryText : MVMTheme.primaryText)
                                .strikethrough(exercise.isCompleted, color: MVMTheme.secondaryText)
                        }

                        Text(exercise.displayDetail)
                            .font(.subheadline)
                            .foregroundStyle(MVMTheme.secondaryText)
                    }

                    Spacer()

                    Image(systemName: isEditing ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            if isEditing {
                Divider()
                    .overlay(MVMTheme.border)

                exerciseEditor(index: index)
                    .padding(16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .premiumCard()
    }

    private func exerciseEditor(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if exercises[index].isCardio {
                cardioEditor(index: index)
            } else if exercises[index].isTimeBased {
                timedEditor(index: index)
            } else {
                strengthEditor(index: index)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Notes")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)

                TextField("Add notes...", text: Binding(
                    get: { exercises[index].notes },
                    set: { exercises[index].notes = $0; hasChanges = true }
                ))
                .font(.subheadline)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(MVMTheme.cardSoft)
                .foregroundStyle(MVMTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border)
                }
            }
        }
    }

    private func strengthEditor(index: Int) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                stepperField(title: "Sets", value: Binding(
                    get: { exercises[index].sets },
                    set: { exercises[index].sets = $0; hasChanges = true }
                ), range: 1...20)

                stepperField(title: "Reps", value: Binding(
                    get: { exercises[index].reps },
                    set: { exercises[index].reps = $0; hasChanges = true }
                ), range: 1...100)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Weight")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)

                TextField("e.g. 135 lbs, 60 kg, Bodyweight", text: Binding(
                    get: { exercises[index].weight },
                    set: { exercises[index].weight = $0; hasChanges = true }
                ))
                .font(.subheadline)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(MVMTheme.cardSoft)
                .foregroundStyle(MVMTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border)
                }
            }
        }
    }

    private func timedEditor(index: Int) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                stepperField(title: "Sets", value: Binding(
                    get: { exercises[index].sets },
                    set: { exercises[index].sets = $0; hasChanges = true }
                ), range: 1...20)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Duration")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    HStack(spacing: 8) {
                        let mins = exercises[index].durationSeconds / 60
                        let secs = exercises[index].durationSeconds % 60

                        stepperCompact(value: Binding(
                            get: { mins },
                            set: {
                                exercises[index].durationSeconds = $0 * 60 + secs
                                hasChanges = true
                            }
                        ), range: 0...120, label: "min")

                        stepperCompact(value: Binding(
                            get: { secs },
                            set: {
                                exercises[index].durationSeconds = mins * 60 + $0
                                hasChanges = true
                            }
                        ), range: 0...59, label: "sec")
                    }
                }
            }
        }
    }

    private func cardioEditor(index: Int) -> some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Cardio Type")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(CardioType.allCases) { type in
                            let selected = exercises[index].cardioType == type
                            Button {
                                exercises[index].cardioType = type
                                hasChanges = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: type.icon)
                                        .font(.caption)
                                    Text(type.rawValue)
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(selected ? .white : MVMTheme.primaryText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selected ? MVMTheme.accent : MVMTheme.cardSoft)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Duration (min)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    stepperCompact(value: Binding(
                        get: { exercises[index].durationSeconds / 60 },
                        set: { exercises[index].durationSeconds = $0 * 60; hasChanges = true }
                    ), range: 1...180, label: "min")
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Distance (mi)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    TextField("0.0", text: Binding(
                        get: { exercises[index].distanceMiles.map { String(format: "%.1f", $0) } ?? "" },
                        set: { exercises[index].distanceMiles = Double($0); hasChanges = true }
                    ))
                    .keyboardType(.decimalPad)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(MVMTheme.cardSoft)
                    .foregroundStyle(MVMTheme.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay { RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border) }
                }
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Speed (mph)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    TextField("0.0", text: Binding(
                        get: { exercises[index].speedMph.map { String(format: "%.1f", $0) } ?? "" },
                        set: { exercises[index].speedMph = Double($0); hasChanges = true }
                    ))
                    .keyboardType(.decimalPad)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(MVMTheme.cardSoft)
                    .foregroundStyle(MVMTheme.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay { RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border) }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Calories")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    TextField("0", text: Binding(
                        get: { exercises[index].caloriesBurned.map { "\($0)" } ?? "" },
                        set: { exercises[index].caloriesBurned = Int($0); hasChanges = true }
                    ))
                    .keyboardType(.numberPad)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(MVMTheme.cardSoft)
                    .foregroundStyle(MVMTheme.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay { RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border) }
                }
            }

            Button {
                exercises[index].stepsLogged = vm.pedometer.todaySteps
                hasChanges = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                        .font(.subheadline)
                    Text("Sync Steps (\(vm.pedometer.todaySteps))")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(MVMTheme.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(MVMTheme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            if let steps = exercises[index].stepsLogged, steps > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(MVMTheme.success)
                    Text("\(steps) steps synced")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }
        }
    }

    private func stepperField(title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)

            HStack(spacing: 0) {
                Button {
                    if value.wrappedValue > range.lowerBound {
                        value.wrappedValue -= 1
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                        .frame(width: 40, height: 44)
                }

                Text("\(value.wrappedValue)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentTransition(.numericText())

                Button {
                    if value.wrappedValue < range.upperBound {
                        value.wrappedValue += 1
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                        .frame(width: 40, height: 44)
                }
            }
            .background(MVMTheme.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay { RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border) }
        }
    }

    private func stepperCompact(value: Binding<Int>, range: ClosedRange<Int>, label: String) -> some View {
        HStack(spacing: 0) {
            Button {
                if value.wrappedValue > range.lowerBound {
                    value.wrappedValue -= 1
                }
            } label: {
                Image(systemName: "minus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .frame(width: 32, height: 44)
            }

            VStack(spacing: 0) {
                Text("\(value.wrappedValue)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .contentTransition(.numericText())
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity)

            Button {
                if value.wrappedValue < range.upperBound {
                    value.wrappedValue += 1
                }
            } label: {
                Image(systemName: "plus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .frame(width: 32, height: 44)
            }
        }
        .frame(height: 44)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay { RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border) }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if hasChanges {
                Button {
                    saveTrigger.toggle()
                    saveChanges()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.subheadline.weight(.bold))
                        Text("Save Changes")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .sensoryFeedback(.impact(weight: .light), trigger: saveTrigger)
                .buttonStyle(PressScaleButtonStyle())
            }

            if workout?.isCompleted != true && !didComplete {
                Button {
                    saveChanges()
                    completeTrigger.toggle()
                    vm.markDayCompleted(dayIndex: dayIndex)
                    didComplete = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline.weight(.bold))
                        Text("Complete Workout")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: MVMTheme.accent.opacity(0.28), radius: 14, y: 8)
                }
                .buttonStyle(PressScaleButtonStyle())
                .sensoryFeedback(.success, trigger: completeTrigger)
            }

            if workout?.isCompleted == true || didComplete {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(MVMTheme.success)
                    Text("Workout Complete")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(MVMTheme.success)
                }
                .frame(height: 52)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func saveChanges() {
        vm.updateDayExercises(dayIndex: dayIndex, exercises: exercises)
        if let w = workout {
            exercises = w.exercises
        }
        hasChanges = false
    }
}
