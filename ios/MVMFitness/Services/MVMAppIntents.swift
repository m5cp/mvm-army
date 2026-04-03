import AppIntents
import SwiftUI

struct ShowAFTScoreIntent: AppIntent {
    static var title: LocalizedStringResource = "Show AFT Score"
    static var description = IntentDescription("Shows your latest AFT score")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let data = SharedDataManager.readWidgetData()
        if let score = data.aftScore {
            let passStatus = data.aftPassed == true ? "PASS" : "NEEDS WORK"
            return .result(dialog: "Your latest AFT score is \(score) — \(passStatus)")
        }
        return .result(dialog: "No AFT score recorded yet. Open the AFT Calculator to calculate your score.")
    }
}

struct StartPTIntent: AppIntent {
    static var title: LocalizedStringResource = "Start My PT"
    static var description = IntentDescription("Opens today's PT workout")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let data = SharedDataManager.readWidgetData()
        if let title = data.todayWorkoutTitle {
            if data.completedToday {
                return .result(dialog: "Today's workout \"\(title)\" is already complete. Great work!")
            }
            return .result(dialog: "Opening today's workout: \(title)")
        }
        return .result(dialog: "No workout scheduled for today. Open MVM Fitness to generate a plan.")
    }
}

struct CheckStreakIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Training Streak"
    static var description = IntentDescription("Shows your current training streak")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let data = SharedDataManager.readWidgetData()
        let streak = data.streak
        if streak > 0 {
            return .result(dialog: "You're on a \(streak)-day training streak. Keep pushing!")
        }
        return .result(dialog: "No active streak. Start a workout today to build your streak!")
    }
}

struct CheckStepsIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Today's Steps"
    static var description = IntentDescription("Shows your step count for today")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let data = SharedDataManager.readWidgetData()
        let steps = data.stepsToday
        return .result(dialog: "You've taken \(steps.formatted()) steps today.")
    }
}

struct MVMFitnessShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ShowAFTScoreIntent(),
            phrases: [
                "Show my AFT score in \(.applicationName)",
                "What's my AFT score on \(.applicationName)",
                "Check my fitness test score in \(.applicationName)"
            ],
            shortTitle: "AFT Score",
            systemImageName: "shield.checkered"
        )
        AppShortcut(
            intent: StartPTIntent(),
            phrases: [
                "Start my PT in \(.applicationName)",
                "Open today's workout in \(.applicationName)",
                "What's my workout today on \(.applicationName)"
            ],
            shortTitle: "Start PT",
            systemImageName: "figure.run"
        )
        AppShortcut(
            intent: CheckStreakIntent(),
            phrases: [
                "Check my training streak in \(.applicationName)",
                "How's my streak on \(.applicationName)"
            ],
            shortTitle: "Training Streak",
            systemImageName: "flame.fill"
        )
        AppShortcut(
            intent: CheckStepsIntent(),
            phrases: [
                "Check my steps in \(.applicationName)",
                "How many steps today on \(.applicationName)"
            ],
            shortTitle: "Today's Steps",
            systemImageName: "figure.walk"
        )
    }

    static var shortcutTileColor: ShortcutTileColor = .navy
}
