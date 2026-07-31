import Foundation

// MARK: - ROTC & Service Academy Applicant Fitness Assessments
//
// IMPORTANT:
// This module is intended for practice, self-assessment, and application preparation.
// It is not affiliated with or endorsed by any ROTC program, service academy,
// military department, or the Department of Defense.
//
// The event structures mirror publicly available applicant assessment formats.
// Several programs do not publicly release their complete selection-board scoring
// formulas. In those cases, this module returns:
//   1. Raw event results
//   2. Event readiness scores on an app-created 0...100 comparison scale
//   3. A practice composite score
//
// Do not label a proprietary practice score as an official scholarship,
// admissions, or selection score.

public enum ApplicantSex: String, Codable, CaseIterable, Sendable {
    case male
    case female
}

public enum ApplicantAssessmentProgram: String, Codable, CaseIterable, Sendable {
    case armyROTC = "Army ROTC Applicant Assessment"
    case airForceROTC = "Air Force ROTC Applicant Assessment"
    case navyROTC = "Navy ROTC Applicant Assessment"
    case marineOptionROTC = "Marine Option Applicant Assessment"
    case serviceAcademyCFA = "Service Academy Candidate Fitness Assessment"
}

public enum ApplicantScoreAuthority: String, Codable, Sendable {
    case officialPublishedTable
    case officialEventFormatProprietaryPracticeScore
    case rawOnly
}

public struct ApplicantTime: Codable, Hashable, Sendable {
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

public struct ApplicantEventResult: Codable, Hashable, Sendable {
    public let eventID: String
    public let displayName: String
    public let rawValue: Double
    public let unit: String
    public let practiceScore: Double
    public let authority: ApplicantScoreAuthority
    public let notes: String?

    public init(
        eventID: String,
        displayName: String,
        rawValue: Double,
        unit: String,
        practiceScore: Double,
        authority: ApplicantScoreAuthority,
        notes: String? = nil
    ) {
        self.eventID = eventID
        self.displayName = displayName
        self.rawValue = rawValue
        self.unit = unit
        self.practiceScore = min(100, max(0, practiceScore))
        self.authority = authority
        self.notes = notes
    }
}

public enum ApplicantReadinessRating: String, Codable, Sendable {
    case exceptional = "Exceptional"
    case highlyCompetitive = "Highly Competitive"
    case competitive = "Competitive"
    case developing = "Developing"
    case foundation = "Foundation"

    public static func from(score: Double) -> Self {
        switch score {
        case 90...: return .exceptional
        case 80..<90: return .highlyCompetitive
        case 70..<80: return .competitive
        case 60..<70: return .developing
        default: return .foundation
        }
    }
}

public struct ApplicantAssessmentResult: Codable, Hashable, Sendable {
    public let program: ApplicantAssessmentProgram
    public let eventResults: [ApplicantEventResult]
    public let practiceComposite: Double
    public let rating: ApplicantReadinessRating
    public let complete: Bool
    public let disclaimer: String

    public init(
        program: ApplicantAssessmentProgram,
        eventResults: [ApplicantEventResult],
        expectedEventCount: Int
    ) {
        let complete = eventResults.count == expectedEventCount
        let composite = complete
            ? eventResults.map(\.practiceScore).reduce(0, +) / Double(expectedEventCount)
            : 0

        self.program = program
        self.eventResults = eventResults
        self.practiceComposite = composite
        self.rating = ApplicantReadinessRating.from(score: composite)
        self.complete = complete
        self.disclaimer =
            "Practice comparison only. This is not an official scholarship, admissions, " +
            "qualification, or selection score."
    }
}

// MARK: - Generic Scoring Curve

public enum ApplicantScoreDirection: String, Codable, Sendable {
    case higherIsBetter
    case lowerIsBetter
}

public struct ApplicantScoreAnchor: Codable, Hashable, Sendable {
    public let performance: Double
    public let score: Double

    public init(_ performance: Double, _ score: Double) {
        self.performance = performance
        self.score = score
    }
}

public struct ApplicantScoreCurve: Codable, Sendable {
    public let direction: ApplicantScoreDirection
    public let anchors: [ApplicantScoreAnchor]

