import SwiftUI

struct PTPlanDayDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    let day: WorkoutDay

    @State private var exercises: [WorkoutExercise] = []
    @State private var expandedID: UUID?
    @State private var hasChanges: Bool = false
    @State private var calendarService = CalendarExportService()

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                if day.isRestDay {
                    restDayContent
                } else {
                    workoutContent
                }
            }
            .navigationTitle(day.isRestDay ? "Recovery & Mobility" : day.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(MVMTheme.secondaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if hasChanges {
                        Button("Save") {
                            vm.updateDayExercises(dayIndex: day.dayIndex, exercises: exercises)
                            if vm.isCalendarSyncEnabled, let plan = vm.currentPlan {
                                Task {
                                    _ = await calendarService.resyncWeeklyPlanFromDate(plan, from: day.date)
                                }
                            }
                            dismiss()
                        }
                        .foregroundStyle(MVMTheme.accent)
                        .fontWeight(.semibold)
                    } else {
                        Button("Done") { dismiss() }
                            .foregroundStyle(MVMTheme.primaryText)
                    }
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            exercises = day.exercises
        }
    }

    private var restDayContent: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(MVMTheme.accent.opacity(0.5))

                Text("Recovery & Mobility")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Active rest day. Light movement, stretching, or mobility work.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button {
                vm.replaceRestDayWithWorkout(dayIndex: day.dayIndex)
                if vm.isCalendarSyncEnabled, let plan = vm.currentPlan {
                    Task {
                        _ = await calendarService.resyncWeeklyPlanFromDate(plan, from: day.date)
                    }
                }
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.subheadline.weight(.bold))
                    Text("Replace with Workout")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(MVMTheme.heroGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressScaleButtonStyle())
            .padding(.horizontal, 20)

            Spacer()
            Spacer()
        }
    }

    private var workoutContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                headerCard
                exercisesList
                actionsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .scrollDismissesKeyboard(.interactively)
        .sensoryFeedback(.selection, trigger: exercises.count)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                if let tag = day.tags.first {
                    Text(tag.uppercased())
                        .font(.caption2.weight(.heavy))
                        .tracking(1.0)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                Text("\(exercises.count) exercises")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
            }

            Text(day.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            let mins = max(exercises.count * 4, 15)
            HStack(spacing: 12) {
                Label("~\(mins) min", systemImage: "clock")
                Label("Individual", systemImage: "person")
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.white.opacity(0.7))
        }
        .padding(22)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#3B6DE0"), Color(hex: "#5B4DC7").opacity(0.95), Color(hex: "#4A3DAF").opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: MVMTheme.accent.opacity(0.2), radius: 20, y: 12)
    }

    @State private var showAddExercise: Bool = false
    @State private var editMode: EditMode = .inactive

    private var exercisesList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("EXERCISES")
                    .font(.caption.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(MVMTheme.tertiaryText)

                Spacer()

                Button {
                    withAnimation {
                        editMode = editMode == .active ? .inactive : .active
                    }
                } label: {
                    Text(editMode == .active ? "Done" : "Reorder")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .padding(.leading, 4)

            if editMode == .active {
                List {
                    ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                        HStack(spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(MVMTheme.accent)
                                .frame(width: 24, height: 24)
                                .background(MVMTheme.accent.opacity(0.12))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(MVMTheme.primaryText)
                                Text(exercise.displayDetail)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(MVMTheme.secondaryText)
                            }
                        }
                        .listRowBackground(MVMTheme.card)
                    }
                    .onMove { from, to in
                        exercises.move(fromOffsets: from, toOffset: to)
                        hasChanges = true
                    }
                    .onDelete { indexSet in
                        exercises.remove(atOffsets: indexSet)
                        hasChanges = true
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, .constant(.active))
                .frame(height: CGFloat(exercises.count * 60 + 10))
            } else {
                ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                    exerciseRow(index: index, exercise: exercise)
                }
            }

            Button {
                showAddExercise = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.body)
                    Text("Add Exercise")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(MVMTheme.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(MVMTheme.accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(MVMTheme.accent.opacity(0.2))
                }
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .sheet(isPresented: $showAddExercise) {
            ArmyPTExercisePickerSheet { exerciseName in
                let exercise = WorkoutExercise(
                    name: exerciseName,
                    sets: 3,
                    reps: 10
                )
                exercises.append(exercise)
                hasChanges = true
            }
        }
    }

    private func exerciseRow(index: Int, exercise: WorkoutExercise) -> some View {
        let isExpanded = expandedID == exercise.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    expandedID = isExpanded ? nil : exercise.id
                }
            } label: {
                HStack(spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.accent)
                        .frame(width: 24, height: 24)
                        .background(MVMTheme.accent.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            if exercise.isCardio, let ct = exercise.cardioType {
                                Image(systemName: ct.icon)
                                    .font(.caption)
                                    .foregroundStyle(MVMTheme.accent)
                            }
                            Text(exercise.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(MVMTheme.primaryText)
                        }
                        Text(exercise.displayDetail)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "pencil")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent.opacity(0.6))
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().overlay(MVMTheme.border)

                VStack(alignment: .leading, spacing: 14) {
                    ExerciseAutocompleteField(
                        title: "Name",
                        text: Binding(
                            get: { exercises[index].name },
                            set: { exercises[index].name = $0; hasChanges = true }
                        ),
                        accentColor: MVMTheme.accent,
                        armyOnly: true,
                        onChanged: { hasChanges = true }
                    )
                    .zIndex(10)

                    if exercises[index].isCardio {
                        cardioEditor(index: index)
                    } else if exercises[index].isTimeBased {
                        timedEditor(index: index)
                    } else {
                        strengthEditor(index: index)
                    }

                    if !exercises[index].isCardio {
                        weightField(index: index)
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
                        .overlay { RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border) }
                    }
                }
                .padding(14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(MVMTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(MVMTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func strengthEditor(index: Int) -> some View {
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
    }

    private func timedEditor(index: Int) -> some View {
        HStack(spacing: 16) {
            stepperField(title: "Sets", value: Binding(
                get: { exercises[index].sets },
                set: { exercises[index].sets = $0; hasChanges = true }
            ), range: 1...20)

            VStack(alignment: .leading, spacing: 6) {
                Text("Duration")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)

                HStack(spacing: 6) {
                    compactStepper(value: Binding(
                        get: { exercises[index].durationSeconds / 60 },
                        set: {
                            let secs = exercises[index].durationSeconds % 60
                            exercises[index].durationSeconds = $0 * 60 + secs
                            hasChanges = true
                        }
                    ), range: 0...120, label: "min")

                    compactStepper(value: Binding(
                        get: { exercises[index].durationSeconds % 60 },
                        set: {
                            let mins = exercises[index].durationSeconds / 60
                            exercises[index].durationSeconds = mins * 60 + $0
                            hasChanges = true
                        }
                    ), range: 0...59, label: "sec")
                }
            }
        }
    }

    private func cardioEditor(index: Int) -> some View {
        VStack(spacing: 12) {
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
                                HStack(spacing: 5) {
                                    Image(systemName: type.icon)
                                        .font(.caption2)
                                    Text(type.rawValue)
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(selected ? .white : MVMTheme.primaryText)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(selected ? MVMTheme.accent : MVMTheme.cardSoft)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Duration (min)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    compactStepper(value: Binding(
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
        }
    }

    private func weightField(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "scalemass.fill")
                    .font(.caption2)
                    .foregroundStyle(MVMTheme.accent)
                Text("Weight / Load")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)
                if ExerciseLibrary.isWeightedExercise(exercises[index].name) {
                    Text("(recommended)")
                        .font(.caption2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            }

            TextField("e.g. 135 lbs, 20 lb vest", text: Binding(
                get: { exercises[index].weight },
                set: { exercises[index].weight = $0; hasChanges = true }
            ))
            .font(.subheadline)
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(MVMTheme.cardSoft)
            .foregroundStyle(MVMTheme.primaryText)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay { RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border) }
        }
    }

    private func stepperField(title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)

            HStack(spacing: 0) {
                Button {
                    if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 }
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
                    .contentTransition(.numericText())

                Button {
                    if value.wrappedValue < range.upperBound { value.wrappedValue += 1 }
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

    private func compactStepper(value: Binding<Int>, range: ClosedRange<Int>, label: String) -> some View {
        HStack(spacing: 0) {
            Button {
                if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 }
            } label: {
                Image(systemName: "minus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .frame(width: 30, height: 44)
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
                if value.wrappedValue < range.upperBound { value.wrappedValue += 1 }
            } label: {
                Image(systemName: "plus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .frame(width: 30, height: 44)
            }
        }
        .frame(height: 44)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay { RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border) }
    }

    private var actionsSection: some View {
        VStack(spacing: 10) {
            Button {
                vm.convertDayToRecovery(dayIndex: day.dayIndex)
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.caption.weight(.bold))
                    Text("Convert to Recovery Day")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(MVMTheme.secondaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(MVMTheme.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(MVMTheme.border)
                }
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                vm.regenerateSingleDay(dayIndex: day.dayIndex)
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption.weight(.bold))
                    Text("Replace with Different Workout")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(MVMTheme.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(MVMTheme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }
}
