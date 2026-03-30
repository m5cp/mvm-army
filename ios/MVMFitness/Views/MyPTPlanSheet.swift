import SwiftUI

struct MyPTPlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var hasGenerated: Bool = false
    @State private var animateCards: Bool = false
    @State private var refreshTrigger: Bool = false

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        if !hasGenerated && vm.currentPlan == nil {
                            generateCard
                        } else if let plan = vm.currentPlan {
                            weekOverviewHeader(plan)
                            weekProgressBar(plan)

                            ForEach(Array(plan.days.enumerated()), id: \.element.id) { offset, day in
                                dayRow(day, offset: offset)
                            }

                            refreshButton
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
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.15)) {
                    animateCards = true
                }
            }
        }
    }

    private var generateCard: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundStyle(MVMTheme.accent)
                    Text("My PT Plan")
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                }

                Text("Generate a personalized 7-day PT plan based on your training focus. It syncs to your home calendar and Today's PT.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            Button {
                vm.generateWeeklyPlan()
                hasGenerated = true
                withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) {
                    animateCards = true
                }
            } label: {
                Text("Generate PT Plan")
                    .font(.headline)
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
                    Text("YOUR WEEK")
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
