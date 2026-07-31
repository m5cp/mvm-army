import Foundation

/// Which sister-service (or proprietary) fitness test a saved result belongs to.
/// The Army AFT/CFT keep their own dedicated records — these cover the rest.
nonisolated enum ServiceTestBranch: String, Codable, CaseIterable, Identifiable, Sendable {
    case navy = "Navy PRT"
    case airForce = "Air Force PT"
    case marinePFT = "Marine PFT"
    case marineCFT = "Marine CFT"
    case advancedReadiness = "Advanced Readiness"

    var id: String { rawValue }

    /// Short code for chips and compact rows.
    var shortCode: String {
        switch self {
        case .navy: return "PRT"
        case .airForce: return "AF PT"
        case .marinePFT: return "PFT"
        case .marineCFT: return "CFT"
        case .advancedReadiness: return "ADV"
        }
    }

    /// SF Symbol for rows and headers.
    var icon: String {
        switch self {
        case .navy: return "figure.pool.swim"
        case .airForce: return "wind"
        case .marinePFT: return "figure.strengthtraining.functional"
        case .marineCFT: return "figure.run.square.stack"
        case .advancedReadiness: return "bolt.shield"
        }
    }

    /// Card photo (existing bundled imagery — neutral, graded in the UI layer).
    var photoAsset: String {
        switch self {
        case .navy: return "golden-runner-wide"
        case .airForce: return "photo-founders-trail-run"
        case .marinePFT: return "ex-hand-release-pushup"
        case .marineCFT: return "photo-ruck-man-scree"
        case .advancedReadiness: return "photo-ruck-man-coldbreath"
        }
    }
}

/// One event line inside a saved service-test result — display-ready strings
/// so history and share cards never re-run scoring.
nonisolated struct ServiceTestEventDetail: Codable, Hashable, Sendable {
    let code: String    // "PU", "PLK", "1.5MI"
    let raw: String     // "72 REPS", "10:30"
    let points: String  // "88", "PASS"
}

/// A saved sister-service test result. Mirrors how AFTScoreRecord flows into
/// history, progress, and the calendar — one unified shape for all four tests.
nonisolated struct ServiceTestRecord: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let date: Date
    let branch: ServiceTestBranch
    /// Secondary line (e.g. the Advanced Readiness benchmark name).
    let subtitle: String?
    /// Display score, e.g. "87" or "266".
    let scoreDisplay: String
    /// Display denominator, e.g. "/100" or "/300".
    let maxDisplay: String
    /// Numeric score for trends.
    let scoreValue: Double
    /// Result label, e.g. "EXCELLENT \u{00B7} HIGH", "FIRST CLASS", "ELITE".
    let resultLabel: String
    let passed: Bool
    let events: [ServiceTestEventDetail]

    init(
        branch: ServiceTestBranch,
        subtitle: String? = nil,
        scoreDisplay: String,
        maxDisplay: String,
        scoreValue: Double,
        resultLabel: String,
        passed: Bool,
        events: [ServiceTestEventDetail],
        date: Date = .now
    ) {
        self.id = UUID()
        self.date = date
        self.branch = branch
        self.subtitle = subtitle
        self.scoreDisplay = scoreDisplay
        self.maxDisplay = maxDisplay
        self.scoreValue = scoreValue
        self.resultLabel = resultLabel
        self.passed = passed
        self.events = events
    }
}
