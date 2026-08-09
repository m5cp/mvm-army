import Foundation
import WatchConnectivity

/// Watch side of the phone <-> watch link.
///
/// The watch previously read an App Group `UserDefaults` suite written only by
/// the phone. App Group containers do not cross devices, so every value the
/// watch displayed was the default — permanently. This receives a real snapshot
/// over Watch Connectivity and writes it into the same local keys
/// `WatchSharedData` already reads, so the existing screens light up unchanged.
@MainActor
@Observable
final class WatchConnectivityManager: NSObject {
    static let shared = WatchConnectivityManager()

    /// Target pace for the ghost runner in seconds per mile, settable here and
    /// mirrored back to the phone.
    var targetPaceSecondsPerMile: Double?

    /// Bumped whenever a fresh snapshot lands, so views can re-read.
    private(set) var revision: Int = 0

    private var session: WCSession? {
        WCSession.isSupported() ? .default : nil
    }

    func activate() {
        guard let session else { return }
        session.delegate = self
        if session.activationState != .activated { session.activate() }
        applyStoredPace()
    }

    private func applyStoredPace() {
        let stored = (WatchSharedData.sharedDefaults ?? .standard).double(forKey: Keys.targetPace)
        targetPaceSecondsPerMile = stored > 0 ? stored : nil
    }

    /// Adjust the ghost pace from the wrist. Sends to the phone so both devices
    /// agree, and persists locally so it survives the app being suspended.
    func setTargetPace(_ seconds: Double?) {
        targetPaceSecondsPerMile = seconds
        (WatchSharedData.sharedDefaults ?? .standard).set(seconds ?? 0, forKey: Keys.targetPace)
        guard let session, session.activationState == .activated else { return }
        let payload: [String: Any] = [
            Keys.targetPace: seconds ?? 0,
            Keys.updatedAt: Date.now.timeIntervalSince1970
        ]
        try? session.updateApplicationContext(payload)
    }

    /// Nudge the target pace by a number of seconds per mile, clamped to a sane
    /// running range so a Digital Crown spin cannot produce nonsense.
    func adjustTargetPace(by delta: Double) {
        let current = targetPaceSecondsPerMile ?? 9 * 60
        setTargetPace(min(max(current + delta, 4 * 60), 20 * 60))
    }

    private func store(_ context: [String: Any]) {
        // Must be the app-group suite WatchSharedData reads from — writing to
        // .standard would leave every screen showing defaults, which is the
        // exact bug this class exists to fix.
        let defaults = WatchSharedData.sharedDefaults ?? .standard
        if let v = context[Keys.workoutTitle] as? String { defaults.set(v, forKey: "widget_todayWorkoutTitle") }
        if let v = context[Keys.exerciseCount] as? Int { defaults.set(v, forKey: "widget_todayExerciseCount") }
        if let v = context[Keys.streak] as? Int { defaults.set(v, forKey: "widget_streak") }
        if let v = context[Keys.steps] as? Int { defaults.set(v, forKey: "widget_stepsToday") }
        if let v = context[Keys.planWeek] as? Int { defaults.set(v, forKey: "widget_planWeek") }
        if let v = context[Keys.planTotalWeeks] as? Int { defaults.set(v, forKey: "widget_planTotalWeeks") }
        if let v = context[Keys.aftScore] as? Int { defaults.set(v, forKey: "widget_aftScore") }
        if let v = context[Keys.aftPassed] as? Bool { defaults.set(v, forKey: "widget_aftPassed") }
        if let v = context[Keys.completedToday] as? Bool { defaults.set(v, forKey: "widget_completedToday") }
        if let pace = context[Keys.targetPace] as? Double {
            defaults.set(pace, forKey: Keys.targetPace)
            targetPaceSecondsPerMile = pace > 0 ? pace : nil
        }
        revision += 1
    }

    enum Keys {
        static let targetPace = "ghostTargetPaceSecondsPerMile"
        static let updatedAt = "updatedAt"
        static let workoutTitle = "todayWorkoutTitle"
        static let exerciseCount = "todayExerciseCount"
        static let streak = "streak"
        static let steps = "stepsToday"
        static let planWeek = "planWeek"
        static let planTotalWeeks = "planTotalWeeks"
        static let aftScore = "aftScore"
        static let aftPassed = "aftPassed"
        static let completedToday = "completedToday"
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        let context = session.receivedApplicationContext
        guard !context.isEmpty else { return }
        Task { @MainActor in self.store(context) }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in self.store(applicationContext) }
    }
}
