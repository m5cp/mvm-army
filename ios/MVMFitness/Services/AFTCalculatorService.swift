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
        let dlPts = AFTScoringTables.scoreDeadlift(lbs: deadliftLbs, age: age, sex: sex, standard: standard)
        let puPts = AFTScoringTables.scorePushUp(reps: pushUpReps, age: age, sex: sex, standard: standard)
        let sdcPts = AFTScoringTables.scoreSDC(seconds: sdcSeconds, age: age, sex: sex, standard: standard)
        let plkPts = AFTScoringTables.scorePlank(seconds: plankSeconds, age: age, sex: sex, standard: standard)
        let runPts = AFTScoringTables.scoreRun(seconds: runSeconds, age: age, sex: sex, standard: standard)

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

    static func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
