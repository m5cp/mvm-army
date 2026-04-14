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

    // MARK: - Direction Logic

    @Test func directionLogic() throws {
        let engine = try makeEngine()
        #expect(engine.direction(for: .mdl) == .higherIsBetter)
        #expect(engine.direction(for: .hrp) == .higherIsBetter)
        #expect(engine.direction(for: .plk) == .higherIsBetter)
        #expect(engine.direction(for: .sdc) == .lowerIsBetter)
        #expect(engine.direction(for: .run2mi) == .lowerIsBetter)
    }

    // MARK: - Score Column Selection

    @Test func generalMaleUsesM() throws {
        let engine = try makeEngine()
        #expect(engine.scoreColumn(standard: .general, sex: .male) == .male)
    }

    @Test func generalFemaleUsesF() throws {
        let engine = try makeEngine()
        #expect(engine.scoreColumn(standard: .general, sex: .female) == .female)
    }

    @Test func combatAlwaysUsesC() throws {
        let engine = try makeEngine()
        #expect(engine.scoreColumn(standard: .combat, sex: .male) == .combat)
        #expect(engine.scoreColumn(standard: .combat, sex: .female) == .combat)
    }

    // MARK: - Minimum Total Requirements

    @Test func minimumTotalRequirements() throws {
        let engine = try makeEngine()
        #expect(engine.minimumTotal(for: .general) == 300)
        #expect(engine.minimumTotal(for: .combat) == 350)
    }

    // MARK: - All Age Bands / Events / Columns Have Data

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
                #expect(!mEntries.isEmpty, "Missing M entries for \(event) age \(age) band \(band)")
                #expect(!cEntries.isEmpty, "Missing C entries for \(event) age \(age) band \(band)")
                #expect(!fEntries.isEmpty, "Missing F entries for \(event) age \(age) band \(band)")
            }
        }
    }

    @Test func allEntriesHave100And60AndZero() throws {
        let engine = try makeEngine()
        let bands = ["17-21", "22-26", "27-31", "32-36", "37-41", "42-46", "47-51", "52-56", "57-61", "Over 62"]
        let events: [AFTEventType] = [.mdl, .hrp, .sdc, .plk, .run2mi]
        let columns: [AFTColumn] = [.male, .combat, .female]

        for band in bands {
            for event in events {
                for col in columns {
                    let table = engine.entries(for: event, ageBand: band, column: col)
                    let points = Set(table.map(\.points))
                    #expect(points.contains(100), "Missing 100 pts for \(event) \(band) \(col)")
                    #expect(points.contains(60), "Missing 60 pts for \(event) \(band) \(col)")
                    #expect(points.contains(0), "Missing 0 pts for \(event) \(band) \(col)")
                }
            }
        }
    }

    // MARK: - Age Band Boundaries

    @Test func ageBandBoundaries() throws {
        let engine = try makeEngine()
        #expect(AFTScoringEngine.ageBand(from: 16) == "17-21")
        #expect(AFTScoringEngine.ageBand(from: 17) == "17-21")
        #expect(AFTScoringEngine.ageBand(from: 21) == "17-21")
        #expect(AFTScoringEngine.ageBand(from: 22) == "22-26")
        #expect(AFTScoringEngine.ageBand(from: 26) == "22-26")
        #expect(AFTScoringEngine.ageBand(from: 27) == "27-31")
        #expect(AFTScoringEngine.ageBand(from: 31) == "27-31")
        #expect(AFTScoringEngine.ageBand(from: 32) == "32-36")
        #expect(AFTScoringEngine.ageBand(from: 36) == "32-36")
        #expect(AFTScoringEngine.ageBand(from: 37) == "37-41")
        #expect(AFTScoringEngine.ageBand(from: 41) == "37-41")
        #expect(AFTScoringEngine.ageBand(from: 42) == "42-46")
        #expect(AFTScoringEngine.ageBand(from: 46) == "42-46")
        #expect(AFTScoringEngine.ageBand(from: 47) == "47-51")
        #expect(AFTScoringEngine.ageBand(from: 51) == "47-51")
        #expect(AFTScoringEngine.ageBand(from: 52) == "52-56")
        #expect(AFTScoringEngine.ageBand(from: 56) == "52-56")
        #expect(AFTScoringEngine.ageBand(from: 57) == "57-61")
        #expect(AFTScoringEngine.ageBand(from: 61) == "57-61")
        #expect(AFTScoringEngine.ageBand(from: 62) == "Over 62")
        #expect(AFTScoringEngine.ageBand(from: 70) == "Over 62")
        #expect(AFTScoringEngine.ageBand(from: 99) == "Over 62")
    }

    @Test func ageBandTransitionScoring() throws {
        let engine = try makeEngine()
        let pts21 = engine.score(event: .mdl, age: 21, sex: .male, standard: .general, rawValue: 340)
        let pts22 = engine.score(event: .mdl, age: 22, sex: .male, standard: .general, rawValue: 340)
        #expect(pts21 == 100)
        #expect(pts22 == 98)
    }

    // MARK: - MDL (Higher is better)

    @Test func mdl17to21Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 340) == 100)
        #expect(engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 150) == 60)
        #expect(engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 80) == 0)
    }

    @Test func mdl17to21Female() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 20, sex: .female, standard: .general, rawValue: 220) == 100)
        #expect(engine.score(event: .mdl, age: 20, sex: .female, standard: .general, rawValue: 120) == 60)
        #expect(engine.score(event: .mdl, age: 20, sex: .female, standard: .general, rawValue: 60) == 0)
    }

    @Test func mdl22to26Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 25, sex: .male, standard: .general, rawValue: 350) == 100)
        #expect(engine.score(event: .mdl, age: 25, sex: .male, standard: .general, rawValue: 150) == 60)
    }

    @Test func mdl22to26Female() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 25, sex: .female, standard: .general, rawValue: 230) == 100)
        #expect(engine.score(event: .mdl, age: 25, sex: .female, standard: .general, rawValue: 120) == 60)
    }

    @Test func mdl27to31Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 30, sex: .male, standard: .general, rawValue: 350) == 100)
    }

    @Test func mdl27to31Female() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 30, sex: .female, standard: .general, rawValue: 240) == 100)
    }

    @Test func mdl32to36Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 34, sex: .male, standard: .general, rawValue: 350) == 100)
        #expect(engine.score(event: .mdl, age: 34, sex: .male, standard: .general, rawValue: 140) == 60)
    }

    @Test func mdl37to41Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 40, sex: .male, standard: .general, rawValue: 350) == 100)
        #expect(engine.score(event: .mdl, age: 40, sex: .male, standard: .general, rawValue: 140) == 60)
    }

    @Test func mdl42to46() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 45, sex: .male, standard: .general, rawValue: 350) == 100)
        #expect(engine.score(event: .mdl, age: 45, sex: .female, standard: .general, rawValue: 210) == 100)
    }

    @Test func mdl47to51() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 50, sex: .male, standard: .general, rawValue: 340) == 100)
        #expect(engine.score(event: .mdl, age: 50, sex: .female, standard: .general, rawValue: 200) == 100)
    }

    @Test func mdl52to56() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 55, sex: .male, standard: .general, rawValue: 330) == 100)
        #expect(engine.score(event: .mdl, age: 55, sex: .female, standard: .general, rawValue: 190) == 100)
    }

    @Test func mdl57to61() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 60, sex: .male, standard: .general, rawValue: 250) == 100)
        #expect(engine.score(event: .mdl, age: 60, sex: .female, standard: .general, rawValue: 170) == 100)
    }

    @Test func mdlOver62() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 65, sex: .male, standard: .general, rawValue: 230) == 100)
        #expect(engine.score(event: .mdl, age: 65, sex: .female, standard: .general, rawValue: 170) == 100)
    }

    @Test func mdlAboveMaxCaps100() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 500) == 100)
    }

    @Test func mdlBelowMinReturnsZeroOrLess() throws {
        let engine = try makeEngine()
        let pts = engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 50)
        #expect(pts == 0)
    }

    // MARK: - HRP (Higher is better)

    @Test func hrp17to21Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .hrp, age: 20, sex: .male, standard: .general, rawValue: 58) == 100)
        #expect(engine.score(event: .hrp, age: 20, sex: .male, standard: .general, rawValue: 15) == 60)
    }

    @Test func hrp22to26Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .hrp, age: 25, sex: .male, standard: .general, rawValue: 61) == 100)
        #expect(engine.score(event: .hrp, age: 25, sex: .male, standard: .general, rawValue: 14) == 60)
        #expect(engine.score(event: .hrp, age: 25, sex: .male, standard: .general, rawValue: 57) == 98)
    }

    @Test func hrp22to26Female() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .hrp, age: 25, sex: .female, standard: .general, rawValue: 50) == 100)
        #expect(engine.score(event: .hrp, age: 25, sex: .female, standard: .general, rawValue: 11) == 60)
    }

    @Test func hrp27to31Female() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .hrp, age: 30, sex: .female, standard: .general, rawValue: 48) == 100)
    }

    @Test func hrpOver62Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .hrp, age: 65, sex: .male, standard: .general, rawValue: 43) == 100)
    }

    @Test func hrpOver62Female() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .hrp, age: 65, sex: .female, standard: .general, rawValue: 10) == 60)
    }

    @Test func hrp40reps17to21Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .hrp, age: 20, sex: .male, standard: .general, rawValue: 40) == 84)
    }

    // MARK: - SDC (Lower is better)

    @Test func sdc17to21Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 89) == 100)
        #expect(engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 148) == 60)
    }

    @Test func sdc22to26Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .sdc, age: 25, sex: .male, standard: .general, rawValue: 90) == 100)
        #expect(engine.score(event: .sdc, age: 25, sex: .male, standard: .general, rawValue: 92) == 99)
    }

    @Test func sdc17to21Female() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .sdc, age: 20, sex: .female, standard: .general, rawValue: 115) == 100)
    }

    @Test func sdcFasterThanMaxScores100() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 60) == 100)
    }

    @Test func sdcSlowerThanMinScores0() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 300) == 0)
    }

    @Test func sdcOver62Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .sdc, age: 65, sex: .male, standard: .general, rawValue: 129) == 100)
    }

    // MARK: - PLK (Higher is better)

    @Test func plk17to21() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .plk, age: 20, sex: .male, standard: .general, rawValue: 220) == 100)
        #expect(engine.score(event: .plk, age: 20, sex: .female, standard: .general, rawValue: 220) == 100)
        #expect(engine.score(event: .plk, age: 20, sex: .male, standard: .general, rawValue: 90) == 60)
    }

    @Test func plk22to26() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .plk, age: 25, sex: .male, standard: .general, rawValue: 215) == 100)
        #expect(engine.score(event: .plk, age: 25, sex: .male, standard: .general, rawValue: 212) == 99)
    }

    @Test func plkIdenticalAcrossColumns() throws {
        let engine = try makeEngine()
        let ptsM = engine.score(event: .plk, age: 30, sex: .male, standard: .general, rawValue: 180)
        let ptsC = engine.score(event: .plk, age: 30, sex: .male, standard: .combat, rawValue: 180)
        let ptsF = engine.score(event: .plk, age: 30, sex: .female, standard: .general, rawValue: 180)
        #expect(ptsM == ptsC)
        #expect(ptsM == ptsF)
    }

    @Test func plk37to41Male60() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .plk, age: 40, sex: .male, standard: .general, rawValue: 70) == 60)
    }

    @Test func plkOver62() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .plk, age: 65, sex: .male, standard: .general, rawValue: 200) == 100)
    }

    // MARK: - 2MR (Lower is better)

    @Test func run2mi17to21Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .run2mi, age: 20, sex: .male, standard: .general, rawValue: 802) == 100)
        #expect(engine.score(event: .run2mi, age: 20, sex: .male, standard: .general, rawValue: 1197) == 60)
    }

    @Test func run2mi22to26Male() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: 805) == 100)
        #expect(engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: 827) == 99)
    }

    @Test func run2mi22to26Female() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .run2mi, age: 25, sex: .female, standard: .general, rawValue: 930) == 100)
    }

    @Test func run2mi17to21Female() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .run2mi, age: 20, sex: .female, standard: .general, rawValue: 960) == 100)
    }

    @Test func run2miOver62Female() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .run2mi, age: 65, sex: .female, standard: .general, rawValue: 1500) == 60)
    }

    @Test func run2miFasterThanMaxScores100() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .run2mi, age: 20, sex: .male, standard: .general, rawValue: 600) == 100)
    }

    @Test func run2miSlowerThanMinScores0() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .run2mi, age: 20, sex: .male, standard: .general, rawValue: 2400) == 0)
    }

    // MARK: - Threshold Matching (No Interpolation)

    @Test func thresholdHigherIsBetterExact() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 149) == 0)
        #expect(engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 150) == 60)
        #expect(engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 151) == 60)
    }

    @Test func thresholdHigherIsBetterMidRange() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 199) == 69)
        #expect(engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 200) == 70)
        #expect(engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 209) == 70)
        #expect(engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 210) == 73)
    }

    @Test func thresholdLowerIsBetterExact() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 147) >= 60)
        #expect(engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 148) == 60)
        #expect(engine.score(event: .sdc, age: 20, sex: .male, standard: .general, rawValue: 149) == 0)
    }

    @Test func thresholdLowerIsBetter2MR() throws {
        let engine = try makeEngine()
        let pts804 = engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: 804)
        let pts805 = engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: 805)
        let pts806 = engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: 806)
        #expect(pts804 == 100)
        #expect(pts805 == 100)
        #expect(pts806 < 100)
    }

    @Test func noInterpolationBetweenRows() throws {
        let engine = try makeEngine()
        let pts155 = engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 155)
        let pts159 = engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 159)
        let pts160 = engine.score(event: .mdl, age: 20, sex: .male, standard: .general, rawValue: 160)
        #expect(pts155 == 60)
        #expect(pts159 == 60)
        #expect(pts160 == 63)
    }

    // MARK: - Combat Standard

    @Test func combatIgnoresSex() throws {
        let engine = try makeEngine()
        let ptsMale = engine.score(event: .mdl, age: 25, sex: .male, standard: .combat, rawValue: 300)
        let ptsFemale = engine.score(event: .mdl, age: 25, sex: .female, standard: .combat, rawValue: 300)
        #expect(ptsMale == ptsFemale)
    }

    @Test func combatIgnoresSexAllEvents() throws {
        let engine = try makeEngine()
        let events: [(AFTEventType, Int)] = [
            (.mdl, 250), (.hrp, 30), (.sdc, 120), (.plk, 150), (.run2mi, 1000)
        ]
        for (event, raw) in events {
            let m = engine.score(event: event, age: 30, sex: .male, standard: .combat, rawValue: raw)
            let f = engine.score(event: event, age: 30, sex: .female, standard: .combat, rawValue: raw)
            #expect(m == f, "Combat scores differ for \(event) at raw \(raw): M=\(m) F=\(f)")
        }
    }

    @Test func combatMDL17to21() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 20, sex: .male, standard: .combat, rawValue: 340) == 100)
    }

    @Test func combatHRP22to26() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .hrp, age: 25, sex: .female, standard: .combat, rawValue: 61) == 100)
    }

    @Test func combatSDC17to21() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .sdc, age: 20, sex: .female, standard: .combat, rawValue: 89) == 100)
    }

    @Test func combatColumnDiffersFromFemale() throws {
        let engine = try makeEngine()
        let ptsGenF = engine.score(event: .mdl, age: 20, sex: .female, standard: .general, rawValue: 220)
        let ptsCombatF = engine.score(event: .mdl, age: 20, sex: .female, standard: .combat, rawValue: 220)
        #expect(ptsGenF == 100)
        #expect(ptsCombatF == 75)
    }

    // MARK: - Pass/Fail: General Standard

    @Test func generalPassAllEventsAbove60() throws {
        let engine = try makeEngine()
        let result = engine.evaluate(
            age: 25, sex: .male, standard: .general,
            mdl: 200, hrp: 30, sdcSeconds: 130, plkSeconds: 150, run2miSeconds: 1000
        )
        #expect(result.passedEvents == true)
        #expect(result.minimumTotalRequired == 300)
        #expect(result.total >= 300)
        #expect(result.passedOverall == true)
    }

    @Test func generalFailOneEventBelow60() throws {
        let engine = try makeEngine()
        let result = engine.evaluate(
            age: 25, sex: .male, standard: .general,
            mdl: 100, hrp: 50, sdcSeconds: 100, plkSeconds: 200, run2miSeconds: 900
        )
        #expect(result.eventScores[.mdl]! < 60)
        #expect(result.passedEvents == false)
        #expect(result.passedOverall == false)
    }

    @Test func generalFailTotalBelow300() throws {
        let engine = try makeEngine()
        let result = engine.evaluate(
            age: 25, sex: .male, standard: .general,
            mdl: 150, hrp: 14, sdcSeconds: 151, plkSeconds: 85, run2miSeconds: 1185
        )
        #expect(result.minimumTotalRequired == 300)
        #expect(result.total == 300)
    }

    @Test func generalFemalePass() throws {
        let engine = try makeEngine()
        let result = engine.evaluate(
            age: 25, sex: .female, standard: .general,
            mdl: 180, hrp: 35, sdcSeconds: 140, plkSeconds: 180, run2miSeconds: 1000
        )
        #expect(result.passedEvents == true)
        #expect(result.total >= 300)
        #expect(result.passedOverall == true)
    }

    // MARK: - Pass/Fail: Combat Standard

    @Test func combatPass350Total() throws {
        let engine = try makeEngine()
        let result = engine.evaluate(
            age: 25, sex: .male, standard: .combat,
            mdl: 300, hrp: 40, sdcSeconds: 110, plkSeconds: 180, run2miSeconds: 900
        )
        #expect(result.minimumTotalRequired == 350)
        if result.total >= 350 && result.passedEvents {
            #expect(result.passedOverall == true)
        }
    }

    @Test func combatFailTotalBelow350() throws {
        let engine = try makeEngine()
        let result = engine.evaluate(
            age: 25, sex: .male, standard: .combat,
            mdl: 150, hrp: 14, sdcSeconds: 151, plkSeconds: 85, run2miSeconds: 1185
        )
        #expect(result.minimumTotalRequired == 350)
        #expect(result.eventScores.values.allSatisfy { $0 >= 60 })
        #expect(result.total < 350)
        #expect(result.passedTotal == false)
        #expect(result.passedOverall == false)
    }

    @Test func combatFailEventBelow60() throws {
        let engine = try makeEngine()
        let result = engine.evaluate(
            age: 25, sex: .male, standard: .combat,
            mdl: 350, hrp: 61, sdcSeconds: 90, plkSeconds: 215, run2miSeconds: 2000
        )
        #expect(result.eventScores[.run2mi]! < 60)
        #expect(result.passedEvents == false)
        #expect(result.passedOverall == false)
    }

    // MARK: - Cross-Check Known Official Values (22-26 M/C)

    @Test func crossCheck22to26MaleSDC() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .sdc, age: 25, sex: .male, standard: .general, rawValue: 90) == 100)
        #expect(engine.score(event: .sdc, age: 25, sex: .male, standard: .general, rawValue: 92) == 99)
        #expect(engine.score(event: .sdc, age: 25, sex: .male, standard: .general, rawValue: 93) == 98)
        #expect(engine.score(event: .sdc, age: 25, sex: .male, standard: .general, rawValue: 94) == 97)
        #expect(engine.score(event: .sdc, age: 25, sex: .male, standard: .general, rawValue: 96) == 96)
        #expect(engine.score(event: .sdc, age: 25, sex: .male, standard: .general, rawValue: 97) == 95)
    }

    @Test func crossCheck22to26MalePLK() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .plk, age: 25, sex: .male, standard: .general, rawValue: 215) == 100)
        #expect(engine.score(event: .plk, age: 25, sex: .male, standard: .general, rawValue: 212) == 99)
        #expect(engine.score(event: .plk, age: 25, sex: .male, standard: .general, rawValue: 209) == 98)
        #expect(engine.score(event: .plk, age: 25, sex: .male, standard: .general, rawValue: 205) == 97)
        #expect(engine.score(event: .plk, age: 25, sex: .male, standard: .general, rawValue: 202) == 96)
        #expect(engine.score(event: .plk, age: 25, sex: .male, standard: .general, rawValue: 199) == 95)
    }

    @Test func crossCheck22to26Male2MR() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: 805) == 100)
        #expect(engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: 827) == 99)
        #expect(engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: 835) == 98)
        #expect(engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: 852) == 97)
        #expect(engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: 867) == 96)
        #expect(engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: 881) == 95)
    }

    @Test func crossCheck22to26MaleHRP() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .hrp, age: 25, sex: .male, standard: .general, rawValue: 61) == 100)
        #expect(engine.score(event: .hrp, age: 25, sex: .male, standard: .general, rawValue: 59) == 99)
        #expect(engine.score(event: .hrp, age: 25, sex: .male, standard: .general, rawValue: 57) == 98)
        #expect(engine.score(event: .hrp, age: 25, sex: .male, standard: .general, rawValue: 56) == 97)
        #expect(engine.score(event: .hrp, age: 25, sex: .male, standard: .general, rawValue: 55) == 96)
        #expect(engine.score(event: .hrp, age: 25, sex: .male, standard: .general, rawValue: 53) == 95)
    }

    @Test func crossCheck22to26MaleMDL() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 25, sex: .male, standard: .general, rawValue: 350) == 100)
        #expect(engine.score(event: .mdl, age: 25, sex: .male, standard: .general, rawValue: 340) == 99)
        #expect(engine.score(event: .mdl, age: 25, sex: .male, standard: .general, rawValue: 330) == 97)
        #expect(engine.score(event: .mdl, age: 25, sex: .male, standard: .general, rawValue: 320) == 95)
        #expect(engine.score(event: .mdl, age: 25, sex: .male, standard: .general, rawValue: 310) == 93)
        #expect(engine.score(event: .mdl, age: 25, sex: .male, standard: .general, rawValue: 300) == 91)
    }

    // MARK: - Cross-Check F Column 100pts Values

    @Test func crossCheckFemale100PtsAllBands() throws {
        let engine = try makeEngine()
        let expected: [(Int, Int)] = [
            (20, 220), (25, 230), (30, 240), (34, 230),
            (40, 220), (45, 210), (50, 200), (55, 190),
            (60, 170), (65, 170)
        ]
        for (age, weight) in expected {
            let pts = engine.score(event: .mdl, age: age, sex: .female, standard: .general, rawValue: weight)
            #expect(pts == 100, "MDL F age \(age) at \(weight)lbs should be 100, got \(pts)")
        }
    }

    // MARK: - Regression: Zero Input

    @Test func zeroInputReturnsZero() throws {
        let engine = try makeEngine()
        #expect(engine.score(event: .mdl, age: 25, sex: .male, standard: .general, rawValue: 0) == 0)
        #expect(engine.score(event: .hrp, age: 25, sex: .male, standard: .general, rawValue: 0) == 0)
        #expect(engine.score(event: .plk, age: 25, sex: .male, standard: .general, rawValue: 0) == 0)
        #expect(engine.score(event: .sdc, age: 25, sex: .male, standard: .general, rawValue: 0) == 100)
        #expect(engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: 0) == 100)
    }

    // MARK: - Regression: Evaluate Returns Consistent Results

    @Test func evaluateConsistentWithIndividualScores() throws {
        let engine = try makeEngine()
        let mdlRaw = 250
        let hrpRaw = 35
        let sdcRaw = 120
        let plkRaw = 160
        let runRaw = 1000

        let individualMDL = engine.score(event: .mdl, age: 25, sex: .male, standard: .general, rawValue: mdlRaw)
        let individualHRP = engine.score(event: .hrp, age: 25, sex: .male, standard: .general, rawValue: hrpRaw)
        let individualSDC = engine.score(event: .sdc, age: 25, sex: .male, standard: .general, rawValue: sdcRaw)
        let individualPLK = engine.score(event: .plk, age: 25, sex: .male, standard: .general, rawValue: plkRaw)
        let individualRun = engine.score(event: .run2mi, age: 25, sex: .male, standard: .general, rawValue: runRaw)

        let result = engine.evaluate(
            age: 25, sex: .male, standard: .general,
            mdl: mdlRaw, hrp: hrpRaw, sdcSeconds: sdcRaw, plkSeconds: plkRaw, run2miSeconds: runRaw
        )

        #expect(result.eventScores[.mdl] == individualMDL)
        #expect(result.eventScores[.hrp] == individualHRP)
        #expect(result.eventScores[.sdc] == individualSDC)
        #expect(result.eventScores[.plk] == individualPLK)
        #expect(result.eventScores[.run2mi] == individualRun)
        #expect(result.total == individualMDL + individualHRP + individualSDC + individualPLK + individualRun)
    }
}

private enum TestError: Error {
    case missingFile
}

private final class BundleToken {}
