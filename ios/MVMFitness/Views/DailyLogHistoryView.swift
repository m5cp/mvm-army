import SwiftUI

/// Rolling history of daily activity (steps, workouts, AFT test) — read from
/// `AppViewModel.dailyLogs`, which is persisted via `DataStore` so past days
/// stay visible even after the app is force-quit and reopened.
struct DailyLogHistoryView: View {
    @Environment(AppViewModel.self) private var vm

    private var groupedLogs: [(String, [DailyFitnessLog])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let grouped = Dictionary(grouping: vm.dailyLogsSorted) {
            formatter.string(from: $0.date)
        }

        return grouped.sorted { lhs, rhs in
            guard let l = lhs.value.first?.date, let r = rhs.value.first?.date else { return false }
            return l > r
        }
    }

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            if vm.dailyLogsSorted.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 48))
                        .foregroundStyle(MVMTheme.tertiaryText)

                    Text("No Daily Logs Yet")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)

                    Text("Complete a workout, log steps, or save an AFT score to start your daily history.")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(groupedLogs, id: \.0) { section in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(section.0)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(MVMTheme.secondaryText)
                                    .padding(.horizontal, 4)

                                ForEach(section.1) { log in
                                    logRow(log)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                withAnimation(.easeOut(duration: 0.2)) {
                                                    vm.deleteDailyLog(log)
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Daily Log")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func logRow(_ log: DailyFitnessLog) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 2) {
                Text(dayNumber(log.date))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(MVMTheme.primaryText)
                Text(dayAbbrev(log.date))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .frame(width: 44, height: 44)
            .background(MVMTheme.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Label("\(log.steps.formatted())", systemImage: "figure.walk")
                    if log.workoutCount > 0 {
                        Label("\(log.workoutCount) workout\(log.workoutCount == 1 ? "" : "s")", systemImage: "dumbbell.fill")
                    }
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(MVMTheme.secondaryText)

                if !log.workoutTitles.isEmpty {
                    Text(log.workoutTitles.joined(separator: ", "))
                        .font(.caption2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .lineLimit(1)
                }

                if let score = log.aftScoreLogged {
                    HStack(spacing: 4) {
                        Image(systemName: "shield.fill")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(MVMTheme.accent)
                        Text("AFT \(score) pts")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(MVMTheme.accent)

                        if let best = vm.bestAFTScore, best.totalScore == score, Calendar.current.isDate(best.date, inSameDayAs: log.date) {
                            personalBestBadge
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .mvmCard(cornerRadius: 16)
    }

    private var personalBestBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 9, weight: .bold))
            Text("PB")
                .font(.system(size: 10, weight: .heavy))
        }
        .foregroundStyle(MVMTheme.warning)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(MVMTheme.warning.opacity(0.15))
        .clipShape(Capsule())
    }

    private func dayNumber(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }

    private func dayAbbrev(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }
}
