import SwiftUI
import UIKit
import PhotosUI
import RevenueCat

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
    @AppStorage("timeFormatPreference") private var timeFormatRaw = TimeFormatPreference.system.rawValue
    @AppStorage("appLockEnabled") private var appLockEnabled = false
    private var opsec = OPSECService.shared

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
    @State private var showDeleteConfirm: Bool = false
    @State private var showABCP = false
    @State private var showCFT = false
    @State private var showScoringReference = false
    @State private var copiedMemberID = false
    @State private var memberIDCopyTrigger = false
    @State private var appLockService = AppLockService()
    @State private var appLockErrorMessage: String?
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    profileHeader
                    AFTTrendChartView()
                    BadgesView()
                    subscriptionSection
                    currentGoalSection
                    fitnessStandardsSection
                    notificationsSection
                    appControlsSection
                    legalSection
                    dangerZoneSection
                    footer
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .adaptiveContainer()
            }
            .scrollDismissesKeyboard(.interactively)
            .hidesTabBarOnScroll()
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
        .sheet(isPresented: $showABCP) { ABCPView() }
        .sheet(isPresented: $showCFT) { CFTView() }
        .sheet(isPresented: $showScoringReference) { ScoringReferenceView() }
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
        .mvmCard(cornerRadius: 24)
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

    // MARK: - Fitness Standards

    private var fitnessStandardsSection: some View {
        settingsSection(title: "FITNESS STANDARDS", icon: "shield.checkered") {
            Button { showABCP = true } label: {
                settingsRowWithSubtitle(icon: "figure.stand", title: "Body Composition (ABCP)", subtitle: "WHtR calculator & screening history")
            }
            sectionDivider
            Button { showCFT = true } label: {
                settingsRowWithSubtitle(icon: "timer", title: "Combat Field Test (CFT)", subtitle: "7-event test day timer & history")
            }
            sectionDivider
            Button { showScoringReference = true } label: {
                settingsRowWithSubtitle(icon: "book.closed.fill", title: "Scoring References", subtitle: "Min/max for every event on every test")
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

    private var timeFormatPreference: TimeFormatPreference {
        TimeFormatPreference(rawValue: timeFormatRaw) ?? .system
    }

    private var appLockToggleBinding: Binding<Bool> {
        Binding(
            get: { appLockEnabled },
            set: { newValue in
                guard hasAppearedOnce else {
                    appLockEnabled = newValue
                    return
                }
                if newValue {
                    Task {
                        let success = await appLockService.authenticate()
                        if success {
                            appLockEnabled = true
                            appLockErrorMessage = nil
                        } else {
                            appLockErrorMessage = appLockService.lastError
                        }
                    }
                } else {
                    appLockEnabled = false
                    appLockErrorMessage = nil
                }
            }
        )
    }

    @AppStorage("serviceBranch") private var serviceBranchRaw: String = UserServiceBranch.army.rawValue
    @AppStorage("defaultCalculatorTest") private var defaultCalculatorTest: String = "AFT"

    private var currentBranch: UserServiceBranch {
        UserServiceBranch(rawValue: serviceBranchRaw) ?? .army
    }

    private var appControlsSection: some View {
        settingsSection(title: "APP", icon: "gearshape") {
            // Service branch — only changes which calculator opens first.
            // No stored records or syncing depend on it.
            Menu {
                ForEach(UserServiceBranch.allCases) { branch in
                    Button {
                        serviceBranchRaw = branch.rawValue
                        defaultCalculatorTest = branch.defaultTestRawValue
                    } label: {
                        Label(branch.rawValue, systemImage: branch.icon)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: currentBranch.icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Service Branch")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(MVMTheme.primaryText)
                        Text("\(currentBranch.rawValue) \(MVMTheme.dot) \(currentBranch.subtitle)")
                            .font(.caption2)
                            .foregroundStyle(MVMTheme.tertiaryText)
                            .lineLimit(1)
                    }
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                .frame(minHeight: 48)
                .contentShape(Rectangle())
            }
            .accessibilityLabel("Service branch, currently \(currentBranch.rawValue)")

            sectionDivider

            appIconRow

            sectionDivider

            HStack {
                Image(systemName: "faceid")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text("App Lock")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Require \(appLockService.biometryLabel) to open the app")
                        .font(.caption2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                Spacer()
                Toggle("", isOn: appLockToggleBinding)
                    .labelsHidden()
                    .tint(MVMTheme.accent)
            }
            .frame(minHeight: 48)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("App Lock, requires \(appLockService.biometryLabel) to open the app")

            sectionDivider
            opsecRows

            if let appLockErrorMessage {
                sectionDivider
                Text(appLockErrorMessage)
                    .font(.caption)
                    .foregroundStyle(MVMTheme.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
            }

            sectionDivider

            Menu {
                ForEach(TimeFormatPreference.allCases) { option in
                    Button {
                        timeFormatRaw = option.rawValue
                    } label: {
                        if option == timeFormatPreference {
                            Label(option.label, systemImage: "checkmark")
                        } else {
                            Text(option.label)
                        }
                    }
                }
            } label: {
                settingsRowWithSubtitle(icon: "clock", title: "Time Format", subtitle: timeFormatPreference.label)
            }
            .accessibilityLabel("Time Format")
            .accessibilityValue(timeFormatPreference.label)

            sectionDivider

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

        }
    }

    // MARK: - Legal

    private var legalSection: some View {
        settingsSection(title: "LEGAL", icon: "doc.text") {
            Button {
                UIPasteboard.general.string = Purchases.shared.appUserID
                memberIDCopyTrigger.toggle()
                copiedMemberID = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    copiedMemberID = false
                }
            } label: {
                memberIDRow
            }
            .sensoryFeedback(.success, trigger: memberIDCopyTrigger)
            .accessibilityHint("Copies your member ID for support requests")

            sectionDivider

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

    // MARK: - Danger Zone

    private var dangerZoneSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Delete All Data", systemImage: "trash.fill")
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Danger Zone")
                .font(.caption.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(MVMTheme.secondaryText)
        } footer: {
            Text("Permanently deletes all your workouts, AFT scores, plans, and settings. This cannot be undone.")
                .foregroundStyle(MVMTheme.secondaryText)
        }
        .confirmationDialog(
            "Delete All Data?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete Everything", role: .destructive) {
                vm.deleteAllData()
                UserDefaults.standard.set(false, forKey: "onboardingComplete")
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently erase all workouts, AFT scores, training plans, and your profile. You will be returned to onboarding.")
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 6) {
            Text("MVM FITNESS")
                .font(.caption.weight(.heavy))
                .tracking(2.0)
                .foregroundStyle(MVMTheme.secondaryText)
            Text("Me vs Me")
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                .font(.caption2)
                .foregroundStyle(MVMTheme.tertiaryText)

            Text(LegalText.nonAffiliation)
                .font(.system(size: 9))
                .foregroundStyle(MVMTheme.tertiaryText)
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
            .mvmCard(cornerRadius: 16)
        }
    }

    /// OPSEC controls. A fitness app's activity data has previously exposed the
    /// layout and patrol patterns of forward operating bases; these switches let
    /// a user shut that off without giving up the rest of the app.
    @ViewBuilder
    private var opsecRows: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.accent)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text("OPSEC Mode")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.primaryText)
                Text("Turns off GPS, iCloud sync and identity on anything you share")
                    .font(.caption2)
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Toggle("", isOn: Binding(get: { opsec.opsecMode }, set: { opsec.opsecMode = $0 }))
                .labelsHidden()
                .tint(MVMTheme.accent)
        }
        .frame(minHeight: 48)
        .accessibilityElement(children: .combine)

        sectionDivider
        opsecDetailRow(
            icon: "location.slash",
            title: "No GPS or route recording",
            subtitle: "Sessions still time and count. No location permission is requested.",
            isOn: Binding(get: { opsec.gpsDisabled }, set: { opsec.gpsDisabled = $0 })
        )

        sectionDivider
        opsecDetailRow(
            icon: "icloud.slash",
            title: "No iCloud sync",
            subtitle: "Everything stays in this device's storage only.",
            isOn: Binding(get: { opsec.iCloudDisabled }, set: { opsec.iCloudDisabled = $0 })
        )

        sectionDivider
        opsecDetailRow(
            icon: "person.slash",
            title: "Strip name and unit from shares",
            subtitle: "Scores still share. The person and the unit do not.",
            isOn: Binding(get: { opsec.stripIdentity }, set: { opsec.stripIdentity = $0 })
        )
    }

    private func opsecDetailRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.tertiaryText)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.primaryText)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(MVMTheme.accent)
        }
        .frame(minHeight: 48)
        .accessibilityElement(children: .combine)
    }

    private var sectionDivider: some View {
        Divider()
            .overlay(MVMTheme.border)
            .padding(.leading, 36)
    }

    private var memberIDRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.text.rectangle")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.accent)
                .frame(width: 24)
            Text("Member ID")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MVMTheme.primaryText)
            Spacer()
            if copiedMemberID {
                Text("Copied")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
            } else {
                Text(Purchases.shared.appUserID)
                    .font(MVMTheme.mono(11))
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: 140, alignment: .trailing)
            }
            Image(systemName: copiedMemberID ? "checkmark" : "doc.on.doc")
                .font(.caption2.weight(.bold))
                .foregroundStyle(copiedMemberID ? MVMTheme.accent : MVMTheme.tertiaryText)
        }
        .frame(minHeight: 48)
        .contentShape(Rectangle())
        .animation(.easeOut(duration: 0.2), value: copiedMemberID)
    }

    // MARK: - App Icon

    @State private var currentIconName: String? = nil
    @State private var iconRowLoaded = false

    private var appIconRow: some View {
        Menu {
            iconChoice(name: nil, label: "Classic")
            iconChoice(name: "AppIconDark", label: "Blackout")
            iconChoice(name: "AppIconGold", label: "Golden Hour")
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "app.badge")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text("App Icon")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text(currentIconLabel)
                        .font(.caption2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
        .onAppear {
            if !iconRowLoaded {
                iconRowLoaded = true
                currentIconName = UIApplication.shared.alternateIconName
            }
        }
        .accessibilityLabel("App icon, currently \(currentIconLabel)")
    }

    private var currentIconLabel: String {
        switch currentIconName {
        case "AppIconDark": return "Blackout"
        case "AppIconGold": return "Golden Hour"
        default: return "Classic"
        }
    }

    private func iconChoice(name: String?, label: String) -> some View {
        Button {
            guard UIApplication.shared.supportsAlternateIcons else { return }
            UIApplication.shared.setAlternateIconName(name)
            currentIconName = name
        } label: {
            if currentIconName == name {
                Label(label, systemImage: "checkmark")
            } else {
                Text(label)
            }
        }
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

    private func settingsRowWithSubtitle(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.accent)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.primaryText)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.tertiaryText)
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
