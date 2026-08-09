import Foundation

// MARK: - Marine Corps PFT / CFT Scoring
//
// Source basis:
// Official Marine Corps PFT/CFT scoring tables published by the
// Human Performance Branch at fitness.marines.mil.
//
// Design:
// - Supports age, sex, event selection, and altitude where applicable.
// - Uses the published maximum and minimum performance endpoints.
// - Scores between endpoints with the same proportional 40–100 point model
//   represented in the official tables, rounded to the nearest whole point.
// - Performance at or better than the maximum receives 100.
// - Performance below the minimum receives 0 and fails that event.
// - The PFT push-up option is capped at 70 points.
// - Pull-ups, plank, run/row, and each CFT event are capped at 100 points.
//
// This file is a scoring implementation and is not an official Marine Corps product.

public enum MarineSex: String, Codable, CaseIterable, Sendable {
    case male
    case female
}

public enum MarineAgeBand: String, Codable, CaseIterable, Sendable {
    case age17To20 = "17-20"
    case age21To25 = "21-25"
    case age26To30 = "26-30"
    case age31To35 = "31-35"
    case age36To40 = "36-40"
    case age41To45 = "41-45"
    case age46To50 = "46-50"
    case age51Plus = "51+"

    public init?(age: Int) {
        guard age >= 17 else { return nil }

        switch age {
        case 17...20: self = .age17To20
        case 21...25: self = .age21To25
        case 26...30: self = .age26To30
        case 31...35: self = .age31To35
        case 36...40: self = .age36To40
        case 41...45: self = .age41To45
        case 46...50: self = .age46To50
        default: self = .age51Plus
        }
    }
}

public enum MarineAltitude: String, Codable, CaseIterable, Sendable {
    case standard
    case atOrAbove4500Feet
}

public enum MarineTestType: String, Codable, CaseIterable, Sendable {
    case pft
    case cft
}

public struct MarineTime: Codable, Hashable, Sendable {
    public let seconds: Int

    public init(seconds: Int) {
        self.seconds = max(0, seconds)
    }

    public init(minutes: Int, seconds: Int) {
        self.seconds = max(0, minutes * 60 + seconds)
    }

    public var formatted: String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

public struct MarineEventScore: Codable, Hashable, Sendable {
    public let points: Int
    public let passed: Bool
    public let maximumPoints: Int
    public let rawValue: Double
    public let eventName: String

    public init(
        points: Int,
        passed: Bool,
        maximumPoints: Int,
        rawValue: Double,
        eventName: String
    ) {
        self.points = points
        self.passed = passed
        self.maximumPoints = maximumPoints
        self.rawValue = rawValue
        self.eventName = eventName
    }
}

public enum MarineTestClassification: String, Codable, Sendable {
    case firstClass = "First Class"
    case secondClass = "Second Class"
    case thirdClass = "Third Class"
    case failed = "Failed"
}

public struct MarineTestResult: Codable, Hashable, Sendable {
    public let testType: MarineTestType
    public let eventScores: [MarineEventScore]
    public let totalPoints: Int
    public let classification: MarineTestClassification
    public let passed: Bool

    public init(testType: MarineTestType, eventScores: [MarineEventScore]) {
        let total = eventScores.reduce(0) { $0 + $1.points }
        let allEventsPassed = eventScores.count == 3 && eventScores.allSatisfy(\.passed)

        let classification: MarineTestClassification
        if !allEventsPassed || total < 150 {
            classification = .failed
        } else if total >= 235 {
            classification = .firstClass
        } else if total >= 200 {
            classification = .secondClass
        } else {
            classification = .thirdClass
        }

        self.testType = testType
        self.eventScores = eventScores
        self.totalPoints = total
        self.classification = classification
        self.passed = classification != .failed
    }
}

// MARK: - PFT Models

public enum MarinePFTUpperBodyEvent: String, Codable, CaseIterable, Sendable {
    case pullUps
    case pushUps
}

public enum MarinePFTCardioEvent: String, Codable, CaseIterable, Sendable {
    case threeMileRun
    case fiveThousandMeterRow
}

public struct MarinePFTInput: Codable, Hashable, Sendable {
    public let age: Int
    public let sex: MarineSex
    public let altitude: MarineAltitude
    public let upperBodyEvent: MarinePFTUpperBodyEvent
    public let upperBodyRepetitions: Int
    public let plankTime: MarineTime
    public let cardioEvent: MarinePFTCardioEvent
    public let cardioTime: MarineTime

