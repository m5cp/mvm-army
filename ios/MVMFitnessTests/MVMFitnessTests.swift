import Testing
@testable import MVMFitness

struct AFTScoringEngineTests {

    private func makeEngine() throws -> AFTScoringEngine {
        guard let url = Bundle(for: BundleToken.self).url(forResource: "aft_scoring_2025_06_01", withExtension: "json") else {
            throw TestError.missingFile
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(AFTScoreFile.self, from: data)
        return AFTScoringEngine(entries: decoded.entries)
    }

    // MARK: - MDL (Higher is better)

    @Test func mdl17to21Male100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 340)
        #expect(pts == 100)
    }

    @Test func mdl17to21Male60() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 150)
        #expect(pts == 60)
    }

    @Test func mdl17to21Female100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 20, sex: .female, standard: .general, rawValue: 220)
        #expect(pts == 100)
    }

    @Test func mdl17to21Female60() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 20, sex: .female, standard: .general, rawValue: 120)
        #expect(pts == 60)
    }

    @Test func mdl22to26Male100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 25, sex: .male, standard: .general, rawValue: 350)
        #expect(pts == 100)
    }

    @Test func mdl32to36Male60() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 34, sex: .male, standard: .general, rawValue: 140)
        #expect(pts == 60)
    }

    @Test func mdlOver62Male100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 65, sex: .male, standard: .general, rawValue: 230)
        #expect(pts == 100)
    }

    @Test func mdlOver62Female100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 65, sex: .female, standard: .general, rawValue: 170)
        #expect(pts == 100)
    }

    @Test func mdlBelowMinReturnsZero() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 80)
        #expect(pts == 0)
    }

    @Test func mdlAboveMaxCaps100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 400)
        #expect(pts == 100)
    }

    @Test func mdl52to56Male100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 55, sex: .male, standard: .general, rawValue: 330)
        #expect(pts == 100)
    }

    @Test func mdl57to61Male100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 60, sex: .male, standard: .general, rawValue: 250)
        #expect(pts == 100)
    }

    // MARK: - HRP (Higher is better)

    @Test func hrp17to21Male100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .hrp, age: 20, sex: .male, standard: .general, rawValue: 58)
        #expect(pts == 100)
    }

    @Test func hrp17to21Male60() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .hrp, age: 20, sex: .male, standard: .general, rawValue: 15)
        #expect(pts == 60)
    }

    @Test func hrp17to21Female100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .hrp, age: 20, sex: .female, standard: .general, rawValue: 53)
        #expect(pts == 100)
    }

    @Test func hrp22to26Male100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .hrp, age: 25, sex: .male, standard: .general, rawValue: 61)
        #expect(pts == 100)
    }

    @Test func hrpOver62Male100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .hrp, age: 65, sex: .male, standard: .general, rawValue: 43)
        #expect(pts == 100)
    }

    @Test func hrpOver62Female60() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .hrp, age: 65, sex: .female, standard: .general, rawValue: 10)
        #expect(pts == 60)
    }

    @Test func hrp40reps17to21Male() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .hrp, age: 20, sex: .male, standard: .general, rawValue: 40)
        #expect(pts == 84)
    }

    // MARK: - SDC (Lower is better)

    @Test func sdc17to21Male100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 89)
        #expect(pts == 100)
    }

    @Test func sdc17to21Male60() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 148)
        #expect(pts == 60)
    }

    @Test func sdc17to21Female100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .sdc, age: 20, sex: .female, standard: .general, rawValue: 115)
        #expect(pts == 100)
    }

    @Test func sdcFasterThanMaxScores100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 70)
        #expect(pts == 100)
    }

    @Test func sdcSlowerThanMinScores0() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 300)
        #expect(pts == 0)
    }

    @Test func sdcOver62Male100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .sdc, age: 65, sex: .male, standard: .general, rawValue: 129)
        #expect(pts == 100)
    }

    // MARK: - PLK (Higher is better)

    @Test func plk17to21MaleAndFemale100() throws {
        let engine = try makeEngine()
        let ptsM = engine.score(event: .plk, age: 20, sex: .male, standard: .general, rawValue: 220)
        let ptsF = engine.score(event: .plk, age: 20, sex: .female, standard: .general, rawValue: 220)
        #expect(ptsM == 100)
        #expect(ptsF == 100)
    }

    @Test func plk17to21Male60() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .plk, age: 20, sex: .male, standard: .general, rawValue: 90)
        #expect(pts == 60)
    }

    @Test func plkOver62SameAsMidAge() throws {
        let engine = try makeEngine()
        let ptsOld = engine.score(event: .plk, age: 65, sex: .male, standard: .general, rawValue: 200)
        let ptsMid = engine.score(event: .plk, age: 45, sex: .male, standard: .general, rawValue: 200)
        #expect(ptsOld == 100)
        #expect(ptsMid == 100)
    }

    @Test func plk37to41Male60() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .plk, age: 40, sex: .male, standard: .general, rawValue: 70)
        #expect(pts == 60)
    }

    // MARK: - 2MR (Lower is better)

    @Test func run2mi17to21Male100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .run2mi, age: 20, sex: .male, standard: .general, rawValue: 802)
        #expect(pts == 100)
    }

    @Test func run2mi17to21Male60() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .run2mi, age: 20, sex: .male, standard: .general, rawValue: 1197)
        #expect(pts == 60)
    }

    @Test func run2mi17to21Female100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .run2mi, age: 20, sex: .female, standard: .general, rawValue: 960)
        #expect(pts == 100)
    }

    @Test func run2miOver62Female60() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .run2mi, age: 65, sex: .female, standard: .general, rawValue: 1500)
        #expect(pts == 60)
    }

    @Test func run2miFasterThanMaxScores100() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .run2mi, age: 20, sex: .male, standard: .general, rawValue: 700)
        #expect(pts == 100)
    }

    // MARK: - Combat Standard

    @Test func combatIgnoresSex() throws {
        let engine = try makeEngine()
        let ptsMale = engine.score(event: .mdl, age: 25, sex: .male, standard: .combat, rawValue: 300)
        let ptsFemale = engine.score(event: .mdl, age: 25, sex: .female, standard: .combat, rawValue: 300)
        #expect(ptsMale == ptsFemale)
    }

    @Test func combatMDL17to21() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 20, sex: .male, standard: .combat, rawValue: 340)
        #expect(pts == 100)
    }

    @Test func combatHRP22to26() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .hrp, age: 25, sex: .female, standard: .combat, rawValue: 61)
        #expect(pts == 100)
    }

    @Test func combatSDC17to21() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .sdc, age: 20, sex: .female, standard: .combat, rawValue: 89)
        #expect(pts == 100)
    }

    @Test func combatColumnUsedNotMaleOrFemale() throws {
        let engine = try makeEngine()
        let ptsGenF = engine.score(event: .mdl, age: 20, sex: .female, standard: .general, rawValue: 220)
        let ptsCombatF = engine.score(event: .mdl, age: 20, sex: .female, standard: .combat, rawValue: 220)
        #expect(ptsGenF == 100)
        #expect(ptsCombatF == 75)
    }

    // MARK: - Pass/Fail Evaluation

    @Test func generalPassAllEventsAbove60() throws {
        let engine = try makeEngine()
        let result = engine.evaluate(
            age: 25,
            sex: .male,
            standard: .general,
            mdl: 200,
            hrp: 30,
            sdcSeconds: 130,
            plkSeconds: 150,
            run2miSeconds: 1000
        )
        #expect(result.passedEvents == true)
        #expect(result.minimumTotalRequired == 300)
        #expect(result.total >= 300)
        #expect(result.passedOverall == true)
    }

    @Test func generalFailOneEventBelow60() throws {
        let engine = try makeEngine()
        let result = engine.evaluate(
            age: 25,
            sex: .male,
            standard: .general,
            mdl: 100,
            hrp: 50,
            sdcSeconds: 100,
            plkSeconds: 200,
            run2miSeconds: 900
        )
        #expect(result.eventScores[.mdl]! < 60)
        #expect(result.passedEvents == false)
        #expect(result.passedOverall == false)
    }

    @Test func combatPass350Total() throws {
        let engine = try makeEngine()
        let result = engine.evaluate(
            age: 25,
            sex: .male,
            standard: .combat,
            mdl: 300,
            hrp: 40,
            sdcSeconds: 110,
            plkSeconds: 180,
            run2miSeconds: 900
        )
        #expect(result.minimumTotalRequired == 350)
        if result.total >= 350 && result.passedEvents {
            #expect(result.passedOverall == true)
        }
    }

    @Test func combatFailTotalBelow350() throws {
        let engine = try makeEngine()
        let result = engine.evaluate(
            age: 25,
            sex: .male,
            standard: .combat,
            mdl: 150,
            hrp: 14,
            sdcSeconds: 151,
            plkSeconds: 85,
            run2miSeconds: 1185
        )
        #expect(result.minimumTotalRequired == 350)
        #expect(result.eventScores.values.allSatisfy { $0 >= 60 })
        #expect(result.total < 350)
        #expect(result.passedTotal == false)
        #expect(result.passedOverall == false)
    }

    @Test func generalFemalePass() throws {
        let engine = try makeEngine()
        let result = engine.evaluate(
            age: 25,
            sex: .female,
            standard: .general,
            mdl: 180,
            hrp: 35,
            sdcSeconds: 140,
            plkSeconds: 180,
            run2miSeconds: 1000
        )
        #expect(result.minimumTotalRequired == 300)
        #expect(result.passedEvents == true)
        #expect(result.total >= 300)
        #expect(result.passedOverall == true)
    }

    // MARK: - Age Band Boundaries

    @Test func ageBandBoundaries() throws {
        let engine = try makeEngine()
        let pts17 = engine.score(event: .mdl, age: 17, sex: .male, standard: .general, rawValue: 340)
        let pts21 = engine.score(event: .mdl, age: 21, sex: .male, standard: .general, rawValue: 340)
        let pts22 = engine.score(event: .mdl, age: 22, sex: .male, standard: .general, rawValue: 340)
        #expect(pts17 == 100)
        #expect(pts21 == 100)
        #expect(pts22 == 98)
    }

    @Test func ageBand62Plus() throws {
        let engine = try makeEngine()
        let pts62 = engine.score(event: .mdl, age: 62, sex: .male, standard: .general, rawValue: 230)
        let pts70 = engine.score(event: .mdl, age: 70, sex: .male, standard: .general, rawValue: 230)
        #expect(pts62 == 100)
        #expect(pts70 == 100)
    }

    // MARK: - Threshold Matching (No Interpolation)

    @Test func thresholdMatchingHigherIsBetter() throws {
        let engine = try makeEngine()
        let pts149 = engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 149)
        let pts150 = engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 150)
        let pts151 = engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 151)
        #expect(pts149 == 0)
        #expect(pts150 == 60)
        #expect(pts151 == 60)
    }

    @Test func thresholdMatchingLowerIsBetter() throws {
        let engine = try makeEngine()
        let pts147 = engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 147)
        let pts148 = engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 148)
        let pts149 = engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 149)
        #expect(pts147 >= 60)
        #expect(pts148 == 60)
        #expect(pts149 == 0)
    }

    // MARK: - All Age Groups Have Data

    @Test func allAgeBandsHaveData() throws {
        let engine = try makeEngine()
        let ages = [20, 25, 30, 35, 40, 45, 50, 55, 60, 65]
        let events: [AFTEventType] = [.mdl, .hrp, .sdc, .plk, .run2mi]

        for age in ages {
            for event in events {
                let band = AFTScoringEngine.ageBand(from: age)
                let mEntries = engine.entries(for: event, ageBand: band, column: .male)
                let cEntries = engine.entries(for: event, ageBand: band, column: .combat)
                let fEntries = engine.entries(for: event, ageBand: band, column: .female)
                #expect(!mEntries.isEmpty, "Missing M entries for \(event) age \(age)")
                #expect(!cEntries.isEmpty, "Missing C entries for \(event) age \(age)")
                #expect(!fEntries.isEmpty, "Missing F entries for \(event) age \(age)")
            }
        }
    }

    // MARK: - Score Column Selection

    @Test func generalMaleUsesM() throws {
        let engine = try makeEngine()
        let col = engine.scoreColumn(standard: .general, sex: .male)
        #expect(col == .male)
    }

    @Test func generalFemaleUsesF() throws {
        let engine = try makeEngine()
        let col = engine.scoreColumn(standard: .general, sex: .female)
        #expect(col == .female)
    }

    @Test func combatMaleUsesC() throws {
        let engine = try makeEngine()
        let col = engine.scoreColumn(standard: .combat, sex: .male)
        #expect(col == .combat)
    }

    @Test func combatFemaleUsesC() throws {
        let engine = try makeEngine()
        let col = engine.scoreColumn(standard: .combat, sex: .female)
        #expect(col == .combat)
    }

    // MARK: - Direction Logic

    @Test func directionLogic() throws {
        let engine = try makeEngine()
        #expect(engine.direction(for: .mdl) == .higherIsBetter)
        #expect(engine.direction(for: .hrp) == .higherIsBetter)
        #expect(engine.direction(for: .plk) == .higherIsBetter)
        #expect(engine.direction(for: .sdc) == .lowerIsBetter)
        #expect(engine.direction(for: .run2mi) == .lowerIsBetter)
    }

    // MARK: - Minimum Total Requirements

    @Test func minimumTotalRequirements() throws {
        let engine = try makeEngine()
        #expect(engine.minimumTotal(for: .general) == 300)
        #expect(engine.minimumTotal(for: .combat) == 350)
    }

    // MARK: - PLK Same For M/C/F

    @Test func plkIdenticalAcrossColumns() throws {
        let engine = try makeEngine()
        let ptsM = engine.score(event: .plk, age: 30, sex: .male, standard: .general, rawValue: 180)
        let ptsC = engine.score(event: .plk, age: 30, sex: .male, standard: .combat, rawValue: 180)
        let ptsF = engine.score(event: .plk, age: 30, sex: .female, standard: .general, rawValue: 180)
        #expect(ptsM == ptsC)
        #expect(ptsM == ptsF)
    }

    // MARK: - Specific Known Values Cross-Check

    @Test func specificKnownValues() throws {
        let engine = try makeEngine()

        #expect(engine.score(event: .hrp, age: 25, sex: .male, standard: .general, rawValue: 57) == 98)
        #expect(engine.score(event: .hrp, age: 30, sex: .female, standard: .general, rawValue: 48) == 100)
        #expect(engine.score(event: .sdc, age: 35, sex: .male, standard: .general, rawValue: 93) == 100)
        #expect(engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: 805) == 100)
        #expect(engine.score(event: .run2mi, age: 25, sex: .female, standard: .general, rawValue: 930) == 100)
    }
}

private enum TestError: Error {
    case missingFile
}

private final class BundleToken {}
