import Foundation
import HealthKit

@Observable
@MainActor
final class WatchWorkoutManager: NSObject {
    static let shared = WatchWorkoutManager()

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    var isActive = false
    var isPaused = false
    var heartRate: Double = 0
    var activeCalories: Double = 0
    var distanceMeters: Double = 0

    /// Wall-clock anchors. Elapsed time is always derived from these rather
    /// than counted by a repeating Timer — a tick counter silently under-counts
    /// whenever watchOS suspends the app (wrist down), and that error is
    /// permanent because it never reconciles against a start date.
    private var startDate: Date?
    private var pauseStartedAt: Date?
    private var accumulatedPause: TimeInterval = 0

    /// (elapsed, cumulativeMeters) samples used to derive rolling-mile pace.
    /// Trimmed to the trailing two miles so it cannot grow without bound.
    private var distanceSamples: [(elapsed: TimeInterval, meters: Double)] = []

    private static let metersPerMile: Double = 1609.344

    // MARK: - Derived metrics

    /// Seconds since the workout started, excluding paused time.
    func elapsed(at date: Date = .now) -> TimeInterval {
        guard let startDate else { return 0 }
        let pausedNow = pauseStartedAt.map { date.timeIntervalSince($0) } ?? 0
        return max(0, date.timeIntervalSince(startDate) - accumulatedPause - pausedNow)
    }

    var distanceMiles: Double { distanceMeters / Self.metersPerMile }

    /// Average pace across the whole workout, in seconds per mile.
    func averagePaceSecondsPerMile(at date: Date = .now) -> Double? {
        let miles = distanceMiles
        guard miles > 0.01 else { return nil }
        return elapsed(at: date) / miles
    }

    /// Pace over the trailing mile, in seconds per mile. Falls back to the
    /// average until a full mile of distance has been recorded.
    func rollingMilePaceSecondsPerMile(at date: Date = .now) -> Double? {
        let now = elapsed(at: date)
        let current = distanceMeters
        guard current > 0 else { return nil }

        let target = current - Self.metersPerMile
        guard target > 0 else { return averagePaceSecondsPerMile(at: date) }

        // Most recent sample at or below the one-mile-ago mark.
        guard let index = distanceSamples.lastIndex(where: { $0.meters <= target }) else {
            return averagePaceSecondsPerMile(at: date)
        }
        let lower = distanceSamples[index]

        // Interpolate between that sample and the next so the split does not
        // quantise to whatever GPS/pedometer update happened to land there.
        var startOfMile = lower.elapsed
        if index + 1 < distanceSamples.count {
            let upper = distanceSamples[index + 1]
            let span = upper.meters - lower.meters
            if span > 0 {
                let fraction = (target - lower.meters) / span
                startOfMile = lower.elapsed + fraction * (upper.elapsed - lower.elapsed)
            }
        }

        let seconds = now - startOfMile
        return seconds > 0 ? seconds : averagePaceSecondsPerMile(at: date)
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }

