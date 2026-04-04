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

    var usesGPS: Bool {
        selectedActivity?.usesGPS ?? false
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

        if activity.usesGPS {
            if locationService.isAuthorized {
                locationService.startTracking()
            } else {
                locationService.requestPermission()
            }
        }

        startTimer()
    }

    func togglePause() {
        if isPaused {
            if let ps = pauseStart {
                pauseAccumulated += Date.now.timeIntervalSince(ps)
            }
            pauseStart = nil
            isPaused = false
            if usesGPS { locationService.startTracking() }
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
            averagePaceSecondsPerKm: locationService.averagePaceSecondsPerKm
        )

        isActive = false
        isPaused = false
        showCompletion = true
    }

    func dismiss() {
        showCompletion = false
        completedRecord = nil
        selectedActivity = nil
        locationService.reset()
        elapsedSeconds = 0
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
