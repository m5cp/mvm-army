import SwiftUI
import FoundationModels

enum AIAvailabilityStatus {
    case available
    case notEnabled
    case notReady
    case deviceNotEligible
    case unknown
    case osNotSupported
}

@available(iOS 26.0, *)
@MainActor
@Observable
final class AppleIntelligenceService {
    var isGenerating: Bool = false

    var availabilityStatus: AIAvailabilityStatus {
        switch SystemLanguageModel.default.availability {
        case .available:
            return .available
        case .unavailable(.appleIntelligenceNotEnabled):
            return .notEnabled
        case .unavailable(.modelNotReady):
            return .notReady
        case .unavailable(.deviceNotEligible):
            return .deviceNotEligible
        default:
            return .unknown
        }
    }

    var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    func generateProgressInsight(
        aftScores: [AFTScoreRecord],
        completedRecords: [CompletedWorkoutRecord],
        streak: Int,
        weeklyStepAverage: Int,
        currentPlan: WeeklyPlan?
    ) async -> String {
        guard isAvailable else {
            return unavailableMessage
        }

        isGenerating = true
        defer { isGenerating = false }

        let context = buildProgressContext(
            aftScores: aftScores,
            completedRecords: completedRecords,
            streak: streak,
            weeklyStepAverage: weeklyStepAverage,
            currentPlan: currentPlan
        )

        let prompt = """
        You are a concise military fitness advisor. Analyze this soldier's training data and provide a brief, actionable insight in 2-3 sentences. Focus on trends, strengths, or areas to improve. Be direct and motivating.

        \(context)

        Provide your analysis:
        """

        do {
            let session = LanguageModelSession {
                "You are a military fitness advisor. Keep responses under 3 sentences. Be direct, motivating, and actionable. DO NOT use markdown formatting."
            }
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            return "Unable to generate insight right now. Keep pushing — your consistency is what counts."
        }
    }

    func generateWeeklySummary(
        completedRecords: [CompletedWorkoutRecord],
        aftScores: [AFTScoreRecord],
        streak: Int,
        stepsThisWeek: Int
    ) async -> String {
        guard isAvailable else {
            return unavailableMessage
        }

        isGenerating = true
        defer { isGenerating = false }

        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now
        let weekRecords = completedRecords.filter { $0.date >= startOfWeek }

        let workoutList = weekRecords.map { "\($0.title) (\($0.exerciseCount) exercises)" }.joined(separator: ", ")

        let latestScore = aftScores.first.map { "Latest AFT: \($0.totalScore) points" } ?? "No AFT scores recorded"

        let prompt = """
        Summarize this soldier's training week in 3-4 sentences. Be specific about what was accomplished and give one forward-looking recommendation.

        Workouts completed this week: \(weekRecords.count)
        Sessions: \(workoutList.isEmpty ? "None" : workoutList)
        Current streak: \(streak) days
        Steps this week: \(stepsThisWeek.formatted())
        \(latestScore)

        Write a brief after-action summary:
        """

        do {
            let session = LanguageModelSession {
                "You are a military fitness advisor writing a brief weekly training summary. Keep it under 4 sentences. Be specific and motivating. DO NOT use markdown formatting."
            }
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            return "Unable to generate summary right now. You completed \(weekRecords.count) workout\(weekRecords.count == 1 ? "" : "s") this week."
        }
    }

    func generateAdaptiveCoachingTip(
        recentWorkouts: [CompletedWorkoutRecord],
        weakEvents: [String],
        currentFocus: String
    ) async -> String {
        guard isAvailable else {
            return unavailableMessage
        }

        isGenerating = true
        defer { isGenerating = false }

        let recentList = recentWorkouts.prefix(5).map(\.title).joined(separator: ", ")

        let prompt = """
        Based on this soldier's recent training, give one specific, actionable tip in 1-2 sentences.

        Recent workouts: \(recentList.isEmpty ? "None yet" : recentList)
        Weak AFT events: \(weakEvents.isEmpty ? "None identified" : weakEvents.joined(separator: ", "))
        Training focus: \(currentFocus)

        Give a short coaching tip:
        """

        do {
            let session = LanguageModelSession {
                "You are a military fitness coach. Give one brief, specific training tip. Keep it under 2 sentences. DO NOT use markdown formatting."
            }
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            return "Stay consistent with your training plan. Focus on your weakest events for the biggest score gains."
        }
    }

    private func buildProgressContext(
        aftScores: [AFTScoreRecord],
        completedRecords: [CompletedWorkoutRecord],
        streak: Int,
        weeklyStepAverage: Int,
        currentPlan: WeeklyPlan?
    ) -> String {
        var parts: [String] = []

        parts.append("Training streak: \(streak) days")
        parts.append("Total workouts completed: \(completedRecords.count)")
        parts.append("Weekly step average: \(weeklyStepAverage.formatted())")

        if let plan = currentPlan {
            parts.append("Current plan: Week \(plan.currentWeek) of \(plan.totalWeeks), \(plan.completedCount)/\(plan.totalWorkoutDays) sessions done")
        }

        if let latest = aftScores.first {
            parts.append("Latest AFT score: \(latest.totalScore) (MDL:\(latest.deadliftPoints) HRP:\(latest.pushUpPoints) SDC:\(latest.sdcPoints) PLK:\(latest.plankPoints) 2MR:\(latest.runPoints))")

            if !latest.weakestEvents.isEmpty {
                parts.append("Weakest events: \(latest.weakestEvents.joined(separator: ", "))")
            }

            if aftScores.count >= 2 {
                let previous = aftScores[1]
                let diff = latest.totalScore - previous.totalScore
                parts.append("Score change: \(diff >= 0 ? "+" : "")\(diff) from previous test")
            }
        }

        let calendar = Calendar.current
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: .now) ?? .now
        let recentCount = completedRecords.filter { $0.date >= twoWeeksAgo }.count
        parts.append("Workouts in last 14 days: \(recentCount)")

        return parts.joined(separator: "\n")
    }

    private var unavailableMessage: String {
        "Apple Intelligence is not available on this device. This feature requires iPhone 15 Pro or later with iOS 26 and Apple Intelligence enabled."
    }
}

enum AIFeatureCheck {
    static var isDeviceCapable: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }

    static var requirementsDescription: String {
        "Apple Intelligence features require iPhone 15 Pro or later running iOS 26+, with Apple Intelligence enabled in Settings."
    }
}
