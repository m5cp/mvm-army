import SwiftUI
import CoreImage.CIFilterBuiltins

struct WODPlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var selectedGoal: PTGoal = .aftScoreImprovement
    @State private var selectedWeeks: Int = 4
    @State private var selectedHeroPreference: WODHeroPreference = .regular
    @State private var showGoalSetup: Bool = false
    @State private var animateCards: Bool = false
    @State private var refreshTrigger: Bool = false

    @State private var showCalendarSheet: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showExportPDFSheet: Bool = false
    @State private var showSavedAlert: Bool = false
    @State private var savedAlertMessage: String = ""
    @State private var showExportAlert: Bool = false
    @State private var exportAlertMessage: String = ""
    @State private var calendarService = CalendarExportService()
    @State private var actionTrigger: Bool = false
    @State private var selectedWODDay: WODPlanDay?

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        if showGoalSetup || vm.wodPlan == nil {
                            goalSetupView
                        } else if let plan = vm.wodPlan {
                            newPlanButton
                            planHeader(plan)
                            planActionsBar
                            weekDaysList(plan)
                            refreshButton
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Plan My Functional Fitness")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sensoryFeedback(.impact(weight: .medium), trigger: refreshTrigger)
            .sensoryFeedback(.success, trigger: actionTrigger)
            .sheet(isPresented: $showCalendarSheet) {
                calendarExportSheet
            }
            .sheet(isPresented: $showShareSheet) {
                if let plan = vm.wodPlan {
                    WODPlanShareSheet(plan: plan, shareText: vm.wodPlanShareText)
                }
            }
            .sheet(isPresented: $showExportPDFSheet) {
                if let plan = vm.wodPlan {
                    WODPlanPDFExportSheet(plan: plan)
                }
            }
            .sheet(item: $selectedWODDay) { day in
                WODPlanDayDetailSheet(day: day)
            }
            .alert("Saved", isPresented: $showSavedAlert) {
                Button("OK") {}
            } message: {
                Text(savedAlertMessage)
            }
            .alert("Calendar Export", isPresented: $showExportAlert) {
                Button("OK") {}
            } message: {
                Text(exportAlertMessage)
            }
            .onAppear {
                if let goal = vm.currentPTGoal {
                    selectedGoal = goal
                }
                selectedWeeks = vm.currentPlanWeeks
                if let plan = vm.wodPlan {
                    selectedHeroPreference = plan.heroPreference
                    showGoalSetup = false
                    isPlanApproved = true
                } else {
                    showGoalSetup = true
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.15)) {
                    animateCards = true
                }
            }
        }
    }

    // MARK: - Plan Actions Bar

    @State private var isPlanApproved: Bool = false
    @State private var approveCalendarTrigger: Bool = false

    private var planActionsBar: some View {
        VStack(spacing: 12) {
            if !isPlanApproved {
                Button {
                    approveCalendarTrigger.toggle()
                    vm.saveWODPlanSnapshot()
                    isPlanApproved = true
                    if let plan = vm.wodPlan {
                        Task {
                            let result = await calendarService.exportWODPlan(plan)
                            handleExportResult(result)
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        if calendarService.isExporting {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline.weight(.bold))
                        }
                        Text("Approve & Sync to Calendar")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color(hex: "#F59E0B").opacity(0.28), radius: 14, y: 8)
                }
                .disabled(calendarService.isExporting)
                .sensoryFeedback(.success, trigger: approveCalendarTrigger)
                .buttonStyle(PressScaleButtonStyle())
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(MVMTheme.success)
                    Text("Plan Approved & Synced")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(MVMTheme.success)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(MVMTheme.success.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(MVMTheme.success.opacity(0.3))
                }
            }

            HStack(spacing: 10) {
                wodActionButton(icon: "square.and.arrow.up", label: "Share") {
                    showShareSheet = true
                }

                wodActionButton(icon: "doc.richtext", label: "Export") {
                    showExportPDFSheet = true
                }
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 8)
    }

    private func wodActionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color(hex: "#F59E0B"))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "#F59E0B").opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(MVMTheme.secondaryText)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Calendar Export Sheet

    private var calendarExportSheet: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40))
                    .foregroundStyle(Color(hex: "#F59E0B"))
                    .padding(.top, 8)

                Text("Sync to Calendar")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Add your fitness plan workouts to your iOS Calendar so they show up with reminders.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 12) {
                if let plan = vm.wodPlan {
                    Button {
                        Task {
                            let result = await calendarService.exportWODPlan(plan)
                            handleExportResult(result)
                            showCalendarSheet = false
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if calendarService.isExporting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.subheadline.weight(.bold))
                            }
                            Text("Export Full Week")
                                .font(.headline.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(calendarService.isExporting)
                    .buttonStyle(PressScaleButtonStyle())
                }

                Button {
                    showCalendarSheet = false
                } label: {
                    Text("Cancel")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(MVMTheme.background)
    }

    private var goalSetupView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "bolt.heart.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color(hex: "#F59E0B"))
                    .frame(width: 64, height: 64)
                    .background(Color(hex: "#F59E0B").opacity(0.12))
                    .clipShape(Circle())

                Text("Plan My Functional Fitness")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Generate a functional fitness weekly plan tailored to your goals. Uses the same goal as your PT plan.")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("TRAINING GOAL")
                    .font(.caption2.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(MVMTheme.tertiaryText)

                ForEach(PTGoal.allCases) { goal in
                    goalRow(goal)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("PLAN DURATION")
                    .font(.caption2.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(MVMTheme.tertiaryText)

                HStack(spacing: 8) {
                    ForEach([2, 4, 6, 8, 12], id: \.self) { weeks in
                        Button {
                            withAnimation(.spring(response: 0.25)) {
                                selectedWeeks = weeks
                            }
                        } label: {
                            VStack(spacing: 3) {
                                Text("\(weeks)")
                                    .font(.headline.weight(.bold))
                                Text("wks")
                                    .font(.caption2.weight(.medium))
                            }
                            .foregroundStyle(selectedWeeks == weeks ? .white : MVMTheme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(selectedWeeks == weeks ? Color(hex: "#F59E0B") : Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("WORKOUT STYLE")
                    .font(.caption2.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(MVMTheme.tertiaryText)

                ForEach(WODHeroPreference.allCases) { pref in
                    heroPreferenceRow(pref)
                }
            }

            Button {
                vm.generateWODPlan(goal: selectedGoal, weeks: selectedWeeks, heroPreference: selectedHeroPreference)
                showGoalSetup = false
                isPlanApproved = false
                animateCards = false
                withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) {
                    animateCards = true
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "bolt.fill")
                        .font(.subheadline.weight(.bold))
                    Text("Generate \(selectedWeeks)-Week Plan")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(18)
        .premiumCard()
    }

    private func heroPreferenceRow(_ pref: WODHeroPreference) -> some View {
        let isSelected = selectedHeroPreference == pref

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedHeroPreference = pref
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: pref.icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : Color(hex: "#F59E0B"))
                    .frame(width: 38, height: 38)
                    .background(isSelected ? Color(hex: "#F59E0B") : Color(hex: "#F59E0B").opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(pref.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text(pref.subtitle)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(Color(hex: "#F59E0B"))
                }
            }
            .padding(12)
            .background(isSelected ? Color(hex: "#F59E0B").opacity(0.08) : Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(hex: "#F59E0B").opacity(0.3) : MVMTheme.border)
            }
        }
        .buttonStyle(.plain)
    }

    private func goalRow(_ goal: PTGoal) -> some View {
        let isSelected = selectedGoal == goal

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedGoal = goal
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: goal.icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : Color(hex: "#F59E0B"))
                    .frame(width: 38, height: 38)
                    .background(isSelected ? Color(hex: "#F59E0B") : Color(hex: "#F59E0B").opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text(goal.subtitle)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(Color(hex: "#F59E0B"))
                }
            }
            .padding(12)
            .background(isSelected ? Color(hex: "#F59E0B").opacity(0.08) : Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(hex: "#F59E0B").opacity(0.3) : MVMTheme.border)
            }
        }
        .buttonStyle(.plain)
    }

    private func planHeader(_ plan: WODPlan) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "bolt.heart.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color(hex: "#F59E0B").opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(plan.ptGoal.isEmpty ? "Functional Fitness Plan" : plan.ptGoal)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)

                Text("Week \(plan.currentWeek) of \(plan.totalWeeks)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer(minLength: 0)

            let workoutDays = plan.days.filter { !$0.isRestDay }.count
            VStack(spacing: 2) {
                Text("\(workoutDays)")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                Text("Sessions")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706").opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 10)
    }

    private func weekDaysList(_ plan: WODPlan) -> some View {
        VStack(spacing: 8) {
            ForEach(Array(plan.days.enumerated()), id: \.element.id) { offset, day in
                dayRow(day, offset: offset)
            }
        }
    }

    private func dayRow(_ day: WODPlanDay, offset: Int) -> some View {
        let isToday = calendar.isDateInToday(day.date)

        return Button {
            selectedWODDay = day
        } label: {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(shortDayName(day.date))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(MVMTheme.tertiaryText)

                Text(dayNumber(day.date))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        day.isCompleted ? MVMTheme.success :
                        isToday ? Color(hex: "#F59E0B") :
                        MVMTheme.secondaryText
                    )
            }
            .frame(width: 36)

            if day.isRestDay {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Rest & Recovery")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.secondaryText)
                    Text("Active rest")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            } else {
                VStack(alignment: .leading, spacing: 3) {
                    Text(day.template.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        if HeroWODLibrary.isHeroWorkout(day.template) {
                            HStack(spacing: 3) {
                                Image(systemName: "medal.fill")
                                    .font(.system(size: 9))
                                Text("MEMORIAL")
                                    .font(.system(size: 9, weight: .heavy))
                            }
                            .foregroundStyle(Color(hex: "#C4A35A"))
                        }
                        Text(day.template.format.rawValue)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color(hex: "#F59E0B"))
                        Text("~\(day.template.durationMinutes) min")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }
            }

            Spacer(minLength: 0)

            if isToday {
                Text("TODAY")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(0.5)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#F59E0B"))
                    .clipShape(Capsule())
            } else if day.isRestDay {
                Image(systemName: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.tertiaryText)
            } else if day.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.body)
                    .foregroundStyle(MVMTheme.success)
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            isToday ? Color(hex: "#F59E0B").opacity(0.08) :
            MVMTheme.card
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isToday ? Color(hex: "#F59E0B").opacity(0.2) :
                    MVMTheme.border
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        }  // end Button label
        .buttonStyle(PressScaleButtonStyle())
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 10)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(offset) * 0.04),
            value: animateCards
        )
    }

    private var refreshButton: some View {
        Button {
            refreshTrigger.toggle()
            animateCards = false
            vm.refreshWODPlan()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.1)) {
                animateCards = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .font(.subheadline.weight(.bold))
                Text("Refresh Week")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(Color(hex: "#F59E0B"))
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#F59E0B").opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(PressScaleButtonStyle())
        .opacity(animateCards ? 1 : 0)
    }

    private var newPlanButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                showGoalSetup = true
                vm.wodPlan = nil
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle")
                    .font(.subheadline.weight(.bold))
                Text("New Plan")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(MVMTheme.secondaryText)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .opacity(animateCards ? 1 : 0)
    }

    private func shortDayName(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }

    private func dayNumber(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }

    private func handleExportResult(_ result: CalendarExportService.ExportResult) {
        switch result {
        case .success(let count):
            exportAlertMessage = "\(count) workout\(count == 1 ? "" : "s") added to your calendar."
        case .partial(let exported, let failed):
            exportAlertMessage = "\(exported) exported, \(failed) failed. Try again for remaining."
        case .denied:
            exportAlertMessage = "Calendar access denied. Go to Settings to enable."
        case .error(let message):
            exportAlertMessage = "Export failed: \(message)"
        }
        showExportAlert = true
    }
}

