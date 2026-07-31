import Testing
import Foundation
@testable import MVMFitness

/// Phase 16 (slice 1) — round-trip tests for `PersistenceCoordinator`, the
/// service `AppViewModel` now delegates `loadLocalData()`/`persistAll()`
/// orchestration to. These exercise the coordinator's own `save`/`load`
/// against the real (shared) `DataStore` keys, mirroring how `AppViewModel`
/// uses it, so a stale key list would be caught here.
@Suite("PersistenceCoordinator — save/load round trip")
struct PersistenceCoordinatorTests {

    @Test func migrationKeysCoverEveryDataStoreBackedField() {
        // Every field PersistenceCoordinator itself saves/loads (plus
        // stepHistory, owned by StepTrackingService) must still be present
        // in the shared migration key list so upgrading users never lose data.
        let expected: Set<String> = [
            "currentPlan", "completedRecords", "stepHistory", "unitPTPlans",
            "unitPTFullPlan", "scheduledUnitPT", "importedWorkouts", "aftScores",
            "aftCalculatorResults", "wodPlan", "quickStartRecords", "dailyLogs"
        ]
        let actual = Set(PersistenceCoordinator.migrationKeys)
        #expect(expected.isSubset(of: actual))
    }

    @Test func saveThenLoadRoundTripsEveryField() {
        let exercise = WorkoutExercise(name: "Push-ups", sets: 3, reps: 20, category: .bodyweight)
        let day = WorkoutDay(dayIndex: 0, title: "Day 1", exercises: [exercise])
        let plan = WeeklyPlan(
            goal: "Strength", level: "Intermediate", equipment: "Bodyweight",
            minutesPerWorkout: 30, days: [day], totalWeeks: 4, currentWeek: 1,
            ptGoal: "General Fitness"
        )
        let completedRecord = CompletedWorkoutRecord(title: "Leg Day", exerciseCount: 1, exercises: [exercise], source: .individual)
        let quickStart = QuickStartRecord(
            activity: .outdoorRun,
            startDate: Date(timeIntervalSince1970: 1_700_000_000),
            endDate: Date(timeIntervalSince1970: 1_700_001_800),
            elapsedSeconds: 1800,
            distanceMeters: 5000,
            routeCoordinates: [],
            averagePaceSecondsPerKm: 360
        )
        let dailyLog = DailyFitnessLog(date: Calendar.current.startOfDay(for: .now))

        let originalTag = UserDefaults.standard.string(forKey: "lastWorkoutTag")
        defer {
            if let originalTag {
                UserDefaults.standard.set(originalTag, forKey: "lastWorkoutTag")
            } else {
                UserDefaults.standard.removeObject(forKey: "lastWorkoutTag")
            }
        }

        let data = PersistenceCoordinator.PersistableData(
            currentPlan: plan,
            completedRecords: [completedRecord],
            lastWorkoutTag: "test_tag_phase16",
            unitPTPlans: [],
            unitPTFullPlan: nil,
            scheduledUnitPT: [],
            importedWorkouts: [],
            aftScores: [],
            aftCalculatorResults: [],
            wodPlan: nil,
            quickStartRecords: [quickStart],
            dailyLogs: [dailyLog]
        )

        PersistenceCoordinator.save(data)
        let loaded = PersistenceCoordinator.load()

        #expect(loaded.currentPlan == plan)
        #expect(loaded.completedRecords == [completedRecord])
        #expect(loaded.lastWorkoutTag == "test_tag_phase16")
        #expect(loaded.quickStartRecords.count == 1)
        #expect(loaded.quickStartRecords[0].elapsedSeconds == 1800)
        #expect(loaded.dailyLogs.contains { $0.date == dailyLog.date })
    }
}
