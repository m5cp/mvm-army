import Foundation

// Proprietary app scoring model.
// These are not official military scoring tables or selection criteria.

enum ScoreDirection: String, Codable {
    case higherIsBetter
    case lowerIsBetter
    case binary
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

    func score(for performance: Double) -> Double {
        guard !anchors.isEmpty else { return 0 }

        if direction == .binary {
            return performance >= 1 ? 100 : 0
        }

        let ordered = anchors.sorted { $0.performance < $1.performance }

        if performance <= ordered[0].performance {
            return direction == .higherIsBetter ? ordered[0].score : ordered[0].score
        }
        if performance >= ordered[ordered.count - 1].performance {
            return direction == .higherIsBetter
                ? ordered[ordered.count - 1].score
                : ordered[ordered.count - 1].score
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

    func totalScore(
        results: [String: Double],
        curves: [String: EventCurve]
    ) -> Double? {
        guard events.allSatisfy({ results[$0.eventID] != nil && curves[$0.eventID] != nil }) else {
            return nil
        }

        let total = events.reduce(0.0) { partial, item in
            guard let raw = results[item.eventID],
                  let curve = curves[item.eventID] else { return partial }
            return partial + curve.score(for: raw) * item.weight
        }

        return max(0, min(100, total))
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
            EventCurve(id: "ruck12mi45", displayName: "12-Mile Ruck (45 lb)", unit: "seconds", direction: .lowerIsBetter,
                       anchors: anchors([(8100,100),(8400,97),(8700,94),(9000,90),(9300,86),(9600,82),(9900,78),(10200,74),(10500,70),(10800,65),(11100,60),(11400,50),(11700,40),(12000,30),(12600,0)])),
            EventCurve(id: "ruck10mi45", displayName: "10-Mile Ruck (45 lb)", unit: "seconds", direction: .lowerIsBetter,
                       anchors: anchors([(6600,100),(6900,96),(7200,92),(7500,88),(7800,84),(8100,80),(8400,75),(8700,70),(9000,65),(9300,60),(9600,50),(9900,40),(10200,30),(10800,10),(11400,0)])),
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