    public init(
        direction: ApplicantScoreDirection,
        anchors: [ApplicantScoreAnchor]
    ) {
        self.direction = direction
        self.anchors = anchors.sorted { $0.performance < $1.performance }
    }

    public func score(for performance: Double) -> Double {
        guard !anchors.isEmpty else { return 0 }

        if performance <= anchors[0].performance {
            return clamp(anchors[0].score)
        }

        if performance >= anchors[anchors.count - 1].performance {
            return clamp(anchors[anchors.count - 1].score)
        }

        for index in 0..<(anchors.count - 1) {
            let lower = anchors[index]
            let upper = anchors[index + 1]

            guard performance >= lower.performance,
                  performance <= upper.performance else {
                continue
            }

            let span = upper.performance - lower.performance
            guard span > 0 else { return clamp(lower.score) }

            let fraction = (performance - lower.performance) / span
            return clamp(lower.score + fraction * (upper.score - lower.score))
        }

        return 0
    }

    private func clamp(_ value: Double) -> Double {
        min(100, max(0, value))
    }
}

// MARK: - Army ROTC Applicant PFA
//
// Public event format:
// - Push-ups: 1 minute
// - Curl-ups: 1 minute
// - 1-mile run
//
// The complete selection-board conversion should be sourced from the current
// USACC Form 145-1-1. The practice scale below is intentionally labeled
// proprietary and should not be displayed as the official Whole Person Score.

public struct ArmyROTCApplicantInput: Codable, Hashable, Sendable {
    public let sex: ApplicantSex
    public let pushUpsOneMinute: Int
    public let curlUpsOneMinute: Int
    public let oneMileRun: ApplicantTime

    public init(
        sex: ApplicantSex,
        pushUpsOneMinute: Int,
        curlUpsOneMinute: Int,
        oneMileRun: ApplicantTime
    ) {
        self.sex = sex
        self.pushUpsOneMinute = pushUpsOneMinute
        self.curlUpsOneMinute = curlUpsOneMinute
        self.oneMileRun = oneMileRun
    }
}

// MARK: - Air Force ROTC Applicant Assessment
//
// Current application cycles must be verified because event distances and
// administrative rules may change. This implementation uses:
// - Push-ups: 1 minute
// - Sit-ups: 1 minute
// - 2-mile run
//
// The complete scholarship scoring rubric is not represented as official here.

public struct AirForceROTCApplicantInput: Codable, Hashable, Sendable {
    public let sex: ApplicantSex
    public let pushUpsOneMinute: Int
    public let sitUpsOneMinute: Int
    public let twoMileRun: ApplicantTime

    public init(
        sex: ApplicantSex,
        pushUpsOneMinute: Int,
        sitUpsOneMinute: Int,
        twoMileRun: ApplicantTime
    ) {
        self.sex = sex
        self.pushUpsOneMinute = pushUpsOneMinute
        self.sitUpsOneMinute = sitUpsOneMinute
        self.twoMileRun = twoMileRun
    }
}

// MARK: - NROTC Navy Option Applicant Fitness Assessment
//
// Public event format:
// - Push-ups: 2 minutes
// - Forearm plank
// - 1-mile run

public struct NavyROTCApplicantInput: Codable, Hashable, Sendable {
    public let sex: ApplicantSex
    public let pushUpsTwoMinutes: Int
    public let forearmPlank: ApplicantTime
    public let oneMileRun: ApplicantTime

