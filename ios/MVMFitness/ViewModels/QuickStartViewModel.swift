import Foundation
import CoreLocation

@Observable
final class QuickStartViewModel {
    var selectedActivity: QuickStartActivity?
    var isActive: Bool = false
    var isPaused: Bool = false
    var elapsedSeconds: Int = 0
    var showCompletion: Bool = false
    var completedRecord: QuickStartRecord?

    // MARK: Ghost race — race the pace curve of a previous session
    var ghostEnabled: Bool = false
    var ghostRecord: QuickStartRecord?
    /// Cumulative (secondsFromStart, metersCovered) curve built from the ghost
    /// record at session start. Empty when racing on average pace only.
    private var ghostCurve: [(t: Double, d: Double)] = []
    private var ghostAveragePaceSecondsPerMeter: Double?

    let locationService = LocationTrackingService()

    private var timer: Timer?
    private var startDate: Date = .now
    private var pauseAccumulated: TimeInterval = 0
    private var pauseStart: Date?

    var formattedTime: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    var distanceMiles: Double {
        locationService.totalDistanceMeters / 1609.34
    }

    var formattedDistance: String {
        String(format: "%.2f mi", distanceMiles)
    }

    /// Live average pace in seconds per mile, or nil before enough distance to
    /// be meaningful. Used by the target-pace control and mirrored to the watch.
    var currentPaceSecondsPerMile: Double? {
        guard locationService.totalDistanceMeters > 50, elapsedSeconds > 0 else { return nil }
        let miles = distanceMiles
        guard miles > 0.01 else { return nil }
        return Double(elapsedSeconds) / miles
    }

    var formattedPace: String {
        guard locationService.totalDistanceMeters > 50, elapsedSeconds > 0 else { return "--:-- /mi" }
        let miles = distanceMiles
        guard miles > 0.01 else { return "--:-- /mi" }
        let paceSeconds = Double(elapsedSeconds) / miles
        let mins = Int(paceSeconds) / 60
        let secs = Int(paceSeconds) % 60
        return String(format: "%d:%02d /mi", mins, secs)
    }

    var currentSpeedMph: Double {
        locationService.currentSpeed * 2.23694
    }

    var formattedSpeed: String {
        String(format: "%.1f mph", currentSpeedMph)
    }

    /// Observes the OPSEC switch so a live session stops recording the moment
    /// GPS is turned off, rather than only hiding the map.
    private var opsecObserver: NSObjectProtocol?