// MARK: - WOD Plan Share Sheet

struct WODPlanShareSheet: View {
    @Environment(\.dismiss) private var dismiss

    let plan: WODPlan
    let shareText: String

    @State private var renderedImage: UIImage?
    @State private var showSavedAlert: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            if let image = renderedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                                    .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .tint(Color(hex: "#F59E0B"))
                                    Text("Generating share card...")
                                        .font(.caption)
                                        .foregroundStyle(MVMTheme.secondaryText)
                                }
                                .frame(height: 300)
                            }

                            VStack(spacing: 6) {
                                Text(plan.ptGoal.isEmpty ? "Functional Fitness Plan" : plan.ptGoal)
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(MVMTheme.primaryText)

                                Text("Week \(plan.currentWeek) of \(plan.totalWeeks) \u{00b7} \(plan.days.filter { !$0.isRestDay }.count) Sessions")
                                    .font(.subheadline)
                                    .foregroundStyle(MVMTheme.secondaryText)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        if renderedImage != nil {
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    if let image = renderedImage {
                                        ShareLink(
                                            item: Image(uiImage: image),
                                            preview: SharePreview("Functional Fitness Plan", image: Image(uiImage: image))
                                        ) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "square.and.arrow.up")
                                                Text("Share")
                                            }
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                            .frame(height: 52)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                LinearGradient(
                                                    colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                        }
                                        .buttonStyle(PressScaleButtonStyle())
                                    }

                                    Button {
                                        if let image = renderedImage {
                                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                            showSavedAlert = true
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "photo.on.rectangle.angled")
                                            Text("Save")
                                        }
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(height: 52)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(hex: "#D97706"))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                    .buttonStyle(PressScaleButtonStyle())
                                }

                                ShareLink(item: shareText) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "doc.text")
                                        Text("Share as Text")
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color(hex: "#F59E0B"))
                                    .frame(height: 44)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: "#F59E0B").opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .buttonStyle(PressScaleButtonStyle())
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Share Fitness Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Saved", isPresented: $showSavedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Share card saved to your photo library.")
            }
        }
        .task {
            renderedImage = WODPlanCardRenderer.render(plan: plan)
        }
    }
}

