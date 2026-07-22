import Foundation
import SwiftUI

/// Army Body Composition Program (Army Directive 2026-06, effective July 7, 2026).
/// Standard: WHtR (waist at navel in inches ÷ height in inches) must be LESS THAN 0.55.
/// Exactly 0.55 or higher does NOT meet the standard.
/// Exemption: AFT total score of 465+ exempts a Soldier from body composition standards
/// (Army Directive 2025-17).
nonisolated struct WHtRRecord: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var date: Date = .now
    var waistInches: Double
    var heightInches: Double

    var ratio: Double {
        guard heightInches > 0 else { return 0 }
        return waistInches / heightInches
    }

    var meetsStandard: Bool { ratio < 0.55 }

    var displayRatio: String { String(format: "%.2f", ratio) }
}

@Observable
@MainActor
final class ABCPStore {
    var records: [WHtRRecord] = []

    private static let storageKey = "whtrRecords"

    init() {
        records = DataStore.load([WHtRRecord].self, forKey: Self.storageKey, fallback: [])
    }

    func add(waistInches: Double, heightInches: Double) {
        let record = WHtRRecord(waistInches: waistInches, heightInches: heightInches)
        records.insert(record, at: 0)
        DataStore.save(records, forKey: Self.storageKey)
    }

    func delete(_ record: WHtRRecord) {
        records.removeAll { $0.id == record.id }
        DataStore.save(records, forKey: Self.storageKey)
    }

    var latest: WHtRRecord? { records.first }
}
