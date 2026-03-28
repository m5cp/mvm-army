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

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    profileSection {
                        profilePicker("PT Mode", selection: $ptModeRaw, values: PTMode.allCases.map(\.rawValue))
                        profilePicker("Duty Type", selection: $dutyTypeRaw, values: DutyType.allCases.map(\.rawValue))
                        profilePicker("Training Focus", selection: $trainingFocusRaw, values: TrainingFocus.allCases.map(\.rawValue))
                        profilePicker("Fitness Level", selection: $fitnessLevelRaw, values: FitnessLevel.allCases.map(\.rawValue))
                        profilePicker("Equipment", selection: $equipmentRaw, values: EquipmentOption.allCases.map(\.rawValue))
                    }

                    profileSection {
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

                    profileSection {
                        Toggle(isOn: $dailyReminderEnabled) {
                            Text("Daily Reminder")
                                .foregroundStyle(MVMTheme.primaryText)
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

                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
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

                    profileSection {
                        Picker("Appearance", selection: $appearanceModeRaw) {
                            ForEach(AppearanceMode.allCases) { mode in
                                Text(mode.title).tag(mode.rawValue)
                            }
                        }
                        .tint(MVMTheme.primaryText)
                    }

                    profileSection {
                        Button(role: .destructive) {
                            showResetAlert = true
                        } label: {
                            Text("Reset All Local Data")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            onboardingComplete = false
                        } label: {
                            Text("Re-run Onboarding")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundStyle(MVMTheme.primaryText)
                    }

                    disclaimerCard

                    profileSection {
                        profileInfo("Version", "3.0")
                        profileInfo("Brand", "MVM Army")
                        profileInfo("Tagline", "Me vs Me")
                    }
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
        .alert("Reset all data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                vm.resetAllData()
            }
        } message: {
            Text("This will erase all saved workouts, completed records, unit PT plans, and step history from this device.")
        }
    }

    private var disclaimerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(MVMTheme.warning)
                Text("Disclaimer")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }

            Text("MVM Army provides example workout structures for planning, organization, and accountability purposes only. It does not provide medical advice or prescribe exercise. Workouts are based on Army fitness test structures and general fitness formats. Consult a physician before beginning any exercise program.")
                .font(.caption)
                .foregroundStyle(MVMTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .premiumCard()
    }

    private func profileSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 14) {
            content()
        }
        .padding(18)
        .premiumCard()
    }

    private func profilePicker(_ title: String, selection: Binding<String>, values: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
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
            .frame(height: 52)
            .background(MVMTheme.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(MVMTheme.border)
            }
        }
    }

    private func profileInfo(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(MVMTheme.secondaryText)
            Spacer()
            Text(value)
                .foregroundStyle(MVMTheme.primaryText)
        }
    }
}
