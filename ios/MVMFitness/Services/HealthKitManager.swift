import Foundation
import HealthKit

/// A workout the app wants to mirror into Apple Health.
///
/// Carries a stable `externalID` (the app record's own UUID) so the same
/// session can never be written twice — backfilling an existing history would
/// otherwise duplicate every workout the user already synced.
nonisolated struct PendingHealthWorkout: Sendable {
    let externalID: UUID
    let activityTag: String
    let title: String
    let start: Date
    let end: Date
    let distanceMeters: Double?
    /// False only for GPS-measured sessions; true for a workout the user
    /// checked off, which Health should label as manually entered.
    let wasUserEntered: Bool

    init(
        externalID: UUID,
        activityTag: String,
        title: String,
        start: Date,
        end: Date,
        distanceMeters: Double? = nil,
        wasUserEntered: Bool = true
    ) {
        self.externalID = externalID
        self.activityTag = activityTag
        self.title = title
        self.start = start
        self.end = end
        self.distanceMeters = distanceMeters
        self.wasUserEntered = wasUserEntered
    }
}

@MainActor
final class HealthKitManager {
    static let shared = HealthKitManager()
    private let store = HKHealthStore()

    /// Custom metadata key so an MVM workout is identifiable in Health and in
    /// our own duplicate check. Apple's reserved keys are not appropriate for
    /// an app-defined session title.
    static let titleMetadataKey = "MVMFitnessActivityTitle"

    enum SyncKeys {
        /// Mirrored by the `@AppStorage("healthKitSyncEnabled")` toggle in the
        /// You tab. Unset means ON — syncing is the documented default and the
        /// per-type Health permission sheet is still the real gate.
        static let syncEnabled = "healthKitSyncEnabled"
    }

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    /// User-facing master switch. Defaults to on when the key has never been
    /// written, so existing installs keep the behavior they already had.
    var isSyncEnabled: Bool {
        get {
            guard UserDefaults.standard.object(forKey: SyncKeys.syncEnabled) != nil else { return true }
            return UserDefaults.standard.bool(forKey: SyncKeys.syncEnabled)
        }
        set { UserDefaults.standard.set(newValue, forKey: SyncKeys.syncEnabled) }
    }

    /// Must include every type saveWorkout actually writes. Distance and energy
    /// samples were being appended without share authorization, so addSamples
    /// threw and the throw escaped before finishWorkout() — every GPS session
    /// failed to save to Health entirely, not just its distance.
    private var typesToShare: Set<HKSampleType> {
        var set: Set<HKSampleType> = [HKObjectType.workoutType()]
        if let walkRun = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) { set.insert(walkRun) }
        if let cycling = HKQuantityType.quantityType(forIdentifier: .distanceCycling) { set.insert(cycling) }
        if let swimming = HKQuantityType.quantityType(forIdentifier: .distanceSwimming) { set.insert(swimming) }
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
        set.insert(HKObjectType.workoutType()) // read runs for calculator auto-fill + duplicate checks
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

    /// True when Health will actually accept our workout writes.
    var isWriteAuthorized: Bool {
        isAvailable && store.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized
    }

