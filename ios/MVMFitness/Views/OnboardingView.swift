import SwiftUI

struct OnboardingView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete: Bool = false
    @AppStorage("ptMode") private var ptModeRaw: String = PTMode.both.rawValue
    @AppStorage("trainingFocus") private var trainingFocusRaw: String = TrainingFocus.generalArmyFitness.rawValue
    @AppStorage("fitnessLevel") private var fitnessLevelRaw: String = FitnessLevel.intermediate.rawValue
    @AppStorage("equipment") private var equipmentRaw: String = EquipmentOption.bodyweight.rawValue
    @AppStorage("daysPerWeek") private var daysPerWeek: Int = 3
    @AppStorage("minutesPerWorkout") private var minutesPerWorkout: Int = 30
    @AppStorage("disclaimerAccepted") private var disclaimerAccepted: Bool = false

    @Environment(AppViewModel.self) private var vm

    @State private var step: Int = 0
    @State private var isGenerating: Bool = false
    @State private var hasAgreed: Bool = false

    private let totalSteps: Int = 7 // steps 5 (paywall) and 6 (notification primer) added in Phase 4

    var body: some View {
        GeometryReader { geo in
            ZStack {
                MVMTheme.screen.ignoresSafeArea()

                RadialGradient(
                    stops: [
                        .init(color: MVMTheme.amber.opacity(0.16), location: 0),
                        .init(color: .clear, location: 0.6)
                    ],
                    center: .init(x: 0.5, y: -0.05),
                    startRadius: 0,
                    endRadius: 460
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button {
                            skipOnboarding()
                        } label: {
                            Text("Skip")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(MVMTheme.textMuted)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(MVMTheme.well)
                                .overlay(Capsule().stroke(MVMTheme.hairline, lineWidth: 1))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 20)

                    if step > 0 {
                        progressIndicator
                            .padding(.top, 12)
                            .padding(.horizontal, 32)
                    }

                    ScrollView(.vertical, showsIndicators: false) {
                        currentStepContent
                            .padding(.horizontal, 24)
                            .frame(maxWidth: min(geo.size.width - 48, 440))
                            .frame(maxWidth: .infinity)
                            .padding(.top, step == 0 ? 40 : 32)
                            .padding(.bottom, 24)
                    }

                    if step < 5 {
                        bottomButtons
                            .padding(.horizontal, 24)
                            .padding(.bottom, geo.safeAreaInsets.bottom > 0 ? 12 : 20)
                            .frame(maxWidth: min(geo.size.width - 48, 440))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: step)
    }

    private func skipOnboarding() {
        disclaimerAccepted = false
        hasAgreed = false
        onboardingComplete = true
        AnalyticsService.track(.onboardingSkipped)
    }

    // MARK: - Progress

    private var progressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(1..<5, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? MVMTheme.amber : MVMTheme.well)
                    .frame(height: 4)
                    .overlay(Capsule().stroke(MVMTheme.hairline, lineWidth: i <= step ? 0 : 1))
                    .animation(.spring(response: 0.3), value: step)
            }
        }
    }

    // MARK: - Step Router

    @ViewBuilder
    private var currentStepContent: some View {
        switch step {
        case 0: welcomeStep
        case 1: trainingSetupStep
        case 2: scheduleStep
        case 3: disclaimerStep
        case 4: reviewStep
        case 5: OnboardingPaywallView { withAnimation { step = 6 } }
        case 6: NotificationPrimerView { onboardingComplete = true }
        default: EmptyView()
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(MVMTheme.cardGradient)
                    .frame(width: 132, height: 132)
                    .overlay(Circle().stroke(MVMTheme.hairline, lineWidth: 1))
                    .shadow(color: .black.opacity(0.6), radius: 16, y: 12)
                Image("mvm-glyph-summit-m")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 66)
            }

            VStack(spacing: 10) {
                Text("MVM FIT")
                    .font(.system(size: 30, weight: .heavy))
                    .tracking(2.5)
                    .foregroundStyle(MVMTheme.text)

                Text("Me vs Me")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(MVMTheme.amber)
            }

            Text("Answer a few quick questions so we\ncan build your PT plan.")
                .font(.body)
                .foregroundStyle(MVMTheme.textMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    // MARK: - Step 1: Training Setup (Mode + Focus + Equipment)

    private var trainingSetupStep: some View {
        VStack(spacing: 28) {
            sectionHeader(icon: "figure.strengthtraining.traditional", title: "Training Setup")

            VStack(alignment: .leading, spacing: 8) {
                Text("PT Mode")
                    .font(MVMTheme.mono(11))
                    .kerning(1.4)
                    .foregroundStyle(MVMTheme.textFaint)

                VStack(spacing: 8) {
                    selectionRow("Individual PT", icon: "person.fill", subtitle: "Personal sessions", isSelected: ptModeRaw == PTMode.individual.rawValue) {
                        ptModeRaw = PTMode.individual.rawValue
                    }
                    selectionRow("Unit PT", icon: "person.3.fill", subtitle: "Lead formation PT", isSelected: ptModeRaw == PTMode.unit.rawValue) {
                        ptModeRaw = PTMode.unit.rawValue
                    }
                    selectionRow("Both", icon: "person.2.fill", subtitle: "Individual + Unit PT", isSelected: ptModeRaw == PTMode.both.rawValue) {
                        ptModeRaw = PTMode.both.rawValue
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Training Focus")
                    .font(MVMTheme.mono(11))
                    .kerning(1.4)
                    .foregroundStyle(MVMTheme.textFaint)

                VStack(spacing: 8) {
                    ForEach(TrainingFocus.allCases) { focus in
                        selectionRow(focus.rawValue, icon: focus.icon, isSelected: trainingFocusRaw == focus.rawValue) {
                            trainingFocusRaw = focus.rawValue
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Equipment")
                    .font(MVMTheme.mono(11))
                    .kerning(1.4)
                    .foregroundStyle(MVMTheme.textFaint)

                VStack(spacing: 8) {
                    ForEach(EquipmentOption.allCases) { equip in
                        selectionRow(equip.rawValue, icon: equip.icon, isSelected: equipmentRaw == equip.rawValue) {
                            equipmentRaw = equip.rawValue
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 2: Schedule

    private var scheduleStep: some View {
        VStack(spacing: 28) {
            sectionHeader(icon: "calendar", title: "Your Schedule")

            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    HStack {
                        Text("Days per week")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.text)
                        Spacer()
                        Text("\(daysPerWeek)")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(MVMTheme.amber)
                            .contentTransition(.numericText())
                    }

                    HStack(spacing: 6) {
                        ForEach([2, 3, 4, 5, 6, 7], id: \.self) { d in
                            Button {
                                withAnimation(.spring(response: 0.25)) { daysPerWeek = d }
                            } label: {
                                Text("\(d)")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(daysPerWeek == d ? MVMTheme.onAmber : MVMTheme.textMuted)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(daysPerWeek == d ? AnyView(MVMTheme.amberButtonGradient) : AnyView(MVMTheme.well))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.hairline, lineWidth: daysPerWeek == d ? 0 : 1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(spacing: 10) {
                    HStack {
                        Text("Session length")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.text)
                        Spacer()
                        Text("\(minutesPerWorkout) min")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(MVMTheme.amber)
                            .contentTransition(.numericText())
                    }

                    HStack(spacing: 6) {
                        ForEach([20, 30, 45, 60], id: \.self) { m in
                            Button {
                                withAnimation(.spring(response: 0.25)) { minutesPerWorkout = m }
                            } label: {
                                Text("\(m)")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(minutesPerWorkout == m ? MVMTheme.onAmber : MVMTheme.textMuted)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(minutesPerWorkout == m ? AnyView(MVMTheme.amberButtonGradient) : AnyView(MVMTheme.well))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.hairline, lineWidth: minutesPerWorkout == m ? 0 : 1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Fitness Level")
                        .font(MVMTheme.mono(11))
                        .kerning(1.4)
                        .foregroundStyle(MVMTheme.textFaint)

                    HStack(spacing: 8) {
                        ForEach(FitnessLevel.allCases) { level in
                            Button {
                                fitnessLevelRaw = level.rawValue
                            } label: {
                                Text(level.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(fitnessLevelRaw == level.rawValue ? MVMTheme.onAmber : MVMTheme.textMuted)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(fitnessLevelRaw == level.rawValue ? AnyView(MVMTheme.amberButtonGradient) : AnyView(MVMTheme.well))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.hairline, lineWidth: fitnessLevelRaw == level.rawValue ? 0 : 1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 3: Disclaimer

    private var disclaimerStep: some View {
        VStack(spacing: 32) {
            sectionHeader(icon: "shield.checkered", title: "Before You Begin")

            Text("MVM Fitness is a fitness tracking and accountability tool. All workout templates and AFT scoring are based on publicly available fitness standards. This app does not provide medical advice, coaching, or exercise instruction. You choose and perform all exercises at your own risk.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.textMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 8)

            VStack(spacing: 12) {
                AmberButton(title: "I Acknowledge — Full Access") {
                    withAnimation(.spring(response: 0.3)) {
                        hasAgreed = true
                    }
                    withAnimation { step += 1 }
                }

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        hasAgreed = false
                    }
                    withAnimation { step += 1 }
                } label: {
                    Text("Skip — AFT Calculator Only")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(MVMTheme.textMuted)
                        .frame(height: 54)
                        .frame(maxWidth: .infinity)
                        .background(MVMTheme.well)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(MVMTheme.hairline, lineWidth: 1)
                        )
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
    }

    // MARK: - Step 4: Review + Build

    private var reviewStep: some View {
        VStack(spacing: 28) {
            sectionHeader(icon: "checkmark.shield.fill", title: "Ready to Build")

            RaisedCard {
                VStack(spacing: 0) {
                    reviewRow(label: "PT Mode", value: ptModeRaw)
                    Divider().overlay(MVMTheme.hairline)
                    reviewRow(label: "Focus", value: trainingFocusRaw)
                    Divider().overlay(MVMTheme.hairline)
                    reviewRow(label: "Equipment", value: equipmentRaw)
                    Divider().overlay(MVMTheme.hairline)
                    reviewRow(label: "Days / Week", value: "\(daysPerWeek)")
                    Divider().overlay(MVMTheme.hairline)
                    reviewRow(label: "Session", value: "\(minutesPerWorkout) min")
                    Divider().overlay(MVMTheme.hairline)
                    reviewRow(label: "Level", value: fitnessLevelRaw)
                }
            }

            if hasAgreed {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(MVMTheme.success)
                    Text("Terms accepted — full access enabled")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.success)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(MVMTheme.success.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.success.opacity(0.3), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(MVMTheme.amber)
                    Text("Calculator only — go back to accept terms for full access")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.amber)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(MVMTheme.amber.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.amber.opacity(0.3), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func reviewRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.textMuted)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.text)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
    }

    // MARK: - Buttons

    private var bottomButtons: some View {
        VStack(spacing: 8) {
            if step != 3 {
                AmberButton(title: nextButtonTitle) {
                    handleNext()
                }
                .overlay {
                    if isGenerating {
                        ProgressView().tint(MVMTheme.onAmber)
                    }
                }
                .disabled(isGenerating)
            }

            if step > 0 {
                Button {
                    withAnimation { step -= 1 }
                } label: {
                    Text("Back")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.textMuted)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var nextButtonTitle: String {
        switch step {
        case 0: return "Get Started"
        case 4: return isGenerating ? "Building Your Plan..." : (hasAgreed ? "Build My Plan" : "Enter App")
        default: return "Continue"
        }
    }

    private func handleNext() {
        if step < 4 {
            withAnimation { step += 1 }
            AnalyticsService.track(.onboardingStepCompleted)
        } else if step == 4 {
            disclaimerAccepted = hasAgreed
            if hasAgreed {
                isGenerating = true
                Task {
                    try? await Task.sleep(for: .milliseconds(600))
                    vm.generateWeeklyPlan()
                    isGenerating = false
                    withAnimation { step = 5 }
                    AnalyticsService.track(.onboardingStepCompleted)
                }
            } else {
                withAnimation { step = 5 }
                AnalyticsService.track(.onboardingStepCompleted)
            }
        }
        // Steps 5 and 6 advance via their own buttons (paywall / primer views).
    }

    // MARK: - Reusable Components

    private func sectionHeader(icon: String, title: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(MVMTheme.amber)

            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.text)
        }
    }

    private func selectionRow(_ title: String, icon: String, subtitle: String? = nil, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isSelected ? MVMTheme.onAmber : MVMTheme.amber)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? AnyView(MVMTheme.amberButtonGradient) : AnyView(MVMTheme.amber.opacity(0.12)))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.text)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(MVMTheme.textMuted)
                    }
                }

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(MVMTheme.amber)
                }
            }
            .padding(12)
            .background(isSelected ? MVMTheme.amber.opacity(0.1) : MVMTheme.well)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? MVMTheme.amber.opacity(0.4) : MVMTheme.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
