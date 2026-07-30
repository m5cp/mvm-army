import SwiftUI

/// 15a — 3x3 milestone coin grid, hung off the You tab below Profile.
/// Coins are static PNGs (icon3d-*) — reward art, never navigation, never a button.
///
/// Earn rules read ONLY already-logged app data (no new storage, no new scoring
/// math): saved AFT results, completed workout records, the active weekly plan,
/// and the existing streak/session counters on AppViewModel. This restyles the
/// same underlying achievement concepts the toast-style MilestoneManager already
/// celebrates in the moment, but as a persistent, always-visible grid.
struct BadgesView: View {
    @Environment(AppViewModel.self) private var vm
    @AppStorage("planWeeks") private var planWeeks = 4

    private struct Coin: Identifiable {
        let id = UUID()
        let asset: String
        let name: String
        let status: String
        let earned: Bool
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Badges")
                    .font(.system(size: 20, weight: .bold))
                    .tracking(-0.4)
                    .foregroundStyle(MVMTheme.text)
                Spacer()
                Text("\(earnedCount) OF \(coins.count) EARNED")
                    .font(MVMTheme.mono(10.5))
                    .kerning(1.4)
                    .foregroundStyle(MVMTheme.textFaint)
                    .lineLimit(1)
                    .fixedSize()
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 11), count: 3), spacing: 11) {
                ForEach(coins) { coin in
                    BadgeCoin(asset: coin.asset, name: coin.name, status: coin.status, earned: coin.earned)
                }
            }
        }
    }

    private var earnedCount: Int {
        coins.filter(\.earned).count
    }

    // MARK: - Coin definitions (earn rules read existing logged data only)

    private var coins: [Coin] {
        [
            Coin(asset: "icon3d-timer", name: "First test logged",
                 status: hasAnyScore ? firstScoreDateLabel : "LOCKED", earned: hasAnyScore),
            Coin(asset: "icon3d-laurel", name: "Plan finisher",
                 status: planFinished ? "ACTIVE" : "LOCKED", earned: planFinished),
            Coin(asset: "icon3d-dumbbell", name: "20 sessions",
                 status: twentySessions ? "\(vm.totalWorkoutsCompleted) LOGGED" : "LOCKED", earned: twentySessions),
            Coin(asset: "icon3d-shaker", name: "7-day streak",
                 status: weekStreak ? "ACTIVE" : "LOCKED", earned: weekStreak),
            Coin(asset: "icon3d-plate", name: "Perfect week",
                 status: perfectWeek ? "ACTIVE" : "LOCKED", earned: perfectWeek),
            Coin(asset: "icon3d-trophy", name: "New record",
                 status: newRecord ? "+\(scoreDelta ?? 0) PTS" : "LOCKED", earned: newRecord),
            Coin(asset: "icon3d-ruck", name: "Ruck ready",
                 status: ruckLogged ? "LOGGED" : "LOCKED", earned: ruckLogged),
            Coin(asset: "icon3d-barbell", name: "+25 total score",
                 status: bigImprovement ? "+\(scoreDelta ?? 0)" : "LOCKED", earned: bigImprovement),
            Coin(asset: "icon3d-pack", name: "12-week plan",
                 status: twelveWeekPlan ? "ACTIVE" : "LOCKED", earned: twelveWeekPlan),
        ]
    }

    // MARK: - Rules

    private var hasAnyScore: Bool { !vm.aftScores.isEmpty }

    private var firstScoreDateLabel: String {
        guard let first = vm.aftScores.last else { return "LOCKED" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: first.date).uppercased()
    }

    private var planFinished: Bool {
        guard let plan = vm.currentPlan, plan.totalWorkoutDays > 0 else { return false }
        return plan.completedCount >= plan.totalWorkoutDays
    }

    private var twentySessions: Bool { vm.totalWorkoutsCompleted >= 20 }

    private var weekStreak: Bool { vm.streak >= 7 }

    private var perfectWeek: Bool {
        vm.weeklyTotalDays > 0 && vm.workoutsThisWeek >= vm.weeklyTotalDays
    }

    private var scoreDelta: Int? { vm.aftScoreDifference }

    private var newRecord: Bool { (scoreDelta ?? -1) > 0 }

    private var bigImprovement: Bool { (scoreDelta ?? 0) >= 25 }

    /// Event-tag coverage stand-in: any completed session logged a ruck/loaded-carry
    /// cardio activity (structured data already on WorkoutExercise).
    private var ruckLogged: Bool {
        vm.completedRecords.contains { record in
            record.exercises.contains { $0.cardioType == .ruck }
        }
    }

    private var twelveWeekPlan: Bool {
        vm.currentPlan != nil && planWeeks >= 12
    }
}