    public init(
        age: Int,
        sex: MarineSex,
        altitude: MarineAltitude = .standard,
        upperBodyEvent: MarinePFTUpperBodyEvent,
        upperBodyRepetitions: Int,
        plankTime: MarineTime,
        cardioEvent: MarinePFTCardioEvent,
        cardioTime: MarineTime
    ) {
        self.age = age
        self.sex = sex
        self.altitude = altitude
        self.upperBodyEvent = upperBodyEvent
        self.upperBodyRepetitions = upperBodyRepetitions
        self.plankTime = plankTime
        self.cardioEvent = cardioEvent
        self.cardioTime = cardioTime
    }
}

// MARK: - CFT Models

public struct MarineCFTInput: Codable, Hashable, Sendable {
    public let age: Int
    public let sex: MarineSex
    public let altitude: MarineAltitude
    public let movementToContactTime: MarineTime
    public let ammunitionLiftRepetitions: Int
    public let maneuverUnderFireTime: MarineTime

    public init(
        age: Int,
        sex: MarineSex,
        altitude: MarineAltitude = .standard,
        movementToContactTime: MarineTime,
        ammunitionLiftRepetitions: Int,
        maneuverUnderFireTime: MarineTime
    ) {
        self.age = age
        self.sex = sex
        self.altitude = altitude
        self.movementToContactTime = movementToContactTime
        self.ammunitionLiftRepetitions = ammunitionLiftRepetitions
        self.maneuverUnderFireTime = maneuverUnderFireTime
    }
}

// MARK: - Internal Standards

private struct HigherIsBetterStandard: Sendable {
    let minimumPerformance: Int
    let maximumPerformance: Int
    let minimumPoints: Int
    let maximumPoints: Int
}

private struct LowerIsBetterStandard: Sendable {
    let maximumPerformanceSeconds: Int
    let minimumPassingSeconds: Int
    let minimumPoints: Int
    let maximumPoints: Int
}

private struct DemographicKey: Hashable, Sendable {
    let sex: MarineSex
    let ageBand: MarineAgeBand
}

private enum MarineScoringMath {
    static func higherIsBetter(
        repetitions: Int,
        standard: HigherIsBetterStandard
    ) -> MarineEventScore {
        fatalError("Use named wrapper")
    }

    static func scoreHigher(
        repetitions: Int,
        standard: HigherIsBetterStandard,
        eventName: String
    ) -> MarineEventScore {
        let reps = max(0, repetitions)

        guard reps >= standard.minimumPerformance else {
            return MarineEventScore(
                points: 0,
                passed: false,
                maximumPoints: standard.maximumPoints,
                rawValue: Double(reps),
                eventName: eventName
            )
        }

        if reps >= standard.maximumPerformance {
            return MarineEventScore(
                points: standard.maximumPoints,
                passed: true,
                maximumPoints: standard.maximumPoints,
                rawValue: Double(reps),
                eventName: eventName
            )
        }

        let performanceRange = Double(
            standard.maximumPerformance - standard.minimumPerformance
        )
        let earnedRange = Double(reps - standard.minimumPerformance)
        let pointRange = Double(standard.maximumPoints - standard.minimumPoints)

        let calculated = Double(standard.minimumPoints)
            + (earnedRange / performanceRange) * pointRange

        let points = Int(calculated.rounded(.toNearestOrAwayFromZero))

        return MarineEventScore(
            points: min(standard.maximumPoints, max(standard.minimumPoints, points)),
            passed: true,
            maximumPoints: standard.maximumPoints,
            rawValue: Double(reps),
            eventName: eventName
        )
    }