    public init(
        sex: ApplicantSex,
        pushUpsTwoMinutes: Int,
        forearmPlank: ApplicantTime,
        oneMileRun: ApplicantTime
    ) {
        self.sex = sex
        self.pushUpsTwoMinutes = pushUpsTwoMinutes
        self.forearmPlank = forearmPlank
        self.oneMileRun = oneMileRun
    }
}

// MARK: - Marine Option
//
// Marine Option applicants use a Marine Corps PFT-style assessment:
// - Pull-ups or push-ups
// - Plank
// - 3-mile run
//
// Use MarineCorpsScoring.swift for the official event-score implementation.
// This wrapper is provided so the applicant section can launch the existing
// Marine scoring module without duplicating its tables.

public enum MarineOptionUpperBodyChoice: String, Codable, CaseIterable, Sendable {
    case pullUps
    case pushUps
}

public struct MarineOptionApplicantInput: Codable, Hashable, Sendable {
    public let age: Int
    public let sex: ApplicantSex
    public let upperBodyChoice: MarineOptionUpperBodyChoice
    public let repetitions: Int
    public let plank: ApplicantTime
    public let threeMileRun: ApplicantTime

    public init(
        age: Int,
        sex: ApplicantSex,
        upperBodyChoice: MarineOptionUpperBodyChoice,
        repetitions: Int,
        plank: ApplicantTime,
        threeMileRun: ApplicantTime
    ) {
        self.age = age
        self.sex = sex
        self.upperBodyChoice = upperBodyChoice
        self.repetitions = repetitions
        self.plank = plank
        self.threeMileRun = threeMileRun
    }
}

// MARK: - Service Academy Candidate Fitness Assessment
//
// Common CFA event sequence:
// - Basketball throw
// - Pull-ups, or flexed-arm hang where authorized
// - Shuttle run
// - Modified sit-ups / crunches
// - Push-ups
// - 1-mile run
//
// The academies do not publish a complete official point-conversion formula.
// The scoring below is a proprietary practice comparison based on event
// performance bands. Do not display it as an admissions score.

public enum CFAUpperBodyEvent: String, Codable, CaseIterable, Sendable {
    case pullUps
    case flexedArmHang
}

public struct ServiceAcademyCFAInput: Codable, Hashable, Sendable {
    public let sex: ApplicantSex
    public let basketballThrowFeet: Double
    public let upperBodyEvent: CFAUpperBodyEvent
    public let pullUpRepetitions: Int?
    public let flexedArmHang: ApplicantTime?
    public let shuttleRun: ApplicantTime
    public let modifiedSitUpsTwoMinutes: Int
    public let pushUpsTwoMinutes: Int
    public let oneMileRun: ApplicantTime

    public init(
        sex: ApplicantSex,
        basketballThrowFeet: Double,
        upperBodyEvent: CFAUpperBodyEvent,
        pullUpRepetitions: Int? = nil,
        flexedArmHang: ApplicantTime? = nil,
        shuttleRun: ApplicantTime,
        modifiedSitUpsTwoMinutes: Int,
        pushUpsTwoMinutes: Int,
        oneMileRun: ApplicantTime
    ) {
        self.sex = sex
        self.basketballThrowFeet = basketballThrowFeet
        self.upperBodyEvent = upperBodyEvent
        self.pullUpRepetitions = pullUpRepetitions
        self.flexedArmHang = flexedArmHang
        self.shuttleRun = shuttleRun
        self.modifiedSitUpsTwoMinutes = modifiedSitUpsTwoMinutes
        self.pushUpsTwoMinutes = pushUpsTwoMinutes
        self.oneMileRun = oneMileRun
    }
}

// MARK: - Scoring Engine

public enum ApplicantAssessmentScoring {

    // MARK: Army ROTC

    public static func scoreArmyROTC(
        _ input: ArmyROTCApplicantInput
    ) -> ApplicantAssessmentResult {
        let curves = armyCurves(for: input.sex)

        let results = [
            event(
                id: "army.pushups.1min",
                name: "Push-Ups (1 minute)",
                raw: Double(input.pushUpsOneMinute),
                unit: "reps",
                curve: curves.pushUps
            ),
            event(
                id: "army.curlups.1min",
                name: "Curl-Ups (1 minute)",
                raw: Double(input.curlUpsOneMinute),
                unit: "reps",
                curve: curves.core
            ),
            event(
                id: "army.run.1mile",
                name: "1-Mile Run",
                raw: Double(input.oneMileRun.seconds),
                unit: "seconds",
                curve: curves.run
            )
        ]

        return ApplicantAssessmentResult(
            program: .armyROTC,
            eventResults: results,
            expectedEventCount: 3
        )
    }

