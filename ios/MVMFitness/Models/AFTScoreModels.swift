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

enum AFTScoreCalculator {
    static func calculateDeadliftPoints(_ lbs: Int) -> Int {
        guard lbs >= 140 else { return 0 }
        guard lbs < 340 else { return 100 }
        return Int((Double(lbs - 140) / 200.0 * 100).rounded())
    }

    static func calculatePushUpPoints(_ reps: Int) -> Int {
        guard reps >= 10 else { return 0 }
        guard reps < 60 else { return 100 }
        return Int((Double(reps - 10) / 50.0 * 100).rounded())
    }

    static func calculateSDCPoints(_ seconds: Int) -> Int {
        guard seconds <= 210 else { return 0 }
        guard seconds > 93 else { return 100 }
        return Int((Double(210 - seconds) / 117.0 * 100).rounded())
    }

    static func calculatePlankPoints(_ seconds: Int) -> Int {
        guard seconds >= 60 else { return 0 }
        guard seconds < 240 else { return 100 }
        return Int((Double(seconds - 60) / 180.0 * 100).rounded())
    }

    static func calculateRunPoints(_ seconds: Int) -> Int {
        guard seconds <= 1320 else { return 0 }
        guard seconds > 810 else { return 100 }
        return Int((Double(1320 - seconds) / 510.0 * 100).rounded())
    }

    static func calculate(
        deadliftLbs: Int,
        pushUpReps: Int,
        sdcSeconds: Int,
        plankSeconds: Int,
        runSeconds: Int
    ) -> AFTScoreRecord {
        let dlPts = calculateDeadliftPoints(deadliftLbs)
        let puPts = calculatePushUpPoints(pushUpReps)
        let sdcPts = calculateSDCPoints(sdcSeconds)
        let plkPts = calculatePlankPoints(plankSeconds)
        let runPts = calculateRunPoints(runSeconds)

        let total = dlPts + puPts + sdcPts + plkPts + runPts

        let pairs: [(String, Int)] = [
            ("MDL", dlPts),
            ("HRP", puPts),
            ("SDC", sdcPts),
            ("PLK", plkPts),
            ("2MR", runPts)
        ]
        let weakest = pairs.sorted { $0.1 < $1.1 }.prefix(2).map(\.0)

        return AFTScoreRecord(
            deadliftLbs: deadliftLbs,
            pushUpReps: pushUpReps,
            sdcSeconds: sdcSeconds,
            plankSeconds: plankSeconds,
            runSeconds: runSeconds,
            deadliftPoints: dlPts,
            pushUpPoints: puPts,
            sdcPoints: sdcPts,
            plankPoints: plkPts,
            runPoints: runPts,
            totalScore: total,
            weakestEvents: weakest
        )
    }

    static func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
