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
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                backgroundGlow

                VStack(spacing: 0) {
                    if step > 0 && step < totalSteps - 1 {
                        progressBar
                            .padding(.top, 12)
                            .padding(.horizontal, 32)
                    }

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer(minLength: 20)

                            stepContent
                                .padding(.horizontal, 24)
                                .frame(maxWidth: min(geo.size.width - 48, 420))

                            Spacer(minLength: 20)
                        }
                        .frame(minHeight: geo.size.height - 180)
                    }

                    buttons
                        .padding(.horizontal, 24)
                        .padding(.bottom, geo.safeAreaInsets.bottom > 0 ? 8 : 16)
                        .frame(maxWidth: min(geo.size.width - 48, 420))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(1..<totalSteps - 1, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? MVMTheme.accent : Color.white.opacity(0.1))
                    .frame(height: 4)
            }
        }
    }

    // MARK: - Step Content Router

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0: welcomeContent
        case 1: ptModeContent
        case 2: focusContent
        case 3: scheduleContent
        case 4: equipmentContent
        case 5: disclaimerContent
        default: EmptyView()
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeContent: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 40)

            ZStack {
                Circle()
                    .fill(MVMTheme.accent.opacity(0.08))
                    .frame(width: 100, height: 100)
                Circle()
                    .fill(MVMTheme.accent.opacity(0.15))
                    .frame(width: 70, height: 70)
                Image(systemName: "shield.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(MVMTheme.heroGradient)
            }

            VStack(spacing: 8) {
                Text("MVM ARMY")
                    .font(.system(size: 28, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(.white)

                Text("Me vs Me")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(MVMTheme.accent)
            }

            Text("Build your PT. Track your progress.\nStay accountable.")
                .font(.body)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer(minLength: 40)
        }
    }

    // MARK: - Step 1: PT Mode

    private var ptModeContent: some View {
        cardWrapper(icon: "figure.strengthtraining.traditional", title: "How will you train?", subtitle: "Choose your PT mode") {
            VStack(spacing: 10) {
                modeRow("Individual PT", icon: "person.fill", sub: "Personal training sessions", value: PTMode.individual.rawValue)
                modeRow("Unit PT", icon: "person.3.fill", sub: "Lead formation PT", value: PTMode.unit.rawValue)
                modeRow("Both", icon: "person.2.fill", sub: "Individual + Unit PT", value: PTMode.both.rawValue)
            }
        }
    }

    private func modeRow(_ title: String, icon: String, sub: String, value: String) -> some View {
        let selected = ptModeRaw == value
        return Button {
            ptModeRaw = value
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(selected ? .white : MVMTheme.accent)
                    .frame(width: 36, height: 36)
                    .background(selected ? MVMTheme.accent : MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(sub)
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                }

                Spacer(minLength: 0)

                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .padding(12)
            .background(selected ? MVMTheme.accent.opacity(0.1) : Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? MVMTheme.accent.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 2: Focus

    private var focusContent: some View {
        cardWrapper(icon: "target", title: "What's your focus?", subtitle: "We'll build your plan around this") {
            VStack(spacing: 10) {
                ForEach(TrainingFocus.allCases) { focus in
                    let selected = trainingFocusRaw == focus.rawValue
                    Button {
                        trainingFocusRaw = focus.rawValue
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: focus.icon)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(selected ? .white : MVMTheme.accent)
                                .frame(width: 36, height: 36)
                                .background(selected ? MVMTheme.accent : MVMTheme.accent.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text(focus.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)

                            Spacer(minLength: 0)

                            if selected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(MVMTheme.accent)
                            }
                        }
                        .padding(12)
                        .background(selected ? MVMTheme.accent.opacity(0.1) : Color.white.opacity(0.03))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selected ? MVMTheme.accent.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Step 3: Schedule

    private var scheduleContent: some View {
        cardWrapper(icon: "calendar", title: "Set your schedule", subtitle: "Days per week and session length") {
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
                        ForEach([2, 3, 4, 5, 6], id: \.self) { d in
                            Button {
                                withAnimation(.spring(response: 0.25)) { daysPerWeek = d }
                            } label: {
                                Text("\(d)")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(daysPerWeek == d ? .white : MVMTheme.secondaryText)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(daysPerWeek == d ? MVMTheme.accent : Color.white.opacity(0.06))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
                                    .frame(height: 44)
                                    .background(minutesPerWorkout == m ? MVMTheme.accent : Color.white.opacity(0.06))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 4: Equipment

    private var equipmentContent: some View {
        cardWrapper(icon: "dumbbell.fill", title: "Available equipment?", subtitle: "Pick what you have access to") {
            VStack(spacing: 10) {
                ForEach(EquipmentOption.allCases) { equip in
                    let selected = equipmentRaw == equip.rawValue
                    Button {
                        equipmentRaw = equip.rawValue
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: equip.icon)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(selected ? .white : MVMTheme.accent)
                                .frame(width: 36, height: 36)
                                .background(selected ? MVMTheme.accent : MVMTheme.accent.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text(equip.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)

                            Spacer(minLength: 0)

                            if selected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(MVMTheme.accent)
                            }
                        }
                        .padding(12)
                        .background(selected ? MVMTheme.accent.opacity(0.1) : Color.white.opacity(0.03))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selected ? MVMTheme.accent.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Step 5: Disclaimer

    private var disclaimerContent: some View {
        cardWrapper(icon: "exclamationmark.shield.fill", title: "Before you begin", subtitle: "Please read carefully", iconColor: MVMTheme.warning) {
            VStack(spacing: 14) {
                Text("MVM Army provides workout structures for planning and accountability. It does not provide medical advice or prescribe exercise.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)

                VStack(alignment: .leading, spacing: 10) {
                    bulletPoint(icon: "heart.text.square", text: "Consult a physician before starting any exercise program")
                    bulletPoint(icon: "shield.lefthalf.filled", text: "Workouts are based on Army fitness templates")
                    bulletPoint(icon: "person.fill.questionmark", text: "You are responsible for your own fitness decisions")
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private func bulletPoint(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MVMTheme.warning)
                .frame(width: 18)
            Text(text)
                .font(.caption)
                .foregroundStyle(MVMTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Card Wrapper

    private func cardWrapper<Content: View>(
        icon: String,
        title: String,
        subtitle: String,
        iconColor: Color = MVMTheme.accent,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 18) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(iconColor)

                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Buttons

    private var buttons: some View {
        VStack(spacing: 8) {
            Button {
                handleNext()
            } label: {
                Text(step == 0 ? "Get Started" : step == totalSteps - 1 ? "I Understand — Begin" : "Continue")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(step == 0 ? Color(hex: "#0A0A0F") : .white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background {
                        if step == 0 {
                            Color.white
                        } else {
                            MVMTheme.heroGradient
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressScaleButtonStyle())

            if step > 0 {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) { step -= 1 }
                } label: {
                    Text("Back")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.secondaryText)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func handleNext() {
        if step < totalSteps - 1 {
            withAnimation(.easeInOut(duration: 0.3)) { step += 1 }
        } else {
            Task {
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
    }

    // MARK: - Background

    private var backgroundGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [MVMTheme.accent.opacity(0.06), .clear],
                    center: .center, startRadius: 0, endRadius: 250
                )
            )
            .frame(width: 500, height: 500)
            .offset(y: -180)
            .blur(radius: 60)
            .ignoresSafeArea()
    }
}
