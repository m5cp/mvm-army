import AppIntents
import SwiftUI

struct LogWorkoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Workout"
    static var description = IntentDescription("Log a completed workout exercise with sets, reps, and weight.")

    @Parameter(title: "Exercise Name", requestValueDialog: "What exercise did you do?")
    var exerciseName: String

    @Parameter(title: "Sets", default: 3)
    var sets: Int

    @Parameter(title: "Reps", default: 10)
    var reps: Int

    @Parameter(title: "Weight", requestValueDialog: "How much weight? (e.g. 135 lbs)")
    var weight: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$sets) x \(\.$reps) of \(\.$exerciseName)") {
            \.$weight
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let weightStr = weight ?? ""
        await MainActor.run {
            WorkoutLogStore.shared.logWorkout(
                name: exerciseName,
                sets: sets,
                reps: reps,
                weight: weightStr
            )
        }

        var summary = "\(sets) x \(reps) \(exerciseName)"
        if let w = weight, !w.isEmpty {
            summary += " @ \(w)"
        }

        return .result(dialog: "Logged: \(summary)")
    }
}

struct GetTodayWorkoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Today's Workout"
    static var description = IntentDescription("See what workout is planned for today.")
    static var openAppWhenRun: Bool = false

    static var parameterSummary: some ParameterSummary {
        Summary("Get today's workout")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let title = await MainActor.run { () -> String? in
            let plan: WeeklyPlan? = LocalStore.load(WeeklyPlan?.self, forKey: "currentPlan", fallback: nil)
            guard let plan else { return nil }
            let today = Calendar.current.startOfDay(for: .now)
            let todayDay = plan.days.first { Calendar.current.isDate($0.date, inSameDayAs: today) && !$0.isRestDay }
            return todayDay?.title
        }

        if let title {
            return .result(dialog: "Today's workout: \(title)")
        } else {
            return .result(dialog: "No workout planned for today. Open MVM Fitness to generate a plan.")
        }
    }
}

struct StartWorkoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Workout"
    static var description = IntentDescription("Open MVM Fitness and start today's workout.")
    static var openAppWhenRun: Bool = true

    static var parameterSummary: some ParameterSummary {
        Summary("Start today's workout")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(dialog: "Opening MVM Fitness...")
    }
}

struct MVMAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogWorkoutIntent(),
            phrases: [
                "Log a workout in \(.applicationName)",
                "Log exercise in \(.applicationName)",
                "Record workout in \(.applicationName)",
                "Log \(\.$exerciseName) in \(.applicationName)"
            ],
            shortTitle: "Log Workout",
            systemImageName: "figure.strengthtraining.traditional"
        )

        AppShortcut(
            intent: GetTodayWorkoutIntent(),
            phrases: [
                "What's my workout in \(.applicationName)",
                "Today's workout in \(.applicationName)",
                "What workout do I have in \(.applicationName)"
            ],
            shortTitle: "Today's Workout",
            systemImageName: "calendar.badge.clock"
        )

        AppShortcut(
            intent: StartWorkoutIntent(),
            phrases: [
                "Start workout in \(.applicationName)",
                "Begin workout in \(.applicationName)",
                "Open workout in \(.applicationName)"
            ],
            shortTitle: "Start Workout",
            systemImageName: "play.fill"
        )
    }

    static var shortcutTileColor: ShortcutTileColor = .teal
}
