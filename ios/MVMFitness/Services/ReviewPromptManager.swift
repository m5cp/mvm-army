import StoreKit
import Foundation

enum ReviewPromptManager {
    private static let maxLifetimePrompts = 3
    private static let cooldownDays = 30
    private static let promptCountKey = "reviewPromptCount"
    private static let lastPromptDateKey = "lastReviewPromptDate"

    static func checkAndPromptIfEligible(trigger: ReviewTrigger) {
        guard shouldPrompt(trigger: trigger) else { return }
        recordPrompt()
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private static func shouldPrompt(trigger: ReviewTrigger) -> Bool {
        let count = UserDefaults.standard.integer(forKey: promptCountKey)
        guard count < maxLifetimePrompts else { return false }

        let lastDate = UserDefaults.standard.double(forKey: lastPromptDateKey)
        if lastDate > 0 {
            let daysSince = Calendar.current.dateComponents([.day], from: Date(timeIntervalSince1970: lastDate), to: .now).day ?? 0
            guard daysSince >= cooldownDays else { return false }
        }

        switch trigger {
        case .streak(let days):
            return [7, 14, 30].contains(days)
        case .workoutMilestone(let total):
            return [5, 10, 25, 50].contains(total)
        case .aftScoreImprovement:
            return count == 0
        case .levelUp(let level):
            return [3, 5].contains(level)
        }
    }

    private static func recordPrompt() {
        let count = UserDefaults.standard.integer(forKey: promptCountKey)
        UserDefaults.standard.set(count + 1, forKey: promptCountKey)
        UserDefaults.standard.set(Date.now.timeIntervalSince1970, forKey: lastPromptDateKey)
    }

    nonisolated enum ReviewTrigger: Sendable {
        case streak(days: Int)
        case workoutMilestone(total: Int)
        case aftScoreImprovement
        case levelUp(level: Int)
    }
}
