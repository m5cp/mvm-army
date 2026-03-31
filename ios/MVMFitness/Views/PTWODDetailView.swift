import SwiftUI

struct PTWODDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var didComplete: Bool = false
    @State private var completeTrigger: Bool = false
    @State private var generateTrigger: Bool = false
    @State private var showQRSheet: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showCalendarSync: Bool = false
    @State private var calendarService = CalendarExportService()
    @State private var showExportAlert: Bool = false
    @State private var exportAlertMessage: String = ""

    private var workout: WorkoutDay? {
        vm.todayPTWorkout
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                if let workout, !workout.isRestDay {
                    ptContent(workout)
                } else {
                    noPlanState
                }
            }
            .navigationTitle("PT Workout of the Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showQRSheet) {
                if let workout {
                    WorkoutQRSheet(workout: workout, workoutType: "PT WOD")
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let workout {
                    PTWODShareSheet(workout: workout)
                }
            }
            .sheet(isPresented: $showCalendarSync) {
                calendarSyncSheet
            }
            .alert("Calendar", isPresented: $showExportAlert) {
                Button("OK") {}
            } message: {
                Text(exportAlertMessage)
            }
        }
        .onAppear {
            if let workout {
                didComplete = workout.isCompleted
            }
        }
    }

    private var noPlanState: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.run")
                .font(.system(size: 44))
                .foregroundStyle(MVMTheme.accent.opacity(0.5))

            Text("No PT Workout Today")
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text("Create a PT plan to get started")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
        }
        .padding(20)
    }

    private func ptContent(_ workout: WorkoutDay) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ptHeader(workout)
                ptDetails(workout)
                exercisesList(workout)
                actionButtons(workout)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 48)
            .adaptiveContainer()
        }
    }

    private func ptHeader(_ workout: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "figure.run")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))

                Text("PT WOD")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                if !workout.tags.isEmpty {
                    Text(workout.tags.first ?? "")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            Text(workout.title)
                .font(.title.weight(.bold))
                .foregroundStyle(.white)

            if workout.tags.count > 1 {
                Text(workout.tags.dropFirst().joined(separator: " · "))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(22)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#3B6DE0"), Color(hex: "#5B4DC7").opacity(0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 24)
                    .fill(MVMTheme.subtleGradient)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: MVMTheme.accent.opacity(0.2), radius: 20, y: 12)
    }

    private func ptDetails(_ workout: WorkoutDay) -> some View {
        let mins = max(workout.exercises.count * 4, 15)
        return HStack(spacing: 0) {
            detailPill(icon: "clock", value: "~\(mins) min", label: "Duration")
            detailDivider
            detailPill(icon: "list.bullet", value: "\(workout.exercises.count)", label: "Exercises")
            detailDivider
            detailPill(icon: "tag", value: workout.source.rawValue, label: "Type")
        }
        .padding(.vertical, 14)
        .background(MVMTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(MVMTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var detailDivider: some View {
        Rectangle()
            .fill(MVMTheme.border)
            .frame(width: 1, height: 28)
    }

    private func detailPill(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                Text(value)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private func exercisesList(_ workout: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EXERCISES")
                .font(.caption.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            ForEach(workout.exercises) { exercise in
                HStack(spacing: 12) {
                    Circle()
                        .fill(exercise.isCompleted ? MVMTheme.success.opacity(0.6) : MVMTheme.accent.opacity(0.3))
                        .frame(width: 8, height: 8)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(exercise.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.primaryText)

                        Text(exercise.displayDetail)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(MVMTheme.accent)

                        if !exercise.notes.isEmpty {
                            Text(exercise.notes)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(MVMTheme.card)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(MVMTheme.border)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func actionButtons(_ workout: WorkoutDay) -> some View {
        VStack(spacing: 10) {
            if !didComplete {
                Button {
                    completeTrigger.toggle()
                    vm.markDayCompleted(dayIndex: workout.dayIndex)
                    didComplete = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline.weight(.bold))
                        Text("Log Workout")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: MVMTheme.accent.opacity(0.28), radius: 14, y: 8)
                }
                .sensoryFeedback(.success, trigger: completeTrigger)
                .buttonStyle(PressScaleButtonStyle())
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(MVMTheme.success)
                    Text("Workout Logged & Tracked")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(MVMTheme.success)
                }
                .frame(height: 52)
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: 10) {
                Button {
                    generateTrigger.toggle()
                    if let today = vm.todayWorkout {
                        vm.regenerateSingleDay(dayIndex: today.dayIndex)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption.weight(.bold))
                        Text("New PT")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(MVMTheme.border)
                    }
                }
                .sensoryFeedback(.impact(weight: .medium), trigger: generateTrigger)
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    showCalendarSync = true
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.secondaryText)
                        .frame(width: 44, height: 44)
                        .background(MVMTheme.cardSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(MVMTheme.border)
                        }
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    showQRSheet = true
                } label: {
                    Image(systemName: "qrcode")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.secondaryText)
                        .frame(width: 44, height: 44)
                        .background(MVMTheme.cardSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(MVMTheme.border)
                        }
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.secondaryText)
                        .frame(width: 44, height: 44)
                        .background(MVMTheme.cardSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(MVMTheme.border)
                        }
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
    }

    private var calendarSyncSheet: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40))
                    .foregroundStyle(MVMTheme.accent)
                    .padding(.top, 8)

                Text("Sync to Calendar")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Add this PT workout to your iOS Calendar.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                if let workout {
                    Button {
                        Task {
                            let result = await calendarService.exportWorkout(workout)
                            handleExportResult(result)
                            showCalendarSync = false
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if calendarService.isExporting {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.subheadline.weight(.bold))
                            }
                            Text("Sync to Calendar")
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
                    showCalendarSync = false
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

    private func handleExportResult(_ result: CalendarExportService.ExportResult) {
        switch result {
        case .success(let count):
            exportAlertMessage = "\(count) workout\(count == 1 ? "" : "s") synced to calendar."
        case .partial(let exported, let failed):
            exportAlertMessage = "\(exported) exported, \(failed) failed."
        case .denied:
            exportAlertMessage = "Calendar access denied. Go to Settings to enable."
        case .error(let message):
            exportAlertMessage = "Sync failed: \(message)"
        }
        showExportAlert = true
    }
}

struct PTWODShareSheet: View {
    let workout: WorkoutDay
    @Environment(\.dismiss) private var dismiss
    @State private var showSavedToast: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Image(systemName: "figure.run")
                                .font(.system(size: 40))
                                .foregroundStyle(MVMTheme.accent)

                            Text(workout.title)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(MVMTheme.primaryText)
                                .multilineTextAlignment(.center)

                            Text("\(workout.exercises.count) exercises · PT WOD")
                                .font(.subheadline)
                                .foregroundStyle(MVMTheme.secondaryText)
                        }
                        .padding(24)
                        .premiumCard()

                        VStack(spacing: 12) {
                            Button {
                                ShareCardRenderer.presentShareSheet(
                                    cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                                )
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                    Text("Share as Card")
                                }
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(height: 52)
                                .frame(maxWidth: .infinity)
                                .background(MVMTheme.heroGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(PressScaleButtonStyle())

                            let shareText = buildShareText()
                            ShareLink(item: shareText) {
                                HStack(spacing: 10) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share as Text")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(MVMTheme.accent)
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                                .background(MVMTheme.accent.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(PressScaleButtonStyle())

                            Button {
                                let image = ShareCardRenderer.renderImage(
                                    cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                                )
                                if let image {
                                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                    showSavedToast = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showSavedToast = false
                                    }
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Save to Photos")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(MVMTheme.secondaryText)
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                                .background(MVMTheme.cardSoft)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14).stroke(MVMTheme.border)
                                }
                            }
                            .buttonStyle(PressScaleButtonStyle())
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Share PT WOD")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .overlay {
                if showSavedToast {
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
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSavedToast)
                }
            }
        }
    }

    private func buildShareText() -> String {
        var text = "MVM Army — PT WOD: \(workout.title)\n"
        text += "\(workout.exercises.count) exercises\n\n"
        for exercise in workout.exercises {
            text += "• \(exercise.name) — \(exercise.displayDetail)\n"
        }
        text += "\n#MVMArmy #ArmyFitness"
        return text
    }
}
