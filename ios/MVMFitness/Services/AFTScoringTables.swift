import Foundation

nonisolated enum AFTAgeGroup: String, CaseIterable, Sendable {
    case age17to21 = "17-21"
    case age22to26 = "22-26"
    case age27to31 = "27-31"
    case age32to36 = "32-36"
    case age37to41 = "37-41"
    case age42to46 = "42-46"
    case age47to51 = "47-51"
    case age52to56 = "52-56"
    case age57to61 = "57-61"
    case age62plus = "62+"

    static func from(age: Int) -> AFTAgeGroup {
        switch age {
        case ..<17: return .age17to21
        case 17...21: return .age17to21
        case 22...26: return .age22to26
        case 27...31: return .age27to31
        case 32...36: return .age32to36
        case 37...41: return .age37to41
        case 42...46: return .age42to46
        case 47...51: return .age47to51
        case 52...56: return .age52to56
        case 57...61: return .age57to61
        default: return .age62plus
        }
    }
}

nonisolated struct AFTEventBounds: Sendable {
    let max100: Double
    let min60: Double
}

nonisolated enum AFTScoringTables: Sendable {

    private static let engine = AFTScoringEngine.shared

    static func scoreDeadlift(lbs: Int, age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> Int {
        engine.score(event: .mdl, age: age, sex: sex, standard: standard, rawValue: lbs)
    }

    static func scorePushUp(reps: Int, age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> Int {
        engine.score(event: .hrp, age: age, sex: sex, standard: standard, rawValue: reps)
    }

    static func scoreSDC(seconds: Int, age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> Int {
        engine.score(event: .sdc, age: age, sex: sex, standard: standard, rawValue: seconds)
    }

    static func scorePlank(seconds: Int, age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> Int {
        engine.score(event: .plk, age: age, sex: sex, standard: standard, rawValue: seconds)
    }

    static func scoreRun(seconds: Int, age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> Int {
        engine.score(event: .run2mi, age: age, sex: sex, standard: standard, rawValue: seconds)
    }

    static func deadliftNeeded(points: Int, age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> Int {
        engine.rawNeeded(event: .mdl, age: age, sex: sex, standard: standard, targetPoints: points) ?? 0
    }

    static func pushUpNeeded(points: Int, age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> Int {
        engine.rawNeeded(event: .hrp, age: age, sex: sex, standard: standard, targetPoints: points) ?? 0
    }

    static func sdcNeeded(points: Int, age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> Int {
        engine.rawNeeded(event: .sdc, age: age, sex: sex, standard: standard, targetPoints: points) ?? 0
    }

    static func plankNeeded(points: Int, age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> Int {
        engine.rawNeeded(event: .plk, age: age, sex: sex, standard: standard, targetPoints: points) ?? 0
    }

    static func runNeeded(points: Int, age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> Int {
        engine.rawNeeded(event: .run2mi, age: age, sex: sex, standard: standard, targetPoints: points) ?? 0
    }

    static func deadliftBounds(age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> AFTEventBounds {
        bounds(event: .mdl, age: age, sex: sex, standard: standard)
    }

    static func pushUpBounds(age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> AFTEventBounds {
        bounds(event: .hrp, age: age, sex: sex, standard: standard)
    }

    static func sdcBounds(age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> AFTEventBounds {
        bounds(event: .sdc, age: age, sex: sex, standard: standard)
    }

    static func plankBounds(age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> AFTEventBounds {
        bounds(event: .plk, age: age, sex: sex, standard: standard)
    }

    static func runBounds(age: Int, sex: SoldierSex, standard: AFTStandard = .general) -> AFTEventBounds {
        bounds(event: .run2mi, age: age, sex: sex, standard: standard)
    }

    private static func bounds(event: AFTEventType, age: Int, sex: SoldierSex, standard: AFTStandard) -> AFTEventBounds {
        let band = AFTScoringEngine.ageBand(from: age)
        let column = engine.scoreColumn(standard: standard, sex: sex)
        let table = engine.entries(for: event, ageBand: band, column: column)

        guard !table.isEmpty else {
            return AFTEventBounds(max100: 0, min60: 0)
        }

        let sorted = table.sorted { $0.points > $1.points }
        let max100Raw = sorted.first?.rawValue ?? 0
        let min60Raw = sorted.last?.rawValue ?? 0

        return AFTEventBounds(max100: Double(max100Raw), min60: Double(min60Raw))
    }
}