    static func scoreLower(
        seconds: Int,
        standard: LowerIsBetterStandard,
        eventName: String
    ) -> MarineEventScore {
        let time = max(0, seconds)

        // A zero time means the field was left blank, not a record run.
        guard time > 0 else {
            return MarineEventScore(
                points: 0,
                passed: false,
                maximumPoints: standard.maximumPoints,
                rawValue: 0,
                eventName: eventName
            )
        }

        guard time <= standard.minimumPassingSeconds else {
            return MarineEventScore(
                points: 0,
                passed: false,
                maximumPoints: standard.maximumPoints,
                rawValue: Double(time),
                eventName: eventName
            )
        }

        if time <= standard.maximumPerformanceSeconds {
            return MarineEventScore(
                points: standard.maximumPoints,
                passed: true,
                maximumPoints: standard.maximumPoints,
                rawValue: Double(time),
                eventName: eventName
            )
        }

        let timeRange = Double(
            standard.minimumPassingSeconds - standard.maximumPerformanceSeconds
        )
        let elapsedBeyondMaximum = Double(
            time - standard.maximumPerformanceSeconds
        )
        let pointRange = Double(standard.maximumPoints - standard.minimumPoints)

        let pointsLost = (elapsedBeyondMaximum / timeRange) * pointRange
        let calculated = Double(standard.maximumPoints) - pointsLost
        let points = Int(calculated.rounded(.toNearestOrAwayFromZero))

        return MarineEventScore(
            points: min(standard.maximumPoints, max(standard.minimumPoints, points)),
            passed: true,
            maximumPoints: standard.maximumPoints,
            rawValue: Double(time),
            eventName: eventName
        )
    }
}

// MARK: - Public Scoring API

public enum MarineCorpsScoring {

    // MARK: Complete Tests

    public static func scorePFT(_ input: MarinePFTInput) -> MarineTestResult? {
        guard let ageBand = MarineAgeBand(age: input.age) else { return nil }

        let upper: MarineEventScore
        switch input.upperBodyEvent {
        case .pullUps:
            upper = scorePullUps(
                repetitions: input.upperBodyRepetitions,
                sex: input.sex,
                ageBand: ageBand
            )
        case .pushUps:
            upper = scorePushUps(
                repetitions: input.upperBodyRepetitions,
                sex: input.sex,
                ageBand: ageBand
            )
        }

        let plank = scorePlank(seconds: input.plankTime.seconds)

        let cardio: MarineEventScore
        switch input.cardioEvent {
        case .threeMileRun:
            cardio = scoreThreeMileRun(
                seconds: input.cardioTime.seconds,
                sex: input.sex,
                ageBand: ageBand,
                altitude: input.altitude
            )
        case .fiveThousandMeterRow:
            cardio = scoreFiveThousandMeterRow(
                seconds: input.cardioTime.seconds,
                sex: input.sex,
                ageBand: ageBand
            )
        }

        return MarineTestResult(
            testType: .pft,
            eventScores: [upper, plank, cardio]
        )
    }

    public static func scoreCFT(_ input: MarineCFTInput) -> MarineTestResult? {
        guard let ageBand = MarineAgeBand(age: input.age) else { return nil }

        let mtc = scoreMovementToContact(
            seconds: input.movementToContactTime.seconds,
            sex: input.sex,
            ageBand: ageBand,
            altitude: input.altitude
        )

        let ammo = scoreAmmunitionLift(
            repetitions: input.ammunitionLiftRepetitions,
            sex: input.sex,
            ageBand: ageBand
        )

        let manuf = scoreManeuverUnderFire(
            seconds: input.maneuverUnderFireTime.seconds,
            sex: input.sex,
            ageBand: ageBand,
            altitude: input.altitude
        )

        return MarineTestResult(
            testType: .cft,
            eventScores: [mtc, ammo, manuf]
        )
    }

    // MARK: Individual PFT Events

    public static func scorePullUps(
        repetitions: Int,
        age: Int,
        sex: MarineSex
    ) -> MarineEventScore? {
        guard let ageBand = MarineAgeBand(age: age) else { return nil }
        return scorePullUps(repetitions: repetitions, sex: sex, ageBand: ageBand)
    }

    public static func scorePushUps(
        repetitions: Int,
        age: Int,
        sex: MarineSex
    ) -> MarineEventScore? {
        guard let ageBand = MarineAgeBand(age: age) else { return nil }
        return scorePushUps(repetitions: repetitions, sex: sex, ageBand: ageBand)
    }

    public static func scorePlank(seconds: Int) -> MarineEventScore {
        // Single age- and sex-neutral standard:
        // 1:10 = 40 points; 3:45 = 100 points.
        MarineScoringMath.scoreHigher(
            repetitions: seconds,
            standard: HigherIsBetterStandard(
                minimumPerformance: 70,
                maximumPerformance: 225,
                minimumPoints: 40,
                maximumPoints: 100
            ),
            eventName: "Plank"
        )
    }

