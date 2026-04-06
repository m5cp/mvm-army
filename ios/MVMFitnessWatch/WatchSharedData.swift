import Foundation

nonisolated enum WatchSharedData: Sendable {
    static let appGroupID = "group.app.rork.sf0lrvsw5r0bpccfi1669"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func readWidgetData() -> WatchData {
        guard let defaults = sharedDefaults else { return WatchData() }

        return WatchData(
            todayWorkoutTitle: defaults.string(forKey: "widget_todayWorkoutTitle"),
            todayExerciseCount: defaults.integer(forKey: "widget_todayExerciseCount"),
            aftScore: defaults.object(forKey: "widget_aftScore") as? Int,
            aftPassed: defaults.object(forKey: "widget_aftPassed") as? Bool,
            streak: defaults.integer(forKey: "widget_streak"),
            stepsToday: defaults.integer(forKey: "widget_stepsToday"),
            completedToday: defaults.bool(forKey: "widget_completedToday"),
            planWeek: defaults.integer(forKey: "widget_planWeek"),
            planTotalWeeks: defaults.integer(forKey: "widget_planTotalWeeks"),
            lastUpdate: Date(timeIntervalSince1970: defaults.double(forKey: "widget_lastUpdate"))
        )
    }
}

nonisolated struct WatchData: Sendable {
    var todayWorkoutTitle: String? = nil
    var todayExerciseCount: Int = 0
    var aftScore: Int? = nil
    var aftPassed: Bool? = nil
    var streak: Int = 0
    var stepsToday: Int = 0
    var completedToday: Bool = false
    var planWeek: Int = 0
    var planTotalWeeks: Int = 0
    var lastUpdate: Date = .distantPast
}
