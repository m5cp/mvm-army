import SwiftUI
import PhotosUI

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
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("profileDisplayName") private var profileDisplayName = ""

    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? .now
    @State private var showResetAlert = false
    @State private var showResetPlanAlert = false
    @State private var resetPlanTrigger = false
    @State private var resetAllTrigger = false
    @State private var showAvatarPicker = false
    @State private var imageManager = ProfileImageManager()
    @State private var isEditingName: Bool = false
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    profileHeader
                    trainingSection
                    notificationsSection
                    appControlsSection
                    legalSection
                    footer
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .adaptiveContainer()
            }
            .scrollDismissesKeyboard(.interactively)
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
                imageManager.removeImage()
                profileDisplayName = ""
                resetAllTrigger.toggle()
            }
        } message: {
            Text("This will erase all saved workouts, completed records, unit PT plans, and step history from this device.")
        }
        .sheet(isPresented: $showAvatarPicker) {
            avatarPickerSheet
        }
        .onChange(of: imageManager.selectedItem) { _, newItem in
            Task {
                await imageManager.handlePickerItem(newItem)
                imageManager.selectedItem = nil
            }
        }
    }

    // MARK: - Header

    private var profileHeader: some View {
        VStack(spacing: 20) {
            Button {
                showAvatarPicker = true
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    avatarImage
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())

                    Circle()
                        .fill(MVMTheme.card)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(MVMTheme.accent)
                        }
                        .overlay {
                            Circle().stroke(MVMTheme.background, lineWidth: 2)
                        }
                }
            }
            .buttonStyle(.plain)

            VStack(spacing: 8) {
                if isEditingName {
                    TextField("Soldier", text: $profileDisplayName)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                        .multilineTextAlignment(.center)
                        .focused($nameFieldFocused)
                        .submitLabel(.done)
                        .onSubmit { isEditingName = false }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(MVMTheme.cardSoft)
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(MVMTheme.accent.opacity(0.3))
                        }
                        .frame(maxWidth: 240)
                } else {
                    Button {
                        isEditingName = true
                        nameFieldFocused = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(profileDisplayName.isEmpty ? "Soldier" : profileDisplayName)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(MVMTheme.primaryText)
                            Image(systemName: "pencil")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }
                    }
                    .buttonStyle(.plain)
                }

                Text(profileSubtitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.accent)
            }

            HStack(spacing: 0) {
                statCell(value: "\(vm.totalWorkoutsCompleted)", label: "Workouts")
                dividerLine
                statCell(value: "\(vm.streak)", label: "Streak")
                dividerLine
                statCell(value: "\(vm.aftScores.count)", label: "AFT")
            }
            .padding(.vertical, 14)
            .background(MVMTheme.cardSoft)
            .clipShape(.rect(cornerRadius: 14))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(MVMTheme.card)
        .clipShape(.rect(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(MVMTheme.border)
        }
    }

    @ViewBuilder
    private var avatarImage: some View {
        if let image = imageManager.profileImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let avatarIdx = imageManager.selectedAvatarIndex,
                  avatarIdx < ProfileImageManager.avatarSymbols.count {
            Circle()
                .fill(MVMTheme.accent.opacity(0.15))
                .overlay {
                    Image(systemName: ProfileImageManager.avatarSymbols[avatarIdx])
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(MVMTheme.accent)
                }
        } else {
            Circle()
                .fill(MVMTheme.accent.opacity(0.12))
                .overlay {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(MVMTheme.accent)
                }
        }
    }

    private var profileSubtitle: String {
        let mode = PTMode(rawValue: ptModeRaw)?.rawValue ?? "Both"
        let focus = TrainingFocus(rawValue: trainingFocusRaw)?.rawValue ?? "General"
        return "\(mode) · \(focus)"
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(MVMTheme.border)
            .frame(width: 1, height: 28)
    }

    // MARK: - Training

    private var trainingSection: some View {
        settingsSection(title: "TRAINING", icon: "figure.strengthtraining.traditional") {
            settingsMenuRow(
                icon: "target",
                title: "Training Focus",
                currentValue: trainingFocusRaw,
                values: TrainingFocus.allCases.map(\.rawValue),
                selection: $trainingFocusRaw
            )
            sectionDivider
            settingsMenuRow(
                icon: "chart.bar.fill",
                title: "Fitness Level",
                currentValue: fitnessLevelRaw,
                values: FitnessLevel.allCases.map(\.rawValue),
                selection: $fitnessLevelRaw
            )
            sectionDivider
            settingsMenuRow(
                icon: "dumbbell.fill",
                title: "Equipment",
                currentValue: equipmentRaw,
                values: EquipmentOption.allCases.map(\.rawValue),
                selection: $equipmentRaw
            )
            sectionDivider
            settingsMenuRow(
                icon: "person.2.fill",
                title: "PT Mode",
                currentValue: ptModeRaw,
                values: PTMode.allCases.map(\.rawValue),
                selection: $ptModeRaw
            )
            sectionDivider
            settingsMenuRow(
                icon: "briefcase.fill",
                title: "Duty Type",
                currentValue: dutyTypeRaw,
                values: DutyType.allCases.map(\.rawValue),
                selection: $dutyTypeRaw
            )
            sectionDivider
            settingsMenuRow(
                icon: "calendar",
                title: "Days per Week",
                currentValue: "\(daysPerWeek)",
                values: (1...7).map { "\($0)" },
                intSelection: $daysPerWeek
            )
            sectionDivider
            settingsMenuRow(
                icon: "clock.fill",
                title: "Workout Duration",
                currentValue: "\(minutesPerWorkout) min",
                values: ["20", "30", "45", "60"],
                intSelection: $minutesPerWorkout
            )
        }
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        settingsSection(title: "NOTIFICATIONS", icon: "bell.badge") {
            HStack {
                Image(systemName: "bell.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 24)
                Text("Daily Reminder")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.primaryText)
                Spacer()
                Toggle("", isOn: $dailyReminderEnabled)
                    .labelsHidden()
                    .tint(MVMTheme.accent)
            }
            .frame(minHeight: 44)
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
                sectionDivider
                HStack {
                    Image(systemName: "clock")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)
                        .frame(width: 24)
                    Text("Time")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.primaryText)
                    Spacer()
                    DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .colorScheme(.dark)
                }
                .frame(minHeight: 44)
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
    }

    // MARK: - App Controls

    private var appControlsSection: some View {
        settingsSection(title: "APP", icon: "gearshape") {
            Button {
                showResetPlanAlert = true
            } label: {
                settingsRow(icon: "arrow.clockwise", title: "Reset Weekly Plan", color: MVMTheme.warning)
            }
            .sensoryFeedback(.warning, trigger: resetPlanTrigger)

            sectionDivider

            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                settingsRow(icon: "trash", title: "Reset All Data", color: MVMTheme.danger)
            }
            .sensoryFeedback(.warning, trigger: resetAllTrigger)

            sectionDivider

            Button {
                onboardingComplete = false
            } label: {
                settingsRow(icon: "arrow.counterclockwise", title: "Re-run Onboarding", color: MVMTheme.secondaryText)
            }
        }
    }

    // MARK: - Legal

    private var legalSection: some View {
        settingsSection(title: "LEGAL", icon: "doc.text") {
            NavigationLink {
                LegalTextView(title: "Privacy Policy", content: LegalContent.privacyPolicy)
            } label: {
                settingsRow(icon: "lock.shield", title: "Privacy Policy", color: MVMTheme.accent, showChevron: true)
            }

            sectionDivider

            NavigationLink {
                LegalTextView(title: "Apple EULA", content: LegalContent.appleEULA)
            } label: {
                settingsRow(icon: "doc.plaintext", title: "Apple EULA", color: MVMTheme.accent, showChevron: true)
            }

            sectionDivider

            NavigationLink {
                LegalTextView(title: "Disclaimer", content: LegalContent.disclaimer)
            } label: {
                settingsRow(icon: "exclamationmark.triangle", title: "Disclaimer", color: MVMTheme.warning, showChevron: true)
            }

            sectionDivider

            NavigationLink {
                LegalTextView(title: "Risks", content: LegalContent.risks)
            } label: {
                settingsRow(icon: "heart.text.square", title: "Risks", color: MVMTheme.danger, showChevron: true)
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 6) {
            Text("MVM ARMY")
                .font(.caption.weight(.heavy))
                .tracking(2.0)
                .foregroundStyle(MVMTheme.tertiaryText)
            Text("Me vs Me")
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText.opacity(0.6))
            Text("Version 4.0")
                .font(.caption2)
                .foregroundStyle(MVMTheme.tertiaryText.opacity(0.4))
        }
        .padding(.top, 8)
    }

    // MARK: - Reusable Components

    private func settingsSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
                Text(title)
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 10)

            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(MVMTheme.card)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(MVMTheme.border)
            }
        }
    }

    private var sectionDivider: some View {
        Divider()
            .overlay(MVMTheme.border)
            .padding(.leading, 36)
    }

    private func settingsRow(icon: String, title: String, color: Color, showChevron: Bool = false) -> some View {
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
        .frame(minHeight: 48)
        .contentShape(Rectangle())
    }

    private func settingsMenuRow(icon: String, title: String, currentValue: String, values: [String], selection: Binding<String>) -> some View {
        Menu {
            ForEach(values, id: \.self) { value in
                Button {
                    selection.wrappedValue = value
                } label: {
                    HStack {
                        Text(value)
                        if value == selection.wrappedValue {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 24)
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.primaryText)
                Spacer()
                Text(currentValue)
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
    }

    private func settingsMenuRow(icon: String, title: String, currentValue: String, values: [String], intSelection: Binding<Int>) -> some View {
        Menu {
            ForEach(values, id: \.self) { value in
                Button {
                    intSelection.wrappedValue = Int(value) ?? intSelection.wrappedValue
                } label: {
                    HStack {
                        Text(title.contains("Duration") ? "\(value) min" : value)
                        if Int(value) == intSelection.wrappedValue {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 24)
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.primaryText)
                Spacer()
                Text(currentValue)
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
    }

    // MARK: - Avatar Picker Sheet

    private var avatarPickerSheet: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            Text("Choose Profile Image")
                                .font(.headline)
                                .foregroundStyle(MVMTheme.primaryText)
                            Text("Upload a photo or pick an avatar")
                                .font(.subheadline)
                                .foregroundStyle(MVMTheme.secondaryText)
                        }

                        PhotosPicker(selection: Binding(
                            get: { imageManager.selectedItem },
                            set: { imageManager.selectedItem = $0 }
                        ), matching: .images) {
                            HStack(spacing: 10) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.subheadline.weight(.semibold))
                                Text("Choose from Library")
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(height: 52)
                            .frame(maxWidth: .infinity)
                            .background(MVMTheme.heroGradient)
                            .clipShape(.rect(cornerRadius: 16))
                        }
                        .buttonStyle(PressScaleButtonStyle())

                        VStack(alignment: .leading, spacing: 14) {
                            Text("AVATARS")
                                .font(.caption.weight(.bold))
                                .tracking(1.0)
                                .foregroundStyle(MVMTheme.tertiaryText)

                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(Array(ProfileImageManager.avatarOptions.enumerated()), id: \.offset) { index, avatar in
                                    let isSelected = imageManager.selectedAvatarIndex == index && imageManager.profileImage == nil
                                    Button {
                                        imageManager.selectAvatar(index)
                                        showAvatarPicker = false
                                    } label: {
                                        VStack(spacing: 6) {
                                            Circle()
                                                .fill(isSelected ? MVMTheme.accent.opacity(0.2) : MVMTheme.cardSoft)
                                                .frame(width: 56, height: 56)
                                                .overlay {
                                                    Image(systemName: avatar.symbol)
                                                        .font(.title3.weight(.bold))
                                                        .foregroundStyle(isSelected ? MVMTheme.accent : MVMTheme.secondaryText)
                                                }
                                                .overlay {
                                                    Circle()
                                                        .stroke(isSelected ? MVMTheme.accent : MVMTheme.border, lineWidth: isSelected ? 2 : 1)
                                                }
                                            Text(avatar.label)
                                                .font(.caption2.weight(.medium))
                                                .foregroundStyle(isSelected ? MVMTheme.accent : MVMTheme.tertiaryText)
                                                .lineLimit(1)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if imageManager.profileImage != nil || imageManager.selectedAvatarIndex != nil {
                            Button {
                                imageManager.removeImage()
                                showAvatarPicker = false
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark.circle")
                                        .font(.subheadline.weight(.semibold))
                                    Text("Remove Image")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .foregroundStyle(MVMTheme.danger)
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                                .background(MVMTheme.danger.opacity(0.1))
                                .clipShape(.rect(cornerRadius: 14))
                            }
                            .buttonStyle(PressScaleButtonStyle())
                        }
                    }
                    .padding(20)
                    .adaptiveContainer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showAvatarPicker = false }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
