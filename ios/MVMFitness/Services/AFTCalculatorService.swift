import Foundation

enum AFTCalculatorService {

    static func calculate(
        soldierName: String,
        age: Int,
        sex: SoldierSex,
        standard: AFTStandard,
        deadliftLbs: Int,
        pushUpReps: Int,
        sdcSeconds: Int,
        plankSeconds: Int,
        runSeconds: Int
    ) -> AFTCalculatorResult {
        let dlPts = scoreDeadlift(lbs: deadliftLbs, age: age, sex: sex)
        let puPts = scorePushUp(reps: pushUpReps, age: age, sex: sex)
        let sdcPts = scoreSDC(seconds: sdcSeconds, age: age, sex: sex)
        let plkPts = scorePlank(seconds: plankSeconds, age: age, sex: sex)
        let runPts = scoreRun(seconds: runSeconds, age: age, sex: sex)

        let total = dlPts + puPts + sdcPts + plkPts + runPts

        let eventScores: [(String, Int)] = [
            ("MDL", dlPts),
            ("HRP", puPts),
            ("SDC", sdcPts),
            ("PLK", plkPts),
            ("2MR", runPts)
        ]
        let weakest = eventScores.sorted { $0.1 < $1.1 }.prefix(2).map(\.0)

        let minPerEvent = standard.minimumPerEvent
        let minTotal = standard.minimumTotal
        let allEventsPassed = eventScores.allSatisfy { $0.1 >= minPerEvent }
        let passed = allEventsPassed && total >= minTotal

        return AFTCalculatorResult(
            soldierName: soldierName,
            age: age,
            sex: sex,
            standard: standard,
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
            passed: passed,
            weakestEvents: weakest
        )
    }

    // MARK: - Placeholder Scoring

    static func scoreDeadlift(lbs: Int, age: Int, sex: SoldierSex) -> Int {
        let (minVal, maxVal): (Double, Double) = sex == .male ? (140, 340) : (120, 210)
        return linearScale(value: Double(lbs), min: minVal, max: maxVal)
    }

    static func scorePushUp(reps: Int, age: Int, sex: SoldierSex) -> Int {
        let (minVal, maxVal): (Double, Double) = sex == .male ? (10, 60) : (10, 40)
        return linearScale(value: Double(reps), min: minVal, max: maxVal)
    }

    static func scoreSDC(seconds: Int, age: Int, sex: SoldierSex) -> Int {
        let (best, worst): (Double, Double) = sex == .male ? (93, 210) : (114, 250)
        return inverseScale(value: Double(seconds), best: best, worst: worst)
    }

    static func scorePlank(seconds: Int, age: Int, sex: SoldierSex) -> Int {
        let (minVal, maxVal): (Double, Double) = (60, 240)
        return linearScale(value: Double(seconds), min: minVal, max: maxVal)
    }

    static func scoreRun(seconds: Int, age: Int, sex: SoldierSex) -> Int {
        let (best, worst): (Double, Double) = sex == .male ? (810, 1320) : (870, 1560)
        return inverseScale(value: Double(seconds), best: best, worst: worst)
    }

    // MARK: - Helpers

    private static func linearScale(value: Double, min: Double, max: Double) -> Int {
        guard value >= min else { return 0 }
        guard value < max else { return 100 }
        return Int(((value - min) / (max - min) * 100).rounded())
    }

    private static func inverseScale(value: Double, best: Double, worst: Double) -> Int {
        guard value <= worst else { return 0 }
        guard value > best else { return 100 }
        return Int(((worst - value) / (worst - best) * 100).rounded())
    }

    static func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
