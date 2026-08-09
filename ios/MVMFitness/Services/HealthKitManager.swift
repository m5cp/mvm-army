import Foundation
import HealthKit

@MainActor
final class HealthKitManager {
    static let shared = HealthKitManager()
    private let store = HKHealthStore()

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    /// Must include every type saveWorkout actually writes. Distance and energy
    /// samples were being appended without share authorization, so addSamples
    /// threw and the throw escaped before finishWorkout() — every GPS session
    /// failed to save to Health entirely, not just its distance.
    private var typesToShare: Set<HKSampleType> {
        var set: Set<HKSampleType> = [HKObjectType.workoutType()]
        if let walkRun = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) { set.insert(walkRun) }
        if let cycling = HKQuantityType.quantityType(forIdentifier: .distanceCycling) { set.insert(cycling) }
        if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) { set.insert(energy) }
        return set
    }
    private var typesToRead: Set<HKObjectType> {
        var set: Set<HKObjectType> = []
        if let steps = HKObjectType.quantityType(forIdentifier: .stepCount) { set.insert(steps) }
        if let energy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) { set.insert(energy) }
        if let hr = HKObjectType.quantityType(forIdentifier: .heartRate) { set.insert(hr) }
        if let walkRun = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) { set.insert(walkRun) }
        if let cycling = HKObjectType.quantityType(forIdentifier: .distanceCycling) { set.insert(cycling) }
        set.insert(HKObjectType.workoutType()) // read runs for calculator auto-fill
        return set
    }

    /// Contextual ask — call the FIRST time a user completes a workout, never at launch.
    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: typesToShare, read: typesToRead)
        } catch {
            print("HealthKit auth failed: \(error.localizedDescription)")
            return false
        }
        // requestAuthorization does NOT throw when the user taps Don't Allow, so
        // returning true on "didn't throw" reported every denial as success.
        return store.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized
    }

    /// True once the prompt has been shown, so the ask stays contextual instead
    /// of re-firing on every completed workout.
    var hasRequestedAuthorization: Bool {
        store.authorizationStatus(for: HKObjectType.workoutType()) != .notDetermined
    }

    /// Map app activities to HK activity types.
    static func activityType(for tag: String) -> HKWorkoutActivityType {
        switch tag.lowercased() {
        case let t where t.contains("ruck") || t.contains("march"): return .hiking
        case let t where t.contains("run"): return .running
        case let t where t.contains("bike") || t.contains("cycl"): return .cycling
        case let t where t.contains("hike"): return .hiking
        case let t where t.contains("walk"): return .walking
        case let t where t.contains("swim"): return .swimming
        case let t where t.contains("row"): return .rowing
        default: return .functionalStrengthTraining
        }
    }

    /// Save a completed workout to Apple Health. Silently no-ops if unauthorized.
    func saveWorkout(activityTag: String, start: Date, end: Date, distanceMeters: Double? = nil, kilocalories: Double? = nil) async {
        guard isAvailable else { return }
        // A zero-length workout is not worth writing and shows up in Health as a
        // glitch; callers pass `.now` for both when start/end were never recorded.
        guard end > start else { return }
        let config = HKWorkoutConfiguration()
        config.activityType = Self.activityType(for: activityTag)
        do {
            let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: .local())
            try await builder.beginCollection(at: start)
            var samples: [HKSample] = []
            if let distance = distanceMeters, distance > 0 {
                // Cycling distance must not be written as walking+running, or it
                // pollutes the user's walk/run totals in Health.
                let identifier: HKQuantityTypeIdentifier = config.activityType == .cycling
                    ? .distanceCycling
                    : .distanceWalkingRunning
                if let type = HKQuantityType.quantityType(forIdentifier: identifier) {
                    samples.append(HKQuantitySample(type: type, quantity: HKQuantity(unit: .meter(), doubleValue: distance), start: start, end: end))
                }
            }
            if let kcal = kilocalories, kcal > 0,
               let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                samples.append(HKQuantitySample(type: type, quantity: HKQuantity(unit: .kilocalorie(), doubleValue: kcal), start: start, end: end))
            }
            // Health permissions are per type and default to off. A user who
            // allowed Workouts but not Walking + Running Distance would
            // otherwise lose the entire workout here, because the throw skips
            // endCollection and finishWorkout below.
            if !samples.isEmpty { try? await builder.addSamples(samples) }
            try await builder.endCollection(at: end)
            try await builder.finishWorkout()
        } catch {
            print("HealthKit workout save failed: \(error.localizedDescription)")
        }
    }

    /// Estimated 2-mile time (seconds) from the user's best recent running
    /// workout in Apple Health (last 90 days, ≥ 1 mile): fastest average pace
    /// × 2 miles. Returns nil when Health is unavailable, unauthorized, or has
    /// no qualifying runs — callers fall back to in-app Quick Start data.
    func estimatedTwoMileSeconds() async -> Int? {
        guard isAvailable else { return nil }
        _ = await requestAuthorization()

        let runPredicate = HKQuery.predicateForWorkouts(with: .running)
        let datePredicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.date(byAdding: .day, value: -90, to: .now),
            end: .now
        )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [runPredicate, datePredicate])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let workouts: [HKWorkout] = await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: 25, sortDescriptors: [sort]) { _, samples, _ in
                continuation.resume(returning: (samples as? [HKWorkout]) ?? [])
            }
            store.execute(query)
        }

        var bestPaceSecondsPerMile: Double?
        for workout in workouts {
            guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
                  let meters = workout.statistics(for: distanceType)?.sumQuantity()?.doubleValue(for: .meter()),
                  meters >= 1609 else { continue }
            let miles = meters / 1609.34
            let pace = workout.duration / miles
            guard pace > 240, pace < 1200 else { continue } // sanity: 4–20 min/mi
            if bestPaceSecondsPerMile == nil || pace < bestPaceSecondsPerMile! {
                bestPaceSecondsPerMile = pace
            }
        }

        return bestPaceSecondsPerMile.map { Int(($0 * 2).rounded()) }
    }

    /// Today's step count from Health (preferred over CMPedometer when authorized).
    func todaySteps() async -> Int? {
        guard isAvailable, let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return nil }
        let start = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
                let value = stats?.sumQuantity()?.doubleValue(for: .count())
                continuation.resume(returning: value.map(Int.init))
            }
            store.execute(query)
        }
    }
}
