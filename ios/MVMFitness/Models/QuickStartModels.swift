import Foundation
import CoreLocation

nonisolated enum QuickStartActivity: String, CaseIterable, Identifiable, Codable, Sendable {
    case outdoorRun = "Outdoor Run"
    case indoorRun = "Indoor Run"
    case functionalFitness = "Functional Fitness"
    case outdoorBike = "Outdoor Bike"
    case indoorBike = "Indoor Bike"
    case outdoorHike = "Outdoor Hike"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .outdoorRun: return "figure.run"
        case .indoorRun: return "figure.run.treadmill"
        case .functionalFitness: return "figure.strengthtraining.functional"
        case .outdoorBike: return "figure.outdoor.cycle"
        case .indoorBike: return "figure.indoor.cycle"
        case .outdoorHike: return "figure.hiking"
        }
    }

    var usesGPS: Bool {
        switch self {
        case .outdoorRun, .outdoorBike, .outdoorHike: return true
        case .indoorRun, .indoorBike, .functionalFitness: return false
        }
    }

    var gradientHex: (String, String) {
        switch self {
        case .outdoorRun: return ("#2563EB", "#1D4ED8")
        case .indoorRun: return ("#7C3AED", "#6D28D9")
        case .functionalFitness: return ("#D97706", "#B45309")
        case .outdoorBike: return ("#059669", "#047857")
        case .indoorBike: return ("#0891B2", "#0E7490")
        case .outdoorHike: return ("#16A34A", "#15803D")
        }
    }
}

nonisolated struct QuickStartRecord: Codable, Identifiable, Sendable {
    let id: UUID
    let activity: QuickStartActivity
    let startDate: Date
    let endDate: Date
    let elapsedSeconds: Int
    let distanceMeters: Double
    let routeCoordinates: [CodableCoordinate]
    let averagePaceSecondsPerKm: Double?

    init(
        activity: QuickStartActivity,
        startDate: Date,
        endDate: Date,
        elapsedSeconds: Int,
        distanceMeters: Double,
        routeCoordinates: [CodableCoordinate] = [],
        averagePaceSecondsPerKm: Double? = nil
    ) {
        self.id = UUID()
        self.activity = activity
        self.startDate = startDate
        self.endDate = endDate
        self.elapsedSeconds = elapsedSeconds
        self.distanceMeters = distanceMeters
        self.routeCoordinates = routeCoordinates
        self.averagePaceSecondsPerKm = averagePaceSecondsPerKm
    }

    var distanceMiles: Double { distanceMeters / 1609.34 }

    var formattedDuration: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    var formattedDistance: String {
        String(format: "%.2f mi", distanceMiles)
    }

    var formattedPace: String {
        guard let pace = averagePaceSecondsPerKm, pace > 0, pace.isFinite else { return "--:--" }
        let pacePerMile = pace * 1.60934
        let mins = Int(pacePerMile) / 60
        let secs = Int(pacePerMile) % 60
        return String(format: "%d:%02d /mi", mins, secs)
    }
}

nonisolated struct CodableCoordinate: Codable, Sendable {
    let latitude: Double
    let longitude: Double

    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
