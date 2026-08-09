import SwiftUI

struct EditWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    let day: WorkoutDay

    @State private var exercises: [WorkoutExercise] = []
    @State private var expandedID: UUID?
    @State private var showAddExercise: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.screen.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        InsetWell(radius: 15) {
                            HStack {
                                Text(day.title)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundStyle(MVMTheme.text)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 54)
                        }
                        summaryChips
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 6)

                    List {
                        Section {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hold \(MVMTheme.dot) drag the handle to reorder \(MVMTheme.dot) swipe to delete \(MVMTheme.dot) tap to edit")
                                    .font(.caption)
                                    .foregroundStyle(MVMTheme.textMuted)
                            }
                            .listRowBackground(Color.clear)
                        }
                        .listRowSeparator(.hidden)

                        Section {
                            ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                                editableExerciseRow(index: index, exercise: exercise)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                            .onMove { from, to in
                                exercises.move(fromOffsets: from, toOffset: to)
                            }
                            .onDelete { indexSet in
                                exercises.remove(atOffsets: indexSet)
                            }
                        } header: {
                            Text("BLOCKS")
                                .font(MVMTheme.mono(11)).kerning(1.2)
                                .foregroundStyle(MVMTheme.textFaint)
                        }

                        Section {
                            addMovement
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .onTapGesture { showAddExercise = true }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(MVMTheme.textMuted)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        vm.updateDayExercises(dayIndex: day.dayIndex, exercises: exercises)
                        dismiss()
                    }
                    .foregroundStyle(MVMTheme.amber)
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(MVMTheme.screen, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showAddExercise) {
                AddExerciseSheet { newExercise in
                    exercises.append(newExercise)
                }
            }
        }
        .onAppear {
            exercises = day.exercises
        }
    }

    // MARK: - Summary chips (TARGETS / EST TIME / BLOCKS)

    private var summaryChips: some View {
        HStack(spacing: 8) {
            chip(label: "TARGETS", value: targetsSummary, color: MVMTheme.amber)
            chip(label: "EST. TIME", value: "~\(max(exercises.count * 4, 15)) MIN", color: MVMTheme.text)
            chip(label: "BLOCKS", value: "\(exercises.count)", color: MVMTheme.text)
        }
    }

    private var targetsSummary: String {
        var seen: [AFTEventType] = []
        for e in exercises {
            if let tag = e.eventTag, !seen.contains(tag) { seen.append(tag) }
        }
        if seen.isEmpty { return "—" }
        return seen.map(\.displayCode).joined(separator: " \(MVMTheme.dot) ")
    }

    private func chip(label: String, value: String, color: Color) -> some View {
        RaisedCard(radius: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(label).font(MVMTheme.mono(9.5)).kerning(1)
                    .foregroundStyle(MVMTheme.textFaint).lineLimit(1).fixedSize()
                Text(value).font(MVMTheme.mono(13, weight: .bold))
                    .foregroundStyle(color).lineLimit(1).fixedSize()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12).padding(.vertical, 9)
        }
    }

    private func editableExerciseRow(index: Int, exercise: WorkoutExercise) -> some View {
        let isExpanded = expandedID == exercise.id

        return RaisedCard {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        expandedID = isExpanded ? nil : exercise.id
                    }
                } label: {
                    HStack(spacing: 12) {
                        if let tag = exercise.eventTag {
                            EventTagChip(event: tag)
                        } else if exercise.isCardio, let ct = exercise.cardioType {
                            Image(systemName: ct.icon)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(MVMTheme.amber)
                                .frame(width: 44, height: 44)
                                .background(MVMTheme.well)
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(exercise.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(MVMTheme.text)
                            Text(exercise.displayDetail)
                                .font(MVMTheme.mono(10.5))
                                .foregroundStyle(MVMTheme.textMuted)
                                .lineLimit(1).fixedSize()
                        }

                        Spacer()

                        Image(systemName: isExpanded ? "chevron.up" : "pencil")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(MVMTheme.amber)

                        Image(systemName: "line.3.horizontal")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(MVMTheme.textFaint)
                            .padding(.leading, 2)
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    VStack(alignment: .leading, spacing: 14) {
                        Rectangle().fill(MVMTheme.hairline).frame(height: 1)
                            .padding(.vertical, 4)

                        ExerciseAutocompleteField(
                            title: "Name",
                            text: $exercises[index].name,
                            accentColor: MVMTheme.amber
                        )
                        .zIndex(10)

                        eventTagPicker(index: index)

                        if exercises[index].isCardio {
                            cardioFields(index: index)
                        } else if exercises[index].isTimeBased {
                            timedFields(index: index)
                        } else {
                            strengthFields(index: index)
                        }

                        if !exercises[index].isCardio {
                            weightField(index: index)
                        }

                        noteField(index: index)

                        Button(role: .destructive) {
                            // Remove by identity, not by index. This row's body
                            // holds live bindings into exercises[index] and may
                            // have a TextField still committing — removing by a
                            // captured index re-evaluates a stale row and traps
                            // with "Index out of range".
                            let doomedID = exercises[safe: index]?.id
                            withAnimation {
                                expandedID = nil
                                if let doomedID {
                                    exercises.removeAll { $0.id == doomedID }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                    .font(.caption.weight(.semibold))
                                Text("Remove Movement")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(MVMTheme.danger)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(MVMTheme.danger.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 2)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(14)
        }
    }

    /// Optional AFT event tag picker — structured data that powers "targets your
    /// weakest event" on Home. Untagged movements remain fully valid.
    private func eventTagPicker(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("EVENT TAG")
                .font(MVMTheme.mono(10)).kerning(1)
                .foregroundStyle(MVMTheme.textFaint)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button {
                        exercises[index].eventTag = nil
                    } label: {
                        Text("NONE")
                            .font(MVMTheme.mono(10.5, weight: .bold))
                            .foregroundStyle(exercises[index].eventTag == nil ? MVMTheme.onAmber : MVMTheme.textMuted)
                            .padding(.horizontal, 12).frame(height: 36)
                            .background(exercises[index].eventTag == nil ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(MVMTheme.well))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)

                    ForEach(AFTEventType.allCases, id: \.self) { tag in
                        let selected = exercises[index].eventTag == tag
                        Button {
                            exercises[index].eventTag = tag
                        } label: {
                            Text(tag.displayCode)
                                .font(MVMTheme.mono(10.5, weight: .bold))
                                .foregroundStyle(selected ? MVMTheme.onAmber : MVMTheme.textMuted)
                                .padding(.horizontal, 12).frame(height: 36)
                                .background(selected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(MVMTheme.well))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentMargins(.horizontal, 0)
        }
    }

    private func strengthFields(index: Int) -> some View {
        HStack(spacing: 8) {
            InsetWell(radius: 13) {
                MetricCell(label: "SETS", value: "\(exercises[index].sets)")
            }
            .overlay { stepperOverlay(value: Binding(
                get: { exercises[index].sets },
                set: { exercises[index].sets = $0 }
            ), range: 1...20) }

            InsetWell(radius: 13) {
                MetricCell(label: "REPS", value: "\(exercises[index].reps)")
            }
            .overlay { stepperOverlay(value: Binding(
                get: { exercises[index].reps },
                set: { exercises[index].reps = $0 }
            ), range: 1...100) }
        }
    }

    private func timedFields(index: Int) -> some View {
        HStack(spacing: 8) {
            InsetWell(radius: 13) {
                MetricCell(label: "SETS", value: "\(exercises[index].sets)")
            }
            .overlay { stepperOverlay(value: Binding(
                get: { exercises[index].sets },
                set: { exercises[index].sets = $0 }
            ), range: 1...20) }

            InsetWell(radius: 13) {
                MetricCell(label: "HOLD", value: durationLabel(exercises[index].durationSeconds))
            }
            .overlay {
                HStack(spacing: 0) {
                    stepButton(systemName: "minus") {
                        if exercises[index].durationSeconds > 5 { exercises[index].durationSeconds -= 5 }
                    }
                    Spacer()
                    stepButton(systemName: "plus") {
                        exercises[index].durationSeconds += 5
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private func cardioFields(index: Int) -> some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                Text("CARDIO TYPE")
                    .font(MVMTheme.mono(10)).kerning(1)
                    .foregroundStyle(MVMTheme.textFaint)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(CardioType.allCases) { type in
                            let selected = exercises[index].cardioType == type
                            Button {
                                exercises[index].cardioType = type
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: type.icon)
                                        .font(.caption2)
                                    Text(type.rawValue)
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(selected ? MVMTheme.onAmber : MVMTheme.text)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(selected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(MVMTheme.well))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
            }

            HStack(spacing: 8) {
                InsetWell(radius: 13) {
                    MetricCell(label: "DURATION", value: "\(exercises[index].durationSeconds / 60) MIN")
                }
                .overlay {
                    HStack(spacing: 0) {
                        stepButton(systemName: "minus") {
                            if exercises[index].durationSeconds > 60 { exercises[index].durationSeconds -= 60 }
                        }
                        Spacer()
                        stepButton(systemName: "plus") {
                            exercises[index].durationSeconds += 60
                        }
                    }
                    .padding(.horizontal, 4)
                }

                InsetWell(radius: 13) {
                    TextField("0.0", value: Binding(
                        get: { exercises[index].distanceMiles },
                        set: { exercises[index].distanceMiles = $0 }
                    ), format: .number)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(MVMTheme.text)
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                }
            }

            Button {
                exercises[index].stepsLogged = vm.pedometer.todaySteps
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                    Text("Sync Steps (\(vm.pedometer.todaySteps))")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(MVMTheme.amber)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(MVMTheme.amber.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    private func weightField(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "scalemass.fill")
                    .font(.caption2)
                    .foregroundStyle(MVMTheme.amber)
                Text("LOAD")
                    .font(MVMTheme.mono(10)).kerning(1)
                    .foregroundStyle(MVMTheme.textFaint)
            }

            InsetWell(radius: 13) {
                TextField("e.g. 135 LB, 20 LB VEST", text: $exercises[index].weight)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(MVMTheme.text)
                    .padding(.horizontal, 14)
                    .frame(height: 46)
            }
        }
    }

    private func noteField(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("NOTES")
                .font(MVMTheme.mono(10)).kerning(1)
                .foregroundStyle(MVMTheme.textFaint)

            InsetWell(radius: 13) {
                TextField("Add notes...", text: $exercises[index].notes)
                    .font(.system(size: 15))
                    .foregroundStyle(MVMTheme.text)
                    .padding(.horizontal, 14)
                    .frame(height: 46)
            }
        }
    }

    private func durationLabel(_ seconds: Int) -> String {
        "\(seconds / 60)\(MVMTheme.dot)\(String(format: "%02d", seconds % 60))"
    }

    private func stepperOverlay(value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack(spacing: 0) {
            stepButton(systemName: "minus") {
                if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 }
            }
            Spacer()
            stepButton(systemName: "plus") {
                if value.wrappedValue < range.upperBound { value.wrappedValue += 1 }
            }
        }
        .padding(.horizontal, 4)
    }

    private func stepButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.caption.weight(.bold))
                .foregroundStyle(MVMTheme.text)
                .frame(width: 30, height: 46)
        }
        .buttonStyle(.plain)
    }

    private var addMovement: some View {
        HStack(spacing: 12) {
            Image(systemName: "plus")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(MVMTheme.amber)
                .frame(width: 36, height: 36)
                .background(MVMTheme.amber.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: 11))
            Text("Add a movement")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(MVMTheme.amber)
            Spacer()
        }
        .padding(.horizontal, 16).frame(minHeight: 56)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(MVMTheme.amber.opacity(0.42), style: .init(lineWidth: 1.5, dash: [6, 5]))
        )
        .contentShape(Rectangle())
    }
}

struct AddExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onAdd: (WorkoutExercise) -> Void

    @State private var name: String = ""
    @State private var sets: Int = 3
    @State private var reps: Int = 10
    @State private var durationSeconds: Int = 0
    @State private var weight: String = ""
    @State private var notes: String = ""
    @State private var exerciseType: Int = 0
    @State private var eventTag: AFTEventType?
    @State private var librarySearch: String = ""

    private var libraryResults: [String] {
        librarySearch.isEmpty ? [] : ExerciseLibrary.search(librarySearch)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.screen.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        librarySearchBar

                        ExerciseAutocompleteField(
                            title: "Movement Name",
                            text: $name,
                            accentColor: MVMTheme.amber
                        )
                        .zIndex(10)

                        InsetWell(radius: 13) {
                            Picker("Type", selection: $exerciseType) {
                                Text("Strength").tag(0)
                                Text("Timed").tag(1)
                                Text("Cardio").tag(2)
                            }
                            .pickerStyle(.segmented)
                            .padding(4)
                        }

                        eventTagRow

                        if exerciseType == 0 {
                            HStack(spacing: 8) {
                                wellStepper(label: "SETS", value: $sets, range: 1...20)
                                wellStepper(label: "REPS", value: $reps, range: 1...100)
                            }
                        } else if exerciseType == 1 {
                            HStack(spacing: 8) {
                                wellStepper(label: "SETS", value: $sets, range: 1...20)
                                wellStepper(label: "DURATION (SEC)", value: $durationSeconds, range: 5...600)
                            }
                        } else {
                            let durationMinutes = Binding(
                                get: { durationSeconds / 60 },
                                set: { durationSeconds = $0 * 60 }
                            )
                            wellStepper(label: "DURATION (MIN)", value: durationMinutes, range: 1...180)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("LOAD")
                                .font(MVMTheme.mono(10)).kerning(1)
                                .foregroundStyle(MVMTheme.textFaint)

                            InsetWell(radius: 13) {
                                TextField("e.g. 135 LB", text: $weight)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(MVMTheme.text)
                                    .padding(.horizontal, 14)
                                    .frame(height: 46)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("NOTES")
                                .font(MVMTheme.mono(10)).kerning(1)
                                .foregroundStyle(MVMTheme.textFaint)

                            InsetWell(radius: 13) {
                                TextField("Optional notes...", text: $notes)
                                    .font(.system(size: 15))
                                    .foregroundStyle(MVMTheme.text)
                                    .padding(.horizontal, 14)
                                    .frame(height: 46)
                            }
                        }

                        AmberButton(title: "Add Movement") {
                            let category: ExerciseCategory = exerciseType == 0 ? .strength : exerciseType == 1 ? .timed : .cardio
                            let exercise = WorkoutExercise(
                                name: name.isEmpty ? "New Exercise" : name,
                                sets: sets,
                                reps: exerciseType == 0 ? reps : 0,
                                durationSeconds: exerciseType != 0 ? durationSeconds : 0,
                                weight: weight,
                                notes: notes,
                                category: category,
                                cardioType: exerciseType == 2 ? .run : nil,
                                eventTag: eventTag
                            )
                            onAdd(exercise)
                            dismiss()
                        }
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1)
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Add Movement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(MVMTheme.textMuted)
                }
            }
            .toolbarBackground(MVMTheme.screen, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(MVMTheme.screen)
    }

    private var librarySearchBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("SEARCH LIBRARY")
                .font(MVMTheme.mono(10)).kerning(1)
                .foregroundStyle(MVMTheme.textFaint)

            InsetWell(radius: 13) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.textMuted)
                    TextField("Search exercise library...", text: $librarySearch)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(MVMTheme.text)
                    if !librarySearch.isEmpty {
                        Button {
                            librarySearch = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(MVMTheme.textMuted)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .frame(height: 46)
            }

            if !libraryResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(libraryResults.prefix(8), id: \.self) { result in
                        Button {
                            name = result
                            librarySearch = ""
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.caption)
                                    .foregroundStyle(MVMTheme.amber.opacity(0.7))
                                Text(result)
                                    .font(.subheadline)
                                    .foregroundStyle(MVMTheme.text)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if result != libraryResults.prefix(8).last {
                            Rectangle().fill(MVMTheme.hairline).frame(height: 1)
                        }
                    }
                }
                .background(MVMTheme.well)
                .clipShape(RoundedRectangle(cornerRadius: 13))
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else if !librarySearch.isEmpty {
                Text("No exercises match \"\(librarySearch)\"")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.textFaint)
                    .padding(.horizontal, 4)
            }
        }
        .animation(.easeOut(duration: 0.2), value: libraryResults.count)
    }

    private var eventTagRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("EVENT TAG")
                .font(MVMTheme.mono(10)).kerning(1)
                .foregroundStyle(MVMTheme.textFaint)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button {
                        eventTag = nil
                    } label: {
                        Text("NONE")
                            .font(MVMTheme.mono(10.5, weight: .bold))
                            .foregroundStyle(eventTag == nil ? MVMTheme.onAmber : MVMTheme.textMuted)
                            .padding(.horizontal, 12).frame(height: 36)
                            .background(eventTag == nil ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(MVMTheme.well))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)

                    ForEach(AFTEventType.allCases, id: \.self) { tag in
                        let selected = eventTag == tag
                        Button {
                            eventTag = tag
                        } label: {
                            Text(tag.displayCode)
                                .font(MVMTheme.mono(10.5, weight: .bold))
                                .foregroundStyle(selected ? MVMTheme.onAmber : MVMTheme.textMuted)
                                .padding(.horizontal, 12).frame(height: 36)
                                .background(selected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(MVMTheme.well))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentMargins(.horizontal, 0)
        }
    }

    private func wellStepper(label: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        InsetWell(radius: 13) {
            MetricCell(label: label, value: "\(value.wrappedValue)")
        }
        .overlay {
            HStack(spacing: 0) {
                Button {
                    if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.text)
                        .frame(width: 30, height: 46)
                }
                .buttonStyle(.plain)
                Spacer()
                Button {
                    if value.wrappedValue < range.upperBound { value.wrappedValue += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.text)
                        .frame(width: 30, height: 46)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
        }
    }
}
