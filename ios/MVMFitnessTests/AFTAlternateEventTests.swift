import Testing
import Foundation
@testable import MVMFitness

/// Phase 15 — alternate aerobic events (Walk / Bike / Swim / Row) regression
/// tests, pinning official HQDA cells (Approved 15 May 2025, Effective 1 Jun 2025).
@Suite("AFT alternate events — official Jun 2025 Go/No-Go tables")
struct AFTAlternateEventTests {

    private func loadService() throws -> AFTAlternateEventService {
        guard let url = Bundle(for: BundleToken.self).url(forResource: "aft_alternate_events_2025_06_01", withExtension: "json") else {
            throw TestError.missingFile
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(AFTAlternateEventFile.self, from: data)
        return AFTAlternateEventService(entries: decoded.entries, distances: decoded.distances)
    }

    @Test func entryCountIs120() throws {
        guard let url = Bundle(for: BundleToken.self).url(forResource: "aft_alternate_events_2025_06_01", withExtension: "json") else {
            throw TestError.missingFile
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(AFTAlternateEventFile.self, from: data)
        #expect(decoded.entries.count == 120, "Alternate event table must contain exactly 120 entries")
    }

    @Test func walkMale17to21() throws {
        let s = try loadService()
        #expect(s.isGo(event: .walk, age: 20, sex: .male, standard: .general, timeSeconds: 1860) == true)
        #expect(s.isGo(event: .walk, age: 20, sex: .male, standard: .general, timeSeconds: 1861) == false)
    }

    @Test func walkFemale17to21() throws {
        let s = try loadService()
        #expect(s.isGo(event: .walk, age: 20, sex: .female, standard: .general, timeSeconds: 2040) == true)
        #expect(s.isGo(event: .walk, age: 20, sex: .female, standard: .general, timeSeconds: 2041) == false)
    }

    @Test func walkMale57to61() throws {
        let s = try loadService()
        #expect(s.isGo(event: .walk, age: 58, sex: .male, standard: .general, timeSeconds: 1980) == true)
        #expect(s.isGo(event: .walk, age: 58, sex: .male, standard: .general, timeSeconds: 1981) == false)
    }

    @Test func bikeMale27to31() throws {
        let s = try loadService()
        #expect(s.isGo(event: .bike, age: 29, sex: .male, standard: .general, timeSeconds: 1560) == true)
        #expect(s.isGo(event: .bike, age: 29, sex: .male, standard: .general, timeSeconds: 1561) == false)
    }

    @Test func bikeFemale47to51() throws {
        let s = try loadService()
        #expect(s.isGo(event: .bike, age: 49, sex: .female, standard: .general, timeSeconds: 1790) == true)
        #expect(s.isGo(event: .bike, age: 49, sex: .female, standard: .general, timeSeconds: 1791) == false)
    }

    @Test func swimMale17to21() throws {
        let s = try loadService()
        #expect(s.isGo(event: .swim, age: 20, sex: .male, standard: .general, timeSeconds: 1848) == true)
        #expect(s.isGo(event: .swim, age: 20, sex: .male, standard: .general, timeSeconds: 1849) == false)
    }

    @Test func rowFemale27to31() throws {
        let s = try loadService()
        #expect(s.isGo(event: .row, age: 29, sex: .female, standard: .general, timeSeconds: 1968) == true)
        #expect(s.isGo(event: .row, age: 29, sex: .female, standard: .general, timeSeconds: 1969) == false)
    }

    /// Row must equal swim for every age band and column.
    @Test func rowEqualsSwimForEveryBandAndColumn() throws {
        let s = try loadService()
        let bands = ["17-21", "22-26", "27-31", "32-36", "37-41", "42-46", "47-51", "52-56", "57-61", "Over 62"]
        let columns: [AFTColumn] = [.male, .combat, .female]
        for band in bands {
            for column in columns {
                let swim = s.entry(event: .swim, ageBand: band, column: column)
                let row = s.entry(event: .row, ageBand: band, column: column)
                #expect(swim?.maxTimeSeconds == row?.maxTimeSeconds, "Row should equal swim for \(band) / \(column)")
            }
        }
    }

    /// Combat column must equal male column for every event/band.
    @Test func combatEqualsMaleForEveryEventAndBand() throws {
        let s = try loadService()
        let bands = ["17-21", "22-26", "27-31", "32-36", "37-41", "42-46", "47-51", "52-56", "57-61", "Over 62"]
        for event in AFTAlternateEvent.allCases {
            for band in bands {
                let male = s.entry(event: event, ageBand: band, column: .male)
                let combat = s.entry(event: event, ageBand: band, column: .combat)
                #expect(male?.maxTimeSeconds == combat?.maxTimeSeconds, "Combat should equal male for \(event.rawValue) / \(band)")
            }
        }
    }
}

private enum TestError: Error {
    case missingFile
}

private final class BundleToken {}
