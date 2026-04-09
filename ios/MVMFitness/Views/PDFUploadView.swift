import SwiftUI
import UniformTypeIdentifiers

struct PDFUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var showFilePicker: Bool = false
    @State private var extractedWorkout: PDFWorkoutExtractor.ExtractedWorkout?
    @State private var editableTitle: String = ""
    @State private var editableExercises: [WorkoutExercise] = []
    @State private var isProcessing: Bool = false
    @State private var errorMessage: String?
    @State private var didImport: Bool = false
    @State private var showRawText: Bool = false
    @State private var importTrigger: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if extractedWorkout == nil && !isProcessing {
                            uploadSection
                        }

                        if isProcessing {
                            processingSection
                        }

                        if let error = errorMessage {
                            errorSection(error)
                        }

                        if extractedWorkout != nil {
                            previewSection
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                    .adaptiveContainer()
                }
            }
            .navigationTitle("Import Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(MVMTheme.secondaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if extractedWorkout != nil && !didImport {
                        Button {
                            showFilePicker = true
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(MVMTheme.accent)
                        }
                    }
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                handleFileResult(result)
            }
        }
    }

    // MARK: - Upload Section

    private var uploadSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(MVMTheme.accent.opacity(0.1))
                        .frame(width: 80, height: 80)
                    Circle()
                        .fill(MVMTheme.accent.opacity(0.06))
                        .frame(width: 100, height: 100)
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(MVMTheme.accent)
                }

                VStack(spacing: 6) {
                    Text("Import Exercises from PDF")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)

                    Text("Upload a PDF to detect exercise movements.\nNames, sets, and reps will be added to your library — not as a ready-made routine.")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
            }

            Button {
                showFilePicker = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "folder.fill")
                        .font(.subheadline.weight(.bold))
                    Text("Choose PDF File")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(MVMTheme.heroGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: MVMTheme.accent.opacity(0.3), radius: 12, y: 6)
            }
            .buttonStyle(PressScaleButtonStyle())

            VStack(alignment: .leading, spacing: 10) {
                Text("SUPPORTED FORMATS")
                    .font(.caption2.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(MVMTheme.tertiaryText)

                HStack(spacing: 12) {
                    formatHint(icon: "list.bullet", text: "Exercise lists")
                    formatHint(icon: "number", text: "Sets × Reps")
                    formatHint(icon: "clock", text: "Timed work")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .premiumCard()
    }

    private func formatHint(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.accent)
            Text(text)
                .font(.caption.weight(.medium))
                .foregroundStyle(MVMTheme.secondaryText)
        }
    }

    // MARK: - Processing

    private var processingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(MVMTheme.accent)
                .scaleEffect(1.2)

            Text("Extracting workout data…")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .premiumCard()
    }

    // MARK: - Error

    private func errorSection(_ message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 28))
                .foregroundStyle(MVMTheme.warning)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                errorMessage = nil
                showFilePicker = true
            } label: {
                Text("Try Another File")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(Capsule())
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .premiumCard()
    }

    // MARK: - Preview Section

    private var previewSection: some View {
        VStack(spacing: 16) {
            titleEditor

            exercisesList

            if let extracted = extractedWorkout {
                rawTextToggle(extracted)
            }

            actionButtons
        }
    }

    private var titleEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WORKOUT TITLE")
                .font(.caption2.weight(.heavy))
                .tracking(0.8)
                .foregroundStyle(MVMTheme.tertiaryText)

            TextField("Workout Title", text: $editableTitle)
                .font(.headline.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(MVMTheme.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border)
                }
        }
    }

    private var exercisesList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("EXERCISES (\(editableExercises.count))")
                    .font(.caption2.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(MVMTheme.tertiaryText)

                Spacer()

                if !editableExercises.isEmpty {
                    Button {
                        let newExercise = WorkoutExercise(
                            name: "New Exercise",
                            sets: 3,
                            reps: 10,
                            category: .strength
                        )
                        editableExercises.append(newExercise)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.caption2.weight(.bold))
                            Text("Add")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(MVMTheme.accent)
                    }
                }
            }

            if editableExercises.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "text.badge.xmark")
                        .font(.system(size: 24))
                        .foregroundStyle(MVMTheme.tertiaryText)

                    Text("No exercises detected")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    Text("The PDF may not contain recognizable workout data. You can add exercises manually.")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .multilineTextAlignment(.center)

                    Button {
                        let newExercise = WorkoutExercise(
                            name: "New Exercise",
                            sets: 3,
                            reps: 10,
                            category: .strength
                        )
                        editableExercises.append(newExercise)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.caption.weight(.bold))
                            Text("Add Exercise")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(MVMTheme.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(MVMTheme.accent.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .premiumCard()
            } else {
                ForEach(Array(editableExercises.enumerated()), id: \.element.id) { index, exercise in
                    exerciseRow(exercise, index: index)
                }
            }
        }
    }

    private func exerciseRow(_ exercise: WorkoutExercise, index: Int) -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text("\(index + 1)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                Circle()
                    .fill(categoryColor(exercise.category))
                    .frame(width: 6, height: 6)
            }
            .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .lineLimit(1)

                Text(exercise.displayDetail)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            Spacer(minLength: 0)

            if !exercise.weight.isEmpty {
                Text(exercise.weight)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(MVMTheme.cardSoft)
                    .clipShape(Capsule())
            }

            Button(role: .destructive) {
                withAnimation(.spring(response: 0.3)) {
                    let _ = editableExercises.remove(at: index)
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .frame(width: 28, height: 28)
                    .background(MVMTheme.cardSoft)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(MVMTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border)
        }
    }

    private func categoryColor(_ category: ExerciseCategory) -> Color {
        switch category {
        case .strength: return MVMTheme.accent
        case .cardio: return Color(hex: "#FF6B35")
        case .timed: return MVMTheme.slateAccent
        case .bodyweight: return MVMTheme.success
        }
    }

    private func rawTextToggle(_ extracted: PDFWorkoutExtractor.ExtractedWorkout) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showRawText.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: showRawText ? "chevron.down" : "chevron.right")
                        .font(.caption2.weight(.bold))
                    Text("Raw PDF Text")
                        .font(.caption.weight(.semibold))
                    Spacer()
                }
                .foregroundStyle(MVMTheme.tertiaryText)
            }
            .buttonStyle(.plain)

            if showRawText {
                Text(extracted.rawText.prefix(2000))
                    .font(.caption)
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .lineSpacing(3)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10).stroke(MVMTheme.border)
                    }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            if !didImport {
                Button {
                    importWorkout()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.down.doc.fill")
                            .font(.subheadline.weight(.bold))
                        Text("Import to My Workouts")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: MVMTheme.accent.opacity(0.3), radius: 12, y: 6)
                }
                .buttonStyle(PressScaleButtonStyle())
                .sensoryFeedback(.success, trigger: importTrigger)
                .disabled(editableExercises.isEmpty && editableTitle == "Imported Workout")

                Button {
                    addToPlan()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.subheadline.weight(.bold))
                        Text("Add to Weekly Plan")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16).stroke(MVMTheme.border)
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
                .disabled(editableExercises.isEmpty)
            } else {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(MVMTheme.success)
                    Text("Workout Imported")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(MVMTheme.success)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(MVMTheme.success.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(MVMTheme.success.opacity(0.3))
                }

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Logic

    private func handleFileResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            processPDF(url: url)
        case .failure:
            errorMessage = "Could not access the selected file. Please try again."
        }
    }

    private func processPDF(url: URL) {
        isProcessing = true
        errorMessage = nil
        extractedWorkout = nil

        let accessing = url.startAccessingSecurityScopedResource()

        Task {
            try? await Task.sleep(for: .milliseconds(500))

            guard let text = PDFWorkoutExtractor.extractText(from: url) else {
                if accessing { url.stopAccessingSecurityScopedResource() }
                isProcessing = false
                errorMessage = "Could not read the PDF. Make sure it contains text (not just images)."
                return
            }

            let extracted = PDFWorkoutExtractor.parseWorkout(from: text)

            if accessing { url.stopAccessingSecurityScopedResource() }

            extractedWorkout = extracted
            editableTitle = extracted.title
            editableExercises = extracted.exercises
            isProcessing = false
        }
    }

    private func importWorkout() {
        let tags = extractedWorkout?.tags ?? ["Imported"]
        let workout = WorkoutDay(
            dayIndex: 0,
            date: Calendar.current.startOfDay(for: .now),
            title: editableTitle,
            exercises: editableExercises,
            templateTag: "pdf_import",
            tags: tags,
            source: .imported
        )
        vm.saveImportedWorkout(workout)
        importTrigger.toggle()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            didImport = true
        }
    }

    private func addToPlan() {
        guard var plan = vm.currentPlan else {
            importWorkout()
            return
        }

        let tags = extractedWorkout?.tags ?? ["Imported"]

        if let restIdx = plan.days.firstIndex(where: { $0.isRestDay && !$0.isCompleted }) {
            plan.days[restIdx] = WorkoutDay(
                dayIndex: plan.days[restIdx].dayIndex,
                date: plan.days[restIdx].date,
                title: editableTitle,
                exercises: editableExercises,
                templateTag: "pdf_import",
                tags: tags,
                source: .imported
            )
            vm.importPlan(plan)
        } else if let uncompletedIdx = plan.days.lastIndex(where: { !$0.isCompleted && !$0.isRestDay }) {
            plan.days[uncompletedIdx] = WorkoutDay(
                dayIndex: plan.days[uncompletedIdx].dayIndex,
                date: plan.days[uncompletedIdx].date,
                title: editableTitle,
                exercises: editableExercises,
                templateTag: "pdf_import",
                tags: tags,
                source: .imported
            )
            vm.importPlan(plan)
        } else {
            importWorkout()
            return
        }

        importTrigger.toggle()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            didImport = true
        }
    }
}
