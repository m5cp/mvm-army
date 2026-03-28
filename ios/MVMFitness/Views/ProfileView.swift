import SwiftUI

struct ProfileView: View {
    @Environment(AppViewModel.self) private var vm

    @AppStorage("ptMode") private var ptModeRaw = PTMode.both.rawValue
    @AppStorage("dutyType") private var dutyTypeRaw = DutyType.both.rawValue
    @AppStorage("trainingFocus") private var trainingFocusRaw = TrainingFocus.generalArmyFitness.rawValue
    @AppStorage("fitnessLevel") private var fitnessLevelRaw = FitnessLevel.intermediate.rawValue
    @AppStorage("equipment") private var equipmentRaw = EquipmentOption.bodyweight.rawValue
    @AppStorage("daysPerWeek") private var daysPerWeek = 3
    @AppStorage("minutesPerWorkout") private var minutesPerWorkout = 30
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 6
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue
    @AppStorage("onboardingComplete") private var onboardingComplete = false

    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? .now
    @State private var showResetAlert = false
    @State private var showResetPlanAlert = false
    @State private var resetPlanTrigger = false
    @State private var resetAllTrigger = false

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    profileHeader

                    sectionCard(title: "Training Setup", icon: "figure.strengthtraining.traditional") {
                        profilePicker("PT Mode", selection: $ptModeRaw, values: PTMode.allCases.map(\.rawValue))
                        profilePicker("Duty Type", selection: $dutyTypeRaw, values: DutyType.allCases.map(\.rawValue))
                        profilePicker("Training Focus", selection: $trainingFocusRaw, values: TrainingFocus.allCases.map(\.rawValue))
                        profilePicker("Fitness Level", selection: $fitnessLevelRaw, values: FitnessLevel.allCases.map(\.rawValue))
                        profilePicker("Equipment", selection: $equipmentRaw, values: EquipmentOption.allCases.map(\.rawValue))

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Days per week")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(MVMTheme.primaryText)
                                Spacer()
                                Text("\(daysPerWeek)")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(MVMTheme.accent)
                            }
                            Picker("Days", selection: $daysPerWeek) {
                                ForEach(2...7, id: \.self) { d in
                                    Text("\(d)").tag(d)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Minutes per workout")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(MVMTheme.primaryText)
                                Spacer()
                                Text("\(minutesPerWorkout) min")
                                    .font(.subheadline.weight(.bold))
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

                    sectionCard(title: "Notifications", icon: "bell.badge") {
                        Toggle(isOn: $dailyReminderEnabled) {
                            HStack(spacing: 10) {
                                Text("Daily Reminder")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(MVMTheme.primaryText)
                            }
                        }
                        .tint(MVMTheme.accent)
                        .onChange(of: dailyReminderEnabled) { _, newValue in
                            Task {
                                if newValue {
                                    let granted = await NotificationManager.requestPermission()
                                    if granted {
                                        await NotificationManager.scheduleDailyReminder(at: reminderTime)
                                    }
                                } else {
                                    NotificationManager.removeDailyReminder()
                                }
                            }
                        }

                        if dailyReminderEnabled {
                            DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .font(.subheadline)
                                .colorScheme(.dark)
                                .onChange(of: reminderTime) { _, newValue in
                                    let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                    reminderHour = comps.hour ?? 6
                                    reminderMinute = comps.minute ?? 0
                                    Task {
                                        if dailyReminderEnabled {
                                            await NotificationManager.scheduleDailyReminder(at: newValue)
                                        }
                                    }
                                }
                        }
                    }

                    sectionCard(title: "Appearance", icon: "paintbrush") {
                        Picker("Appearance", selection: $appearanceModeRaw) {
                            ForEach(AppearanceMode.allCases) { mode in
                                Text(mode.title).tag(mode.rawValue)
                            }
                        }
                        .tint(MVMTheme.primaryText)
                    }

                    sectionCard(title: "App Controls", icon: "gearshape") {
                        Button {
                            showResetPlanAlert = true
                        } label: {
                            profileRow(icon: "arrow.clockwise", title: "Reset Weekly Plan", color: MVMTheme.warning)
                        }
                        .sensoryFeedback(.warning, trigger: resetPlanTrigger)

                        Divider().overlay(MVMTheme.border)

                        Button(role: .destructive) {
                            showResetAlert = true
                        } label: {
                            profileRow(icon: "trash", title: "Reset All Data", color: MVMTheme.danger)
                        }
                        .sensoryFeedback(.warning, trigger: resetAllTrigger)

                        Divider().overlay(MVMTheme.border)

                        Button {
                            onboardingComplete = false
                        } label: {
                            profileRow(icon: "arrow.counterclockwise", title: "Re-run Onboarding", color: MVMTheme.secondaryText)
                        }
                    }

                    sectionCard(title: "Legal & Info", icon: "doc.text") {
                        NavigationLink {
                            LegalTextView(title: "Privacy Policy", content: LegalContent.privacyPolicy)
                        } label: {
                            profileRow(icon: "lock.shield", title: "Privacy Policy", color: MVMTheme.accent, showChevron: true)
                        }

                        Divider().overlay(MVMTheme.border)

                        NavigationLink {
                            LegalTextView(title: "Apple EULA", content: LegalContent.appleEULA)
                        } label: {
                            profileRow(icon: "doc.plaintext", title: "Apple EULA", color: MVMTheme.accent, showChevron: true)
                        }

                        Divider().overlay(MVMTheme.border)

                        NavigationLink {
                            LegalTextView(title: "Disclaimer", content: LegalContent.disclaimer)
                        } label: {
                            profileRow(icon: "exclamationmark.triangle", title: "Disclaimer", color: MVMTheme.warning, showChevron: true)
                        }

                        Divider().overlay(MVMTheme.border)

                        NavigationLink {
                            LegalTextView(title: "Risks", content: LegalContent.risks)
                        } label: {
                            profileRow(icon: "heart.text.square", title: "Risks", color: MVMTheme.danger, showChevron: true)
                        }
                    }

                    VStack(spacing: 6) {
                        Text("MVM ARMY")
                            .font(.caption.weight(.heavy))
                            .tracking(2.0)
                            .foregroundStyle(MVMTheme.tertiaryText)

                        Text("Me vs Me")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText.opacity(0.6))

                        Text("Version 3.0")
                            .font(.caption2)
                            .foregroundStyle(MVMTheme.tertiaryText.opacity(0.4))
                    }
                    .padding(.top, 8)
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            reminderTime = Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? .now
        }
        .alert("Reset weekly plan?", isPresented: $showResetPlanAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset Plan", role: .destructive) {
                vm.generateWeeklyPlan()
                resetPlanTrigger.toggle()
            }
        } message: {
            Text("This will generate a new weekly plan, replacing the current one.")
        }
        .alert("Reset all data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                vm.resetAllData()
                resetAllTrigger.toggle()
            }
        } message: {
            Text("This will erase all saved workouts, completed records, unit PT plans, and step history from this device.")
        }
    }

    // MARK: - Header

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(MVMTheme.accent.opacity(0.12))
                    .frame(width: 72, height: 72)

                Image(systemName: "shield.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(MVMTheme.accent)
            }

            VStack(spacing: 4) {
                Text("MVM ARMY")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                HStack(spacing: 16) {
                    statPill(value: "\(vm.totalWorkoutsCompleted)", label: "Workouts")
                    statPill(value: "\(vm.streak)", label: "Streak")
                    statPill(value: "\(vm.aftScores.count)", label: "AFT Scores")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(MVMTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(MVMTheme.accent.opacity(0.12))
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func statPill(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
    }

    // MARK: - Section Card

    private func sectionCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 28, height: 28)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
            }

            content()
        }
        .padding(18)
        .premiumCard()
    }

    // MARK: - Profile Row

    private func profileRow(icon: String, title: String, color: Color, showChevron: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 24)

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MVMTheme.primaryText)

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }

    // MARK: - Pickers

    private func profilePicker(_ title: String, selection: Binding<String>, values: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.primaryText)

            Picker(title, selection: selection) {
                ForEach(values, id: \.self) { value in
                    Text(value).tag(value)
                }
            }
            .pickerStyle(.menu)
            .tint(MVMTheme.primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(MVMTheme.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(MVMTheme.border)
            }
        }
    }
}
