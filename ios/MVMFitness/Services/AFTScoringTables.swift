import Foundation

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
