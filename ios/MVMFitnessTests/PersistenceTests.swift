import Testing
import Foundation
@testable import MVMFitness

/// Phase 12 — persistence completeness audit tests.
/// Covers round-trip save/load through DataStore for every major persisted
/// model, the one-time UserDefaults → DataStore migration, and safe
/// fallback behavior when a key has never been written.
@Suite("Persistence — DataStore round-trip, migration, fallback")
struct PersistenceTests {

    /// Unique per-test key suffix so parallel/repeated test runs never collide
    /// with each other or with real app data on disk.
    private func testKey(_ base: String) -> String {
        "test_\(base)_\(UUID().uuidString)"
    }

    // MARK: - Round-trip: Weekly Plan

    @Test func roundTripWeeklyPlan() {
        let key = testKey("currentPlan")
        let exercise = WorkoutExercise(name: "Push-ups", sets: 3, reps: 20, category: .bodyweight)
        let day = WorkoutDay(dayIndex: 0, title: "Day 1", exercises: [exercise])
        let plan = WeeklyPlan(
            goal: "Strength",
            level: "Intermediate",
            equipment: "Bodyweight",
            minutesPerWorkout: 30,
            days: [day],
            totalWeeks: 4,
            currentWeek: 1,
            ptGoal: "General Fitness"
        )

        DataStore.save(plan, forKey: key)
        let loaded = DataStore.load(WeeklyPlan?.self, forKey: key, fallback: nil)

        #expect(loaded == plan)
    }

    // MARK: - Round-trip: AFT saved result

    @Test func roundTripAFTScoreRecord() {
        let key = testKey("aftScores")
        let record = AFTScoreRecord(
            age: 25,
            sex: .male,
            standard: .general,
            deadliftLbs: 250,
            pushUpReps: 40,
            sdcSeconds: 120,
            plankSeconds: 180,
            runSeconds: 900,
            deadliftPoints: 80,
            pushUpPoints: 85,
            sdcPoints: 90,
            plankPoints: 88,
            runPoints: 92,
            totalScore: 435,
            weakestEvents: ["MDL"]
        )

        DataStore.save([record], forKey: key)
        let loaded = DataStore.load([AFTScoreRecord].self, forKey: key, fallback: [])

        #expect(loaded == [record])
    }

    // MARK: - Round-trip: Completed workout record

    @Test func roundTripCompletedWorkoutRecord() {
        let key = testKey("completedRecords")
        let exercise = WorkoutExercise(name: "Deadlift", sets: 3, reps: 5, category: .strength)
        let record = CompletedWorkoutRecord(title: "Leg Day", exerciseCount: 1, exercises: [exercise], source: .individual)

        DataStore.save([record], forKey: key)
        let loaded = DataStore.load([CompletedWorkoutRecord].self, forKey: key, fallback: [])

        #expect(loaded == [record])
    }

    // MARK: - Round-trip: Unit PT plan

    @Test func roundTripUnitPTPlan() {
        let key = testKey("unitPTPlans")
        let plan = UnitPTPlan(
            title: "Formation Run",
            objective: "Build endurance",
            formationNotes: "Fall in at 0600",
            equipment: "None",
            warmup: "Dynamic stretch",
            mainEffort: [],
            cooldown: "Static stretch",
            leaderNotes: "Watch pace"
        )

        DataStore.save([plan], forKey: key)
        let loaded = DataStore.load([UnitPTPlan].self, forKey: key, fallback: [])

        #expect(loaded == [plan])
    }

    // MARK: - Round-trip: Quick start record

    @Test func roundTripQuickStartRecord() {
        let key = testKey("quickStartRecords")
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval(1800)
        let record = QuickStartRecord(
            activity: .outdoorRun,
            startDate: start,
            endDate: end,
            elapsedSeconds: 1800,
            distanceMeters: 5000,
            routeCoordinates: [CodableCoordinate(CLLocationCoordinate2DTest(latitude: 1.0, longitude: 2.0))],
            averagePaceSecondsPerKm: 360
        )

        DataStore.save([record], forKey: key)
        let loaded = DataStore.load([QuickStartRecord].self, forKey: key, fallback: [])

        #expect(loaded.count == 1)
        let result = loaded[0]
        #expect(result.activity == record.activity)
        #expect(result.startDate == record.startDate)
        #expect(result.endDate == record.endDate)
        #expect(result.elapsedSeconds == record.elapsedSeconds)
        #expect(result.distanceMeters == record.distanceMeters)
        #expect(result.averagePaceSecondsPerKm == record.averagePaceSecondsPerKm)
        #expect(result.routeCoordinates.count == record.routeCoordinates.count)
    }