    public static func scoreThreeMileRun(
        seconds: Int,
        age: Int,
        sex: MarineSex,
        altitude: MarineAltitude = .standard
    ) -> MarineEventScore? {
        guard let ageBand = MarineAgeBand(age: age) else { return nil }
        return scoreThreeMileRun(
            seconds: seconds,
            sex: sex,
            ageBand: ageBand,
            altitude: altitude
        )
    }

    public static func scoreFiveThousandMeterRow(
        seconds: Int,
        age: Int,
        sex: MarineSex
    ) -> MarineEventScore? {
        guard let ageBand = MarineAgeBand(age: age) else { return nil }
        return scoreFiveThousandMeterRow(
            seconds: seconds,
            sex: sex,
            ageBand: ageBand
        )
    }

    // MARK: Individual CFT Events

    public static func scoreMovementToContact(
        seconds: Int,
        age: Int,
        sex: MarineSex,
        altitude: MarineAltitude = .standard
    ) -> MarineEventScore? {
        guard let ageBand = MarineAgeBand(age: age) else { return nil }
        return scoreMovementToContact(
            seconds: seconds,
            sex: sex,
            ageBand: ageBand,
            altitude: altitude
        )
    }

    public static func scoreAmmunitionLift(
        repetitions: Int,
        age: Int,
        sex: MarineSex
    ) -> MarineEventScore? {
        guard let ageBand = MarineAgeBand(age: age) else { return nil }
        return scoreAmmunitionLift(
            repetitions: repetitions,
            sex: sex,
            ageBand: ageBand
        )
    }

    public static func scoreManeuverUnderFire(
        seconds: Int,
        age: Int,
        sex: MarineSex,
        altitude: MarineAltitude = .standard
    ) -> MarineEventScore? {
        guard let ageBand = MarineAgeBand(age: age) else { return nil }
        return scoreManeuverUnderFire(
            seconds: seconds,
            sex: sex,
            ageBand: ageBand,
            altitude: altitude
        )
    }

    // MARK: Internal Event Scoring

    private static func scorePullUps(
        repetitions: Int,
        sex: MarineSex,
        ageBand: MarineAgeBand
    ) -> MarineEventScore {
        let key = DemographicKey(sex: sex, ageBand: ageBand)
        guard let standard = pullUpStandards[key] else {
            return MarineEventScore(
                points: 0, passed: false, maximumPoints: 100,
                rawValue: Double(repetitions), eventName: "Pull-Ups"
            )
        }

        return MarineScoringMath.scoreHigher(
            repetitions: repetitions,
            standard: standard,
            eventName: "Pull-Ups"
        )
    }

    private static func scorePushUps(
        repetitions: Int,
        sex: MarineSex,
        ageBand: MarineAgeBand
    ) -> MarineEventScore {
        let key = DemographicKey(sex: sex, ageBand: ageBand)
        guard let standard = pushUpStandards[key] else {
            return MarineEventScore(
                points: 0, passed: false, maximumPoints: 70,
                rawValue: Double(repetitions), eventName: "Push-Ups"
            )
        }

        return MarineScoringMath.scoreHigher(
            repetitions: repetitions,
            standard: standard,
            eventName: "Push-Ups"
        )
    }

    private static func scoreThreeMileRun(
        seconds: Int,
        sex: MarineSex,
        ageBand: MarineAgeBand,
        altitude: MarineAltitude
    ) -> MarineEventScore {
        let key = DemographicKey(sex: sex, ageBand: ageBand)
        let standards = altitude == .standard
            ? runStandards
            : altitudeRunStandards

        guard let standard = standards[key] else {
            return MarineEventScore(
                points: 0, passed: false, maximumPoints: 100,
                rawValue: Double(seconds), eventName: "3-Mile Run"
            )
        }

        return MarineScoringMath.scoreLower(
            seconds: seconds,
            standard: standard,
            eventName: altitude == .standard
                ? "3-Mile Run"
                : "3-Mile Run (Altitude)"
        )
    }

