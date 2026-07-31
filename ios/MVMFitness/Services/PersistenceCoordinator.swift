import Foundation

/// Owns the `loadLocalData()` / `persistAll()` orchestration and the
/// `DataStore` key inventory (including the one-time migration key list) for
/// `AppViewModel`. Extracted from `AppViewModel` in Phase 16 (slice 1) with
/// zero behavior change — every key, load order, and save order matches what
/// `AppViewModel` did inline before this extraction.
///
/// Deliberately excludes step history / the pedometer, which now live in
/// `StepTrackingService`; `AppViewModel` coordinates both services together.
enum PersistenceCoordinator {

    /// Every legacy UserDefaults-backed key that must be copied into
    /// `DataStore` the first time a device runs the file-based store.
    static let migrationKeys: [String] = [
        "completedRecords", "stepHistory", "unitPTPlans", "aftScores",
        "aftCalculatorResults", "currentPlan", "quickStartRecords",
        "unitPTFullPlan", "scheduledUnitPT", "importedWorkouts", "wodPlan",
        "whtrRecords", "cftRecords", "dailyLogs", "squadData",
        "shownMilestones", "todayFunctionalWOD"
    ]

    /// Runs the one-time UserDefaults → DataStore migration. Safe to call
    /// repeatedly; `DataStore` itself no-ops after the first successful run.
    static func migrateIfNeeded() {
        DataStore.migrateFromUserDefaultsIfNeeded(keys: migrationKeys)
    }

    /// Snapshot of everything `AppViewModel` loads from disk on launch
    /// (excluding step history, which `StepTrackingService` owns).
    struct LoadedData {
        var currentPlan: WeeklyPlan?
        var completedRecords: [CompletedWorkoutRecord]
        var lastWorkoutTag: String
        var unitPTPlans: [UnitPTPlan]
        var unitPTFullPlan: UnitPTFullPlan?
        var scheduledUnitPT: [WorkoutDay]
        var importedWorkouts: [WorkoutDay]
        var aftScores: [AFTScoreRecord]
        var aftCalculatorResults: [AFTCalculatorResult]
        var wodPlan: WODPlan?
        var quickStartRecords: [QuickStartRecord]
        var dailyLogs: [DailyFitnessLog]
    }

    /// Snapshot of everything `AppViewModel` writes to disk on every
    /// `persistAll()` call (excluding step history, which
    /// `StepTrackingService` owns).
    struct PersistableData {
        var currentPlan: WeeklyPlan?
        var completedRecords: [CompletedWorkoutRecord]
        var lastWorkoutTag: String
        var unitPTPlans: [UnitPTPlan]
        var unitPTFullPlan: UnitPTFullPlan?
        var scheduledUnitPT: [WorkoutDay]
        var importedWorkouts: [WorkoutDay]
        var aftScores: [AFTScoreRecord]
        var aftCalculatorResults: [AFTCalculatorResult]
        var wodPlan: WODPlan?
        var quickStartRecords: [QuickStartRecord]
        var dailyLogs: [DailyFitnessLog]
    }

    static func load() -> LoadedData {
        LoadedData(
            currentPlan: DataStore.load(WeeklyPlan?.self, forKey: "currentPlan", fallback: nil),
            completedRecords: DataStore.load([CompletedWorkoutRecord].self, forKey: "completedRecords", fallback: []),
            lastWorkoutTag: UserDefaults.standard.string(forKey: "lastWorkoutTag") ?? "",
            unitPTPlans: DataStore.load([UnitPTPlan].self, forKey: "unitPTPlans", fallback: []),
            unitPTFullPlan: DataStore.load(UnitPTFullPlan?.self, forKey: "unitPTFullPlan", fallback: nil),
            scheduledUnitPT: DataStore.load([WorkoutDay].self, forKey: "scheduledUnitPT", fallback: []),
            importedWorkouts: DataStore.load([WorkoutDay].self, forKey: "importedWorkouts", fallback: []),
            aftScores: DataStore.load([AFTScoreRecord].self, forKey: "aftScores", fallback: []),
            aftCalculatorResults: DataStore.load([AFTCalculatorResult].self, forKey: "aftCalculatorResults", fallback: []),
            wodPlan: DataStore.load(WODPlan?.self, forKey: "wodPlan", fallback: nil),
            quickStartRecords: DataStore.load([QuickStartRecord].self, forKey: "quickStartRecords", fallback: []),
            dailyLogs: DataStore.load([DailyFitnessLog].self, forKey: "dailyLogs", fallback: [])
        )
    }

    static func save(_ data: PersistableData) {
        DataStore.save(data.currentPlan, forKey: "currentPlan")
        DataStore.save(data.completedRecords, forKey: "completedRecords")
        UserDefaults.standard.set(data.lastWorkoutTag, forKey: "lastWorkoutTag")
        DataStore.save(data.unitPTPlans, forKey: "unitPTPlans")
        DataStore.save(data.unitPTFullPlan, forKey: "unitPTFullPlan")
        DataStore.save(data.scheduledUnitPT, forKey: "scheduledUnitPT")
        DataStore.save(data.importedWorkouts, forKey: "importedWorkouts")
        DataStore.save(data.aftScores, forKey: "aftScores")
        DataStore.save(data.aftCalculatorResults, forKey: "aftCalculatorResults")
        DataStore.save(data.wodPlan, forKey: "wodPlan")
        DataStore.save(data.quickStartRecords, forKey: "quickStartRecords")
        DataStore.save(data.dailyLogs, forKey: "dailyLogs")
    }
}
