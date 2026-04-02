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

    private let totalSteps: Int = 5

    var body: some View {
        GeometryReader { geo in
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    if step > 0 {
                        progressIndicator
                            .padding(.top, 16)
                            .padding(.horizontal, 32)
                    }

                    ScrollView(.vertical, showsIndicators: false) {
                        currentStepContent
                            .padding(.horizontal, 24)
                            .frame(maxWidth: min(geo.size.width - 48, 440))
                            .frame(maxWidth: .infinity)
                            .padding(.top, step == 0 ? 60 : 32)
                            .padding(.bottom, 24)
                    }

                    bottomButtons
                        .padding(.horizontal, 24)
                        .padding(.bottom, geo.safeAreaInsets.bottom > 0 ? 12 : 20)
                        .frame(maxWidth: min(geo.size.width - 48, 440))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: step)
    }

    // MARK: - Progress

    private var progressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(1..<totalSteps, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? MVMTheme.accent : Color.white.opacity(0.1))
                    .frame(height: 4)
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
        default: EmptyView()
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 32) {
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 28))

            VStack(spacing: 10) {
                Text("MVM ARMY")
                    .font(.system(size: 30, weight: .heavy))
                    .tracking(2.5)
                    .foregroundStyle(.white)

                Text("Me vs Me")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(MVMTheme.accent)
            }

            Text("Answer a few quick questions so we\ncan build your PT plan.")
                .font(.body)
                .foregroundStyle(MVMTheme.secondaryText)
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
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .tracking(0.5)

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
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .tracking(0.5)

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
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .tracking(0.5)

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
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(daysPerWeek)")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(MVMTheme.accent)
                            .contentTransition(.numericText())
                    }

                    HStack(spacing: 6) {
                        ForEach([2, 3, 4, 5, 6, 7], id: \.self) { d in
                            Button {
                                withAnimation(.spring(response: 0.25)) { daysPerWeek = d }
                            } label: {
                                Text("\(d)")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(daysPerWeek == d ? .white : MVMTheme.secondaryText)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(daysPerWeek == d ? MVMTheme.accent : Color.white.opacity(0.06))
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
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(minutesPerWorkout) min")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(MVMTheme.accent)
                            .contentTransition(.numericText())
                    }

                    HStack(spacing: 6) {
                        ForEach([20, 30, 45, 60], id: \.self) { m in
                            Button {
                                withAnimation(.spring(response: 0.25)) { minutesPerWorkout = m }
                            } label: {
                                Text("\(m)")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(minutesPerWorkout == m ? .white : MVMTheme.secondaryText)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(minutesPerWorkout == m ? MVMTheme.accent : Color.white.opacity(0.06))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Fitness Level")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .tracking(0.5)

                    HStack(spacing: 8) {
                        ForEach(FitnessLevel.allCases) { level in
                            Button {
                                fitnessLevelRaw = level.rawValue
                            } label: {
                                Text(level.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(fitnessLevelRaw == level.rawValue ? .white : MVMTheme.secondaryText)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(fitnessLevelRaw == level.rawValue ? MVMTheme.accent : Color.white.opacity(0.06))
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
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 8)

            VStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        hasAgreed = true
                    }
                    withAnimation { step += 1 }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.body.weight(.semibold))
                        Text("I Acknowledge — Full Access")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        hasAgreed = false
                    }
                    withAnimation { step += 1 }
                } label: {
                    Text("Skip — AFT Calculator Only")
                        .font(.headline.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
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

            VStack(spacing: 2) {
                reviewRow(label: "PT Mode", value: ptModeRaw)
                reviewRow(label: "Focus", value: trainingFocusRaw)
                reviewRow(label: "Equipment", value: equipmentRaw)
                reviewRow(label: "Days / Week", value: "\(daysPerWeek)")
                reviewRow(label: "Session", value: "\(minutesPerWorkout) min")
                reviewRow(label: "Level", value: fitnessLevelRaw)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))

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
                .background(MVMTheme.success.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(MVMTheme.warning)
                    Text("Calculator only — go back to accept terms for full access")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.warning)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(MVMTheme.warning.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func reviewRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(MVMTheme.card)
    }

    // MARK: - Buttons

    private var bottomButtons: some View {
        VStack(spacing: 8) {
            if step != 3 {
                Button {
                    handleNext()
                } label: {
                    HStack(spacing: 8) {
                        if isGenerating {
                            ProgressView()
                                .tint(step == 0 ? Color(hex: "#0A0A0F") : .white)
                        }
                        Text(nextButtonTitle)
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(step == 0 ? Color(hex: "#0A0A0F") : .white)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background {
                        if step == 0 {
                            Color.white
                        } else {
                            MVMTheme.heroGradient
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(isGenerating)
                .buttonStyle(PressScaleButtonStyle())
            }

            if step > 0 {
                Button {
                    withAnimation { step -= 1 }
                } label: {
                    Text("Back")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.secondaryText)
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
        case totalSteps - 1: return isGenerating ? "Building Your Plan..." : (hasAgreed ? "Build My Plan" : "Enter App")
        default: return "Continue"
        }
    }

    private func handleNext() {
        if step < totalSteps - 1 {
            withAnimation { step += 1 }
        } else {
            disclaimerAccepted = hasAgreed
            if hasAgreed {
                isGenerating = true
                Task {
                    try? await Task.sleep(for: .milliseconds(600))
                    vm.generateWeeklyPlan()
                    onboardingComplete = true
                }
            } else {
                onboardingComplete = true
            }
        }
    }

    // MARK: - Reusable Components

    private func sectionHeader(icon: String, title: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(MVMTheme.accent)

            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
        }
    }

    private func selectionRow(_ title: String, icon: String, subtitle: String? = nil, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : MVMTheme.accent)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? MVMTheme.accent : MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                }

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .padding(12)
            .background(isSelected ? MVMTheme.accent.opacity(0.1) : Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? MVMTheme.accent.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
