import SwiftUI
import CoreImage.CIFilterBuiltins

struct UnitPTBuilderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var fullPlan: UnitPTFullPlan?
    @State private var showQRSheet: Bool = false
    @State private var showDatePicker: Bool = false
    @State private var scheduledStartTime: Date = {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        comps.hour = 6
        comps.minute = 30
        return Calendar.current.date(from: comps) ?? .now
    }()
    @State private var scheduledEndTime: Date = {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        comps.hour = 7
        comps.minute = 30
        return Calendar.current.date(from: comps) ?? .now
    }()
    @State private var addedToCalendar: Bool = false

    @State private var selectedGoal: PTGoal = .aftScoreImprovement
    @State private var selectedWeeks: Int = 4
    @State private var selectedDaysPerWeek: Int = 5
    @State private var selectedWeekIndex: Int = 0
    @State private var selectedDayPlan: UnitPTDayPlan?
    @State private var showDayDetail: Bool = false
    @State private var hapticTrigger: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        if fullPlan == nil {
                            goalSetupView
                        }

                        if let plan = fullPlan {
                            planHeaderCard(plan)
                            weekSelector(plan)
                            weekDaysList(plan)
                            calendarSyncCard(plan)
                            planActionsCard(plan)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Plan My Unit PT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(isPresented: $showDayDetail) {
                if let dayPlan = selectedDayPlan {
                    UnitPTDayDetailView(
                        dayPlan: dayPlan,
                        onSave: { updated in
                            vm.updateUnitPTDay(
                                weekIndex: updated.weekIndex,
                                dayIndex: updated.dayIndex,
                                updatedDay: updated
                            )
                            fullPlan = vm.unitPTFullPlan
                        },
                        onRegenerate: {
                            vm.regenerateUnitPTDay(weekIndex: dayPlan.weekIndex, dayIndex: dayPlan.dayIndex)
                            fullPlan = vm.unitPTFullPlan
                            if let updated = vm.unitPTFullPlan?.weeks[dayPlan.weekIndex].days[dayPlan.dayIndex] {
                                selectedDayPlan = updated
                            }
                        }
                    )
                }
            }
            .sheet(isPresented: $showQRSheet) {
                if let plan = fullPlan {
                    UnitPTFullPlanQRSheet(plan: plan)
                }
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
            .onAppear {
                if let existing = vm.unitPTFullPlan {
                    fullPlan = existing
                }
            }
        }
    }

    // MARK: - Goal Setup

    private var goalSetupView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 64, height: 64)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(Circle())

                Text("Unit PT Builder")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Build a multi-week Unit PT program. Each day is fully customizable with objectives, formations, exercises, and leader notes.")
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
                    unitGoalRow(goal)
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
                            .background(selectedWeeks == weeks ? MVMTheme.accent : Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                if selectedWeeks == weeks {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(MVMTheme.accent.opacity(0.4))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("DAYS PER WEEK")
                    .font(.caption2.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(MVMTheme.tertiaryText)

                HStack(spacing: 8) {
                    ForEach([3, 4, 5, 6], id: \.self) { days in
                        Button {
                            withAnimation(.spring(response: 0.25)) {
                                selectedDaysPerWeek = days
                            }
                        } label: {
                            VStack(spacing: 3) {
                                Text("\(days)")
                                    .font(.headline.weight(.bold))
                                Text("days")
                                    .font(.caption2.weight(.medium))
                            }
                            .foregroundStyle(selectedDaysPerWeek == days ? .white : MVMTheme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(selectedDaysPerWeek == days ? MVMTheme.accent : Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                if selectedDaysPerWeek == days {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(MVMTheme.accent.opacity(0.4))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            unitPlanBreakdownPreview

            Button {
                let plan = vm.generateUnitPTFullPlan(
                    goal: selectedGoal,
                    weeks: selectedWeeks,
                    daysPerWeek: selectedDaysPerWeek
                )
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    fullPlan = plan
                    selectedWeekIndex = 0
                    addedToCalendar = false
                }
                hapticTrigger.toggle()
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
                .background(MVMTheme.heroGradient)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(18)
        .premiumCard()
    }

    private func unitGoalRow(_ goal: PTGoal) -> some View {
        let isSelected = selectedGoal == goal

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedGoal = goal
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: goal.icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : MVMTheme.accent)
                    .frame(width: 38, height: 38)
                    .background(isSelected ? MVMTheme.accent : MVMTheme.accent.opacity(0.12))
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
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .padding(12)
            .background(isSelected ? MVMTheme.accent.opacity(0.08) : Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? MVMTheme.accent.opacity(0.3) : MVMTheme.border)
            }
        }
        .buttonStyle(.plain)
    }

    private var unitPlanBreakdownPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                Text("PLAN OVERVIEW")
                    .font(.caption2.weight(.heavy))
                    .tracking(0.6)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            let totalSessions = selectedWeeks * selectedDaysPerWeek
            HStack(spacing: 20) {
                statMini(value: "\(selectedWeeks)", label: "Weeks")
                statMini(value: "\(selectedDaysPerWeek)", label: "Days/Wk")
                statMini(value: "\(totalSessions)", label: "Sessions")
            }

            Text("Periodized progression adapts each week based on your goal")
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .padding(14)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func statMini(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.accent)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Plan Header

    private func planHeaderCard(_ plan: UnitPTFullPlan) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: selectedGoal.icon)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Unit PT Plan")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)

                    Text("\(plan.goal) · \(plan.totalWeeks) Weeks · \(plan.daysPerWeek) Days/Wk")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 16) {
                progressStat(
                    icon: "calendar",
                    value: "\(plan.totalWorkoutDays)",
                    label: "Sessions"
                )
                progressStat(
                    icon: "checkmark.circle",
                    value: "\(plan.totalCompletedDays)",
                    label: "Done"
                )
                progressStat(
                    icon: "flame",
                    value: phaseLabel(for: selectedWeekIndex, totalWeeks: plan.totalWeeks),
                    label: "Phase"
                )
            }
        }
        .padding(18)
        .premiumCard()
    }

    private func progressStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(MVMTheme.accent)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private func phaseLabel(for weekIdx: Int, totalWeeks: Int) -> String {
        let progress = Double(weekIdx) / Double(max(totalWeeks - 1, 1))
        if progress < 0.33 { return "Foundation" }
        else if progress < 0.66 { return "Build" }
        else { return "Peak" }
    }

    // MARK: - Week Selector

    private func weekSelector(_ plan: UnitPTFullPlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SELECT WEEK")
                .font(.caption2.weight(.heavy))
                .tracking(0.8)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<plan.totalWeeks, id: \.self) { weekIdx in
                        let week = plan.weeks[weekIdx]
                        let isSelected = selectedWeekIndex == weekIdx

                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedWeekIndex = weekIdx
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Text("WK \(weekIdx + 1)")
                                    .font(.caption.weight(.bold))

                                let completed = week.completedCount
                                let total = week.days.count
                                Text("\(completed)/\(total)")
                                    .font(.caption2.weight(.medium))

                                let dateStr = week.weekStartDate.formatted(.dateTime.month(.abbreviated).day())
                                Text(dateStr)
                                    .font(.system(size: 9, weight: .medium))
                            }
                            .foregroundStyle(isSelected ? .white : MVMTheme.secondaryText)
                            .frame(width: 72, height: 72)
                            .background(isSelected ? MVMTheme.accent : Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(MVMTheme.accent.opacity(0.4))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentMargins(.horizontal, 4)
        }
    }

    // MARK: - Week Days List

    private func weekDaysList(_ plan: UnitPTFullPlan) -> some View {
        let week = plan.weeks[selectedWeekIndex]
        let phaseText = phaseLabel(for: selectedWeekIndex, totalWeeks: plan.totalWeeks)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Week \(selectedWeekIndex + 1)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("\(phaseText) Phase · \(week.days.count) Sessions")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                Spacer()
            }

            ForEach(week.days) { day in
                Button {
                    selectedDayPlan = day
                    showDayDetail = true
                } label: {
                    dayRowCard(day)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .premiumCard()
    }

    private func dayRowCard(_ day: UnitPTDayPlan) -> some View {
        let dayName = day.date.formatted(.dateTime.weekday(.abbreviated))
        let dateStr = day.date.formatted(.dateTime.month(.abbreviated).day())
        let exerciseCount = day.mainEffort.count

        return HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(dayName.uppercased())
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(day.isCompleted ? MVMTheme.success : MVMTheme.accent)
                Text(dateStr)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .frame(width: 44)

            Rectangle()
                .fill(day.isCompleted ? MVMTheme.success.opacity(0.3) : MVMTheme.accent.opacity(0.2))
                .frame(width: 3, height: 44)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 3) {
                Text(day.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label("\(exerciseCount) exercises", systemImage: "figure.mixed.cardio")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)

                    if day.isCompleted {
                        Text("Done")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(MVMTheme.success)
                    }
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .padding(14)
        .background(day.isCompleted ? MVMTheme.success.opacity(0.04) : MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            if day.isCompleted {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(MVMTheme.success.opacity(0.2))
            }
        }
    }

    // MARK: - Calendar Sync

    private func calendarSyncCard(_ plan: UnitPTFullPlan) -> some View {
        VStack(spacing: 14) {
            if !addedToCalendar {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundStyle(Color(hex: "#2563EB"))
                    Text("Sync All Weeks to Calendar")
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                }

                Text("Add all \(plan.totalWorkoutDays) sessions to your in-app calendar with scheduled times.")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)

                VStack(spacing: 10) {
                    DatePicker("Daily Start", selection: $scheduledStartTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .foregroundStyle(MVMTheme.primaryText)
                        .tint(MVMTheme.accent)

                    DatePicker("Daily End", selection: $scheduledEndTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .foregroundStyle(MVMTheme.primaryText)
                        .tint(MVMTheme.accent)
                }
                .padding(12)
                .background(MVMTheme.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button {
                    vm.addFullUnitPTToCalendar(startTime: scheduledStartTime, endTime: scheduledEndTime)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        addedToCalendar = true
                    }
                    hapticTrigger.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add to Calendar")
                    }
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#2563EB"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(MVMTheme.success)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Added to Calendar")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.primaryText)
                        Text("All \(plan.totalWorkoutDays) sessions synced to your training calendar.")
                            .font(.caption)
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(18)
        .premiumCard()
    }

    // MARK: - Plan Actions

    private func planActionsCard(_ plan: UnitPTFullPlan) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    showQRSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "qrcode")
                        Text("Share QR")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())

                ShareLink(item: plan.shareText) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#2563EB"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())
            }

            Button {
                addedToCalendar = false
                let plan = vm.generateUnitPTFullPlan(
                    goal: selectedGoal,
                    weeks: selectedWeeks,
                    daysPerWeek: selectedDaysPerWeek
                )
                withAnimation(.spring(response: 0.4)) {
                    fullPlan = plan
                    selectedWeekIndex = 0
                }
                hapticTrigger.toggle()
            } label: {
                Text("Regenerate Entire Plan")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                withAnimation(.spring(response: 0.4)) {
                    fullPlan = nil
                    addedToCalendar = false
                    vm.clearUnitPTFullPlan()
                }
            } label: {
                Text("New Plan")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .premiumCard()
    }
}

