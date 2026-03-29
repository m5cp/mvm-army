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

    @State private var step = 0
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? .now
    @State private var direction: Int = 1

    private let totalSteps = 7

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()
            backgroundAmbience

            VStack(spacing: 0) {
                if step > 0 && step < totalSteps - 1 {
                    progressIndicator
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                }

                TabView(selection: $step) {
                    welcomeStep.tag(0)
                    ptModeStep.tag(1)
                    focusStep.tag(2)
                    scheduleStep.tag(3)
                    equipmentStep.tag(4)
                    reminderStep.tag(5)
                    disclaimerStep.tag(6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: step)

                bottomControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Progress

    private var progressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(1..<totalSteps - 1, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? MVMTheme.accent : MVMTheme.cardSoft)
                    .frame(height: 4)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: step)
            }
        }
    }

    // MARK: - Welcome

    private var welcomeStep: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(MVMTheme.accent.opacity(0.1))
                        .frame(width: 120, height: 120)

                    Circle()
                        .fill(MVMTheme.accent.opacity(0.18))
                        .frame(width: 88, height: 88)

                    Image(systemName: "shield.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(MVMTheme.heroGradient)
                }

                VStack(spacing: 12) {
                    Text("MVM ARMY")
                        .font(.system(size: 36, weight: .heavy))
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

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - PT Mode

    private var ptModeStep: some View {
        onboardingPage(
            icon: "figure.strengthtraining.traditional",
            title: "How will you train?",
            subtitle: "Choose your PT mode"
        ) {
            VStack(spacing: 12) {
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

    private var focusStep: some View {
        onboardingPage(
            icon: "target",
            title: "What's your focus?",
            subtitle: "We'll build your plan around this"
        ) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
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

    // MARK: - Schedule

    private var scheduleStep: some View {
        onboardingPage(
            icon: "calendar",
            title: "Set your schedule",
            subtitle: "Days per week and session length"
        ) {
            VStack(spacing: 28) {
                VStack(spacing: 14) {
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
                                    .frame(height: 52)
                                    .background(daysPerWeek == d ? MVMTheme.accent : MVMTheme.cardSoft)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay {
                                        if daysPerWeek == d {
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(MVMTheme.accent.opacity(0.5), lineWidth: 1.5)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(spacing: 14) {
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
                                    .frame(height: 52)
                                    .background(minutesPerWorkout == m ? MVMTheme.accent : MVMTheme.cardSoft)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay {
                                        if minutesPerWorkout == m {
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(MVMTheme.accent.opacity(0.5), lineWidth: 1.5)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Equipment

    private var equipmentStep: some View {
        onboardingPage(
            icon: "dumbbell.fill",
            title: "Available equipment?",
            subtitle: "Pick what you have access to"
        ) {
            VStack(spacing: 12) {
                ForEach(EquipmentOption.allCases) { equip in
                    onboardingOption(
                        title: equip.rawValue,
                        icon: equip.icon,
                        subtitle: equipSubtitle(equip),
                        isSelected: equipmentRaw == equip.rawValue
                    ) {
                        equipmentRaw = equip.rawValue
                    }
                }
            }
        }
    }

    private func equipSubtitle(_ equip: EquipmentOption) -> String {
        switch equip {
        case .bodyweight: return "No equipment needed"
        case .minimal: return "Bands, kettlebells, pull-up bar"
        case .gym: return "Full gym access"
        case .running: return "Track or road running"
        case .field: return "Outdoor / tactical environment"
        }
    }

    // MARK: - Reminder

    private var reminderStep: some View {
        onboardingPage(
            icon: "bell.badge",
            title: "Daily reminder?",
            subtitle: "Stay on track with a daily nudge"
        ) {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Reminder")
                            .font(.headline)
                            .foregroundStyle(MVMTheme.primaryText)
                        Text("One notification per day")
                            .font(.subheadline)
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                    Spacer()
                    Toggle("", isOn: $dailyReminderEnabled)
                        .tint(MVMTheme.accent)
                        .labelsHidden()
                }
                .padding(18)
                .background(MVMTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18).stroke(MVMTheme.border)
                }

                if dailyReminderEnabled {
                    DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .colorScheme(.dark)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
        }
    }

    // MARK: - Disclaimer

    private var disclaimerStep: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(MVMTheme.warning.opacity(0.1))
                        .frame(width: 80, height: 80)

                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(MVMTheme.warning)
                }

                VStack(spacing: 10) {
                    Text("Before you begin")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)

                    Text("MVM Army provides example workout structures for planning, organization, and accountability. It does not provide medical advice or prescribe exercise.")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                VStack(alignment: .leading, spacing: 10) {
                    disclaimerBullet(icon: "heart.text.square", text: "Consult a physician before starting any exercise program")
                    disclaimerBullet(icon: "shield.lefthalf.filled", text: "Workouts are based on Army fitness structures and templates")
                    disclaimerBullet(icon: "person.fill.questionmark", text: "You are responsible for your own fitness decisions")
                }
                .padding(18)
                .background(MVMTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18).stroke(MVMTheme.border)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }

    private func disclaimerBullet(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.warning)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    if step < totalSteps - 1 {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
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
                    .foregroundStyle(step == 0 ? Color(hex: "#1A1A2E") : .white)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background {
                        if step == 0 {
                            Color.white
                        } else {
                            MVMTheme.heroGradient
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: (step == 0 ? Color.white : MVMTheme.accent).opacity(0.2), radius: 16, y: 8)
            }
            .buttonStyle(PressScaleButtonStyle())

            if step > 0 {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
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
    }

    private var primaryButtonTitle: String {
        switch step {
        case 0: return "Get Started"
        case totalSteps - 1: return "I Understand — Begin"
        default: return "Continue"
        }
    }

    // MARK: - Reusable Components

    private func onboardingPage<Content: View>(
        icon: String,
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: icon)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(MVMTheme.accent)
                        Text(title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(MVMTheme.primaryText)
                    }

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                }

                content()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 80)
        }
    }

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
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : MVMTheme.accent)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? MVMTheme.accent : MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .padding(16)
            .background(isSelected ? MVMTheme.accent.opacity(0.08) : MVMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? MVMTheme.accent.opacity(0.4) : MVMTheme.border, lineWidth: isSelected ? 1.5 : 1)
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
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : MVMTheme.accent)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? MVMTheme.accent : MVMTheme.accent.opacity(0.12))
                    .clipShape(Circle())

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(isSelected ? MVMTheme.accent.opacity(0.08) : MVMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? MVMTheme.accent.opacity(0.4) : MVMTheme.border, lineWidth: isSelected ? 1.5 : 1)
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
