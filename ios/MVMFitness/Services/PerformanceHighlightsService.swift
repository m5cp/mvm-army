import Foundation

nonisolated enum HighlightType: Sendable {
    case personalBest
    case eventImprovement
    case scoreChange
    case completion
    case planProgress
    case streak
}

nonisolated struct PerformanceHighlight: Identifiable, Sendable {
    let id: UUID = UUID()
    let type: HighlightType
    let title: String
    let detail: String?
    let icon: String
    let isPositive: Bool

    init(type: HighlightType, title: String, detail: String? = nil, icon: String, isPositive: Bool = true) {
        self.type = type
        self.title = title
        self.detail = detail
        self.icon = icon
        self.isPositive = isPositive
    }
}

nonisolated struct InstantRecap: Identifiable, Sendable {
    let id: UUID = UUID()
    let title: String
    let detail: String?
    let icon: String
    let isPositive: Bool

    init(title: String, detail: String? = nil, icon: String, isPositive: Bool = true) {
        self.title = title
        self.detail = detail
        self.icon = icon
        self.isPositive = isPositive
    }
}

enum PerformanceHighlightsService {

    static func generateHighlights(
        aftScores: [AFTScoreRecord],
        completedRecords: [CompletedWorkoutRecord],
        currentPlan: WeeklyPlan?,
        wodPlan: WODPlan?,
        streak: Int
    ) -> [PerformanceHighlight] {
        var highlights: [PerformanceHighlight] = []

        if let pb = personalBestHighlight(aftScores: aftScores) {
            highlights.append(pb)
        }

        if let sc = scoreChangeHighlight(aftScores: aftScores) {
            highlights.append(sc)
        }

        if let ev = bestEventImprovementHighlight(aftScores: aftScores) {
            highlights.append(ev)
        }

        if let pp = planProgressHighlight(currentPlan: currentPlan) {
            highlights.append(pp)
        }

        if let wpp = wodPlanProgressHighlight(wodPlan: wodPlan) {
            highlights.append(wpp)
        }

        if let sk = streakHighlight(streak: streak) {
            highlights.append(sk)
        }

        if let tc = totalCompletionsHighlight(completedRecords: completedRecords) {
            highlights.append(tc)
        }

        return Array(highlights.prefix(3))
    }

    static func workoutRecap(title: String, exerciseCount: Int) -> InstantRecap {
        InstantRecap(
            title: "Workout Complete",
            detail: "\(title) — \(exerciseCount) exercises",
            icon: "checkmark.circle.fill"
        )
    }

    static func aftScoreRecap(
        newScore: AFTScoreRecord,
        previousScores: [AFTScoreRecord]
    ) -> InstantRecap {
        let allScores = previousScores
        let isPersonalBest = allScores.allSatisfy { $0.totalScore <= newScore.totalScore }

        if isPersonalBest && !allScores.isEmpty {
            return InstantRecap(
                title: "New Personal Best: \(newScore.totalScore)",
                detail: nil,
                icon: "trophy.fill"
            )
        }

        if let previous = allScores.first {
            let diff = newScore.totalScore - previous.totalScore
            if diff > 0 {
                return InstantRecap(
                    title: "+\(diff) pts since last test",
                    detail: "Total: \(newScore.totalScore)",
                    icon: "arrow.up.right"
                )
            } else if diff < 0 {
                return InstantRecap(
                    title: "\(diff) pts since last test",
                    detail: "Total: \(newScore.totalScore)",
                    icon: "arrow.down.right",
                    isPositive: false
                )
            }
        }

        return InstantRecap(
            title: "AFT Score: \(newScore.totalScore)",
            detail: nil,
            icon: "shield.fill"
        )
    }

    static func planDayRecap(dayNumber: Int, totalDays: Int) -> InstantRecap {
        InstantRecap(
            title: "Day \(dayNumber) of \(totalDays) completed",
            detail: nil,
            icon: "checkmark.circle.fill"
        )
    }

    // MARK: - Private

