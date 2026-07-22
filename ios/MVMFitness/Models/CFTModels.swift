import Foundation
import SwiftUI

/// Combat Field Test (Army Directive 2026-07).
/// 7 events in sequence; cumulative time; pass/fail (GO/NO-GO).
/// The official time standard has NOT yet been published (DCS G-3/5/7 will publish it),
/// so the grader enters GO/NO-GO manually and raw time is stored for future re-evaluation.
nonisolated enum CFTEvent: String, CaseIterable, Codable, Sendable {
    case run1 = "1-Mile Run"
    case pushups = "30 Dead-Stop Push-ups"
    case sprint = "100m Sprint"
    case sandbag = "16× 40-lb Sandbag Lifts (65-in platform)"
    case carry = "50m Water Can Carry (2× 40 lb)"
    case movement = "50m Movement Drill (25m high crawl + 25m rush)"
    case run2 = "Second 1-Mile Run"
}

nonisolated struct CFTRecord: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var date: Date = .now
    var totalSeconds: Int
    var isGo: Bool
    var graderName: String = ""
    var eventSplits: [Int] = [] // informational only — official test has no per-event times

    var formattedTime: String {
        let m = totalSeconds / 60, s = totalSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

@Observable
@MainActor
final class CFTStore {
    var records: [CFTRecord] = []
    private static let storageKey = "cftRecords"

    init() {
        records = LocalStore.load([CFTRecord].self, forKey: Self.storageKey, fallback: [])
    }

    func add(_ record: CFTRecord) {
        records.insert(record, at: 0)
        LocalStore.save(records, forKey: Self.storageKey)
    }

    func delete(_ record: CFTRecord) {
        records.removeAll { $0.id == record.id }
        LocalStore.save(records, forKey: Self.storageKey)
    }
}
