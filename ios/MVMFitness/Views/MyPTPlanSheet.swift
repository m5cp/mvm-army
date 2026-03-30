import SwiftUI

struct MyPTPlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var hasGenerated: Bool = false
    @State private var animateCards: Bool = false
    @State private var refreshTrigger: Bool = false

    @State private var selectedGoal: PTGoal = .aftScoreImprovement
    @State private var selectedWeeks: Int = 4
    @State private var showGoalSetup: Bool = true

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        if showGoalSetup && vm.currentPlan == nil {
                            goalSetupView
                        } else if let plan = vm.currentPlan {
                            planHeaderBadge(plan)
                            weekOverviewHeader(plan)
                            weekProgressBar(plan)

                            ForEach(Array(plan.days.enumerated()), id: \.element.id) { offset, day in
                                dayRow(day, offset: offset)
                            }

                            if plan.currentWeek < plan.totalWeeks {
                                nextWeekButton
                            }

                            refreshButton
                            newPlanButton
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("My PT Plan")
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
            .onAppear {
                if vm.currentPlan != nil {
                    hasGenerated = true
                    showGoalSetup = false
                }
                if let goal = vm.currentPTGoal {
                    selectedGoal = goal
                }
                selectedWeeks = vm.currentPlanWeeks
                withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.15)) {
                    animateCards = true
                }
            }
        }
    }

    // MARK: - Goal Setup

    private var goalSetupView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 64, height: 64)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(Circle())

                Text("Set Your Goal")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Your plan will be tailored to your goal using Army PRT principles and ACFT event standards.")
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

            goalImpactPreview

            Button {
                vm.generateGoalPlan(goal: selectedGoal, weeks: selectedWeeks)
                hasGenerated = true
                showGoalSetup = false
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
                .background(MVMTheme.heroGradient)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(18)
        .premiumCard()
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

    private var goalImpactPreview: some View {
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

            Text("Week \(1) of \(selectedWeeks) • Periodized progression adapts each week")
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .padding(14)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Plan Header Badge

    private func planHeaderBadge(_ plan: WeeklyPlan) -> some View {
        HStack(spacing: 12) {
            Image(systemName: selectedGoal.icon)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(MVMTheme.accent.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(plan.ptGoal.isEmpty ? "General Plan" : plan.ptGoal)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)

                Text("Week \(plan.currentWeek) of \(plan.totalWeeks)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer(minLength: 0)

            let progress = Double(plan.currentWeek) / Double(max(plan.totalWeeks, 1))
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.15), lineWidth: 3)
                    .frame(width: 40, height: 40)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(MVMTheme.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#4A3DAF"), Color(hex: "#3B6DE0").opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 10)
    }

    // MARK: - Week Overview

    private func weekOverviewHeader(_ plan: WeeklyPlan) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text("WEEK \(plan.currentWeek)")
                        .font(.caption2.weight(.heavy))
                        .tracking(0.8)
                        .foregroundStyle(.white.opacity(0.7))

                    Text(weekRangeString(plan))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                }

                Spacer(minLength: 0)

                VStack(spacing: 2) {
                    Text("\(plan.totalWorkoutDays)")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                    Text("workouts")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            if let todayWorkout = todayFromPlan(plan) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(MVMTheme.accent)
                        .frame(width: 8, height: 8)
                    Text("Today: \(todayWorkout.title)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                }
                .padding(.top, 4)
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#3B6DE0"), Color(hex: "#5B4DC7").opacity(0.95), Color(hex: "#4A3DAF").opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: MVMTheme.accent.opacity(0.2), radius: 20, y: 12)
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 10)
    }

    private func weekProgressBar(_ plan: WeeklyPlan) -> some View {
        let total = plan.totalWorkoutDays
        let completed = plan.completedCount
        let progress: Double = total > 0 ? Double(completed) / Double(total) : 0

        return HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(completed) of \(total) complete")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(MVMTheme.cardSoft)
                            .frame(height: 5)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [MVMTheme.accent, MVMTheme.accent2],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geo.size.width * progress, progress > 0 ? 5 : 0), height: 5)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: completed)
                    }
                }
                .frame(height: 5)
            }

            Text("\(Int(progress * 100))%")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(MVMTheme.accent)
                .contentTransition(.numericText())
                .frame(width: 50, alignment: .trailing)
        }
        .padding(16)
        .background(MVMTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(MVMTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 8)
    }

    private func dayRow(_ day: WorkoutDay, offset: Int) -> some View {
        let isToday = calendar.isDateInToday(day.date)

        return HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(shortDayName(day.date))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(MVMTheme.tertiaryText)

                Text(dayNumber(day.date))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        day.isCompleted ? MVMTheme.success :
                        isToday ? MVMTheme.accent :
                        MVMTheme.secondaryText
                    )
            }
            .frame(width: 36)

            if day.isRestDay {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Recovery & Mobility")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.secondaryText)

                    Text("Active rest")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            } else {
                VStack(alignment: .leading, spacing: 3) {
                    Text(day.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(day.isCompleted ? MVMTheme.secondaryText : MVMTheme.primaryText)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        if let tag = day.tags.first {
                            Text(tag)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(MVMTheme.accent)
                        }
                        Text("\(day.exercises.count) exercises")
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
                    .background(MVMTheme.accent)
                    .clipShape(Capsule())
            } else if day.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.body)
                    .foregroundStyle(MVMTheme.success)
            } else if day.isRestDay {
                Image(systemName: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(Color(hex: "#1E3A5F").opacity(0.5))
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            isToday ? MVMTheme.accent.opacity(0.08) :
            MVMTheme.card.opacity(day.isCompleted ? 0.5 : 1)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isToday ? MVMTheme.accent.opacity(0.2) :
                    day.isCompleted ? MVMTheme.success.opacity(0.1) :
                    MVMTheme.border
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 10)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(offset) * 0.04),
            value: animateCards
        )
    }

    // MARK: - Action Buttons

    private var nextWeekButton: some View {
        Button {
            refreshTrigger.toggle()
            animateCards = false
            vm.advanceToNextWeek()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.1)) {
                animateCards = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.subheadline.weight(.bold))
                Text("Next Week")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [MVMTheme.accent, MVMTheme.accent2],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(PressScaleButtonStyle())
        .opacity(animateCards ? 1 : 0)
    }

    private var refreshButton: some View {
        Button {
            refreshTrigger.toggle()
            animateCards = false
            vm.generateWeeklyPlan()
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
            .foregroundStyle(MVMTheme.accent)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(MVMTheme.accent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(PressScaleButtonStyle())
        .opacity(animateCards ? 1 : 0)
    }

    private var newPlanButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                showGoalSetup = true
                vm.currentPlan = nil
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

    // MARK: - Helpers

    private func todayFromPlan(_ plan: WeeklyPlan) -> WorkoutDay? {
        plan.days.first { calendar.isDateInToday($0.date) && !$0.isRestDay }
    }

    private func weekRangeString(_ plan: WeeklyPlan) -> String {
        guard let first = plan.days.first, let last = plan.days.last else { return "This Week" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: first.date)) – \(f.string(from: last.date))"
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
}