// MARK: - WOD Plan PDF Export Sheet

struct WODPlanPDFExportSheet: View {
    @Environment(\.dismiss) private var dismiss

    let plan: WODPlan

    @State private var pdfURL: URL?
    @State private var isGenerating: Bool = false
    @State private var showShareSheet: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.richtext")
                            .font(.system(size: 44))
                            .foregroundStyle(Color(hex: "#F59E0B"))
                            .padding(.top, 20)

                        Text("Export as PDF")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(MVMTheme.primaryText)

                        Text("Generate a printable PDF of your full fitness plan with all movements and schedule details.")
                            .font(.subheadline)
                            .foregroundStyle(MVMTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        pdfInfoRow(icon: "target", label: "Goal", value: plan.ptGoal.isEmpty ? "General" : plan.ptGoal)
                        pdfInfoRow(icon: "calendar", label: "Week", value: "\(plan.currentWeek) of \(plan.totalWeeks)")
                        pdfInfoRow(icon: "flame.fill", label: "WODs", value: "\(plan.days.filter { !$0.isRestDay }.count) sessions")
                        pdfInfoRow(icon: "medal.fill", label: "Style", value: plan.heroPreference.rawValue)
                    }
                    .padding(16)
                    .background(MVMTheme.card)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(MVMTheme.border)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(spacing: 12) {
                        Button {
                            generateAndShare()
                        } label: {
                            HStack(spacing: 10) {
                                if isGenerating {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.subheadline.weight(.bold))
                                }
                                Text("Generate & Share PDF")
                                    .font(.headline.weight(.bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(isGenerating)
                        .buttonStyle(PressScaleButtonStyle())
                    }
                    .padding(.horizontal, 4)

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Export PDF")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showShareSheet) {
                if let pdfURL {
                    ShareSheet(items: [pdfURL])
                }
            }
        }
    }