    /// One-line status for the settings row, so the user can tell the
    /// difference between "off by choice", "never asked" and "denied in Health".
    var statusDescription: String {
        guard isAvailable else { return "Not available on this device" }
        guard isSyncEnabled else { return "Off \(MVMTheme.dot) workouts stay in MVM Fitness only" }
        switch store.authorizationStatus(for: HKObjectType.workoutType()) {
        case .sharingAuthorized: return "On \(MVMTheme.dot) workouts save to Apple Health"
        case .sharingDenied: return "Blocked in Health \(MVMTheme.dot) enable under Settings \(MVMTheme.dot) Health"
        default: return "On \(MVMTheme.dot) you'll be asked after your next workout"
        }
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

    // MARK: - Automatic sync

    /// The single entry point every completed workout flows through.
    ///
    /// Gates on the user's sync toggle, asks for permission contextually the
    /// first time, skips anything already written, and never throws back into
    /// the caller — a Health failure must not disturb saving the workout in the
    /// app itself.
    func sync(_ workout: PendingHealthWorkout) async {
        guard isAvailable, isSyncEnabled else { return }
        guard await requestAuthorization() else { return }
        guard await !workoutExists(externalID: workout.externalID) else { return }
        await write(workout)
    }

    /// Mirrors a batch of already-saved records into Health and returns how
    /// many were newly written. Used by "Sync Past Workouts" so a user who
    /// turns Health on late does not lose their existing history.
    func backfill(_ workouts: [PendingHealthWorkout]) async -> Int {
        guard isAvailable, isSyncEnabled else { return 0 }
        guard await requestAuthorization() else { return 0 }

        var written = 0
        for workout in workouts {
            guard workout.end > workout.start else { continue }
            if await workoutExists(externalID: workout.externalID) { continue }
            await write(workout)
            written += 1
        }
        return written
    }

    /// True when a workout carrying this app record's ID is already in Health.
    private func workoutExists(externalID: UUID) async -> Bool {
        let predicate = HKQuery.predicateForObjects(
            withMetadataKey: HKMetadataKeyExternalUUID,
            allowedValues: [externalID.uuidString]
        )
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: 1,
                sortDescriptors: nil
            ) { _, samples, _ in
                continuation.resume(returning: (samples?.isEmpty == false))
            }
            store.execute(query)
        }
    }

    private func write(_ workout: PendingHealthWorkout) async {
        await saveWorkout(
            activityTag: workout.activityTag,
            start: workout.start,
            end: workout.end,
            distanceMeters: workout.distanceMeters,
            externalID: workout.externalID,
            title: workout.title,
            wasUserEntered: workout.wasUserEntered
        )
    }

    /// Save a completed workout to Apple Health. Silently no-ops if unauthorized.
    func saveWorkout(
        activityTag: String,
        start: Date,
        end: Date,
        distanceMeters: Double? = nil,
        kilocalories: Double? = nil,
        externalID: UUID? = nil,
        title: String? = nil,
        wasUserEntered: Bool = true
    ) async {
        guard isAvailable else { return }
        // A zero-length workout is not worth writing and shows up in Health as a
        // glitch; callers pass `.now` for both when start/end were never recorded.
        guard end > start else { return }
        let config = HKWorkoutConfiguration()
        config.activityType = Self.activityType(for: activityTag)
        do {
            let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: .local())
            try await builder.beginCollection(at: start)

            // Metadata is what makes these entries identifiable as ours in the
            // Health app and what the duplicate check queries against.
            var metadata: [String: Any] = [HKMetadataKeyWasUserEntered: wasUserEntered]
            if let externalID { metadata[HKMetadataKeyExternalUUID] = externalID.uuidString }
            if let title, !title.isEmpty { metadata[Self.titleMetadataKey] = title }
            try? await builder.addMetadata(metadata)

            var samples: [HKSample] = []
            if let distance = distanceMeters, distance > 0,
               let identifier = Self.distanceIdentifier(for: config.activityType),
               let type = HKQuantityType.quantityType(forIdentifier: identifier) {
                // Cycling and swimming distance must not be written as
                // walking+running, or they pollute the user's walk/run totals.
                samples.append(HKQuantitySample(
                    type: type,
                    quantity: HKQuantity(unit: .meter(), doubleValue: distance),
                    start: start,
                    end: end
                ))
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

    /// Which distance type a given activity's meters belong to. Returns nil for
    /// activities where a distance figure would be meaningless (strength work),
    /// so we write no distance rather than a misfiled one.
    private static func distanceIdentifier(for activity: HKWorkoutActivityType) -> HKQuantityTypeIdentifier? {
        switch activity {
        case .cycling: return .distanceCycling
        case .swimming: return .distanceSwimming
        case .running, .walking, .hiking: return .distanceWalkingRunning
        case .rowing: return nil
        default: return nil
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
