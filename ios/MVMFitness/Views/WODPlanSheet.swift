import SwiftUI

struct WODPlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var selectedGoal: PTGoal = .aftScoreImprovement
    @State private var selectedWeeks: Int = 4
    @State private var selectedHeroPreference: WODHeroPreference = .regular
    @State private var showGoalSetup: Bool = false
    @State private var animateCards: Bool = false
    @State private var refreshTrigger: Bool = false

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
                            planHeader(plan)
                            weekDaysList(plan)
                            refreshButton
                            newPlanButton
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("WOD Plan")
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
                if let goal = vm.currentPTGoal {
                    selectedGoal = goal
                }
                selectedWeeks = vm.currentPlanWeeks
                if vm.wodPlan != nil {
                    showGoalSetup = false
                } else {
                    showGoalSetup = true
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.15)) {
                    animateCards = true
                }
            }
        }
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

                Text("WOD Plan")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Generate a CrossFit-style weekly plan tailored to your goals. Uses the same goal as your PT plan.")
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
                Text(plan.ptGoal.isEmpty ? "WOD Plan" : plan.ptGoal)
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
                Text("WODs")
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

        return HStack(spacing: 14) {
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
                        if HeroWODLibrary.isHeroWOD(day.template) {
                            HStack(spacing: 3) {
                                Image(systemName: "medal.fill")
                                    .font(.system(size: 9))
                                Text("HERO")
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
            } else if !day.isRestDay {
                Button {
                    vm.regenerateWODDay(dayId: day.id)
                    refreshTrigger.toggle()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
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
}
