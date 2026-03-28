import SwiftUI

struct PlanView: View {
    @Environment(AppViewModel.self) private var vm

    @State private var selectedDayIndex: Int?
    @State private var showEditSheet = false
    @State private var navigateToDetail = false
    @State private var detailDayIndex: Int = 0

    private let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    weekHeader

                    if let plan = vm.currentPlan {
                        weekGrid(plan)

                        ForEach(plan.days.filter { !$0.isRestDay }) { day in
                            dayCard(day)
                        }
                    } else {
                        emptyState
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Weekly Plan")
        .navigationBarTitleDisplayMode(.inline)
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
    }

    private var weekHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("This Week")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(MVMTheme.primaryText)

                if let plan = vm.currentPlan {
                    Text("\(plan.completedCount) of \(plan.totalWorkoutDays) completed")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }

            Spacer()

            Button {
                vm.generateWeeklyPlan()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 44, height: 44)
                    .background(MVMTheme.cardSoft)
                    .clipShape(Circle())
            }
        }
    }

    private func weekGrid(_ plan: WeeklyPlan) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { index in
                let day = plan.days.first { $0.dayIndex == index }
                VStack(spacing: 6) {
                    Text(dayNames[index])
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    ZStack {
                        Circle()
                            .fill(dayColor(day))
                            .frame(width: 38, height: 38)

                        if let day, day.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                        } else if let day, day.isRestDay {
                            Image(systemName: "moon.zzz")
                                .font(.caption2)
                                .foregroundStyle(MVMTheme.tertiaryText)
                        } else {
                            Circle()
                                .fill(MVMTheme.accent.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .premiumCard()
    }

    private func dayColor(_ day: WorkoutDay?) -> Color {
        guard let day else { return MVMTheme.cardSoft }
        if day.isCompleted { return MVMTheme.success }
        if day.isRestDay { return MVMTheme.cardSoft }
        let isToday = Calendar.current.isDateInToday(day.date)
        return isToday ? MVMTheme.accent.opacity(0.3) : MVMTheme.cardSoft
    }

    private func dayCard(_ day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dayLabel(day))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)

                    Text(day.title)
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                }

                Spacer()

                if day.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(MVMTheme.success)
                }
            }

            if !day.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(day.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(MVMTheme.accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(MVMTheme.accent.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            HStack(spacing: 16) {
                Label("\(day.exercises.count) exercises", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.secondaryText)

                if day.completedExerciseCount > 0 && !day.isCompleted {
                    Label("\(day.completedExerciseCount)/\(day.exercises.count) done", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.accent)
                }
            }

            ForEach(day.exercises.prefix(4)) { exercise in
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(exercise.isCompleted ? MVMTheme.success.opacity(0.2) : MVMTheme.cardSoft)
                            .frame(width: 24, height: 24)
                            .overlay {
                                if exercise.isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(MVMTheme.success)
                                }
                            }

                        Text(exercise.name)
                            .font(.subheadline)
                            .foregroundStyle(exercise.isCompleted ? MVMTheme.secondaryText : MVMTheme.primaryText)
                            .strikethrough(exercise.isCompleted, color: MVMTheme.secondaryText)
                    }

                    Spacer()

                    Text(exercise.displayDetail)
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }

            if day.exercises.count > 4 {
                Text("+\(day.exercises.count - 4) more")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            HStack(spacing: 10) {
                Button {
                    detailDayIndex = day.dayIndex
                    navigateToDetail = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil.and.list.clipboard")
                            .font(.caption)
                        Text("Open & Edit")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())

                if !day.isCompleted {
                    Button {
                        vm.markDayCompleted(dayIndex: day.dayIndex)
                    } label: {
                        Text("Complete")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(MVMTheme.success)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                } else {
                    Button {
                        vm.markDayIncomplete(dayIndex: day.dayIndex)
                    } label: {
                        Text("Undo")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(MVMTheme.cardSoft)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
            }
        }
        .padding(18)
        .premiumCard()
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(MVMTheme.secondaryText)

            Text("No plan yet")
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text("Generate a weekly plan from the Home tab.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .premiumCard()
    }

    private func dayLabel(_ day: WorkoutDay) -> String {
        let isToday = Calendar.current.isDateInToday(day.date)
        let name = dayNames[day.dayIndex]
        return isToday ? "\(name) — Today" : name
    }
}