    // MARK: Air Force ROTC

    public static func scoreAirForceROTC(
        _ input: AirForceROTCApplicantInput
    ) -> ApplicantAssessmentResult {
        let curves = airForceCurves(for: input.sex)

        let results = [
            event(
                id: "afrotc.pushups.1min",
                name: "Push-Ups (1 minute)",
                raw: Double(input.pushUpsOneMinute),
                unit: "reps",
                curve: curves.pushUps
            ),
            event(
                id: "afrotc.situps.1min",
                name: "Sit-Ups (1 minute)",
                raw: Double(input.sitUpsOneMinute),
                unit: "reps",
                curve: curves.core
            ),
            event(
                id: "afrotc.run.2mile",
                name: "2-Mile Run",
                raw: Double(input.twoMileRun.seconds),
                unit: "seconds",
                curve: curves.run
            )
        ]

        return ApplicantAssessmentResult(
            program: .airForceROTC,
            eventResults: results,
            expectedEventCount: 3
        )
    }

    // MARK: Navy ROTC

    public static func scoreNavyROTC(
        _ input: NavyROTCApplicantInput
    ) -> ApplicantAssessmentResult {
        let curves = navyCurves(for: input.sex)

        let results = [
            event(
                id: "nrotc.pushups.2min",
                name: "Push-Ups (2 minutes)",
                raw: Double(input.pushUpsTwoMinutes),
                unit: "reps",
                curve: curves.pushUps
            ),
            event(
                id: "nrotc.plank",
                name: "Forearm Plank",
                raw: Double(input.forearmPlank.seconds),
                unit: "seconds",
                curve: curves.core
            ),
            event(
                id: "nrotc.run.1mile",
                name: "1-Mile Run",
                raw: Double(input.oneMileRun.seconds),
                unit: "seconds",
                curve: curves.run
            )
        ]

        return ApplicantAssessmentResult(
            program: .navyROTC,
            eventResults: results,
            expectedEventCount: 3
        )
    }

    // MARK: Service Academy CFA

    public static func scoreServiceAcademyCFA(
        _ input: ServiceAcademyCFAInput
    ) -> ApplicantAssessmentResult {
        let curves = cfaCurves(for: input.sex)

        var results: [ApplicantEventResult] = [
            event(
                id: "cfa.basketballThrow",
                name: "Basketball Throw",
                raw: input.basketballThrowFeet,
                unit: "feet",
                curve: curves.basketballThrow
            )
        ]

        switch input.upperBodyEvent {
        case .pullUps:
            if let reps = input.pullUpRepetitions {
                results.append(
                    event(
                        id: "cfa.pullups",
                        name: "Pull-Ups",
                        raw: Double(reps),
                        unit: "reps",
                        curve: curves.pullUps
                    )
                )
            }

        case .flexedArmHang:
            if let hang = input.flexedArmHang {
                results.append(
                    event(
                        id: "cfa.flexedArmHang",
                        name: "Flexed-Arm Hang",
                        raw: Double(hang.seconds),
                        unit: "seconds",
                        curve: curves.flexedArmHang
                    )
                )
            }
        }

        results.append(contentsOf: [
            event(
                id: "cfa.shuttle",
                name: "Shuttle Run",
                raw: Double(input.shuttleRun.seconds),
                unit: "seconds",
                curve: curves.shuttle
            ),
            event(
                id: "cfa.situps",
                name: "Modified Sit-Ups (2 minutes)",
                raw: Double(input.modifiedSitUpsTwoMinutes),
                unit: "reps",
                curve: curves.sitUps
            ),
            event(
                id: "cfa.pushups",
                name: "Push-Ups (2 minutes)",
                raw: Double(input.pushUpsTwoMinutes),
                unit: "reps",
                curve: curves.pushUps
            ),
            event(
                id: "cfa.run.1mile",
                name: "1-Mile Run",
                raw: Double(input.oneMileRun.seconds),
                unit: "seconds",
                curve: curves.run
            )
        ])

        return ApplicantAssessmentResult(
            program: .serviceAcademyCFA,
            eventResults: results,
            expectedEventCount: 6
        )
    }