    private static func scoreFiveThousandMeterRow(
        seconds: Int,
        sex: MarineSex,
        ageBand: MarineAgeBand
    ) -> MarineEventScore {
        let key = DemographicKey(sex: sex, ageBand: ageBand)
        guard let standard = rowStandards[key] else {
            return MarineEventScore(
                points: 0, passed: false, maximumPoints: 100,
                rawValue: Double(seconds), eventName: "5,000-Meter Row"
            )
        }

        return MarineScoringMath.scoreLower(
            seconds: seconds,
            standard: standard,
            eventName: "5,000-Meter Row"
        )
    }

    private static func scoreMovementToContact(
        seconds: Int,
        sex: MarineSex,
        ageBand: MarineAgeBand,
        altitude: MarineAltitude
    ) -> MarineEventScore {
        let key = DemographicKey(sex: sex, ageBand: ageBand)
        let standards = altitude == .standard
            ? movementToContactStandards
            : altitudeMovementToContactStandards

        guard let standard = standards[key] else {
            return MarineEventScore(
                points: 0, passed: false, maximumPoints: 100,
                rawValue: Double(seconds), eventName: "Movement to Contact"
            )
        }

        return MarineScoringMath.scoreLower(
            seconds: seconds,
            standard: standard,
            eventName: altitude == .standard
                ? "Movement to Contact"
                : "Movement to Contact (Altitude)"
        )
    }

    private static func scoreAmmunitionLift(
        repetitions: Int,
        sex: MarineSex,
        ageBand: MarineAgeBand
    ) -> MarineEventScore {
        let key = DemographicKey(sex: sex, ageBand: ageBand)
        guard let standard = ammunitionLiftStandards[key] else {
            return MarineEventScore(
                points: 0, passed: false, maximumPoints: 100,
                rawValue: Double(repetitions), eventName: "Ammunition Lift"
            )
        }

        return MarineScoringMath.scoreHigher(
            repetitions: repetitions,
            standard: standard,
            eventName: "Ammunition Lift"
        )
    }

    private static func scoreManeuverUnderFire(
        seconds: Int,
        sex: MarineSex,
        ageBand: MarineAgeBand,
        altitude: MarineAltitude
    ) -> MarineEventScore {
        let key = DemographicKey(sex: sex, ageBand: ageBand)
        let standards = altitude == .standard
            ? maneuverUnderFireStandards
            : altitudeManeuverUnderFireStandards

        guard let standard = standards[key] else {
            return MarineEventScore(
                points: 0, passed: false, maximumPoints: 100,
                rawValue: Double(seconds), eventName: "Maneuver Under Fire"
            )
        }

        return MarineScoringMath.scoreLower(
            seconds: seconds,
            standard: standard,
            eventName: altitude == .standard
                ? "Maneuver Under Fire"
                : "Maneuver Under Fire (Altitude)"
        )
    }

    // MARK: Standards Builders

    private static func demographicStandards<T>(
        male: [T],
        female: [T]
    ) -> [DemographicKey: T] {
        precondition(male.count == MarineAgeBand.allCases.count)
        precondition(female.count == MarineAgeBand.allCases.count)

        var result: [DemographicKey: T] = [:]

        for (index, band) in MarineAgeBand.allCases.enumerated() {
            result[DemographicKey(sex: .male, ageBand: band)] = male[index]
            result[DemographicKey(sex: .female, ageBand: band)] = female[index]
        }

        return result
    }

    private static func higher(
        minimums: [Int],
        maximums: [Int],
        minimumPoints: Int,
        maximumPoints: Int
    ) -> [HigherIsBetterStandard] {
        zip(minimums, maximums).map {
            HigherIsBetterStandard(
                minimumPerformance: $0.0,
                maximumPerformance: $0.1,
                minimumPoints: minimumPoints,
                maximumPoints: maximumPoints
            )
        }
    }

    private static func lower(
        maximumTimes: [Int],
        minimumTimes: [Int]
    ) -> [LowerIsBetterStandard] {
        zip(maximumTimes, minimumTimes).map {
            LowerIsBetterStandard(
                maximumPerformanceSeconds: $0.0,
                minimumPassingSeconds: $0.1,
                minimumPoints: 40,
                maximumPoints: 100
            )
        }
    }

    private static func t(_ minutes: Int, _ seconds: Int) -> Int {
        minutes * 60 + seconds
    }

    // MARK: PFT Endpoint Tables

