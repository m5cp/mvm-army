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
    // Contact fields (optional so pre-existing rosters decode unchanged)
    var rankTitle: String?
    var email: String?
    var phone: String?
    var unit: String?

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
    /// Six-character invite code shown in the invite QR. Optional so existing
    /// saved squads decode; generated on first use.
    var inviteCode: String?
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

    /// Wipes the roster in memory and on disk. The squad holds other soldiers'
    /// names, emails and phone numbers, so "Delete All Data" must reach it.
    func clear() {
        data = SquadData()
        DataStore.delete(forKey: Self.storageKey)
    }

    /// Re-reads from disk. The store is view-local `@State`, so after a global
    /// wipe a still-alive Squad screen would otherwise keep showing the roster
    /// that was just deleted.
    func reload() {
        data = DataStore.load(SquadData.self, forKey: Self.storageKey, fallback: SquadData())
    }

    var activeMembers: [SquadMember] { data.members.filter { !$0.isArchived } }

    func addMember(_ member: SquadMember) { data.members.append(member); persist() }

    func updateMember(_ member: SquadMember) {
        if let i = data.members.firstIndex(where: { $0.id == member.id }) {
            data.members[i] = member; persist()
        }
    }

    /// Invite code for the squad QR — generated once, then stable.
    func ensureInviteCode() -> String {
        if let code = data.inviteCode { return code }
        let alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        let code = String((0..<6).compactMap { _ in alphabet.randomElement() })
        data.inviteCode = code
        persist()
        return code
    }

    /// Newest FIRST by test date. Results are stored insertion-ordered, and an
    /// imported QR can carry an older date than something already logged — which
    /// made standings show a stale total and render a regression that never
    /// happened.
    func aftHistory(for member: SquadMember) -> [SquadAFTResult] {
        data.aftResults.filter { $0.memberID == member.id }.sorted { $0.date > $1.date }
    }
    func cftHistory(for member: SquadMember) -> [SquadCFTResult] {
        data.cftResults.filter { $0.memberID == member.id }
    }
    func whtrHistory(for member: SquadMember) -> [SquadWHtRResult] {
        data.whtrResults.filter { $0.memberID == member.id }
    }

    /// Imports a scanned member-stats payload: updates the matching member (by
    /// case-insensitive name) or creates one, then appends any shared results.
    /// Returns a human-readable summary for the confirmation UI.
    func importStats(_ payload: SquadStatsPayload, isPremium: Bool = true) -> String {
        let member: SquadMember
        // Prefer the stable id the sender embeds; fall back to name only for
        // codes generated before that existed. Matching on lowercased name alone
        // created a duplicate whenever someone was renamed, and collided two
        // soldiers who happen to share a name.
        let existingMatch = payload.memberID.flatMap { id in data.members.first { $0.id == id } }
            ?? data.members.first { $0.name.lowercased() == payload.name.lowercased() && !$0.isArchived }
        if let existing = existingMatch {
            var updated = existing
            if let rank = payload.rankTitle, !rank.isEmpty { updated.rankTitle = rank }
            if let email = payload.email, !email.isEmpty { updated.email = email }
            if let phone = payload.phone, !phone.isEmpty { updated.phone = phone }
            if let unit = payload.unit, !unit.isEmpty { updated.unit = unit }
            updateMember(updated)
            member = updated
        } else {
            // The free roster cap was enforced only on the + button, so a free
            // user could scan their way past it indefinitely.
            guard isPremium || activeMembers.count < ProGate.freeSquadMemberLimit else {
                return "Roster is full. Upgrade to add more than \(ProGate.freeSquadMemberLimit) members."
            }
            var created = SquadMember(
                name: payload.name,
                birthYear: payload.birthYear,
                sex: SoldierSex(rawValue: payload.sexRaw) ?? .male,
                standard: AFTStandard(rawValue: payload.standardRaw) ?? .general
            )
            created.rankTitle = payload.rankTitle
            created.email = payload.email
            created.phone = payload.phone
            created.unit = payload.unit
            if let id = payload.memberID { created.id = id }
            addMember(created)
            member = created
        }

        var imported: [String] = []
        if let total = payload.aftTotal, let raw = payload.aftRaw, raw.count == 5,
           let points = payload.aftPoints, points.count == 5 {
            let result = SquadAFTResult(
                memberID: member.id,
                date: payload.aftDate ?? .now,
                mdlLbs: raw[0], hrpReps: raw[1], sdcSeconds: raw[2],
                plkSeconds: raw[3], runSeconds: raw[4],
                eventPoints: points,
                total: total,
                passed: payload.aftPassed ?? false
            )
            // Rescanning the same code appended a duplicate row every time.
            let alreadyHave = data.aftResults.contains {
                $0.memberID == member.id
                    && abs($0.date.timeIntervalSince(result.date)) < 60
                    && $0.total == result.total
            }
            if !alreadyHave { addAFT(result) }
            imported.append("AFT \(total)")
        }
        if let seconds = payload.cftSeconds {
            addCFT(SquadCFTResult(memberID: member.id, date: payload.cftDate ?? .now, totalSeconds: seconds, isGo: payload.cftGo ?? false))
            imported.append("CFT \(payload.cftGo == true ? "GO" : "NO-GO")")
        }
        let detail = imported.isEmpty ? "contact info" : imported.joined(separator: ", ")
        return "\(member.name): \(detail) imported."
    }
    /// Permanently removes a member AND every result row referencing them.
    /// Archiving alone left another soldier's name, email and phone in
    /// `squadData` forever with no way to get them out.
    func deleteMember(_ member: SquadMember) {
        data.members.removeAll { $0.id == member.id }
        data.aftResults.removeAll { $0.memberID == member.id }
        data.cftResults.removeAll { $0.memberID == member.id }
        data.whtrResults.removeAll { $0.memberID == member.id }
        persist()
    }

    func archiveMember(_ member: SquadMember) {
        if let i = data.members.firstIndex(where: { $0.id == member.id }) {
            data.members[i].isArchived = true; persist()
        }
    }

    func addAFT(_ result: SquadAFTResult) { data.aftResults.insert(result, at: 0); persist() }
    func addCFT(_ result: SquadCFTResult) { data.cftResults.insert(result, at: 0); persist() }
    func addWHtR(_ result: SquadWHtRResult) { data.whtrResults.insert(result, at: 0); persist() }

    func latestAFT(for member: SquadMember) -> SquadAFTResult? {
        aftHistory(for: member).first
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

    /// Ranked roster. This is the leaderboard that makes sense for a military
    /// unit: results are entered by a leader who witnessed them, and it never
    /// leaves the squad. A global leaderboard of self-entered scores would rank
    /// whoever is most willing to type 600, and publishing units and routes is
    /// how a fitness app once exposed forward operating bases.
    struct StandingRow: Identifiable {
        let member: SquadMember
        let total: Int?
        let passed: Bool?
        let date: Date?
        let delta: Int?
        var id: UUID { member.id }
    }

    /// Sorted best-first. Members with no logged AFT sort last, so the list
    /// doubles as a "who still owes me a test" view.
    func standings() -> [StandingRow] {
        activeMembers.map { member in
            let history = aftHistory(for: member)
            let latest = history.first
            let previous = history.dropFirst().first
            return StandingRow(
                member: member,
                total: latest?.total,
                passed: latest?.passed,
                date: latest?.date,
                delta: latest.flatMap { current in previous.map { current.total - $0.total } }
            )
        }
        .sorted { a, b in
            switch (a.total, b.total) {
            case let (l?, r?): return l > r
            case (nil, _?): return false
            case (_?, nil): return true
            default: return a.member.name.lowercased() < b.member.name.lowercased()
            }
        }
    }

    /// Members with no AFT on record, or whose most recent one is older than a
    /// year — the two things a squad leader actually chases.
    func overdueMembers(asOf date: Date = .now) -> [SquadMember] {
        let cutoff = Calendar.current.date(byAdding: .month, value: -12, to: date) ?? date
        return activeMembers.filter { member in
            guard let latest = latestAFT(for: member) else { return true }
            return latest.date < cutoff
        }
    }

    /// Average of the most recent AFT total across members who have one.
    var averageAFTTotal: Int? {
        let totals = activeMembers.compactMap { latestAFT(for: $0)?.total }
        guard !totals.isEmpty else { return nil }
        return totals.reduce(0, +) / totals.count
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

        let clean: (String?) -> String = { ($0 ?? "").replacingOccurrences(of: ",", with: " ") }
        let fields: [String] = [
            name, clean(m.rankTitle), clean(m.email), clean(m.phone),
            standard, aftTotal, aftPass, aftDate,
            cftGo, cftTime, cftDate,
            whtrRatio, whtrMeets, whtrDate
        ]
        return fields.joined(separator: ",")
    }

    func exportCSV() -> String {
        var lines = ["Name,Rank,Email,Phone,Standard,Latest AFT Total,AFT Pass,AFT Date,CFT GO,CFT Time,CFT Date,WHtR,WHtR Meets,WHtR Date"]
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        for m in activeMembers {
            lines.append(csvRow(for: m, df: df))
        }
        return lines.joined(separator: "\n")
    }
}


// MARK: - Squad QR payloads

/// Invite QR content — a member scans this to join the squad by name + code.
nonisolated struct SquadInvitePayload: Codable, Sendable {
    var v: Int = 1
    var kind: String = "mvmSquadInvite"
    let squadName: String
    let code: String
}

/// Member-stats QR content — a member generates this so the squad owner can
/// scan and import their latest results. Shared explicitly by the member;
/// nothing is transmitted anywhere except inside this code.
nonisolated struct SquadStatsPayload: Codable, Sendable {
    var v: Int = 1
    var kind: String = "mvmSquadStats"
    let code: String?
    let name: String
    let rankTitle: String?
    let email: String?
    let phone: String?
    /// Stable identity so a rename does not create a duplicate member.
    var memberID: UUID?
    var unit: String?
    let birthYear: Int
    let sexRaw: String
    let standardRaw: String
    let aftDate: Date?
    let aftRaw: [Int]?      // [mdl lbs, hrp reps, sdc sec, plk sec, run sec]
    let aftPoints: [Int]?
    let aftTotal: Int?
    let aftPassed: Bool?
    let cftDate: Date?
    let cftSeconds: Int?
    let cftGo: Bool?
}