    // MARK: Helpers

    private static func event(
        id: String,
        name: String,
        raw: Double,
        unit: String,
        curve: ApplicantScoreCurve
    ) -> ApplicantEventResult {
        ApplicantEventResult(
            eventID: id,
            displayName: name,
            rawValue: raw,
            unit: unit,
            practiceScore: curve.score(for: raw),
            authority: .officialEventFormatProprietaryPracticeScore
        )
    }

    private struct ThreeEventCurves {
        let pushUps: ApplicantScoreCurve
        let core: ApplicantScoreCurve
        let run: ApplicantScoreCurve
    }

    private struct CFACurves {
        let basketballThrow: ApplicantScoreCurve
        let pullUps: ApplicantScoreCurve
        let flexedArmHang: ApplicantScoreCurve
        let shuttle: ApplicantScoreCurve
        let sitUps: ApplicantScoreCurve
        let pushUps: ApplicantScoreCurve
        let run: ApplicantScoreCurve
    }

    private static func higher(
        _ values: [(Double, Double)]
    ) -> ApplicantScoreCurve {
        ApplicantScoreCurve(
            direction: .higherIsBetter,
            anchors: values.map { ApplicantScoreAnchor($0.0, $0.1) }
        )
    }

    private static func lower(
        _ values: [(Double, Double)]
    ) -> ApplicantScoreCurve {
        ApplicantScoreCurve(
            direction: .lowerIsBetter,
            anchors: values.map { ApplicantScoreAnchor($0.0, $0.1) }
        )
    }

    // Note: For lower-is-better curves, anchors remain ordered by raw seconds,
    // with faster times assigned higher scores.

    private static func armyCurves(for sex: ApplicantSex) -> ThreeEventCurves {
        switch sex {
        case .male:
            return ThreeEventCurves(
                pushUps: higher([(0,0),(20,40),(30,55),(40,70),(50,85),(60,100)]),
                core: higher([(0,0),(25,40),(35,55),(45,70),(55,85),(65,100)]),
                run: lower([(300,100),(330,90),(360,80),(390,70),(420,60),(480,40),(600,0)])
            )
        case .female:
            return ThreeEventCurves(
                pushUps: higher([(0,0),(10,40),(20,55),(30,70),(40,85),(50,100)]),
                core: higher([(0,0),(25,40),(35,55),(45,70),(55,85),(65,100)]),
                run: lower([(330,100),(360,90),(390,80),(420,70),(450,60),(510,40),(630,0)])
            )
        }
    }

    private static func airForceCurves(for sex: ApplicantSex) -> ThreeEventCurves {
        switch sex {
        case .male:
            return ThreeEventCurves(
                pushUps: higher([(0,0),(20,40),(30,55),(40,70),(50,85),(60,100)]),
                core: higher([(0,0),(25,40),(35,55),(45,70),(55,85),(65,100)]),
                run: lower([(660,100),(720,90),(780,80),(840,70),(900,60),(1020,40),(1200,0)])
            )
        case .female:
            return ThreeEventCurves(
                pushUps: higher([(0,0),(10,40),(20,55),(30,70),(40,85),(50,100)]),
                core: higher([(0,0),(25,40),(35,55),(45,70),(55,85),(65,100)]),
                run: lower([(720,100),(780,90),(840,80),(900,70),(960,60),(1080,40),(1260,0)])
            )
        }
    }

    private static func navyCurves(for sex: ApplicantSex) -> ThreeEventCurves {
        switch sex {
        case .male:
            return ThreeEventCurves(
                pushUps: higher([(0,0),(30,40),(45,55),(60,70),(75,85),(90,100)]),
                core: higher([(0,0),(90,40),(120,55),(150,70),(180,85),(205,100)]),
                run: lower([(300,100),(330,90),(360,80),(390,70),(420,60),(480,40),(600,0)])
            )
        case .female:
            return ThreeEventCurves(
                pushUps: higher([(0,0),(15,40),(25,55),(35,70),(45,85),(55,100)]),
                core: higher([(0,0),(90,40),(120,55),(150,70),(180,88),(194,100)]),
                run: lower([(330,100),(360,90),(390,80),(420,70),(450,60),(510,40),(630,0)])
            )
        }
    }