    private static let pullUpStandards: [DemographicKey: HigherIsBetterStandard] =
        demographicStandards(
            male: higher(
                minimums: [4, 5, 5, 5, 5, 5, 4, 3],
                maximums: [20, 23, 23, 23, 21, 20, 19, 18],
                minimumPoints: 40,
                maximumPoints: 100
            ),
            female: higher(
                minimums: [1, 3, 4, 3, 3, 2, 2, 2],
                maximums: [7, 11, 12, 11, 10, 8, 6, 4],
                minimumPoints: 60,
                maximumPoints: 100
            )
        )

    private static let pushUpStandards: [DemographicKey: HigherIsBetterStandard] =
        demographicStandards(
            male: higher(
                minimums: [42, 40, 39, 36, 34, 30, 25, 20],
                maximums: [82, 87, 84, 80, 76, 72, 68, 64],
                minimumPoints: 40,
                maximumPoints: 70
            ),
            female: higher(
                minimums: [19, 18, 18, 17, 17, 15, 12, 10],
                maximums: [42, 50, 50, 47, 45, 40, 38, 35],
                minimumPoints: 40,
                maximumPoints: 70
            )
        )

    private static let runStandards: [DemographicKey: LowerIsBetterStandard] =
        demographicStandards(
            male: lower(
                maximumTimes: [
                    t(18,0), t(18,0), t(18,0), t(18,0),
                    t(18,0), t(18,30), t(19,0), t(19,30)
                ],
                minimumTimes: [
                    t(27,40), t(27,40), t(28,0), t(28,20),
                    t(28,40), t(29,20), t(30,0), t(33,0)
                ]
            ),
            female: lower(
                maximumTimes: [
                    t(21,0), t(21,0), t(21,0), t(21,0),
                    t(21,0), t(21,30), t(22,0), t(22,30)
                ],
                minimumTimes: [
                    t(30,50), t(30,50), t(31,10), t(31,30),
                    t(31,50), t(32,30), t(33,30), t(36,0)
                ]
            )
        )

    private static let altitudeRunStandards: [DemographicKey: LowerIsBetterStandard] =
        demographicStandards(
            male: lower(
                maximumTimes: [
                    t(19,30), t(19,30), t(19,30), t(19,30),
                    t(19,30), t(20,0), t(20,30), t(21,0)
                ],
                minimumTimes: [
                    t(29,10), t(29,10), t(29,30), t(29,50),
                    t(30,10), t(30,50), t(31,30), t(34,30)
                ]
            ),
            female: lower(
                maximumTimes: [
                    t(22,30), t(22,30), t(22,30), t(22,30),
                    t(22,30), t(23,0), t(23,30), t(24,0)
                ],
                minimumTimes: [
                    t(32,20), t(32,20), t(32,40), t(33,0),
                    t(33,20), t(34,0), t(35,0), t(37,30)
                ]
            )
        )

    private static let rowStandards: [DemographicKey: LowerIsBetterStandard] =
        demographicStandards(
            male: lower(
                maximumTimes: [
                    t(18,0), t(18,15), t(18,30), t(18,45),
                    t(19,0), t(19,15), t(19,35), t(20,0)
                ],
                minimumTimes: [
                    t(23,30), t(23,50), t(24,10), t(24,30),
                    t(24,50), t(25,10), t(25,35), t(26,0)
                ]
            ),
            female: lower(
                maximumTimes: [
                    t(21,0), t(21,15), t(21,30), t(21,45),
                    t(22,0), t(22,15), t(22,35), t(23,0)
                ],
                minimumTimes: [
                    t(26,30), t(26,50), t(27,10), t(27,30),
                    t(27,50), t(28,10), t(28,35), t(29,0)
                ]
            )
        )

    // MARK: CFT Endpoint Tables

    private static let movementToContactStandards:
        [DemographicKey: LowerIsBetterStandard] =
        demographicStandards(
            male: lower(
                maximumTimes: [
                    t(2,40), t(2,38), t(2,39), t(2,42),
                    t(2,45), t(2,52), t(3,1), t(3,5)
                ],
                minimumTimes: [
                    t(3,45), t(3,45), t(3,48), t(3,51),
                    t(3,58), t(4,11), t(4,28), t(5,7)
                ]
            ),
            female: lower(
                maximumTimes: [
                    t(3,19), t(3,13), t(3,10), t(3,12),
                    t(3,18), t(3,25), t(3,39), t(3,55)
                ],
                minimumTimes: [
                    t(4,36), t(4,41), t(4,45), t(4,46),
                    t(4,55), t(4,58), t(5,26), t(5,52)
                ]
            )
        )

