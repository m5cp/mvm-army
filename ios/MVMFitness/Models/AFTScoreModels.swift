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
}

