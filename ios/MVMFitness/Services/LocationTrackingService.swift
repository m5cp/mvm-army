import Foundation
import CoreLocation
import MapKit

@Observable
final class LocationTrackingService: NSObject, CLLocationManagerDelegate {
    var currentLocation: CLLocation?
    var routeCoordinates: [CLLocationCoordinate2D] = []
    var totalDistanceMeters: Double = 0
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isTracking: Bool = false
    var currentSpeed: Double = 0

    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.distanceFilter = 5
        manager.allowsBackgroundLocationUpdates = false
        authorizationStatus = manager.authorizationStatus
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// Pause bookkeeping so time offsets reflect MOVING time, matching the
    /// session's elapsedSeconds (which also excludes pauses).
    private var pausedTotal: TimeInterval = 0
    private var pauseBegan: Date?
    /// Pause-adjusted seconds-from-start, appended in lockstep with
    /// `routeCoordinates`. Powers mile splits and ghost racing.
    private(set) var recordedOffsets: [Double] = []
    private var firstFixDate: Date?

    func startTracking() {
        routeCoordinates = []
        locationTimestamps = []
        recordedOffsets = []
        firstFixDate = nil
        pausedTotal = 0
        pauseBegan = nil
        totalDistanceMeters = 0
        lastLocation = nil
        currentSpeed = 0
        isTracking = true
        manager.startUpdatingLocation()
    }

    /// Continues an existing session after a pause WITHOUT wiping the route
    /// already recorded (startTracking resets everything).
    func resumeTracking() {
        if let began = pauseBegan {
            pausedTotal += Date.now.timeIntervalSince(began)
            pauseBegan = nil
        }
        isTracking = true
        manager.startUpdatingLocation()
    }

    func stopTracking() {
        if isTracking, pauseBegan == nil {
            pauseBegan = .now
        }
        isTracking = false
        manager.stopUpdatingLocation()
    }

    func reset() {
        stopTracking()
        routeCoordinates = []
        locationTimestamps = []
        recordedOffsets = []
        firstFixDate = nil
        pausedTotal = 0
        pauseBegan = nil
        totalDistanceMeters = 0
        lastLocation = nil
        currentLocation = nil
        currentSpeed = 0
    }

    /// Seconds-from-start (moving time) for each recorded coordinate, aligned
    /// with `routeCoordinates`.
    var routeTimeOffsets: [Double] {
        recordedOffsets
    }

    var averagePaceSecondsPerKm: Double? {
        guard totalDistanceMeters > 50 else { return nil }
        let km = totalDistanceMeters / 1000
        guard let first = routeCoordinates.first, let firstLoc = findTimestamp(for: first) else { return nil }
        let elapsed = Date.now.timeIntervalSince(firstLoc)
        guard elapsed > 0, km > 0 else { return nil }
        return elapsed / km
    }

    private var locationTimestamps: [Date] = []

    private func findTimestamp(for coord: CLLocationCoordinate2D) -> Date? {
        locationTimestamps.first
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            for location in locations {
                guard location.horizontalAccuracy >= 0, location.horizontalAccuracy < 30 else { continue }

                currentLocation = location
                currentSpeed = max(location.speed, 0)

                if isTracking {
                    routeCoordinates.append(location.coordinate)
                    locationTimestamps.append(location.timestamp)
                    if firstFixDate == nil { firstFixDate = location.timestamp }
                    if let first = firstFixDate {
                        recordedOffsets.append(max(0, location.timestamp.timeIntervalSince(first) - pausedTotal))
                    }

                    if let last = lastLocation {
                        let delta = location.distance(from: last)
                        if delta > 1 && delta < 100 {
                            totalDistanceMeters += delta
                        }
                    }
                    lastLocation = location
                }
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