    private static let altitudeMovementToContactStandards:
        [DemographicKey: LowerIsBetterStandard] =
        demographicStandards(
            male: lower(
                maximumTimes: [
                    t(2,46), t(2,44), t(2,45), t(2,48),
                    t(2,51), t(2,58), t(3,7), t(3,11)
                ],
                minimumTimes: [
                    t(3,51), t(3,51), t(3,54), t(3,57),
                    t(4,4), t(4,17), t(4,34), t(5,11)
                ]
            ),
            female: lower(
                maximumTimes: [
                    t(3,25), t(3,19), t(3,16), t(3,18),
                    t(3,24), t(3,31), t(3,45), t(4,1)
                ],
                minimumTimes: [
                    t(4,42), t(4,47), t(4,51), t(4,52),
                    t(5,1), t(5,4), t(5,32), t(5,58)
                ]
            )
        )

    private static let ammunitionLiftStandards:
        [DemographicKey: HigherIsBetterStandard] =
        demographicStandards(
            male: higher(
                minimums: [62, 67, 67, 67, 67, 66, 65, 16],
                maximums: [106, 115, 116, 120, 110, 106, 100, 95],
                minimumPoints: 40,
                maximumPoints: 100
            ),
            female: higher(
                minimums: [30, 30, 30, 30, 30, 28, 26, 6],
                maximums: [66, 74, 75, 72, 70, 62, 53, 44],
                minimumPoints: 40,
                maximumPoints: 100
            )
        )

    private static let maneuverUnderFireStandards:
        [DemographicKey: LowerIsBetterStandard] =
        demographicStandards(
            male: lower(
                maximumTimes: [
                    t(2,7), t(2,4), t(2,5), t(2,10),
                    t(2,16), t(2,23), t(2,40), t(2,52)
                ],
                minimumTimes: [
                    t(3,17), t(3,18), t(3,22), t(3,30),
                    t(3,42), t(3,59), t(4,14), t(6,9)
                ]
            ),
            female: lower(
                maximumTimes: [
                    t(2,55), t(2,45), t(2,42), t(2,49),
                    t(2,53), t(2,57), t(3,35), t(3,44)
                ],
                minimumTimes: [
                    t(4,53), t(4,34), t(4,40), t(4,44),
                    t(4,56), t(5,1), t(5,6), t(6,33)
                ]
            )
        )

    private static let altitudeManeuverUnderFireStandards:
        [DemographicKey: LowerIsBetterStandard] =
        demographicStandards(
            male: lower(
                maximumTimes: [
                    t(2,15), t(2,12), t(2,13), t(2,18),
                    t(2,24), t(2,31), t(2,48), t(3,0)
                ],
                minimumTimes: [
                    t(3,25), t(3,26), t(3,30), t(3,38),
                    t(3,50), t(4,7), t(4,22), t(6,17)
                ]
            ),
            female: lower(
                maximumTimes: [
                    t(3,3), t(2,53), t(2,50), t(2,57),
                    t(3,1), t(3,5), t(3,43), t(3,52)
                ],
                minimumTimes: [
                    t(5,1), t(4,42), t(4,48), t(4,52),
                    t(5,4), t(5,9), t(5,14), t(6,41)
                ]
            )
        )
}

// MARK: - Examples
//
// PFT:
//
// let pft = MarineCorpsScoring.scorePFT(
//     MarinePFTInput(
//         age: 28,
//         sex: .male,
//         altitude: .standard,
//         upperBodyEvent: .pullUps,
//         upperBodyRepetitions: 20,
//         plankTime: MarineTime(minutes: 3, seconds: 30),
//         cardioEvent: .threeMileRun,
//         cardioTime: MarineTime(minutes: 20, seconds: 10)
//     )
// )
//
// CFT:
//
// let cft = MarineCorpsScoring.scoreCFT(
//     MarineCFTInput(
//         age: 28,
//         sex: .male,
//         altitude: .standard,
//         movementToContactTime: MarineTime(minutes: 2, seconds: 50),
//         ammunitionLiftRepetitions: 100,
//         maneuverUnderFireTime: MarineTime(minutes: 2, seconds: 30)
//     )
// )
