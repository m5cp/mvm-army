import Foundation

nonisolated enum SoldierSex: String, CaseIterable, Codable, Identifiable, Sendable {
    case male = "Male"
    case female = "Female"

    var id: String { rawValue }
}

nonisolated enum AFTStandard: String, CaseIterable, Codable, Identifiable, Sendable {
    case combat = "Combat"
    case general = "General"

    var id: String { rawValue }

    var minimumPerEvent: Int {
        switch self {
        case .combat: return 60
        case .general: return 60
        }
    }

    var minimumTotal: Int {
        switch self {
        case .combat: return 350
        case .general: return 300
        }
    }
}

nonisolated struct AFTCalculatorResult: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var date: Date
    var soldierName: String
    var age: Int
    var sex: SoldierSex
    var standard: AFTStandard
    var deadliftLbs: Int
    var pushUpReps: Int
    var sdcSeconds: Int
    var plankSeconds: Int
    var runSeconds: Int
    var deadliftPoints: Int
    var pushUpPoints: Int
    var sdcPoints: Int
    var plankPoints: Int
    var runPoints: Int
    var totalScore: Int
    var passed: Bool
    var weakestEvents: [String]

    init(
        date: Date = .now,
        soldierName: String,
        age: Int,
        sex: SoldierSex,
        standard: AFTStandard,
        deadliftLbs: Int,
        pushUpReps: Int,
        sdcSeconds: Int,
        plankSeconds: Int,
        runSeconds: Int,
        deadliftPoints: Int,
        pushUpPoints: Int,
        sdcPoints: Int,
        plankPoints: Int,
        runPoints: Int,
        totalScore: Int,
        passed: Bool,
        weakestEvents: [String]
    ) {
        self.id = UUID()
        self.date = date
        self.soldierName = soldierName
        self.age = age
        self.sex = sex
        self.standard = standard
        self.deadliftLbs = deadliftLbs
        self.pushUpReps = pushUpReps
        self.sdcSeconds = sdcSeconds
        self.plankSeconds = plankSeconds
        self.runSeconds = runSeconds
        self.deadliftPoints = deadliftPoints
        self.pushUpPoints = pushUpPoints
        self.sdcPoints = sdcPoints
        self.plankPoints = plankPoints
        self.runPoints = runPoints
        self.totalScore = totalScore
        self.passed = passed
        self.weakestEvents = weakestEvents
    }
}
