import Foundation

nonisolated struct Milestone: Identifiable, Sendable {
    let id = UUID()
    let icon: String
    let title: String
    let message: String
    let shareText: String
    let suggestUpgrade: Bool
}

enum MilestoneManager {
    private static let shownMilestonesKey = "shownMilestones"

    static func checkWorkoutMilestone(totalCompleted: Int) -> Milestone? {
        let milestones: [(count: Int, icon: String, title: String, message: String)] = [
            (3, "flame.fill", "Momentum Building", "3 workouts in the books. The habit is forming."),
            (5, "star.fill", "First Five", "5 workouts complete. You're building consistency."),
            (10, "trophy.fill", "Double Digits", "10 workouts logged. That's real dedication."),
            (25, "medal.fill", "Quarter Century", "25 workouts. You're outpacing most people."),
            (50, "shield.checkered", "Half Century", "50 workouts complete. Elite discipline."),
            (100, "crown.fill", "Centurion", "100 workouts. You are the standard."),
        ]

        guard let milestone = milestones.first(where: { $0.count == totalCompleted }) else { return nil }
        let key = "workout_\(totalCompleted)"
        guard !hasShown(key) else { return nil }
        markShown(key)

        let suggestUpgrade = [3, 10].contains(totalCompleted)

        return Milestone(
            icon: milestone.icon,
            title: milestone.title,
            message: milestone.message,
            shareText: "Just hit \(totalCompleted) workouts on MVM Fitness 💪 #MVMFitness",
            suggestUpgrade: suggestUpgrade
        )
    }

    static func checkStreakMilestone(streak: Int) -> Milestone? {
        let milestones: [(days: Int, icon: String, title: String, message: String)] = [
            (3, "flame.fill", "3-Day Streak", "Three days straight. Keep the momentum."),
            (7, "flame.circle.fill", "Week Warrior", "7-day streak. A full week of discipline."),
            (14, "flame.circle.fill", "Two Week Force", "14-day streak. Consistency is your weapon."),
            (30, "star.circle.fill", "30-Day Machine", "30 days. This isn't a phase — it's who you are."),
            (60, "medal.fill", "60-Day Operator", "60 days of unbroken training. Respect."),
            (90, "crown.fill", "90-Day Legend", "90 days. You've earned legendary status."),
        ]

        guard let milestone = milestones.first(where: { $0.days == streak }) else { return nil }
        let key = "streak_\(streak)"
        guard !hasShown(key) else { return nil }
        markShown(key)

        return Milestone(
            icon: milestone.icon,
            title: milestone.title,
            message: milestone.message,
            shareText: "🔥 \(streak)-day training streak on MVM Fitness #MVMFitness",
            suggestUpgrade: false
        )
    }

    static func checkAFTMilestone(newScore: Int, previousScore: Int?) -> Milestone? {
        guard let prev = previousScore, newScore > prev else { return nil }
        let improvement = newScore - prev
        let key = "aft_improve_\(newScore)"
        guard !hasShown(key) else { return nil }
        markShown(key)

        if newScore >= 300 && prev < 300 {
            return Milestone(
                icon: "shield.checkered",
                title: "You Passed!",
                message: "Crossed the 300-point threshold. Outstanding.",
                shareText: "Just passed my AFT with a \(newScore) on MVM Fitness 🎯 #MVMFitness",
                suggestUpgrade: false
            )
        }

        if improvement >= 20 {
            return Milestone(
                icon: "chart.line.uptrend.xyaxis",
                title: "+\(improvement) Points!",
                message: "Score jumped from \(prev) to \(newScore). The work is paying off.",
                shareText: "AFT score up +\(improvement) points to \(newScore) on MVM Fitness 📈 #MVMFitness",
                suggestUpgrade: false
            )
        }

        return nil
    }

    static func checkFirstAFTScore() -> Milestone? {
        let key = "first_aft"
        guard !hasShown(key) else { return nil }
        markShown(key)

        return Milestone(
            icon: "shield.fill",
            title: "First Score Logged",
            message: "Your baseline is set. Now let's improve it.",
            shareText: "Logged my first AFT score on MVM Fitness 🎯 #MVMFitness",
            suggestUpgrade: true
        )
    }

    private static func hasShown(_ key: String) -> Bool {
        let shown = UserDefaults.standard.stringArray(forKey: shownMilestonesKey) ?? []
        return shown.contains(key)
    }

    private static func markShown(_ key: String) {
        var shown = UserDefaults.standard.stringArray(forKey: shownMilestonesKey) ?? []
        shown.append(key)
        UserDefaults.standard.set(shown, forKey: shownMilestonesKey)
    }
}
