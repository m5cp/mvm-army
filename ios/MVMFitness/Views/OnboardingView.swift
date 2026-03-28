import SwiftUI

struct OnboardingView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("trainingGoal") private var trainingGoalRaw = TrainingGoal.generalFitness.rawValue
    @AppStorage("fitnessLevel") private var fitnessLevelRaw = FitnessLevel.intermediate.rawValue
    @AppStorage("equipment") private var equipmentRaw = EquipmentOption.bodyweight.rawValue
    @AppStorage("daysPerWeek") private var daysPerWeek = 3
    @AppStorage("minutesPerWorkout") private var minutesPerWorkout = 30
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 6
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @State private var step = 1
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? .now

    private let totalSteps = 5

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("MVM Fitness")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(MVMTheme.primaryText)

                        Text("Me vs Me")
                            .font(.headline)
                            .foregroundStyle(MVMTheme.secondaryText)
                    }

                    Spacer()

                    Text("Step \(step) / \(totalSteps)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(MVMTheme.cardSoft)
                        .clipShape(Capsule())
                }

                Spacer()

                Group {
                    switch step {
                    case 1:
                        onboardingCard(
                            title: "What's your training goal?",
                            subtitle: "We'll build your weekly plan around this."
                        ) {
                            selectableGrid(TrainingGoal.allCases.map(\.rawValue), selection: $trainingGoalRaw)
                        }

                    case 2:
                        onboardingCard(
                            title: "Your fitness level",
                            subtitle: "This adjusts volume and intensity."
                        ) {
                            selectableGrid(FitnessLevel.allCases.map(\.rawValue), selection: $fitnessLevelRaw)
                        }

                    case 3:
                        onboardingCard(
                            title: "Equipment available",
                            subtitle: "We'll tailor exercises to what you have."
                        ) {
                            selectableGrid(EquipmentOption.allCases.map(\.rawValue), selection: $equipmentRaw)
                        }

                    case 4:
                        onboardingCard(
                            title: "Training schedule",
                            subtitle: "How many days and how long per session."
                        ) {
                            VStack(alignment: .leading, spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Days per week")
                                            .font(.headline)
                                            .foregroundStyle(MVMTheme.primaryText)
                                        Spacer()
                                        Text("\(daysPerWeek)")
                                            .font(.headline)
                                            .foregroundStyle(MVMTheme.accent)
                                    }
                                    Picker("Days", selection: $daysPerWeek) {
                                        ForEach(2...6, id: \.self) { d in
                                            Text("\(d)").tag(d)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Minutes per workout")
                                            .font(.headline)
                                            .foregroundStyle(MVMTheme.primaryText)
                                        Spacer()
                                        Text("\(minutesPerWorkout) min")
                                            .font(.headline)
                                            .foregroundStyle(MVMTheme.accent)
                                    }
                                    Picker("Minutes", selection: $minutesPerWorkout) {
                                        Text("20").tag(20)
                                        Text("30").tag(30)
                                        Text("45").tag(45)
                                        Text("60").tag(60)
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }
                        }

                    default:
                        onboardingCard(
                            title: "You're ready",
                            subtitle: "Plan. Train. Repeat."
                        ) {
                            VStack(alignment: .leading, spacing: 16) {
                                Toggle(isOn: $dailyReminderEnabled) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Daily reminder")
                                            .font(.headline)
                                            .foregroundStyle(MVMTheme.primaryText)
                                        Text("Get one local notification per day.")
                                            .font(.subheadline)
                                            .foregroundStyle(MVMTheme.secondaryText)
                                    }
                                }
                                .tint(MVMTheme.accent)

                                DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                    .colorScheme(.dark)

                                Text("MVM Fitness provides example workout structures for planning, organization, and accountability purposes only. It does not provide medical advice or prescribe exercise. Consult a physician before beginning any exercise program.")
                                    .font(.caption)
                                    .foregroundStyle(MVMTheme.tertiaryText)
                            }
                        }
                    }
                }

                Spacer()

                HStack {
                    if step > 1 {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                step -= 1
                            }
                        } label: {
                            Text("Back")
                                .font(.headline)
                                .foregroundStyle(MVMTheme.primaryText)
                                .frame(height: 56)
                                .frame(maxWidth: 120)
                                .background(MVMTheme.cardSoft)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(MVMTheme.border)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }

                    Spacer()

                    Button {
                        Task {
                            if step < totalSteps {
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
                        Text(step == totalSteps ? "Begin" : "Continue")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .background(MVMTheme.heroGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: MVMTheme.accent.opacity(0.35), radius: 18, y: 10)
                    }
                }
            }
            .padding(24)
        }
    }

    @ViewBuilder
    private func onboardingCard<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(MVMTheme.primaryText)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)

            content()
        }
        .padding(22)
        .premiumCard()
    }

    private func selectableGrid(_ items: [String], selection: Binding<String>) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(items, id: \.self) { item in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selection.wrappedValue = item
                    }
                } label: {
                    Text(item)
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .padding(.horizontal, 8)
                        .background {
                            if selection.wrappedValue == item {
                                MVMTheme.heroGradient.opacity(0.22)
                            } else {
                                MVMTheme.cardSoft
                            }
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(selection.wrappedValue == item ? MVMTheme.accent : MVMTheme.border, lineWidth: 1.2)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