    private func pdfInfoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(hex: "#F59E0B"))
                .frame(width: 28, height: 28)
                .background(Color(hex: "#F59E0B").opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MVMTheme.secondaryText)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.primaryText)
        }
    }

    private func generateAndShare() {
        isGenerating = true

        guard let pdfData = WODPlanPDFService.generatePDF(from: plan) else {
            isGenerating = false
            return
        }

        let goalName = plan.ptGoal
        guard let url = WODPlanPDFService.savePDFToTemp(data: pdfData, goalName: goalName) else {
            isGenerating = false
            return
        }

        pdfURL = url
        isGenerating = false
        showShareSheet = true
    }
}

// MARK: - WOD Plan Card Renderer

@MainActor
enum WODPlanCardRenderer {
    private static let wodAmber = UIColor(red: 0.961, green: 0.62, blue: 0.043, alpha: 1.0)
    private static let heroGold = UIColor(red: 0.769, green: 0.639, blue: 0.353, alpha: 1.0)

    static func render(plan: WODPlan) -> UIImage? {
        let w: CGFloat = 1080
        let workoutDays = plan.days.filter { !$0.isRestDay }
        let dayRows = min(workoutDays.count, 5)
        let h: CGFloat = CGFloat(560 + dayRows * 80)
        let renderer = ShareCardCGHelpers.makeRenderer(width: w, height: h)

        return renderer.image { ctx in
            let context = ctx.cgContext

            context.setFillColor(ShareCardCGHelpers.bgColor.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: w, height: h))

            let colors = [
                wodAmber.withAlphaComponent(0.14).cgColor,
                wodAmber.withAlphaComponent(0.04).cgColor,
                UIColor.clear.cgColor
            ] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 0.5, 1.0]) {
                context.drawRadialGradient(gradient,
                                           startCenter: CGPoint(x: w / 2, y: 200),
                                           startRadius: 0,
                                           endCenter: CGPoint(x: w / 2, y: 200),
                                           endRadius: 600,
                                           options: [])
            }

            ShareCardCGHelpers.drawHeader(context: context, width: w, date: .now)

            let badgeAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .heavy),
                .foregroundColor: wodAmber,
                .kern: 2.0
            ]
            let badgeStr = NSAttributedString(string: "FUNCTIONAL FITNESS PLAN", attributes: badgeAttrs)
            badgeStr.draw(at: CGPoint(x: 60, y: 130))

            let styleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
            let styleStr = NSAttributedString(string: plan.heroPreference.rawValue, attributes: styleAttrs)
            let styleSize = styleStr.size()
            let stylePillRect = CGRect(x: w - 60 - styleSize.width - 24, y: 126, width: styleSize.width + 24, height: 32)
            let stylePillPath = UIBezierPath(roundedRect: stylePillRect, cornerRadius: 16)
            context.setFillColor(UIColor.white.withAlphaComponent(0.08).cgColor)
            context.addPath(stylePillPath.cgPath)
            context.fillPath()
            styleStr.draw(at: CGPoint(x: stylePillRect.midX - styleSize.width / 2, y: stylePillRect.midY - styleSize.height / 2))

            let goalLabel = plan.ptGoal.isEmpty ? "Functional Fitness Plan" : plan.ptGoal
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 44, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let titleStr = NSAttributedString(string: goalLabel, attributes: titleAttrs)
            titleStr.draw(with: CGRect(x: 60, y: 175, width: w - 120, height: 110), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)

            let weekAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
            let weekStr = NSAttributedString(string: "Week \(plan.currentWeek) of \(plan.totalWeeks) \u{00b7} \(workoutDays.count) Sessions", attributes: weekAttrs)
            weekStr.draw(at: CGPoint(x: 60, y: 240))

            let boxWidth = (w - 160) / 3
            let boxHeight: CGFloat = 100
            let statsY: CGFloat = 300
            ShareCardCGHelpers.drawStatBox(context: context, x: 60, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: "\(workoutDays.count)", label: "Sessions", valueColor: wodAmber)

            let totalMins = workoutDays.reduce(0) { $0 + $1.template.durationMinutes }
            ShareCardCGHelpers.drawStatBox(context: context, x: 60 + boxWidth + 20, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: "~\(totalMins)m", label: "Duration", valueColor: wodAmber)

            let restCount = plan.days.filter { $0.isRestDay }.count
            ShareCardCGHelpers.drawStatBox(context: context, x: 60 + (boxWidth + 20) * 2, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: "\(restCount)", label: "Rest", valueColor: ShareCardCGHelpers.successGreen)

            var rowY: CGFloat = statsY + boxHeight + 30

            let sectionAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .heavy),
                .foregroundColor: UIColor.white.withAlphaComponent(0.4),
                .kern: 2.0
            ]
            let sectionStr = NSAttributedString(string: "SCHEDULE", attributes: sectionAttrs)
            sectionStr.draw(at: CGPoint(x: 60, y: rowY))
            rowY += 36

            context.setStrokeColor(UIColor.white.withAlphaComponent(0.06).cgColor)
            context.setLineWidth(1)
            context.move(to: CGPoint(x: 60, y: rowY))
            context.addLine(to: CGPoint(x: w - 60, y: rowY))
            context.strokePath()
            rowY += 16

            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"

            for day in workoutDays.prefix(5) {
                let dotColor = wodAmber
                let dotRect = CGRect(x: 70, y: rowY + 12, width: 10, height: 10)
                context.setFillColor(dotColor.cgColor)
                context.fillEllipse(in: dotRect)

                let dayNameStr = dayFormatter.string(from: day.date).uppercased()
                let dayLabelAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.4)
                ]
                let dayLabel = NSAttributedString(string: dayNameStr, attributes: dayLabelAttrs)
                dayLabel.draw(at: CGPoint(x: 95, y: rowY + 6))

                let nameAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.85)
                ]
                let nameStr = NSAttributedString(string: day.template.title, attributes: nameAttrs)
                nameStr.draw(at: CGPoint(x: 160, y: rowY + 4))

                let metaText = "\(day.template.format.rawValue) \u{00b7} ~\(day.template.durationMinutes)m"
                let metaAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                    .foregroundColor: wodAmber.withAlphaComponent(0.7)
                ]
                let metaStr = NSAttributedString(string: metaText, attributes: metaAttrs)
                metaStr.draw(at: CGPoint(x: 160, y: rowY + 36))


                rowY += 70
            }

            if workoutDays.count > 5 {
                let moreAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.3)
                ]
                let moreStr = NSAttributedString(string: "+\(workoutDays.count - 5) more sessions", attributes: moreAttrs)
                moreStr.draw(at: CGPoint(x: 95, y: rowY + 4))
            }

            ShareCardCGHelpers.drawFooter(context: context, width: w, height: h)
        }
    }
}
