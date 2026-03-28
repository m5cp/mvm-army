import SwiftUI

struct PlanView: View {
    @Environment(AppViewModel.self) private var vm

    @State private var showEditSheet: Bool = false
    @State private var selectedDayIndex: Int?
    @State private var navigateToDetail: Bool = false
    @State private var detailDayIndex: Int = 0
    @State private var animateCards: Bool = false

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()
            backgroundAmbience

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    planHeader
                    weekProgressBar

                    if let plan = vm.currentPlan {
                        dayTimeline(plan)
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("MVM ARMY")
                    .font(.caption.weight(.heavy))
                    .tracking(2.4)
                    .foregroundStyle(MVMTheme.secondaryText)
            }
        }
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $navigateToDetail) {
            WorkoutDetailView(dayIndex: detailDayIndex, isStandalone: false)
        }
        .sheet(isPresented: $showEditSheet) {
            if let dayIndex = selectedDayIndex,
               let plan = vm.currentPlan,
               let day = plan.days.first(where: { $0.dayIndex == dayIndex }) {
                EditWorkoutSheet(day: day)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.15)) {
                animateCards = true
            }
        }
    }

    // MARK: - Background

    private var backgroundAmbience: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [MVMTheme.accent.opacity(0.06), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 280
                )
            )
            .frame(width: 560, height: 560)
            .offset(y: -180)
            .blur(radius: 80)
            .ignoresSafeArea()
    }

    // MARK: - Header

    private var planHeader: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Plan")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text(weekRangeString)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            Spacer()

            if vm.currentPlan != nil {
                Button {
                    vm.generateWeeklyPlan()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(MVMTheme.accent)
                        .frame(width: 44, height: 44)
                        .background(MVMTheme.cardSoft)
                        .clipShape(Circle())
                        .overlay {
                            Circle().stroke(MVMTheme.border)
                        }
                }
            }
        }
    }

    // MARK: - Week Progress Bar

    @ViewBuilder
    private var weekProgressBar: some View {
        if let plan = vm.currentPlan {
            let total = plan.totalWorkoutDays
            let completed = plan.completedCount
            let progress: Double = total > 0 ? Double(completed) / Double(total) : 0

            VStack(spacing: 10) {
                HStack {
                    Text("\(completed) of \(total) sessions complete")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    Spacer()

                    Text("\(Int(progress * 100))%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.accent)
                        .contentTransition(.numericText())
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(MVMTheme.cardSoft)
                            .frame(height: 6)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [MVMTheme.accent, MVMTheme.accent2],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geo.size.width * progress, progress > 0 ? 6 : 0), height: 6)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: completed)
                    }
                }
                .frame(height: 6)
            }
            .padding(16)
            .background(MVMTheme.card)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(MVMTheme.border)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Day Timeline

    private func dayTimeline(_ plan: WeeklyPlan) -> some View {
        VStack(spacing: 12) {
            ForEach(Array(plan.days.enumerated()), id: \.element.id) { offset, day in
                if day.isRestDay {
                    recoveryCard(day, offset: offset)
                } else if isToday(day.date) {
                    todayCard(day, offset: offset)
                } else {
                    standardCard(day, offset: offset)
                }
            }
        }
    }

    // MARK: - Today Card (Hero)

    private func todayCard(_ day: WorkoutDay, offset: Int) -> some View {
        Button {
            detailDayIndex = day.dayIndex
            navigateToDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Text("TODAY")
                        .font(.caption2.weight(.heavy))
                        .tracking(1.0)
                        .foregroundStyle(.white.opacity(0.9))

                    Spacer()

                    if day.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2.weight(.bold))
                            Text("DONE")
                                .font(.caption2.weight(.heavy))
                                .tracking(0.5)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                    } else if let tag = day.tags.first {
                        Text(tag)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(day.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 12) {
                        Label("\(day.exercises.count) exercises", systemImage: "list.bullet")
                        Label(estimatedDuration(day), systemImage: "clock")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                }

                if !day.isCompleted {
                    HStack(spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.caption.weight(.bold))
                            Text("Start Workout")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundStyle(Color(hex: "#1A1A2E"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                        Button {
                            vm.markDayCompleted(dayIndex: day.dayIndex)
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 46, height: 46)
                                .background(.white.opacity(0.18))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .sensoryFeedback(.success, trigger: day.isCompleted)
                    }
                }
            }
            .padding(22)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(todayGradient)

                    RoundedRectangle(cornerRadius: 24)
                        .fill(MVMTheme.subtleGradient)

                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.04), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: MVMTheme.accent.opacity(0.2), radius: 24, y: 14)
        }
        .buttonStyle(PressScaleButtonStyle())
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 16)
    }

    // MARK: - Standard Day Card

    private func standardCard(_ day: WorkoutDay, offset: Int) -> some View {
        Button {
            detailDayIndex = day.dayIndex
            navigateToDetail = true
        } label: {
            HStack(spacing: 16) {
                dayIndicator(day)

                VStack(alignment: .leading, spacing: 5) {
                    Text(dayLabel(day))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(day.isCompleted ? MVMTheme.success : MVMTheme.tertiaryText)

                    Text(day.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(day.isCompleted ? MVMTheme.secondaryText : MVMTheme.primaryText)
                        .lineLimit(1)

                    HStack(spacing: 10) {
                        if let tag = day.tags.first {
                            Text(tag)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(MVMTheme.accent)
                        }

                        Text(estimatedDuration(day))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)

                        Text("\(day.exercises.count) exercises")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }

                Spacer(minLength: 0)

                if day.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(MVMTheme.success)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            }
            .padding(18)
            .background(MVMTheme.card.opacity(day.isCompleted ? 0.6 : 1))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(day.isCompleted ? MVMTheme.success.opacity(0.15) : MVMTheme.border)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(PressScaleButtonStyle())
        .contextMenu {
            if !day.isCompleted {
                Button {
                    vm.markDayCompleted(dayIndex: day.dayIndex)
                } label: {
                    Label("Mark Complete", systemImage: "checkmark.circle")
                }
            } else {
                Button {
                    vm.markDayIncomplete(dayIndex: day.dayIndex)
                } label: {
                    Label("Mark Incomplete", systemImage: "arrow.uturn.backward")
                }
            }

            Button {
                selectedDayIndex = day.dayIndex
                showEditSheet = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 12)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(offset) * 0.04),
            value: animateCards
        )
    }

    // MARK: - Recovery Card

    private func recoveryCard(_ day: WorkoutDay, offset: Int) -> some View {
        HStack(spacing: 16) {
            dayIndicator(day)

            VStack(alignment: .leading, spacing: 5) {
                Text(dayLabel(day))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.tertiaryText)

                Text("Recovery & Mobility")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)

                Text("Active rest · Light movement")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            Spacer(minLength: 0)

            Image(systemName: "leaf.fill")
                .font(.body)
                .foregroundStyle(Color(hex: "#1E3A5F").opacity(0.6))
        }
        .padding(18)
        .background(MVMTheme.card.opacity(0.5))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(MVMTheme.border.opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 12)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(offset) * 0.04),
            value: animateCards
        )
    }

    // MARK: - Day Indicator

    private func dayIndicator(_ day: WorkoutDay) -> some View {
        let today = isToday(day.date)
        let completed = day.isCompleted
        let rest = day.isRestDay

        return VStack(spacing: 4) {
            Text(shortDayName(day.date))
                .font(.caption2.weight(.bold))
                .foregroundStyle(today ? MVMTheme.accent : MVMTheme.tertiaryText)

            Text(dayNumber(day.date))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(
                    completed ? .white :
                    today ? MVMTheme.accent :
                    rest ? MVMTheme.tertiaryText :
                    MVMTheme.secondaryText
                )
        }
        .frame(width: 44, height: 52)
        .background(
            completed ? MVMTheme.success.opacity(0.2) :
            today ? MVMTheme.accent.opacity(0.1) :
            MVMTheme.cardSoft
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            if completed {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(MVMTheme.success.opacity(0.3), lineWidth: 1)
            } else if today {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(MVMTheme.accent.opacity(0.3), lineWidth: 1)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 44))
                    .foregroundStyle(MVMTheme.accent.opacity(0.5))

                Text("No Plan Yet")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Build your week and stay ready.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            VStack(spacing: 10) {
                Button {
                    vm.generateWeeklyPlan()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.subheadline.weight(.bold))
                        Text("Build Weekly Plan")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [MVMTheme.accent, MVMTheme.accent2],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: MVMTheme.accent.opacity(0.3), radius: 12, y: 6)
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    vm.generateWeeklyPlan()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.subheadline.weight(.bold))
                        Text("Quick Start")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(MVMTheme.border)
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 8)
    }

    // MARK: - Helpers

    private var todayGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#3B6DE0"),
                Color(hex: "#5B4DC7").opacity(0.95),
                Color(hex: "#4A3DAF").opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var weekRangeString: String {
        guard let plan = vm.currentPlan, let first = plan.days.first, let last = plan.days.last else {
            return "This Week"
        }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: first.date)) – \(f.string(from: last.date))"
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
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

    private func dayLabel(_ day: WorkoutDay) -> String {
        if isToday(day.date) { return "Today" }
        if Calendar.current.isDateInTomorrow(day.date) { return "Tomorrow" }
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: day.date)
    }

    private func estimatedDuration(_ day: WorkoutDay) -> String {
        let mins = max(day.exercises.count * 4, 15)
        return "~\(mins) min"
    }
}
