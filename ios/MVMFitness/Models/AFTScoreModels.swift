import Foundation

nonisolated struct AFTEvent: Sendable {
    let name: String
    let abbreviation: String
    let unit: String
    let icon: String
}

nonisolated enum AFTEvents: Sendable {
    static let deadlift = AFTEvent(name: "3-Rep Max Deadlift", abbreviation: "MDL", unit: "lbs", icon: "figure.strengthtraining.traditional")
    static let handReleasePushUp = AFTEvent(name: "Hand-Release Push-Up", abbreviation: "HRP", unit: "reps", icon: "figure.core.training")
    static let sprintDragCarry = AFTEvent(name: "Sprint-Drag-Carry", abbreviation: "SDC", unit: "sec", icon: "figure.run")
    static let plank = AFTEvent(name: "Plank", abbreviation: "PLK", unit: "sec", icon: "figure.pilates")
    static let twoMileRun = AFTEvent(name: "2-Mile Run", abbreviation: "2MR", unit: "sec", icon: "figure.outdoor.cycle")

    static let all: [AFTEvent] = [deadlift, handReleasePushUp, sprintDragCarry, plank, twoMileRun]
}

nonisolated struct AFTScoreRecord: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var date: Date
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
    var weakestEvents: [String]

    init(
        date: Date = .now,
        age: Int = 0,
        sex: SoldierSex = .male,
        standard: AFTStandard = .general,
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
        weakestEvents: [String]
    ) {
        self.id = UUID()
        self.date = date
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
        self.weakestEvents = weakestEvents
    }

    enum CodingKeys: String, CodingKey {
        case id, date, age, sex, standard
        case deadliftLbs, pushUpReps, sdcSeconds, plankSeconds, runSeconds
        case deadliftPoints, pushUpPoints, sdcPoints, plankPoints, runPoints
        case totalScore, weakestEvents
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id             = try c.decode(UUID.self,  forKey: .id)
        date           = try c.decode(Date.self,  forKey: .date)
        age            = try c.decodeIfPresent(Int.self,           forKey: .age)      ?? 0
        sex            = try c.decodeIfPresent(SoldierSex.self,    forKey: .sex)      ?? .male
        standard       = try c.decodeIfPresent(AFTStandard.self,   forKey: .standard) ?? .general
        deadliftLbs    = try c.decode(Int.self, forKey: .deadliftLbs)
        pushUpReps     = try c.decode(Int.self, forKey: .pushUpReps)
        sdcSeconds     = try c.decode(Int.self, forKey: .sdcSeconds)
        plankSeconds   = try c.decode(Int.self, forKey: .plankSeconds)
        runSeconds     = try c.decode(Int.self, forKey: .runSeconds)
        deadliftPoints = try c.decode(Int.self, forKey: .deadliftPoints)
        pushUpPoints   = try c.decode(Int.self, forKey: .pushUpPoints)
        sdcPoints      = try c.decode(Int.self, forKey: .sdcPoints)
        plankPoints    = try c.decode(Int.self, forKey: .plankPoints)
        runPoints      = try c.decode(Int.self, forKey: .runPoints)
        totalScore     = try c.decode(Int.self, forKey: .totalScore)
        weakestEvents  = try c.decode([String].self, forKey: .weakestEvents)
    }
}