        let share: Set<HKSampleType> = [HKObjectType.workoutType()]
        var read: Set<HKObjectType> = [HKObjectType.workoutType()]
        if let hr = HKObjectType.quantityType(forIdentifier: .heartRate) { read.insert(hr) }
        if let cal = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) { read.insert(cal) }
        if let walkRun = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) { read.insert(walkRun) }
        if let cycling = HKObjectType.quantityType(forIdentifier: .distanceCycling) { read.insert(cycling) }

        do {
            try await healthStore.requestAuthorization(toShare: share, read: read)
        } catch {
            return false
        }

        // requestAuthorization does not throw when the user declines, so the
        // share status is the only reliable signal that we can actually run.
        return healthStore.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized
    }

    // MARK: - Lifecycle

    func start(activityType: HKWorkoutActivityType, isOutdoor: Bool) async {
        guard !isActive else { return }
        let config = HKWorkoutConfiguration()
        config.activityType = activityType
        config.locationType = isOutdoor ? .outdoor : .indoor
        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            let builder = session.associatedWorkoutBuilder()
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)
            session.delegate = self
            builder.delegate = self
            self.session = session
            self.builder = builder

            resetMetrics()
            let now = Date.now
            session.startActivity(with: now)
            try await builder.beginCollection(at: now)
            startDate = now
            isActive = true
        } catch {
            // startActivity may already have put HealthKit into a running
            // workout; drop it explicitly or the watch is stuck "in a workout".
            session?.end()
            lastError = error.localizedDescription
            session = nil
            builder = nil
            isActive = false
        }
    }

    func pause() {
        guard isActive, !isPaused else { return }
        session?.pause()
    }

    func resume() {
        guard isActive, isPaused else { return }
        session?.resume()
    }

    /// Single place the pause clock is maintained, driven by the session
    /// delegate — so a system auto-pause is excluded from elapsed time exactly
    /// like an in-app pause.
    fileprivate func applyPaused(_ paused: Bool) {
        guard paused != isPaused else { return }
        if paused {
            pauseStartedAt = .now
        } else if let pauseStartedAt {
            accumulatedPause += Date.now.timeIntervalSince(pauseStartedAt)
            self.pauseStartedAt = nil
        }
        isPaused = paused
    }

    func end() async {
        // Guard on the builder, not isActive: the session delegate clears
        // isActive when HealthKit ends the session itself, and we still need to
        // finish collection or the workout is never saved.
        //
        // Ownership is taken BEFORE the first await. A second tap during the
        // suspension would otherwise pass the guard and finish the same builder
        // twice, which throws and reports a failure over a save that worked.
        // Clearing `builder` first also stops the delegate callback raised by
        // our own `end()` below from re-entering here.
        guard let builder else { return }
        let endingSession = session
        self.builder = nil
        self.session = nil
        isActive = false
        isPaused = false

        let endDate = Date.now
        endingSession?.end()
        do {
            try await builder.endCollection(at: endDate)
            try await builder.finishWorkout()
        } catch {
            // Surface the failure instead of reporting a save that never happened.
            lastError = error.localizedDescription
        }
    }

    /// Non-nil when the last start or end attempt failed, so the UI can say so.
    var lastError: String?

    private func resetMetrics() {
        heartRate = 0
        activeCalories = 0
        distanceMeters = 0
        distanceSamples.removeAll()
        startDate = nil
        pauseStartedAt = nil
        accumulatedPause = 0
        isPaused = false
        lastError = nil
    }

    fileprivate func recordDistance(_ meters: Double) {
        // Strictly greater: an equal reading (stalled GPS, indoor, stopped at a
        // light) would append duplicates forever without moving the trim point.
        guard meters > distanceMeters else { return }
        distanceMeters = meters
        distanceSamples.append((elapsed: elapsed(), meters: meters))

        // Keep only what the rolling-mile window can still need.
        let cutoff = meters - (Self.metersPerMile * 2)
        if cutoff > 0, let firstKeep = distanceSamples.firstIndex(where: { $0.meters >= cutoff }), firstKeep > 0 {
            distanceSamples.removeFirst(firstKeep)
        }
    }
}

// MARK: - Session lifecycle

extension WatchWorkoutManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        Task { @MainActor in
            switch toState {
            case .running: self.applyPaused(false)
            case .paused: self.applyPaused(true)
            case .ended, .stopped:
                // The session can end without the user pressing Stop (mirrored
                // session, system termination). Finish collection rather than
                // just flipping the flag, or the workout is silently lost —
                // the UI swaps away from the metrics screen and Stop is gone.
                if self.builder != nil {
                    await self.end()
                } else {
                    self.isActive = false
                }
            default: break
            }
        }
    }

    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            self.lastError = error.localizedDescription
            if self.builder != nil {
                await self.end()
            } else {
                self.isActive = false
            }
        }
    }
}

// MARK: - Live metrics

extension WatchWorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType,
                  let stats = workoutBuilder.statistics(for: quantityType) else { continue }
            Task { @MainActor in
                switch quantityType.identifier {
                case HKQuantityTypeIdentifier.heartRate.rawValue:
                    self.heartRate = stats.mostRecentQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? self.heartRate
                case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
                    self.activeCalories = stats.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? self.activeCalories
                case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
                     HKQuantityTypeIdentifier.distanceCycling.rawValue:
                    if let meters = stats.sumQuantity()?.doubleValue(for: .meter()) {
                        self.recordDistance(meters)
                    }
                default: break
                }
            }
        }
    }

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