// MARK: - Full Plan QR Sheet

struct UnitPTFullPlanQRSheet: View {
    @Environment(\.dismiss) private var dismiss

    let plan: UnitPTFullPlan

    @State private var qrImage: UIImage?
    @State private var showSavedAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            if let qrImage {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 260, height: 260)
                                    .padding(20)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            } else {
                                ProgressView()
                                    .frame(width: 260, height: 260)
                            }

                            Text("Unit PT Plan")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(MVMTheme.primaryText)

                            Text("\(plan.goal) · \(plan.totalWeeks) Weeks")
                                .font(.subheadline)
                                .foregroundStyle(MVMTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .premiumCard()

                        if let qrImage {
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    ShareLink(
                                        item: Image(uiImage: qrImage),
                                        preview: SharePreview("Unit PT Plan", image: Image(uiImage: qrImage))
                                    ) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "square.and.arrow.up")
                                            Text("Share QR")
                                        }
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(height: 52)
                                        .frame(maxWidth: .infinity)
                                        .background(MVMTheme.heroGradient)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                    .buttonStyle(PressScaleButtonStyle())

                                    Button {
                                        UIImageWriteToSavedPhotosAlbum(qrImage, nil, nil, nil)
                                        showSavedAlert = true
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "square.and.arrow.down")
                                            Text("Save")
                                        }
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(height: 52)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(hex: "#2563EB"))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                    .buttonStyle(PressScaleButtonStyle())
                                }

                                ShareLink(item: plan.shareText) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "doc.text")
                                        Text("Share as Text")
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(MVMTheme.accent)
                                    .frame(height: 44)
                                    .frame(maxWidth: .infinity)
                                    .background(MVMTheme.accent.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .buttonStyle(PressScaleButtonStyle())
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("QR Code")
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
                Text("QR code saved to your photo library.")
            }
        }
        .onAppear { generateQR() }
    }

    private func generateQR() {
        guard let data = plan.shareText.data(using: .utf8) else { return }

        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "L"

        guard let outputImage = filter.outputImage else { return }

        let scale = 260.0 / outputImage.extent.width
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return }
        qrImage = UIImage(cgImage: cgImage)
    }
}
