import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(StoreViewModel.self) private var store

    @AppStorage("ptGoal") private var ptGoalRaw = ""
    @AppStorage("planWeeks") private var planWeeks = 4
    @AppStorage("daysPerWeek") private var daysPerWeek = 3
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 6
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("profileDisplayName") private var profileDisplayName = ""

    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? .now
    @State private var showResetAlert = false
    @State private var showResetPlanAlert = false
    @State private var resetPlanTrigger = false
    @State private var resetAllTrigger = false
    @State private var showAvatarPicker = false
    @State private var showUpgrade = false
    @State private var restoreTrigger = false
    @State private var imageManager = ProfileImageManager()
    @State private var isEditingName: Bool = false
    @State private var hasAppearedOnce: Bool = false
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    profileHeader
                    subscriptionSection
                    currentGoalSection
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                hasAppearedOnce = true
            }
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
        if let goal = PTGoal(rawValue: ptGoalRaw) {
            return "\(goal.rawValue) · \(planWeeks)-Week Plan"
        }
        return "No goal set · Open Plan My Individual PT"
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

    // MARK: - Subscription Management

    private var subscriptionSection: some View {
        settingsSection(title: "SUBSCRIPTION", icon: "crown") {
            if store.isPremium {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.heroAmber)
                        .frame(width: 24)
                    Text("MVM Pro Active")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.primaryText)
                    Spacer()
                    Text("PRO")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(MVMTheme.heroAmber)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(MVMTheme.heroAmber.opacity(0.15))
                        .clipShape(Capsule())
                }
                .frame(minHeight: 48)
            } else {
                Button {
                    showUpgrade = true
                } label: {
                    settingsRow(icon: "crown.fill", title: "Upgrade to Pro", color: MVMTheme.heroAmber, showChevron: true)
                }
            }

            sectionDivider

            Button {
                restoreTrigger.toggle()
                Task { await store.restore() }
            } label: {
                settingsRow(icon: "arrow.triangle.2.circlepath", title: "Restore Purchases", color: MVMTheme.accent)
            }
            .sensoryFeedback(.impact(weight: .light), trigger: restoreTrigger)

            sectionDivider

            Button {
                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                    UIApplication.shared.open(url)
                }
            } label: {
                settingsRow(icon: "creditcard", title: "Manage Subscription", color: MVMTheme.slateAccent, showChevron: true)
            }
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
        }
    }

    // MARK: - Current Goal

    private var currentGoalSection: some View {
        settingsSection(title: "CURRENT GOAL", icon: "target") {
            if let goal = PTGoal(rawValue: ptGoalRaw) {
                VStack(spacing: 12) {
                    HStack(spacing: 14) {
                        Image(systemName: goal.icon)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(
                                    colors: [MVMTheme.accent, MVMTheme.accent2],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(goal.rawValue)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(MVMTheme.primaryText)
                            Text(goal.subtitle)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(MVMTheme.tertiaryText)
                                .lineLimit(2)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)

                    HStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text("\(planWeeks)")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(MVMTheme.accent)
                            Text("Weeks")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }
                        .frame(maxWidth: .infinity)

                        Rectangle()
                            .fill(MVMTheme.border)
                            .frame(width: 1, height: 28)

                        VStack(spacing: 2) {
                            Text("\(vm.currentPlan?.currentWeek ?? 1)")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(MVMTheme.accent)
                            Text("Current")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }
                        .frame(maxWidth: .infinity)

                        Rectangle()
                            .fill(MVMTheme.border)
                            .frame(width: 1, height: 28)

                        VStack(spacing: 2) {
                            Text("\(daysPerWeek)")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(MVMTheme.accent)
                            Text("Days/Wk")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(12)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.vertical, 4)
            } else {
                VStack(spacing: 12) {
                    HStack(spacing: 14) {
                        Image(systemName: "target")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(MVMTheme.secondaryText)
                            .frame(width: 44, height: 44)
                            .background(MVMTheme.cardSoft)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 3) {
                            Text("No Goal Set")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(MVMTheme.primaryText)
                            Text("Open Plan My Individual PT to set your training goal and plan duration")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(MVMTheme.tertiaryText)
                                .lineLimit(2)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)
                }
                .padding(.vertical, 4)
            }
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
                guard hasAppearedOnce else { return }
                Task {
                    if newValue {
                        let granted = await NotificationManager.requestPermission()
                        if granted {
                            await NotificationManager.scheduleDailyReminder(at: reminderTime)
                        } else {
                            dailyReminderEnabled = false
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

            NavigationLink {
                ResourcesView()
            } label: {
                settingsRow(icon: "tablecells", title: "Scoring Reference", color: MVMTheme.accent, showChevron: true)
            }

            sectionDivider

            NavigationLink {
                CompetitorComparisonView()
            } label: {
                settingsRow(icon: "medal.fill", title: "Why MVM?", color: MVMTheme.heroAmber, showChevron: true)
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
            .accessibilityHint("View the app privacy policy")

            sectionDivider

            NavigationLink {
                LegalTextView(title: "Terms of Use", content: LegalContent.termsOfUse)
            } label: {
                settingsRow(icon: "doc.plaintext", title: "Terms of Use", color: MVMTheme.accent, showChevron: true)
            }
            .accessibilityHint("View the terms of use")

            sectionDivider

            NavigationLink {
                LegalTextView(title: "Disclaimer", content: LegalContent.disclaimer)
            } label: {
                settingsRow(icon: "exclamationmark.triangle", title: "Disclaimer", color: MVMTheme.warning, showChevron: true)
            }
            .accessibilityHint("View the fitness disclaimer")

            sectionDivider

            NavigationLink {
                LegalTextView(title: "Risks", content: LegalContent.risks)
            } label: {
                settingsRow(icon: "heart.text.square", title: "Risks", color: MVMTheme.danger, showChevron: true)
            }
            .accessibilityHint("View exercise risk information")

            sectionDivider

            NavigationLink {
                LegalTextView(title: "Accessibility", content: LegalContent.accessibilityStatement)
            } label: {
                settingsRow(icon: "accessibility", title: "Accessibility", color: MVMTheme.accent, showChevron: true)
            }
            .accessibilityHint("View the accessibility statement")

            sectionDivider

            NavigationLink {
                LegalTextView(title: "EULA", content: LegalContent.eula)
            } label: {
                settingsRow(icon: "doc.badge.gearshape", title: "EULA", color: MVMTheme.slateAccent, showChevron: true)
            }
            .accessibilityHint("View the end user license agreement")
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 6) {
            Text("MVM FITNESS")
                .font(.caption.weight(.heavy))
                .tracking(2.0)
                .foregroundStyle(MVMTheme.tertiaryText)
            Text("Me vs Me")
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText.opacity(0.6))
            Text("Version 5.0")
                .font(.caption2)
                .foregroundStyle(MVMTheme.tertiaryText.opacity(0.4))

            Text("Not affiliated with, endorsed by, or sponsored by the U.S. Department of War, the Department of the Army, or any government agency.")
                .font(.system(size: 9))
                .foregroundStyle(MVMTheme.tertiaryText.opacity(0.35))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.top, 4)
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
