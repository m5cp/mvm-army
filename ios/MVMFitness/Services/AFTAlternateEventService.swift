import Foundation

/// Alternate aerobic events (Walk / Bike / Swim / Row) for soldiers on
/// permanent profiles — HQDA AFT Score Tables, Go/No-Go only. These are
/// scored as a straight pass/fail against a max time per age band + column;
/// a GO credits a flat 60 points toward the aerobic event slot in the total.
///
/// Mirrors the loading/error pattern of `AFTScoringEngine` exactly, including
/// graceful degradation if the bundled file fails to load.
nonisolated enum AFTAlternateEvent: String, Codable, CaseIterable, Sendable {
    case walk
    case bike
    case swim
    case row

    /// Short spec-sheet chip label — matches the "AERO EVENT" selector style.
    var displayCode: String {
        switch self {
        case .walk: return "WALK"
        case .bike: return "BIKE"
        case .swim: return "SWIM"
        case .row: return "ROW"
        }
    }

    /// Full spoken/display name for VoiceOver and headers.
    var fullName: String {
        switch self {
        case .walk: return "2.5-Mile Walk"
        case .bike: return "12km Bike"
        case .swim: return "1km Swim"
        case .row: return "5km Row"
        }
    }
}

nonisolated struct AFTAlternateEventEntry: Codable, Hashable, Sendable {
    let event: AFTAlternateEvent
    let ageBand: String
    let column: AFTColumn
    let maxTimeSeconds: Int
}

nonisolated struct AFTAlternateEventFile: Codable, Sendable {
    let version: String
    let effectiveDate: String
    let source: String
    let distances: [String: String]
    let entries: [AFTAlternateEventEntry]
}

final class AFTAlternateEventService: @unchecked Sendable {

    static let shared: AFTAlternateEventService = {
        do {
            let service = try loadFromBundle()
            if service.allEntries.isEmpty {
                return AFTAlternateEventService(entries: [], distances: [:], loadError: "Alternate event data loaded but contains no entries.")
            }
            return service
        } catch {
            return AFTAlternateEventService(entries: [], distances: [:], loadError: "Failed to load alternate event data: \(error.localizedDescription)")
        }
    }()

    private let allEntries: [AFTAlternateEventEntry]
    private let bundledDistances: [String: String]

    /// Non-nil if the bundled alternate-event table failed to load. When set,
    /// `maxTime` returns nil and `isGo` always returns false (fail-safe).
    let loadError: String?

    var isOperational: Bool { loadError == nil }

    init(entries: [AFTAlternateEventEntry], distances: [String: String], loadError: String? = nil) {
        self.allEntries = entries
        self.bundledDistances = distances
        self.loadError = loadError
    }

    static func loadFromBundle(named fileName: String = "aft_alternate_events_2025_06_01") throws -> AFTAlternateEventService {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw NSError(domain: "AFTAlternate", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Missing bundled alternate events file \(fileName).json"
            ])
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(AFTAlternateEventFile.self, from: data)
        return AFTAlternateEventService(entries: decoded.entries, distances: decoded.distances)
    }

    /// Bundled distance label for an event, e.g. "2.5 mi".
    func distance(for event: AFTAlternateEvent) -> String {
        bundledDistances[event.rawValue] ?? ""
    }

    func entry(event: AFTAlternateEvent, ageBand: String, column: AFTColumn) -> AFTAlternateEventEntry? {
        allEntries.first { $0.event == event && $0.ageBand == ageBand && $0.column == column }
    }

    /// Max qualifying time in seconds for the given event/age/sex/standard, or
    /// nil if the data is unavailable. Uses the same age-band mapping and
    /// column logic (male/combat share M|C, female uses F) as `AFTScoringEngine`.
    func maxTime(event: AFTAlternateEvent, age: Int, sex: SoldierSex, standard: AFTStandard) -> Int? {
        let band = AFTScoringEngine.ageBand(from: age)
        let column = AFTScoringEngine.shared.scoreColumn(standard: standard, sex: sex)
        return entry(event: event, ageBand: band, column: column)?.maxTimeSeconds
    }

    /// GO if the recorded time is at or under the max qualifying time; NO-GO
    /// otherwise, including whenever the data failed to load.
    func isGo(event: AFTAlternateEvent, age: Int, sex: SoldierSex, standard: AFTStandard, timeSeconds: Int) -> Bool {
        guard let max = maxTime(event: event, age: age, sex: sex, standard: standard) else { return false }
        return timeSeconds <= max
    }
}
