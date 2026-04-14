import Foundation

nonisolated enum AFTEventType: String, Codable, CaseIterable, Sendable {
    case mdl
    case hrp
    case sdc
    case plk
    case run2mi
}

nonisolated enum AFTColumn: String, Codable, Sendable {
    case male = "M"
    case combat = "C"
    case female = "F"
}

nonisolated enum AFTDirection: Sendable {
    case higherIsBetter
    case lowerIsBetter
}

nonisolated struct AFTScoreEntry: Codable, Hashable, Sendable {
    let event: AFTEventType
    let ageBand: String
    let column: AFTColumn
    let points: Int
    let rawValue: Int
}

nonisolated struct AFTScoreFile: Codable, Sendable {
    let version: String
    let effectiveDate: String
    let entries: [AFTScoreEntry]
}

nonisolated struct AFTResult: Sendable {
    let eventScores: [AFTEventType: Int]
    let total: Int
    let passedEvents: Bool
    let passedTotal: Bool
    let passedOverall: Bool
    let minimumTotalRequired: Int
}

final class AFTScoringEngine: @unchecked Sendable {

    static let shared: AFTScoringEngine = {
        do {
            return try loadFromBundle()
        } catch {
            return AFTScoringEngine(entries: [])
        }
    }()

    private let allEntries: [AFTScoreEntry]

    init(entries: [AFTScoreEntry]) {
        self.allEntries = entries
    }

    func entries(for event: AFTEventType, ageBand: String, column: AFTColumn) -> [AFTScoreEntry] {
        allEntries.filter { $0.event == event && $0.ageBand == ageBand && $0.column == column }
    }

    static func loadFromBundle(named fileName: String = "aft_scoring_2025_06_01") throws -> AFTScoringEngine {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw NSError(domain: "AFT", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Missing bundled scoring file \(fileName).json"
            ])
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(AFTScoreFile.self, from: data)
        return AFTScoringEngine(entries: decoded.entries)
    }

    static func ageBand(from age: Int) -> String {
        switch age {
        case ..<17: return "17-21"
        case 17...21: return "17-21"
        case 22...26: return "22-26"
        case 27...31: return "27-31"
        case 32...36: return "32-36"
        case 37...41: return "37-41"
        case 42...46: return "42-46"
        case 47...51: return "47-51"
        case 52...56: return "52-56"
        case 57...61: return "57-61"
        default: return "Over 62"
        }
    }

    func scoreColumn(standard: AFTStandard, sex: SoldierSex) -> AFTColumn {
        switch standard {
        case .combat:
            return .combat
        case .general:
            return sex == .male ? .male : .female
        }
    }

    func minimumTotal(for standard: AFTStandard) -> Int {
        standard.minimumTotal
    }

    func direction(for event: AFTEventType) -> AFTDirection {
        switch event {
        case .mdl, .hrp, .plk:
            return .higherIsBetter
        case .sdc, .run2mi:
            return .lowerIsBetter
        }
    }

    func score(
        event: AFTEventType,
        age: Int,
        sex: SoldierSex,
        standard: AFTStandard,
        rawValue: Int
    ) -> Int {
        let band = Self.ageBand(from: age)
        let column = scoreColumn(standard: standard, sex: sex)

        let table = entries(for: event, ageBand: band, column: column)

        guard !table.isEmpty else { return 0 }

        switch direction(for: event) {
        case .higherIsBetter:
            let eligible = table.filter { rawValue >= $0.rawValue }
            return eligible.max(by: { $0.points < $1.points })?.points ?? 0

        case .lowerIsBetter:
            let eligible = table.filter { rawValue <= $0.rawValue }
            return eligible.max(by: { $0.points < $1.points })?.points ?? 0
        }
    }

    func evaluate(
        age: Int,
        sex: SoldierSex,
        standard: AFTStandard,
        mdl: Int,
        hrp: Int,
        sdcSeconds: Int,
        plkSeconds: Int,
        run2miSeconds: Int
    ) -> AFTResult {
        let eventScores: [AFTEventType: Int] = [
            .mdl: score(event: .mdl, age: age, sex: sex, standard: standard, rawValue: mdl),
            .hrp: score(event: .hrp, age: age, sex: sex, standard: standard, rawValue: hrp),
            .sdc: score(event: .sdc, age: age, sex: sex, standard: standard, rawValue: sdcSeconds),
            .plk: score(event: .plk, age: age, sex: sex, standard: standard, rawValue: plkSeconds),
            .run2mi: score(event: .run2mi, age: age, sex: sex, standard: standard, rawValue: run2miSeconds)
        ]

        let total = eventScores.values.reduce(0, +)
        let passedEvents = eventScores.values.allSatisfy { $0 >= 60 }
        let minimum = minimumTotal(for: standard)
        let passedTotal = total >= minimum

        return AFTResult(
            eventScores: eventScores,
            total: total,
            passedEvents: passedEvents,
            passedTotal: passedTotal,
            passedOverall: passedEvents && passedTotal,
            minimumTotalRequired: minimum
        )
    }

    func rawNeeded(
        event: AFTEventType,
        age: Int,
        sex: SoldierSex,
        standard: AFTStandard,
        targetPoints: Int
    ) -> Int? {
        let band = Self.ageBand(from: age)
        let column = scoreColumn(standard: standard, sex: sex)

        let table = entries(for: event, ageBand: band, column: column)
            .filter { $0.points >= targetPoints }

        guard !table.isEmpty else { return nil }

        switch direction(for: event) {
        case .higherIsBetter:
            return table.min(by: { $0.rawValue < $1.rawValue })?.rawValue
        case .lowerIsBetter:
            return table.max(by: { $0.rawValue < $1.rawValue })?.rawValue
        }
    }
}