    private static func personalBestHighlight(aftScores: [AFTScoreRecord]) -> PerformanceHighlight? {
        guard aftScores.count >= 2 else { return nil }
        let latest = aftScores[0]
        let previousBest = aftScores.dropFirst().max(by: { $0.totalScore < $1.totalScore })
        guard let best = previousBest, latest.totalScore > best.totalScore else { return nil }

        return PerformanceHighlight(
            type: .personalBest,
            title: "Personal Best: \(latest.totalScore)",
            icon: "trophy.fill"
        )
    }

    private static func scoreChangeHighlight(aftScores: [AFTScoreRecord]) -> PerformanceHighlight? {
        guard aftScores.count >= 2 else { return nil }
        let diff = aftScores[0].totalScore - aftScores[1].totalScore
        guard diff != 0 else { return nil }

        if personalBestHighlight(aftScores: aftScores) != nil && diff > 0 {
            return nil
        }

        let sign = diff > 0 ? "+" : ""
        return PerformanceHighlight(
            type: .scoreChange,
            title: "\(sign)\(diff) pts since last test",
            icon: diff > 0 ? "arrow.up.right" : "arrow.down.right",
            isPositive: diff > 0
        )
    }

    private static func bestEventImprovementHighlight(aftScores: [AFTScoreRecord]) -> PerformanceHighlight? {
        guard aftScores.count >= 2 else { return nil }
        let latest = aftScores[0]
        let previous = aftScores[1]

        let events: [(String, Int)] = [
            ("MDL", latest.deadliftPoints - previous.deadliftPoints),
            ("HRP", latest.pushUpPoints - previous.pushUpPoints),
            ("SDC", latest.sdcPoints - previous.sdcPoints),
            ("PLK", latest.plankPoints - previous.plankPoints),
            ("2MR", latest.runPoints - previous.runPoints)
        ]

        guard let best = events.max(by: { $0.1 < $1.1 }), best.1 > 0 else { return nil }

        return PerformanceHighlight(
            type: .eventImprovement,
            title: "+\(best.1) pts (\(best.0))",
            icon: "chart.line.uptrend.xyaxis"
        )
    }

    private static func planProgressHighlight(currentPlan: WeeklyPlan?) -> PerformanceHighlight? {
        guard let plan = currentPlan else { return nil }
        let completed = plan.completedCount
        let total = plan.totalWorkoutDays
        guard total > 0, completed > 0 else { return nil }

        if completed == total {
            return PerformanceHighlight(
                type: .planProgress,
                title: "Week \(plan.currentWeek) complete",
                icon: "flag.fill"
            )
        }

        return PerformanceHighlight(
            type: .planProgress,
            title: "\(completed) of \(total) workouts done",
            detail: "Week \(plan.currentWeek)",
            icon: "list.bullet.circle"
        )
    }

    private static func wodPlanProgressHighlight(wodPlan: WODPlan?) -> PerformanceHighlight? {
        guard let plan = wodPlan else { return nil }
        let completed = plan.days.filter(\.isCompleted).count
        let total = plan.days.filter { !$0.isRestDay }.count
        guard total > 0, completed > 0 else { return nil }

        if completed == total {
            return PerformanceHighlight(
                type: .planProgress,
                title: "Functional week complete",
                icon: "flag.fill"
            )
        }

        return nil
    }

    private static func streakHighlight(streak: Int) -> PerformanceHighlight? {
        let milestones = [3, 5, 7, 10, 14, 21, 30, 60, 90, 100, 365]
        guard milestones.contains(streak) else { return nil }

        return PerformanceHighlight(
            type: .streak,
            title: "\(streak)-day streak",
            icon: "flame.fill"
        )
    }

    private static func totalCompletionsHighlight(completedRecords: [CompletedWorkoutRecord]) -> PerformanceHighlight? {
        let milestones = [10, 25, 50, 75, 100, 150, 200, 250, 300, 500, 1000]
        let count = completedRecords.count
        guard let milestone = milestones.last(where: { count >= $0 }) else { return nil }
        guard count == milestone || (count - milestone) < 3 else { return nil }

        return PerformanceHighlight(
            type: .completion,
            title: "\(milestone) workouts completed",
            icon: "star.fill"
        )
    }
}