    private static func cfaCurves(for sex: ApplicantSex) -> CFACurves {
        switch sex {
        case .male:
            return CFACurves(
                basketballThrow: higher([(0,0),(40,35),(55,50),(70,65),(85,80),(100,90),(120,100)]),
                pullUps: higher([(0,0),(3,35),(6,50),(9,65),(12,80),(15,90),(18,100)]),
                flexedArmHang: higher([(0,0),(10,35),(20,50),(30,65),(40,80),(50,90),(60,100)]),
                shuttle: lower([(7.5,100),(8.0,90),(8.5,80),(9.0,70),(9.5,60),(10.0,45),(11.0,20)]),
                sitUps: higher([(0,0),(40,35),(55,50),(70,65),(85,80),(95,90),(100,100)]),
                pushUps: higher([(0,0),(30,35),(40,50),(50,65),(60,80),(70,90),(75,100)]),
                run: lower([(300,100),(330,90),(360,80),(390,70),(420,60),(480,40),(600,0)])
            )
        case .female:
            return CFACurves(
                basketballThrow: higher([(0,0),(25,35),(35,50),(45,65),(55,80),(65,90),(80,100)]),
                pullUps: higher([(0,0),(1,45),(3,65),(5,80),(7,90),(9,100)]),
                flexedArmHang: higher([(0,0),(10,35),(20,50),(30,65),(40,80),(50,90),(60,100)]),
                shuttle: lower([(8.0,100),(8.5,90),(9.0,80),(9.5,70),(10.0,60),(10.5,45),(11.5,20)]),
                sitUps: higher([(0,0),(35,35),(50,50),(65,65),(80,80),(90,90),(95,100)]),
                pushUps: higher([(0,0),(15,35),(25,50),(35,65),(45,80),(50,90),(55,100)]),
                run: lower([(330,100),(360,90),(390,80),(420,70),(450,60),(510,40),(630,0)])
            )
        }
    }
}

// MARK: - Example Usage
//
// Army ROTC:
//
// let army = ApplicantAssessmentScoring.scoreArmyROTC(
//     ArmyROTCApplicantInput(
//         sex: .female,
//         pushUpsOneMinute: 38,
//         curlUpsOneMinute: 52,
//         oneMileRun: ApplicantTime(minutes: 7, seconds: 4)
//     )
// )
//
// Air Force ROTC:
//
// let airForce = ApplicantAssessmentScoring.scoreAirForceROTC(
//     AirForceROTCApplicantInput(
//         sex: .male,
//         pushUpsOneMinute: 52,
//         sitUpsOneMinute: 55,
//         twoMileRun: ApplicantTime(minutes: 13, seconds: 20)
//     )
// )
//
// Navy ROTC:
//
// let navy = ApplicantAssessmentScoring.scoreNavyROTC(
//     NavyROTCApplicantInput(
//         sex: .female,
//         pushUpsTwoMinutes: 45,
//         forearmPlank: ApplicantTime(minutes: 3, seconds: 0),
//         oneMileRun: ApplicantTime(minutes: 7, seconds: 15)
//     )
// )
//
// Service Academy CFA:
//
// let cfa = ApplicantAssessmentScoring.scoreServiceAcademyCFA(
//     ServiceAcademyCFAInput(
//         sex: .female,
//         basketballThrowFeet: 48,
//         upperBodyEvent: .pullUps,
//         pullUpRepetitions: 4,
//         shuttleRun: ApplicantTime(seconds: 9),
//         modifiedSitUpsTwoMinutes: 78,
//         pushUpsTwoMinutes: 42,
//         oneMileRun: ApplicantTime(minutes: 7, seconds: 20)
//     )
// )
