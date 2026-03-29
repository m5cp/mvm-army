import SwiftUI

struct OnboardingView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("ptMode") private var ptModeRaw = PTMode.both.rawValue
    @AppStorage("trainingFocus") private var trainingFocusRaw = TrainingFocus.generalArmyFitness.rawValue
    @AppStorage("fitnessLevel") private var fitnessLevelRaw = FitnessLevel.intermediate.rawValue
    @AppStorage("equipment") private var equipmentRaw = EquipmentOption.bodyweight.rawValue
    @AppStorage("daysPerWeek") private var daysPerWeek = 3
    @AppStorage("minutesPerWorkout") private var minutesPerWorkout = 30
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 6
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @State private var step: Int = 0
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? .now

    private let totalSteps = 6

    var body: some View {
        GeometryReader { geo in
            let isWide = geo.size.width > 600
            let contentWidth = isWide ? min(geo.size.width * 0.55, 520.0) : geo.size.width - 48

            ZStack {
                MVMTheme.background.ignoresSafeArea()
                backgroundAmbience

                VStack(spacing: 0) {
                    if step > 0 && step < totalSteps - 1 {
                        progressIndicator
                            .frame(maxWidth: contentWidth)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                    }

                    Spacer(minLength: 0)

                    Group {
                        switch step {
                        case 0: welcomeStep(contentWidth: contentWidth)
                        case 1: ptModeStep(contentWidth: contentWidth)
                        case 2: focusStep(contentWidth: contentWidth)
                        case 3: scheduleStep(contentWidth: contentWidth)
                        case 4: equipmentStep(contentWidth: contentWidth)
                        case 5: disclaimerStep(contentWidth: contentWidth)
                        default: EmptyView()
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

                    Spacer(minLength: 0)

                    bottomControls(contentWidth: contentWidth)
                        .padding(.bottom, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.88), value: step)
    }

    // MARK: - Progress

    private var progressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(1..<totalSteps - 1, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? MVMTheme.accent : MVMTheme.cardSoft)
                    .frame(height: 4)
            }
        }
    }

    // MARK: - Welcome

    private func welcomeStep(contentWidth: CGFloat) -> some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(MVMTheme.accent.opacity(0.08))
                    .frame(width: 110, height: 110)
                Circle()
                    .fill(MVMTheme.accent.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "shield.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(MVMTheme.heroGradient)
            }

            VStack(spacing: 10) {
                Text("MVM ARMY")
                    .font(.system(size: 32, weight: .heavy))
                    .tracking(2.0)
                    .foregroundStyle(MVMTheme.primaryText)
                Text("Me vs Me")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(MVMTheme.accent)
            }

            Text("Build your PT. Track your progress.\nStay accountable.")
                .font(.body)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: contentWidth)
    }

    // MARK: - PT Mode

    private func ptModeStep(contentWidth: CGFloat) -> some View {
        glassCard(contentWidth: contentWidth) {
            VStack(spacing: 20) {
                stepHeader(icon: "figure.strengthtraining.traditional", title: "How will you train?", subtitle: "Choose your PT mode")

                VStack(spacing: 10) {
                    ForEach(PTMode.allCases) { mode in
                        onboardingOption(
                            title: mode.rawValue,
                            icon: modeIcon(mode),
                            subtitle: modeSubtitle(mode),
                            isSelected: ptModeRaw == mode.rawValue
                        ) {
                            ptModeRaw = mode.rawValue
                        }
                    }
                }
            }
        }
    }

    private func modeIcon(_ mode: PTMode) -> String {
        switch mode {
        case .individual: return "person.fill"
        case .unit: return "person.3.fill"
        case .both: return "person.2.fill"
        }
    }

    private func modeSubtitle(_ mode: PTMode) -> String {
        switch mode {
        case .individual: return "Personal training sessions"
        case .unit: return "Lead formation PT"
        case .both: return "Individual + Unit PT"
        }
    }

    // MARK: - Focus

    private func focusStep(contentWidth: CGFloat) -> some View {
        glassCard(contentWidth: contentWidth) {
            VStack(spacing: 20) {
                stepHeader(icon: "target", title: "What's your focus?", subtitle: "We'll build your plan around this")

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(TrainingFocus.allCases) { focus in
                        onboardingChip(
                            title: focus.rawValue,
                            icon: focus.icon,
                            isSelected: trainingFocusRaw == focus.rawValue
                        ) {
                            trainingFocusRaw = focus.rawValue
                        }
                    }
                }
            }
        }
    }

    // MARK: - Schedule

    private func scheduleStep(contentWidth: CGFloat) -> some View {
        glassCard(contentWidth: contentWidth) {
            VStack(spacing: 24) {
                stepHeader(icon: "calendar", title: "Set your schedule", subtitle: "Days per week and session length")

                VStack(spacing: 12) {
                    HStack {
                        Text("Days per week")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.primaryText)
                        Spacer()
                        Text("\(daysPerWeek)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(MVMTheme.accent)
                            .contentTransition(.numericText())
                    }

                    HStack(spacing: 8) {
                        ForEach(2...6, id: \.self) { d in
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    daysPerWeek = d
                                }
                            } label: {
                                Text("\(d)")
                                    .font(.headline.weight(.bold))
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

                VStack(spacing: 12) {
                    HStack {
                        Text("Session length")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.primaryText)
                        Spacer()
                        Text("\(minutesPerWorkout) min")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(MVMTheme.accent)
                            .contentTransition(.numericText())
                    }

                    HStack(spacing: 8) {
                        ForEach([20, 30, 45, 60], id: \.self) { m in
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    minutesPerWorkout = m
                                }
                            } label: {
                                Text("\(m)")
                                    .font(.headline.weight(.bold))
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
            }
        }
    }

    // MARK: - Equipment

    private func equipmentStep(contentWidth: CGFloat) -> some View {
        glassCard(contentWidth: contentWidth) {
            VStack(spacing: 20) {
                stepHeader(icon: "dumbbell.fill", title: "Available equipment?", subtitle: "Pick what you have access to")

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(EquipmentOption.allCases) { equip in
                        onboardingChip(
                            title: equip.rawValue,
                            icon: equip.icon,
                            isSelected: equipmentRaw == equip.rawValue
                        ) {
                            equipmentRaw = equip.rawValue
                        }
                    }
                }
            }
        }
    }

    // MARK: - Disclaimer

    private func disclaimerStep(contentWidth: CGFloat) -> some View {
        glassCard(contentWidth: contentWidth) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(MVMTheme.warning.opacity(0.1))
                        .frame(width: 72, height: 72)
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(MVMTheme.warning)
                }

                VStack(spacing: 8) {
                    Text("Before you begin")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)

                    Text("MVM Army provides example workout structures for planning, organization, and accountability. It does not provide medical advice or prescribe exercise.")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 10) {
                    disclaimerBullet(icon: "heart.text.square", text: "Consult a physician before starting any exercise program")
                    disclaimerBullet(icon: "shield.lefthalf.filled", text: "Workouts are based on Army fitness structures and templates")
                    disclaimerBullet(icon: "person.fill.questionmark", text: "You are responsible for your own fitness decisions")
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func disclaimerBullet(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.warning)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Bottom Controls

    private func bottomControls(contentWidth: CGFloat) -> some View {
        VStack(spacing: 10) {
            Button {
                Task {
                    if step < totalSteps - 1 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.88)) {
                            step += 1
                        }
                    } else {
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                        reminderHour = comps.hour ?? 6
                        reminderMinute = comps.minute ?? 0

                        if dailyReminderEnabled {
                            let granted = await NotificationManager.requestPermission()
                            if granted {
                                await NotificationManager.scheduleDailyReminder(at: reminderTime)
                            }
                        }

                        onboardingComplete = true
                    }
                }
            } label: {
                Text(primaryButtonTitle)
                    .font(.headline.weight(.bold))
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
                    .shadow(color: (step == 0 ? Color.white : MVMTheme.accent).opacity(0.15), radius: 12, y: 6)
            }
            .buttonStyle(PressScaleButtonStyle())

            if step > 0 {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.88)) {
                        step -= 1
                    }
                } label: {
                    Text("Back")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: contentWidth)
    }

    private var primaryButtonTitle: String {
        switch step {
        case 0: return "Get Started"
        case totalSteps - 1: return "I Understand — Begin"
        default: return "Continue"
        }
    }

    // MARK: - Glass Card Container

    private func glassCard<Content: View>(contentWidth: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            content()
                .padding(20)
        }
        .frame(maxWidth: contentWidth)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial.opacity(0.3))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Step Header

    private func stepHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(MVMTheme.accent)

            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Reusable Components

    private func onboardingOption(
        title: String,
        icon: String,
        subtitle: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                action()
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : MVMTheme.accent)
                    .frame(width: 40, height: 40)
                    .background(isSelected ? MVMTheme.accent : MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                }

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .padding(14)
            .background(isSelected ? MVMTheme.accent.opacity(0.08) : Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? MVMTheme.accent.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func onboardingChip(
        title: String,
        icon: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                action()
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : MVMTheme.accent)
                    .frame(width: 40, height: 40)
                    .background(isSelected ? MVMTheme.accent : MVMTheme.accent.opacity(0.12))
                    .clipShape(Circle())

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 6)
            .background(isSelected ? MVMTheme.accent.opacity(0.08) : Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? MVMTheme.accent.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Background

    private var backgroundAmbience: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [MVMTheme.accent.opacity(0.06), .clear],
                        center: .center, startRadius: 0, endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .offset(y: -200)
                .blur(radius: 80)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [MVMTheme.accent2.opacity(0.04), .clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 100, y: 200)
                .blur(radius: 60)
        }
        .ignoresSafeArea()
    }
}
