import SwiftUI
import CoreImage.CIFilterBuiltins

struct UnitPTBuilderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var plan: UnitPTPlan?
    @State private var showQRSheet: Bool = false
    @State private var showDatePicker: Bool = false
    @State private var scheduledDate: Date = Calendar.current.startOfDay(for: .now)
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

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        if plan == nil {
                            goalSetupView
                        }

                        if let plan {
                            unitPlanCard(plan)

                            if !addedToCalendar {
                                addToCalendarCard(plan)
                            } else {
                                addedConfirmation
                            }
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
            .sheet(isPresented: $showQRSheet) {
                if let plan {
                    QRDisplaySheet(plan: plan)
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

                Text("Build a structured Unit PT session tailored to your training goal. Share via QR code or text.")
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

            unitPlanBreakdownPreview

            Button {
                plan = vm.generateUnitPT(goal: selectedGoal, weeks: selectedWeeks)
                addedToCalendar = false
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
                Text("PLAN BREAKDOWN")
                    .font(.caption2.weight(.heavy))
                    .tracking(0.6)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            let focuses = selectedGoal.armyFocuses
            let uniqueFocuses = Array(Set(focuses))

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(uniqueFocuses, id: \.rawValue) { focus in
                    let count = focuses.filter { $0 == focus }.count
                    HStack(spacing: 6) {
                        Circle()
                            .fill(MVMTheme.accent.opacity(0.6))
                            .frame(width: 6, height: 6)
                        Text(focus.rawValue)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.secondaryText)
                        Spacer(minLength: 0)
                        Text("×\(count)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(MVMTheme.accent)
                    }
                }
            }

            Text("Week 1 of \(selectedWeeks) · Periodized progression adapts each week")
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .padding(14)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Generated Plan Card

    private func unitPlanCard(_ plan: UnitPTPlan) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: selectedGoal.icon)
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(MVMTheme.accent.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)

                    Text("\(selectedGoal.rawValue) · \(selectedWeeks)-Week Plan")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)
                }
            }

            Text(plan.date.formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)

            labelValue("Objective", plan.objective)
            labelValue("Formation", plan.formationNotes)
            labelValue("Equipment", plan.equipment)
            labelValue("Warm-Up", plan.warmup)

            VStack(alignment: .leading, spacing: 6) {
                Text("Main Effort")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)

                ForEach(Array(plan.mainEffort.enumerated()), id: \.element.id) { index, block in
                    Text("\(index + 1). \(block.description)")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(MVMTheme.cardSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            labelValue("Cool-Down", plan.cooldown)
            labelValue("Leader Notes", plan.leaderNotes)

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
                self.plan = vm.generateUnitPT(goal: selectedGoal, weeks: selectedWeeks)
            } label: {
                Text("Regenerate")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                self.plan = nil
                addedToCalendar = false
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

    // MARK: - Calendar

    private func addToCalendarCard(_ unitPlan: UnitPTPlan) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .foregroundStyle(Color(hex: "#2563EB"))
                Text("Add to Your Calendar")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }

            Text("Schedule this Unit PT so it appears alongside your individual plan.")
                .font(.caption)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                DatePicker("Date", selection: $scheduledDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .foregroundStyle(MVMTheme.primaryText)
                    .tint(MVMTheme.accent)

                DatePicker("Start", selection: $scheduledStartTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .foregroundStyle(MVMTheme.primaryText)
                    .tint(MVMTheme.accent)

                DatePicker("End", selection: $scheduledEndTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .foregroundStyle(MVMTheme.primaryText)
                    .tint(MVMTheme.accent)
            }
            .padding(12)
            .background(MVMTheme.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                vm.addUnitPTToCalendar(
                    unitPlan,
                    on: scheduledDate,
                    startTime: scheduledStartTime,
                    endTime: scheduledEndTime
                )
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    addedToCalendar = true
                }
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
        }
        .padding(18)
        .premiumCard()
    }

    private var addedConfirmation: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(MVMTheme.success)

            VStack(alignment: .leading, spacing: 2) {
                Text("Added to Calendar")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("This Unit PT will show on your home calendar.")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .premiumCard()
    }

    private func labelValue(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.headline)
                .foregroundStyle(MVMTheme.primaryText)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
        }
    }
}
