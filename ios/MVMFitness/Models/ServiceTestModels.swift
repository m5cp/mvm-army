import Foundation

/// Which sister-service (or proprietary) fitness test a saved result belongs to.
/// The Army AFT/CFT keep their own dedicated records — these cover the rest.
nonisolated enum ServiceTestBranch: String, Codable, CaseIterable, Identifiable, Sendable {
    case navy = "Navy PRT"
    case airForce = "Air Force PT"
    case marinePFT = "Marine PFT"
    case marineCFT = "Marine CFT"
    case advancedReadiness = "Advanced Readiness"
    case applicant = "ROTC & Academy"

    var id: String { rawValue }

    /// Full name used on the unofficial score sheet.
    var displayName: String { rawValue }

    /// Where the OFFICIAL record for this assessment actually lives. Printed on
    /// every exported score sheet so nobody mistakes the app's output for one.
    var authorityNote: String {
        switch self {
        case .navy:
            return "Official Navy PRT results are recorded by your Command Fitness Leader in PRIMS. This sheet is not a PRIMS entry."
        case .airForce:
            return "Official Air Force PT results are recorded by a certified PTL and live in myFSS. This sheet is not an official AF Form 4446."
        case .marinePFT, .marineCFT:
            return "Official Marine Corps PFT/CFT results are recorded in MCTFS by an authorised monitor. This sheet is not an MCTFS entry."
        case .advancedReadiness:
            return "Advanced Readiness benchmarks are this app's own proprietary standards. They are NOT official military selection criteria and no unit, school or selection board recognises them."
        case .applicant:
            return "ROTC and Service Academy fitness standards are set by each program and scored by an authorised administrator. These are practice values only and cannot be submitted to any admissions or scholarship board."
        }
    }

    /// Short code for chips and compact rows.
    var shortCode: String {
        switch self {
        case .navy: return "PRT"
        case .airForce: return "AF PT"
        case .marinePFT: return "PFT"
        case .marineCFT: return "CFT"
        case .advancedReadiness: return "ADV"
        case .applicant: return "ROTC"
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
        case .applicant: return "graduationcap.fill"
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
        case .applicant: return "photo-run-silhouette-sunrise"
        }
    }
}

/// The user's service branch (or Fitness Athlete), chosen at onboarding and
/// changeable any time in Profile. Only sets DEFAULTS (which calculator opens
/// first) — every test stays available to everyone, and no stored data or
/// syncing depends on this value.
nonisolated enum UserServiceBranch: String, Codable, CaseIterable, Identifiable, Sendable {
    case army = "Army"
    case navy = "Navy"
    case airForce = "Air Force"
    case marines = "Marines"
    case athlete = "Fitness Athlete"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .army: return "shield.lefthalf.filled"
        case .navy: return "figure.pool.swim"
        case .airForce: return "wind"
        case .marines: return "figure.strengthtraining.functional"
        case .athlete: return "bolt.heart.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .army: return "AFT calculator first"
        case .navy: return "Navy PRT calculator first"
        case .airForce: return "Air Force PT calculator first"
        case .marines: return "Marine PFT/CFT calculator first"
        case .athlete: return "AFT calculator first"
        }
    }

    /// Raw value of the `FitnessTestKind` the calculator should open with.
    var defaultTestRawValue: String {
        switch self {
        case .army, .athlete: return "AFT"
        case .navy: return "NAVY"
        case .airForce: return "AIR FORCE"
        case .marines: return "MARINES"
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
