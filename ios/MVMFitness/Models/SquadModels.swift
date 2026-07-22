import Foundation
import SwiftUI

// MARK: - Member

nonisolated struct SquadMember: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var name: String // full name, initials, or roster number
    var birthYear: Int // age derived per test date
    var sex: SoldierSex
    var standard: AFTStandard // .combat or .general
    var isArchived: Bool = false
    var notes: String = ""

    func age(on date: Date = .now) -> Int {
        max(17, Calendar.current.component(.year, from: date) - birthYear)
    }
}

// MARK: - Results

nonisolated struct SquadAFTResult: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var memberID: UUID
    var date: Date = .now
    var mdlLbs: Int
    var hrpReps: Int
    var sdcSeconds: Int
    var plkSeconds: Int
    var runSeconds: Int
    var eventPoints: [Int] // [mdl, hrp, sdc, plk, run]
    var total: Int
    var passed: Bool
}

nonisolated struct SquadCFTResult: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var memberID: UUID
    var date: Date = .now
    var totalSeconds: Int
    var isGo: Bool
}

nonisolated struct SquadWHtRResult: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var memberID: UUID
    var date: Date = .now
    var waistInches: Double
    var heightInches: Double

    var ratio: Double { heightInches > 0 ? waistInches / heightInches : 0 }
    var meetsStandard: Bool { ratio < 0.55 }
}

// MARK: - Container

nonisolated struct SquadData: Codable, Sendable {
    var squadName: String = "My Squad"
    var members: [SquadMember] = []
    var aftResults: [SquadAFTResult] = []
    var cftResults: [SquadCFTResult] = []
    var whtrResults: [SquadWHtRResult] = []
}

// MARK: - Store

@Observable
@MainActor
final class SquadStore {
    var data = SquadData()
    private static let storageKey = "squadData"

    init() {
        data = DataStore.load(SquadData.self, forKey: Self.storageKey, fallback: SquadData())
    }

    private func persist() { DataStore.save(data, forKey: Self.storageKey) }

    var activeMembers: [SquadMember] { data.members.filter { !$0.isArchived } }

    func addMember(_ member: SquadMember) { data.members.append(member); persist() }
    func archiveMember(_ member: SquadMember) {
        if let i = data.members.firstIndex(where: { $0.id == member.id }) {
            data.members[i].isArchived = true; persist()
        }
    }

    func addAFT(_ result: SquadAFTResult) { data.aftResults.insert(result, at: 0); persist() }
    func addCFT(_ result: SquadCFTResult) { data.cftResults.insert(result, at: 0); persist() }
    func addWHtR(_ result: SquadWHtRResult) { data.whtrResults.insert(result, at: 0); persist() }

    func latestAFT(for member: SquadMember) -> SquadAFTResult? {
        data.aftResults.first { $0.memberID == member.id }
    }
    func latestCFT(for member: SquadMember) -> SquadCFTResult? {
        data.cftResults.first { $0.memberID == member.id }
    }
    func latestWHtR(for member: SquadMember) -> SquadWHtRResult? {
        data.whtrResults.first { $0.memberID == member.id }
    }

    /// AD 2025-17: 465+ AFT exempts from body composition standards.
    func isBodyCompExempt(_ member: SquadMember) -> Bool {
        (latestAFT(for: member)?.total ?? 0) >= 465
    }

    // MARK: - Readiness rollup

    struct Readiness {
        var aftGreen = 0, aftTotal = 0
        var cftGo = 0, cftTotal = 0
        var whtrMet = 0, whtrTotal = 0
    }

    var readiness: Readiness {
        var r = Readiness()
        for member in activeMembers {
            r.aftTotal += 1
            if latestAFT(for: member)?.passed == true { r.aftGreen += 1 }
            if member.standard == .combat {
                r.cftTotal += 1
                if latestCFT(for: member)?.isGo == true { r.cftGo += 1 }
            }
            r.whtrTotal += 1
            if isBodyCompExempt(member) || latestWHtR(for: member)?.meetsStandard == true { r.whtrMet += 1 }
        }
        return r
    }

    // MARK: - CSV export

    private func csvRow(for m: SquadMember, df: DateFormatter) -> String {
        let aft = latestAFT(for: m)
        let cft = latestCFT(for: m)
        let whtr = latestWHtR(for: m)
        let exempt = isBodyCompExempt(m)

        let name: String = m.name.replacingOccurrences(of: ",", with: " ")
        let standard: String = m.standard.rawValue

        var aftTotal = ""
        var aftPass = ""
        var aftDate = ""
        if let aft {
            aftTotal = String(aft.total)
            aftPass = aft.passed ? "PASS" : "FAIL"
            aftDate = df.string(from: aft.date)
        }

        var cftGo = ""
        var cftTime = ""
        var cftDate = ""
        if let cft {
            cftGo = cft.isGo ? "GO" : "NO-GO"
            cftTime = String(format: "%d:%02d", cft.totalSeconds / 60, cft.totalSeconds % 60)
            cftDate = df.string(from: cft.date)
        }

        var whtrRatio = ""
        var whtrMeets = exempt ? "EXEMPT" : ""
        var whtrDate = ""
        if let whtr {
            whtrRatio = String(format: "%.2f", whtr.ratio)
            whtrMeets = exempt ? "EXEMPT" : (whtr.meetsStandard ? "MEETS" : "NO")
            whtrDate = df.string(from: whtr.date)
        }

        let fields: [String] = [
            name, standard, aftTotal, aftPass, aftDate,
            cftGo, cftTime, cftDate,
            whtrRatio, whtrMeets, whtrDate
        ]
        return fields.joined(separator: ",")
    }

    func exportCSV() -> String {
        var lines = ["Name,Standard,Latest AFT Total,AFT Pass,AFT Date,CFT GO,CFT Time,CFT Date,WHtR,WHtR Meets,WHtR Date"]
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        for m in activeMembers {
            lines.append(csvRow(for: m, df: df))
        }
        return lines.joined(separator: "\n")
    }
}