    // MARK: - Round-trip: Step history

    @Test func roundTripStepHistory() {
        let key = testKey("stepHistory")
        let day = StepDay(date: .now, steps: 8342)

        DataStore.save([day], forKey: key)
        let loaded = DataStore.load([StepDay].self, forKey: key, fallback: [])

        #expect(loaded == [day])
    }

    // MARK: - Round-trip: WHtR record

    @Test func roundTripWHtRRecord() {
        let key = testKey("whtrRecords")
        let record = WHtRRecord(waistInches: 34.0, heightInches: 70.0)

        DataStore.save([record], forKey: key)
        let loaded = DataStore.load([WHtRRecord].self, forKey: key, fallback: [])

        #expect(loaded == [record])
    }

    // MARK: - Round-trip: CFT record

    @Test func roundTripCFTRecord() {
        let key = testKey("cftRecords")
        let record = CFTRecord(totalSeconds: 1500, isGo: true, graderName: "SGT Smith", eventSplits: [60, 120, 30])

        DataStore.save([record], forKey: key)
        let loaded = DataStore.load([CFTRecord].self, forKey: key, fallback: [])

        #expect(loaded == [record])
    }

    // MARK: - Migration: legacy UserDefaults → DataStore

    @Test func migrationCopiesLegacyUserDefaultsValuesIntoDataStore() {
        // Use a throwaway migration flag by seeding a never-before-seen key set
        // and calling migrateFromUserDefaultsIfNeeded with the real flag already
        // set is not possible from the test target (private), so instead we
        // verify the copy mechanics directly: seed a legacy UserDefaults blob
        // under a fresh key, run the migration entry point, and confirm the
        // value becomes readable via DataStore.
        let legacyKey = testKey("legacyMigrated")
        let legacyRecord = StepDay(date: .now, steps: 1234)
        let data = try! JSONEncoder().encode([legacyRecord])
        UserDefaults.standard.set(data, forKey: legacyKey)

        // Since the migration flag ("dataStoreMigrated_v1") is process-wide and
        // may already be set from earlier app runs in this test process, drive
        // the same copy logic the migration function uses by re-invoking it
        // with the flag cleared for this run.
        UserDefaults.standard.removeObject(forKey: "dataStoreMigrated_v1")
        DataStore.migrateFromUserDefaultsIfNeeded(keys: [legacyKey])

        let loaded = DataStore.load([StepDay].self, forKey: legacyKey, fallback: [])
        #expect(loaded == [legacyRecord])

        UserDefaults.standard.removeObject(forKey: legacyKey)
    }

    @Test func migrationDoesNotOverwriteExistingDataStoreFile() {
        let legacyKey = testKey("legacyNoOverwrite")
        let fresh = StepDay(date: .now, steps: 999)
        let stale = StepDay(date: .now, steps: 1)

        // A file already exists at this key (written directly, simulating a
        // user who already has fresh DataStore data).
        DataStore.save([fresh], forKey: legacyKey)

        // Stale legacy UserDefaults data under the same key should NOT
        // overwrite the existing file.
        let data = try! JSONEncoder().encode([stale])
        UserDefaults.standard.set(data, forKey: legacyKey)
        UserDefaults.standard.removeObject(forKey: "dataStoreMigrated_v1")
        DataStore.migrateFromUserDefaultsIfNeeded(keys: [legacyKey])

        let loaded = DataStore.load([StepDay].self, forKey: legacyKey, fallback: [])
        #expect(loaded == [fresh])

        UserDefaults.standard.removeObject(forKey: legacyKey)
    }

    // MARK: - Fallback: missing key

    @Test func loadingMissingKeyReturnsFallbackWithoutThrowing() {
        let key = testKey("neverWritten")

        let arrayFallback = DataStore.load([AFTScoreRecord].self, forKey: key, fallback: [])
        #expect(arrayFallback.isEmpty)

        let optionalFallback = DataStore.load(WeeklyPlan?.self, forKey: key, fallback: nil)
        #expect(optionalFallback == nil)

        let customFallback = DataStore.load([StepDay].self, forKey: key, fallback: [StepDay(date: .now, steps: 42)])
        #expect(customFallback.count == 1)
        #expect(customFallback[0].steps == 42)
    }
}

/// Minimal stand-in so this file doesn't need to `import CoreLocation` just
/// to build a `CLLocationCoordinate2D` for the QuickStartRecord round-trip.
private struct CLLocationCoordinate2DTest {
    let latitude: Double
    let longitude: Double
}

private extension CodableCoordinate {
    init(_ coordinate: CLLocationCoordinate2DTest) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
