import Foundation

// Proprietary app scoring model.
// These are not official military scoring tables or selection criteria.

enum ScoreDirection: String, Codable {
    case higherIsBetter
    case lowerIsBetter
    case binary
    /// Finish inside a maximum allowable time, or fail. Not graded on a curve:
    /// a ruck march is a standard you meet or you don't, and awarding partial
    /// credit for finishing 40 minutes late misrepresents it.
    case goNoGo
}

struct ScoreAnchor: Codable, Hashable {
    let performance: Double
    let score: Double
}

struct EventCurve: Codable {
    let id: String
    let displayName: String
    let unit: String
    let direction: ScoreDirection
    let anchors: [ScoreAnchor]
    /// Maximum allowable time in seconds for a `.goNoGo` event.
    var capSeconds: Double?

    init(id: String, displayName: String, unit: String, direction: ScoreDirection,
         anchors: [ScoreAnchor], capSeconds: Double? = nil) {
        self.id = id
        self.displayName = displayName
        self.unit = unit
        self.direction = direction
        self.anchors = anchors
        self.capSeconds = capSeconds
    }

    /// True when this event gates the benchmark rather than contributing points.
    var isGate: Bool { direction == .goNoGo || direction == .binary }

    /// Human-readable standard shown on the event row, e.g. "MUST FINISH 3:00:00".
    var standardLabel: String? {
        switch direction {
        case .goNoGo:
            guard let capSeconds else { return nil }
            let total = Int(capSeconds)
            return String(format: "MUST FINISH %d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60)
        case .binary:
            return "GO / NO-GO"
        case .lowerIsBetter:
            // Anchors are ascending by performance (fastest first), so the
            // 60-point reference is the SLOWEST time that still scores 60 —
            // `first(where:)` would return the 100-point anchor and print the
            // same number twice.
            guard let best = anchors.map(\.performance).min(),
                  let pass = anchors.filter({ $0.score >= 60 }).map(\.performance).max() else { return nil }
            return "60 PT \(Self.clock(pass)) \(MVMTheme.dot) 100 PT \(Self.clock(best))"
        case .higherIsBetter:
            guard let top = anchors.map(\.performance).max(),
                  let pass = anchors.first(where: { $0.score >= 60 })?.performance else { return nil }
            if unit == "seconds" {
                return "60 PT \(Self.clock(pass)) \(MVMTheme.dot) 100 PT \(Self.clock(top))"
            }
            return "60 PT \(Int(pass)) \(MVMTheme.dot) 100 PT \(Int(top))"
        }
    }

    private static func clock(_ seconds: Double) -> String {
        let total = Int(seconds)
        if total >= 3600 {
            return String(format: "%d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60)
        }
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    /// A gate event passes when it is entered and meets the standard.
    func passesGate(_ performance: Double?) -> Bool {
        guard let performance else { return false }
        switch direction {
        case .goNoGo:
            guard let capSeconds else { return false }
            return performance > 0 && performance <= capSeconds
        case .binary:
            return performance >= 1
        default:
            return true
        }
    }

    func score(for performance: Double) -> Double {
        guard !anchors.isEmpty else { return 0 }

        if direction == .binary {
            return performance >= 1 ? 100 : 0
        }

        if direction == .goNoGo {
            guard let capSeconds, performance > 0 else { return 0 }
            return performance <= capSeconds ? 100 : 0
        }

        // A non-positive measurement is not a performance — it means the field
        // was left blank. Without this guard a lowerIsBetter event treats 0
        // seconds as the fastest possible time and awards the maximum score.
        guard performance > 0 else { return 0 }

        let ordered = anchors.sorted { $0.performance < $1.performance }

        if performance <= ordered[0].performance {
            return ordered[0].score
        }
        if performance >= ordered[ordered.count - 1].performance {
            return ordered[ordered.count - 1].score
        }

        for index in 0..<(ordered.count - 1) {
            let a = ordered[index]
            let b = ordered[index + 1]
            guard performance >= a.performance, performance <= b.performance else { continue }

            let span = b.performance - a.performance
            guard span > 0 else { return max(0, min(100, a.score)) }

            let fraction = (performance - a.performance) / span
            let interpolated = a.score + fraction * (b.score - a.score)
            return max(0, min(100, interpolated))
        }

        return 0
    }
}

struct BenchmarkEvent: Codable, Hashable {
    let eventID: String
    let weight: Double
}

struct ReadinessBenchmark: Codable {
    let id: String
    let displayName: String
    let events: [BenchmarkEvent]

    /// Scored (non-gate) events, with their weights renormalised so the graded
    /// portion still totals 100 once GO/NO-GO events are pulled out.
    func scoredEvents(curves: [String: EventCurve]) -> [(event: BenchmarkEvent, weight: Double)] {
        let scored = events.filter { curves[$0.eventID]?.isGate == false }
        let sum = scored.reduce(0.0) { $0 + $1.weight }
        guard sum > 0 else { return [] }
        return scored.map { ($0, $0.weight / sum) }
    }

    func gateEvents(curves: [String: EventCurve]) -> [BenchmarkEvent] {
        events.filter { curves[$0.eventID]?.isGate == true }
    }

    /// The graded score, out of 100, over the non-gate events only.
    func totalScore(
        results: [String: Double],
        curves: [String: EventCurve]
    ) -> Double? {
        guard events.allSatisfy({ results[$0.eventID] != nil && curves[$0.eventID] != nil }) else {
            return nil
        }

        let total = scoredEvents(curves: curves).reduce(0.0) { partial, item in
            guard let raw = results[item.event.eventID],
                  let curve = curves[item.event.eventID] else { return partial }
            return partial + curve.score(for: raw) * item.weight
        }

        return max(0, min(100, total))
    }

    /// Every GO/NO-GO event met its standard. A benchmark cannot be passed on
    /// points alone — the same way the Air Force 2 km walk gates its composite.
    func gatesPassed(results: [String: Double], curves: [String: EventCurve]) -> Bool {
        gateEvents(curves: curves).allSatisfy { event in
            guard let curve = curves[event.eventID] else { return false }
            return curve.passesGate(results[event.eventID])
        }
    }
}

enum ReadinessRating: String {
    case elite = "Elite"
    case advanced = "Advanced"
    case strong = "Strong"
    case developing = "Developing"
    case foundation = "Foundation"

    static func from(score: Double) -> ReadinessRating {
        switch score {
        case 90...: return .elite
        case 80..<90: return .advanced
        case 70..<80: return .strong
        case 60..<70: return .developing
        default: return .foundation
        }
    }
}

enum ReadinessScoringData {
    private static func anchors(_ values: [(Double, Double)]) -> [ScoreAnchor] {
        values.map { ScoreAnchor(performance: $0.0, score: $0.1) }
    }

    static let curves: [String: EventCurve] = {
        let list: [EventCurve] = [
            EventCurve(id: "swim500yd", displayName: "500 yd Swim", unit: "seconds", direction: .lowerIsBetter,
                       anchors: anchors([(420,100),(450,95),(480,90),(510,85),(540,80),(570,75),(600,70),(630,65),(660,60),(690,55),(720,50),(750,45),(780,35),(840,20),(900,0)])),
            EventCurve(id: "swim1000m", displayName: "1000 m Swim", unit: "seconds", direction: .lowerIsBetter,
                       anchors: anchors([(780,100),(840,95),(900,90),(960,85),(1020,80),(1080,75),(1140,70),(1200,65),(1260,60),(1320,55),(1380,50),(1440,40),(1560,25),(1680,10),(1800,0)])),
            EventCurve(id: "run1_5mi", displayName: "1.5-Mile Run", unit: "seconds", direction: .lowerIsBetter,
                       anchors: anchors([(480,100),(510,95),(540,90),(570,85),(600,80),(630,75),(660,70),(690,65),(720,60),(750,55),(780,50),(810,40),(840,30),(900,15),(960,0)])),
            EventCurve(id: "run3mi", displayName: "3-Mile Run", unit: "seconds", direction: .lowerIsBetter,
                       anchors: anchors([(1020,100),(1080,95),(1140,90),(1200,85),(1260,80),(1320,75),(1380,70),(1440,65),(1500,60),(1560,55),(1620,50),(1680,40),(1800,25),(1920,10),(2040,0)])),
            EventCurve(id: "run5mi", displayName: "5-Mile Run", unit: "seconds", direction: .lowerIsBetter,
                       anchors: anchors([(1800,100),(1860,97),(1920,94),(1980,91),(2040,88),(2100,85),(2160,80),(2220,75),(2280,70),(2340,65),(2400,60),(2460,50),(2520,40),(2640,20),(2760,0)])),
            // A ruck march is pass/fail against a maximum allowable time, not a
            // graded curve. 15:00 per mile is the recognised standard, so the cap
            // is 3:00:00 for twelve miles.
            EventCurve(id: "ruck12mi45", displayName: "12-Mile Ruck (45 lb)", unit: "seconds", direction: .goNoGo,
                       anchors: anchors([(10800,100),(10801,0)]), capSeconds: 10800),
            // Same 15:00 per mile standard — 2:30:00 for ten miles.
            EventCurve(id: "ruck10mi45", displayName: "10-Mile Ruck (45 lb)", unit: "seconds", direction: .goNoGo,
                       anchors: anchors([(9000,100),(9001,0)]), capSeconds: 9000),
            EventCurve(id: "shuttle300yd", displayName: "300 yd Shuttle", unit: "seconds", direction: .lowerIsBetter,
                       anchors: anchors([(50,100),(52,95),(54,90),(56,85),(58,80),(60,75),(62,70),(64,65),(66,60),(68,55),(70,50),(74,40),(78,30),(84,15),(90,0)])),
            EventCurve(id: "farmer400m106", displayName: "Farmer Carry 400 m (2 × 53 lb)", unit: "seconds", direction: .lowerIsBetter,
                       anchors: anchors([(150,100),(165,95),(180,90),(195,85),(210,80),(225,75),(240,70),(255,65),(270,60),(285,55),(300,50),(330,40),(360,30),(420,15),(480,0)])),
            EventCurve(id: "pullUps", displayName: "Pull-Ups", unit: "reps", direction: .higherIsBetter,
                       anchors: anchors([(0,0),(2,10),(4,20),(6,35),(8,50),(10,60),(12,70),(14,80),(16,88),(18,94),(20,100)])),
            EventCurve(id: "pushUps2m", displayName: "Push-Ups (2 min)", unit: "reps", direction: .higherIsBetter,
                       anchors: anchors([(0,0),(20,20),(30,35),(40,50),(50,60),(60,70),(70,80),(80,90),(90,95),(100,100)])),
            EventCurve(id: "hrPushUps2m", displayName: "Hand-Release Push-Ups (2 min)", unit: "reps", direction: .higherIsBetter,
                       anchors: anchors([(0,0),(10,15),(20,30),(30,45),(40,60),(45,70),(50,80),(55,90),(60,95),(65,100)])),
            EventCurve(id: "sitUps2m", displayName: "Sit-Ups (2 min)", unit: "reps", direction: .higherIsBetter,
                       anchors: anchors([(0,0),(20,20),(30,35),(40,50),(50,60),(60,70),(70,80),(80,90),(90,95),(100,100)])),
            EventCurve(id: "plank", displayName: "Plank", unit: "seconds", direction: .higherIsBetter,
                       anchors: anchors([(0,0),(60,25),(90,40),(120,55),(150,65),(180,75),(210,85),(240,92),(270,97),(300,100)])),
            EventCurve(id: "armyFitnessTotal", displayName: "Army Fitness Test Total", unit: "points", direction: .higherIsBetter,
                       anchors: anchors([(0,0),(300,50),(360,60),(420,70),(480,80),(540,90),(570,95),(600,100)])),
            EventCurve(id: "waterConfidence", displayName: "Water Confidence", unit: "pass/fail", direction: .binary,
                       anchors: anchors([(0,0),(1,100)]))
        ]
        return Dictionary(uniqueKeysWithValues: list.map { ($0.id, $0) })
    }()

    static let benchmarks: [ReadinessBenchmark] = [
        ReadinessBenchmark(id: "waterOperations", displayName: "Water Operations Benchmark", events: [
            .init(eventID: "swim500yd", weight: 0.30),
            .init(eventID: "pullUps", weight: 0.20),
            .init(eventID: "pushUps2m", weight: 0.15),
            .init(eventID: "sitUps2m", weight: 0.10),
            .init(eventID: "run1_5mi", weight: 0.25)
        ]),
        ReadinessBenchmark(id: "lightInfantry", displayName: "Light Infantry Benchmark", events: [
            .init(eventID: "run5mi", weight: 0.30),
            .init(eventID: "ruck12mi45", weight: 0.35),
            .init(eventID: "pullUps", weight: 0.15),
            .init(eventID: "hrPushUps2m", weight: 0.10),
            .init(eventID: "plank", weight: 0.10)
        ]),
        ReadinessBenchmark(id: "specialOperations", displayName: "Special Operations Benchmark", events: [
            .init(eventID: "armyFitnessTotal", weight: 0.25),
            .init(eventID: "run5mi", weight: 0.20),
            .init(eventID: "ruck12mi45", weight: 0.25),
            .init(eventID: "pullUps", weight: 0.15),
            .init(eventID: "waterConfidence", weight: 0.15)
        ]),
        ReadinessBenchmark(id: "tacticalMobility", displayName: "Tactical Mobility Benchmark", events: [
            .init(eventID: "run1_5mi", weight: 0.20),
            .init(eventID: "swim1000m", weight: 0.20),
            .init(eventID: "pullUps", weight: 0.15),
            .init(eventID: "pushUps2m", weight: 0.15),
            .init(eventID: "sitUps2m", weight: 0.15),
            .init(eventID: "shuttle300yd", weight: 0.15)
        ]),
        ReadinessBenchmark(id: "reconnaissance", displayName: "Reconnaissance Benchmark", events: [
            .init(eventID: "run3mi", weight: 0.25),
            .init(eventID: "ruck10mi45", weight: 0.30),
            .init(eventID: "pullUps", weight: 0.15),
            .init(eventID: "pushUps2m", weight: 0.10),
            .init(eventID: "plank", weight: 0.10),
            .init(eventID: "farmer400m106", weight: 0.10)
        ])
    ]
}
