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

    func startTracking() {
        routeCoordinates = []
        totalDistanceMeters = 0
        lastLocation = nil
        currentSpeed = 0
        isTracking = true
        manager.startUpdatingLocation()
    }

    func stopTracking() {
        isTracking = false
        manager.stopUpdatingLocation()
    }

    func reset() {
        stopTracking()
        routeCoordinates = []
        totalDistanceMeters = 0
        lastLocation = nil
        currentLocation = nil
        currentSpeed = 0
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
