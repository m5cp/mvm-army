import SwiftUI

struct WODDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var wodTemplate: WODTemplate?
    @State private var workout: WorkoutDay?
    @State private var didComplete: Bool = false
    @State private var isLoading: Bool = true
    @State private var completeTrigger: Bool = false
    @State private var generateTrigger: Bool = false
    @State private var shareItems: [Any] = []
    @State private var showShareSheet: Bool = false
    @State private var showQRSheet: Bool = false

    let initialTemplate: WODTemplate?

    init(template: WODTemplate? = nil) {
        self.initialTemplate = template
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                if isLoading {
                    loadingState
                } else if let template = wodTemplate, let workout {
                    wodContent(template: template, workout: workout)
                } else {
                    unavailableState
                }
            }
            .navigationTitle("Workout of the Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showShareSheet) {
                if !shareItems.isEmpty {
                    ShareSheet(items: shareItems)
                }
            }
            .sheet(isPresented: $showQRSheet) {
                if let workout {
                    WorkoutQRSheet(workout: workout, workoutType: "WOD")
                }
            }
        }
        .onAppear {
            loadWOD()
        }
    }

    private func loadWOD() {
        if let initial = initialTemplate {
            wodTemplate = initial
            workout = WODService.convertToWorkoutDay(initial)
            isLoading = false
        } else {
            let template = WODService.generateWOD(
                equipment: vm.currentEquipment,
                dutyType: vm.currentDutyType
            )
            wodTemplate = template
            workout = WODService.convertToWorkoutDay(template)
            isLoading = false
        }
    }

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(MVMTheme.accent)
            Text("Generating WOD...")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MVMTheme.secondaryText)
        }
    }

    private var unavailableState: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.slash")
                .font(.system(size: 44))
                .foregroundStyle(MVMTheme.accent.opacity(0.5))

            Text("Workout of the Day Unavailable")
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text("Tap below to generate a new session")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)

            Button {
                generateAnother()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline.weight(.bold))
                    Text("Generate WOD")
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
            .padding(.horizontal, 40)
        }
        .padding(20)
    }

    private func wodContent(template: WODTemplate, workout: WorkoutDay) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                wodHeader(template)
                wodDetails(template)
                movementsList(template)
                actionButtons(workout)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 48)
            .adaptiveContainer()
        }
    }

    private func wodHeader(_ template: WODTemplate) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))

                Text("WOD")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                Text(template.format.rawValue)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
            }

            Text(template.title)
                .font(.title.weight(.bold))
                .foregroundStyle(.white)

            Text(template.workoutDescription)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
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

    private func wodDetails(_ template: WODTemplate) -> some View {
        HStack(spacing: 0) {
            detailPill(icon: "clock", value: "~\(template.durationMinutes) min", label: "Duration")
            detailDivider
            detailPill(icon: "tag", value: template.category.rawValue, label: "Type")
            detailDivider
            detailPill(icon: "wrench.and.screwdriver", value: template.equipment.rawValue, label: "Equipment")
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

    private func movementsList(_ template: WODTemplate) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MOVEMENTS")
                .font(.caption.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            ForEach(template.movements) { movement in
                HStack(spacing: 12) {
                    Circle()
                        .fill(MVMTheme.accent.opacity(0.3))
                        .frame(width: 8, height: 8)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(movement.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.primaryText)

                        HStack(spacing: 8) {
                            if let reps = movement.reps {
                                Text(reps)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(MVMTheme.accent)
                            }
                            if let dur = movement.duration {
                                Text(dur)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(MVMTheme.accent)
                            }
                            if let notes = movement.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(MVMTheme.tertiaryText)
                            }
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

            if let notes = template.notes, !notes.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.warning)
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                }
                .padding(12)
                .background(MVMTheme.warning.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func actionButtons(_ workout: WorkoutDay) -> some View {
        VStack(spacing: 10) {
            if !didComplete {
                Button {
                    completeTrigger.toggle()
                    var wodWorkout = workout
                    wodWorkout.source = .wod
                    vm.completeStandaloneWorkout(wodWorkout)
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
                    generateAnother()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption.weight(.bold))
                        Text("New WOD")
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
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    if let w = self.workout {
                        vm.saveImportedWorkout(w)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.caption.weight(.bold))
                        Text("Save")
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
                    shareItems = ShareCardRenderer.shareItems(
                        cardType: .workout(title: workout.title, exercises: workout.exercises, tags: [])
                    )
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

    private func generateAnother() {
        didComplete = false
        let template = WODService.generateWOD(
            equipment: vm.currentEquipment,
            dutyType: vm.currentDutyType
        )
        wodTemplate = template
        workout = WODService.convertToWorkoutDay(template)
    }
}