    func observeOPSEC() {
        guard opsecObserver == nil else { return }
        opsecObserver = NotificationCenter.default.addObserver(
            forName: .opsecGPSDisabled, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.locationService.stopTracking()
                self.locationService.reset()
                self.ghostEnabled = false
            }
        }
    }

    var usesGPS: Bool {
        guard !OPSECService.isGPSDisabled else { return false }
        return selectedActivity?.usesGPS ?? false
    }

    func selectActivity(_ activity: QuickStartActivity) {
        selectedActivity = activity
    }

    func startSession() {
        guard let activity = selectedActivity else { return }
        isActive = true
        isPaused = false
        showCompletion = false
        completedRecord = nil
        elapsedSeconds = 0
        pauseAccumulated = 0
        startDate = .now

        // OPSEC mode records no route and never asks for location. The session
        // still times and still counts; only the map goes away.
        if activity.usesGPS, !OPSECService.isGPSDisabled {
            if locationService.isAuthorized {
                locationService.startTracking()
            } else {
                // requestPermission is async from the user's point of view; arm
                // the callback so the session records once they tap Allow.
                locationService.startTrackingWhenAuthorized = true
                locationService.requestPermission()
            }
        }

        buildGhostCurve()
        startTimer()
    }

    // MARK: - Ghost race

    private func buildGhostCurve() {
        ghostCurve = []
        ghostAveragePaceSecondsPerMeter = nil
        guard ghostEnabled, let ghost = ghostRecord else { return }

        // Preferred: the real distance-over-time curve from the previous run.
        if let offsets = ghost.routeTimeOffsets,
           offsets.count == ghost.routeCoordinates.count,
           ghost.routeCoordinates.count > 1 {
            var cumulative: Double = 0
            var curve: [(Double, Double)] = [(0, 0)]
            for i in 1..<ghost.routeCoordinates.count {
                let a = ghost.routeCoordinates[i - 1].clCoordinate
                let b = ghost.routeCoordinates[i].clCoordinate
                let delta = CLLocation(latitude: a.latitude, longitude: a.longitude)
                    .distance(from: CLLocation(latitude: b.latitude, longitude: b.longitude))
                if delta > 0, delta < 200 { cumulative += delta }
                curve.append((offsets[i], cumulative))
            }
            if cumulative > 100 {
                ghostCurve = curve
                return
            }
        }

        // Fallback: constant average pace from the previous session.
        if ghost.distanceMeters > 100, ghost.elapsedSeconds > 0 {
            ghostAveragePaceSecondsPerMeter = Double(ghost.elapsedSeconds) / ghost.distanceMeters
        }
    }

    /// Where the ghost is right now, in meters from the start.
    var ghostDistanceMeters: Double {
        let t = Double(elapsedSeconds)
        if !ghostCurve.isEmpty {
            // Interpolate on the recorded curve; past the end, the ghost is finished.
            guard let last = ghostCurve.last else { return 0 }
            if t >= last.t { return last.d }
            var previous = ghostCurve[0]
            for point in ghostCurve {
                if point.t >= t {
                    let span = point.t - previous.t
                    guard span > 0 else { return point.d }
                    let fraction = (t - previous.t) / span
                    return previous.d + fraction * (point.d - previous.d)
                }
                previous = point
            }
            return last.d
        }
        if let pace = ghostAveragePaceSecondsPerMeter, pace > 0 {
            return t / pace
        }
        return 0
    }

    var ghostActive: Bool {
        ghostEnabled && ghostRecord != nil && usesGPS
    }

    /// Positive = you're ahead of the ghost (meters).
    var ghostDeltaMeters: Double {
        locationService.totalDistanceMeters - ghostDistanceMeters
    }

    /// The gap expressed in seconds at the ghost's pace. Positive = ahead.
    var ghostDeltaSeconds: Double {
        let pace: Double
        if let avg = ghostAveragePaceSecondsPerMeter {
            pace = avg
        } else if let ghost = ghostRecord, ghost.distanceMeters > 0 {
            pace = Double(ghost.elapsedSeconds) / ghost.distanceMeters
        } else {
            return 0
        }
        return ghostDeltaMeters * pace
    }

    /// 0…1 progress of you and the ghost along the ghost's total distance,
    /// for the visual pacer track.
    var ghostProgress: (you: Double, ghost: Double) {
        guard let ghost = ghostRecord, ghost.distanceMeters > 0 else { return (0, 0) }
        let total = ghost.distanceMeters
        return (
            min(locationService.totalDistanceMeters / total, 1),
            min(ghostDistanceMeters / total, 1)
        )
    }

    func togglePause() {
        if isPaused {
            if let ps = pauseStart {
                pauseAccumulated += Date.now.timeIntervalSince(ps)
            }
            pauseStart = nil
            isPaused = false
            // resumeTracking, NOT startTracking — start would wipe the route
            // recorded before the pause.
            if usesGPS { locationService.resumeTracking() }
            startTimer()
        } else {
            isPaused = true
            pauseStart = .now
            timer?.invalidate()
            timer = nil
            if usesGPS { locationService.stopTracking() }
        }
    }

    func endSession() {
        timer?.invalidate()
        timer = nil
        locationService.startTrackingWhenAuthorized = false
        locationService.stopTracking()

        guard let activity = selectedActivity else { return }

        let coords = locationService.routeCoordinates.map { CodableCoordinate($0) }

        completedRecord = QuickStartRecord(
            activity: activity,
            startDate: startDate,
            endDate: .now,
            elapsedSeconds: elapsedSeconds,
            distanceMeters: locationService.totalDistanceMeters,
            routeCoordinates: coords,
            averagePaceSecondsPerKm: locationService.averagePaceSecondsPerKm,
            routeTimeOffsets: coords.isEmpty ? nil : locationService.routeTimeOffsets
        )

        isActive = false
        isPaused = false
        showCompletion = true
        AnalyticsService.track(.quickStartCompleted)
    }

    func dismiss() {
        locationService.startTrackingWhenAuthorized = false
        showCompletion = false
        completedRecord = nil
        selectedActivity = nil
        locationService.reset()
        elapsedSeconds = 0
        ghostEnabled = false
        ghostRecord = nil
        ghostCurve = []
        ghostAveragePaceSecondsPerMeter = nil
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, !self.isPaused else { return }
                self.elapsedSeconds += 1
            }
        }
    }
}
