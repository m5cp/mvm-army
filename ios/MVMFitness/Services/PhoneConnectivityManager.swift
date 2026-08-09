import Foundation
import WatchConnectivity

/// Phone side of the phone <-> watch link.
///
/// Before this existed the watch read an App Group `UserDefaults` suite that only
/// the phone ever wrote. App Group containers are per-device, so the watch's copy
/// was always empty — its Home, Stats and AFT screens showed "Rest Day", zero
/// streak and no score on real hardware no matter what the phone displayed.
///
/// `updateApplicationContext` is the right primitive for this: last-value-wins,
/// delivered even if the counterpart is asleep, and cheap enough to send on every
/// meaningful change.
@MainActor
@Observable
final class PhoneConnectivityManager: NSObject {
    static let shared = PhoneConnectivityManager()

    /// Target pace for the ghost runner, in seconds per mile. Mirrored in both
    /// directions so it can be set from either device mid-session.
    var targetPaceSecondsPerMile: Double?

    /// Set by the app so a pace edit arriving from the watch reaches the session.
    var onTargetPaceChanged: ((Double?) -> Void)?

    private var session: WCSession? {
        WCSession.isSupported() ? .default : nil
    }

    func activate() {
        guard let session else { return }
        session.delegate = self
        if session.activationState != .activated { session.activate() }
    }

    /// Pushes the current snapshot to the watch. Safe to call often — Watch
    /// Connectivity coalesces application context updates.
    func send(snapshot: [String: Any]) {
        guard let session, session.activationState == .activated else { return }
        var payload = snapshot
        if let pace = targetPaceSecondsPerMile { payload[Keys.targetPace] = pace }
        payload[Keys.updatedAt] = Date.now.timeIntervalSince1970
        try? session.updateApplicationContext(payload)
    }

    func setTargetPace(_ seconds: Double?) {
        targetPaceSecondsPerMile = seconds
        guard let session, session.activationState == .activated else { return }
        var payload: [String: Any] = [Keys.updatedAt: Date.now.timeIntervalSince1970]
        payload[Keys.targetPace] = seconds ?? 0
        try? session.updateApplicationContext(payload)
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

extension PhoneConnectivityManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate so the link survives a watch switch.
        session.activate()
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        let pace = applicationContext[Keys.targetPace] as? Double
        Task { @MainActor in
            let resolved = (pace ?? 0) > 0 ? pace : nil
            self.targetPaceSecondsPerMile = resolved
            self.onTargetPaceChanged?(resolved)
        }
    }
}
