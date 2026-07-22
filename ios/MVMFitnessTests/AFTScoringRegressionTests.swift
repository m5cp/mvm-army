import Testing
import Foundation
@testable import MVMFitness

@Suite("AFT scoring table regression — official Jun 2025 scales")
struct AFTScoringRegressionTests {

    private func loadEngine() throws -> AFTScoringEngine {
        // Mirror the loading approach used in MVMFitnessTests.swift
        guard let url = Bundle(for: BundleToken.self).url(forResource: "aft_scoring_2025_06_01", withExtension: "json") else {
            throw TestError.missingFile
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(AFTScoreFile.self, from: data)
        #expect(decoded.entries.count == 10100, "Scoring table must contain exactly 10,100 entries")
        return AFTScoringEngine(entries: decoded.entries)
    }

    @Test func knownCellsMatchOfficialTables() throws {
        let e = try loadEngine()
        // MDL — male 17-21: 340 lbs = 100 pts, 150 lbs = 60 pts
        #expect(e.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 340) == 100)
        #expect(e.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 150) == 60)
        // MDL — female 17-21: 220 = 100 pts, 120 = 60 pts
        #expect(e.score(event: .mdl, age: 20, sex: .female, standard: .general, rawValue: 220) == 100)
        #expect(e.score(event: .mdl, age: 20, sex: .female, standard: .general, rawValue: 120) == 60)
        // MDL — male 37-41: 140 = 60 pts
        #expect(e.score(event: .mdl, age: 39, sex: .male, standard: .general, rawValue: 140) == 60)
        // HRP — male 17-21: 58 reps = 100 pts, 15 reps = 60 pts
        #expect(e.score(event: .hrp, age: 18, sex: .male, standard: .general, rawValue: 58) == 100)
        #expect(e.score(event: .hrp, age: 18, sex: .male, standard: .general, rawValue: 15) == 60)
        // SDC — female 17-21: 1:55 (115s) = 100 pts
        #expect(e.score(event: .sdc, age: 20, sex: .female, standard: .general, rawValue: 115) == 100)
        // SDC — male 17-21: 2:28 (148s) = 60 pts
        #expect(e.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 148) == 60)
        // PLK — 17-21 (all columns): 3:40 (220s) = 100 pts, 1:30 (90s) = 60 pts
        #expect(e.score(event: .plk, age: 20, sex: .male, standard: .general, rawValue: 220) == 100)
        #expect(e.score(event: .plk, age: 20, sex: .male, standard: .general, rawValue: 90) == 60)
        // 2MR — male 17-21: 13:22 (802s) = 100 pts, 19:57 (1197s) = 60 pts
        #expect(e.score(event: .run2mi, age: 20, sex: .male, standard: .general, rawValue: 802) == 100)
        #expect(e.score(event: .run2mi, age: 20, sex: .male, standard: .general, rawValue: 1197) == 60)
        // 2MR — male 37-41: 20:44 (1244s) = 60 pts
        #expect(e.score(event: .run2mi, age: 39, sex: .male, standard: .general, rawValue: 1244) == 60)
        // Combat column equals male scale (sex-neutral)
        #expect(e.score(event: .mdl, age: 20, sex: .female, standard: .combat, rawValue: 340) == 100)
    }

    @Test func standardsMinimums() {
        #expect(AFTStandard.combat.minimumTotal == 350)
        #expect(AFTStandard.general.minimumTotal == 300)
        #expect(AFTStandard.combat.minimumPerEvent == 60)
        #expect(AFTStandard.general.minimumPerEvent == 60)
    }
}

private enum TestError: Error {
    case missingFile
}

private final class BundleToken {}
