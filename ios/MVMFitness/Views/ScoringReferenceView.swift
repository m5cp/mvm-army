import SwiftUI

/// Scoring reference guide — the min (pass) and max (100%) raw performance for
/// every event on every test, computed by probing the SAME engines the
/// calculators use, so the reference can never drift from actual scoring.
/// Includes Advanced Readiness rating bands + anchors and each service's body
/// composition standard.
struct ScoringReferenceView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var sex: SoldierSex = .male
    @State private var ageText = "25"
    @State private var standard: AFTStandard = .combat

    private var age: Int { Int(ageText) ?? 25 }
    private let engine = AFTScoringEngine.shared

    /// Probe results cached per (age, sex) so typing in the age field never
    /// re-runs thousands of engine calls mid-keystroke.
    @MainActor
    private final class ProbeCache {
        static let shared = ProbeCache()
        var rows: [String: [(String, String, String)]] = [:]
    }

    private func cachedRows(_ key: String, compute: () -> [(String, String, String)]) -> [(String, String, String)] {
        if let hit = ProbeCache.shared.rows[key] { return hit }
        let result = compute()
        ProbeCache.shared.rows[key] = result
        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.screen.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        controls
                        aftSection
                        cftSection
                        navySection
                        airForceSection
                        marineSection
                        advancedSection
                        applicantSection
                        bodyCompSection

                        Text("All values come from the same scoring engines the calculators use. Where a program has not published official tables, values are the app's practice scale and are labeled as such.")
                            .font(.caption2)
                            .foregroundStyle(MVMTheme.textFaint)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .adaptiveContainer()
                }
            }
            .navigationTitle("Scoring References")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }.foregroundStyle(MVMTheme.accent)
                }
            }
            .toolbarBackground(MVMTheme.screen, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Controls

    private var controls: some View {
        RaisedCard {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        refLabel("AGE")
                        InsetWell {
                            TextField("25", text: $ageText)
                                .keyboardType(.numberPad)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(MVMTheme.text)
                                .padding(.horizontal, 14)
                                .frame(height: 46)
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        refLabel("SEX")
                        InsetWell {
                            HStack(spacing: 3) {
                                ForEach(SoldierSex.allCases, id: \.self) { option in
                                    let selected = sex == option
                                    Text(option.rawValue.capitalized)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(selected ? MVMTheme.onAmber : MVMTheme.textMuted)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 40)
                                        .background(selected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(.clear))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .contentShape(Rectangle())
                                        .onTapGesture { sex = option }
                                }
                            }
                            .padding(3)
                        }
                    }
                }
                Text("References update live for this age and sex.")
                    .font(.caption2)
                    .foregroundStyle(MVMTheme.textFaint)
            }
            .padding(16)
        }
    }

    private func refLabel(_ text: String) -> some View {
        Text(text)
            .font(MVMTheme.mono(10))
            .kerning(1.2)
            .foregroundStyle(MVMTheme.textFaint)
    }

    private func section(_ title: String, subtitle: String, rows: [(String, String, String)]) -> some View {
        RaisedCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MVMTheme.text)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(MVMTheme.textMuted)

                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    Divider().overlay(MVMTheme.hairline)
                    HStack(alignment: .top, spacing: 10) {
                        Text(row.0)
                            .font(MVMTheme.mono(10, weight: .bold))
                            .foregroundStyle(MVMTheme.amber)
                            .frame(width: 52, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.1)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MVMTheme.text)
                            Text(row.2)
                                .font(MVMTheme.mono(10.5))
                                .foregroundStyle(MVMTheme.textMuted)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func mmss(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: - AFT

    private var aftSection: some View {
        let events: [(AFTEventType, String, String)] = [
            (.mdl, "MDL", "3-Rep Max Deadlift"),
            (.hrp, "HRP", "Hand-Release Push-Up"),
            (.sdc, "SDC", "Sprint-Drag-Carry"),
            (.plk, "PLK", "Plank"),
            (.run2mi, "2MR", "2-Mile Run")
        ]
        let rows = events.map { event, code, name -> (String, String, String) in
            let min60 = engine.rawNeeded(event: event, age: age, sex: sex, standard: standard, targetPoints: 60)
            let max100 = engine.rawNeeded(event: event, age: age, sex: sex, standard: standard, targetPoints: 100)
            let fmt: (Int?) -> String = { value in
                guard let value else { return "—" }
                switch event {
                case .mdl: return "\(value) lb"
                case .hrp: return "\(value) reps"
                default: return self.mmss(value)
                }
            }
            return (code, name, "MIN 60 PT \(fmt(min60)) \(MVMTheme.dot) MAX 100 PT \(fmt(max100))")
        }
        return VStack(spacing: 10) {
            standardToggle
            section(
                "Army Fitness Test",
                subtitle: "\(standard.rawValue) standard \(MVMTheme.dot) \(engine.minimumTotal(for: standard)) total minimum \(MVMTheme.dot) 60 per event",
                rows: rows
            )
        }
    }

    private var standardToggle: some View {
        InsetWell {
            HStack(spacing: 3) {
                ForEach(AFTStandard.allCases) { option in
                    let selected = standard == option
                    Text(option.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(selected ? MVMTheme.onAmber : MVMTheme.textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(selected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(.clear))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .contentShape(Rectangle())
                        .onTapGesture { standard = option }
                }
            }
            .padding(3)
        }
    }

    // MARK: - CFT

    private var cftSection: some View {
        section(
            "Combat Field Test",
            subtitle: "7 events in sequence \(MVMTheme.dot) one cumulative time \(MVMTheme.dot) grader GO/NO-GO",
            rows: [("TIME", "Official time standard", "Pending publication — the app records raw time + grader determination")]
        )
    }

    // MARK: - Navy PRT (probed from the engine tables)

    private var navySection: some View {
        let svcSex: ServiceSex = sex == .male ? .male : .female
        func probeReps(_ event: NavyEvent, top: Int) -> (String, String) {
            var minPass: Int?
            var maxRaw: Int?
            var best = -1
            for reps in 0...top {
                let result = NavyScoring.score(event: event, rawValue: reps, age: age, sex: svcSex, altitude: .below5000)
                if minPass == nil, result.points >= 50 { minPass = reps }
                if result.points > best { best = result.points; maxRaw = reps }
            }
            return (minPass.map { "\($0)" } ?? "—", maxRaw.map { "\($0)" } ?? "—")
        }
        func probeTime(_ event: NavyEvent, limit: Int) -> (String, String) {
            var slowestPass: Int?
            var fastestMax: Int?
            var best = -1
            for seconds in stride(from: limit, through: 1, by: -1) {
                let result = NavyScoring.score(event: event, rawValue: seconds, age: age, sex: svcSex, altitude: .below5000)
                if slowestPass == nil, result.points >= 50 { slowestPass = seconds }
                if result.points > best { best = result.points; fastestMax = seconds }
            }
            return (slowestPass.map(mmss) ?? "—", fastestMax.map(mmss) ?? "—")
        }

        let rows = cachedRows("navy-\(age)-\(svcSex.rawValue)") {
            let pushups = probeReps(.pushUps, top: 150)
            let plank = probeReps(.forearmPlank, top: 600)
            let run = probeTime(.run1_5Mile, limit: 1500)
            let row = probeTime(.row2Kilometer, limit: 1500)
            let swim = probeTime(.swim500Yard, limit: 1500)
            return [
                ("PU", "Push-Ups (2 min)", "MIN \(pushups.0) reps \(MVMTheme.dot) MAX \(pushups.1) reps"),
                ("PLK", "Forearm Plank", "MIN \(mmss(Int(plank.0) ?? 0)) \(MVMTheme.dot) MAX \(mmss(Int(plank.1) ?? 0))"),
                ("1.5MI", "1.5-Mile Run", "SLOWEST PASS \(run.0) \(MVMTheme.dot) MAX \(run.1)"),
                ("2K", "2000 m Row", "SLOWEST PASS \(row.0) \(MVMTheme.dot) MAX \(row.1)"),
                ("500YD", "500 yd Swim", "SLOWEST PASS \(swim.0) \(MVMTheme.dot) MAX \(swim.1)")
            ]
        }

        return section(
            "Navy PRT",
            subtitle: "Satisfactory (50 pts) is the passing floor \(MVMTheme.dot) Outstanding starts at 90",
            rows: rows
        )
    }

    // MARK: - Air Force (probed)

    private var airForceSection: some View {
        let svcSex: ServiceSex = sex == .male ? .male : .female
        func probeRepsAF(_ event: AirForceEvent, top: Int) -> (String, String) {
            var minScored: Int?
            var maxRaw: Int?
            var best = -1.0
            for reps in 0...top {
                guard let points = AirForceScoring.score(event: event, rawValue: Double(reps), age: age, sex: svcSex) else { continue }
                if minScored == nil, points > 0 { minScored = reps }
                if points > best { best = points; maxRaw = reps }
            }
            return (minScored.map { "\($0)" } ?? "—", maxRaw.map { "\($0)" } ?? "—")
        }
        func probeRunAF(limit: Int) -> (String, String) {
            var slowestScored: Int?
            var fastestMax: Int?
            var best = -1.0
            for seconds in stride(from: limit, through: 1, by: -1) {
                guard let points = AirForceScoring.score(event: .twoMileRun, rawValue: Double(seconds), age: age, sex: svcSex) else { continue }
                if slowestScored == nil, points > 0 { slowestScored = seconds }
                if points > best { best = points; fastestMax = seconds }
            }
            return (slowestScored.map(mmss) ?? "—", fastestMax.map(mmss) ?? "—")
        }
        func probeWalk() -> String {
            for seconds in stride(from: 3000, through: 1, by: -1) {
                if AirForceScoring.twoKilometerWalkPassed(seconds: seconds, age: age, sex: svcSex) {
                    return mmss(seconds)
                }
            }
            return "—"
        }
        func probeWHtR() -> (String, String) {
            var maxRatio: Double?
            var bestRatio: Double?
            var best = -1.0
            for step in 35...70 {
                let ratio = Double(step) / 100
                guard let points = AirForceScoring.score(event: .waistToHeightRatio, rawValue: ratio, age: age, sex: svcSex) else { continue }
                if points > 0 { maxRatio = ratio }
                if points > best { best = points; bestRatio = ratio }
            }
            return (
                bestRatio.map { String(format: "%.2f", $0) } ?? "—",
                maxRatio.map { String(format: "%.2f", $0) } ?? "—"
            )
        }

        let rows = cachedRows("af-\(age)-\(svcSex.rawValue)") {
            let pushups = probeRepsAF(.pushUps, top: 100)
            let situps = probeRepsAF(.sitUps, top: 100)
            let hamr = probeRepsAF(.hamr20m, top: 130)
            let run = probeRunAF(limit: 1500)
            let whtr = probeWHtR()
            return [
                ("WHtR", "Waist-to-Height Ratio (20 pts)", "BEST \(whtr.0) \(MVMTheme.dot) LAST SCORED \(whtr.1)"),
                ("2MI", "2-Mile Run (50 pts)", "SLOWEST SCORED \(run.0) \(MVMTheme.dot) MAX \(run.1)"),
                ("HAMR", "20 m HAMR (50 pts)", "MIN \(hamr.0) \(MVMTheme.dot) MAX \(hamr.1) shuttles"),
                ("WALK", "2-Km Walk (pass/fail)", "MAX TIME \(probeWalk())"),
                ("PU", "Push-Ups (15 pts)", "MIN \(pushups.0) \(MVMTheme.dot) MAX \(pushups.1) reps"),
                ("SU", "Sit-Ups (15 pts)", "MIN \(situps.0) \(MVMTheme.dot) MAX \(situps.1) reps")
            ]
        }

        return section(
            "Air Force PT",
            subtitle: "Composite = earned / possible × 100 \(MVMTheme.dot) 75 to pass \(MVMTheme.dot) 90+ Excellent",
            rows: rows
        )
    }

    // MARK: - Marines (probed)

    private var marineSection: some View {
        let marineSex: MarineSex = sex == .male ? .male : .female
        func repsRange(min minCheck: @escaping (Int) -> MarineEventScore?, top: Int) -> (String, String) {
            var minPass: Int?
            var maxRaw: Int?
            for reps in 0...top {
                guard let score = minCheck(reps) else { continue }
                if minPass == nil, score.passed { minPass = reps }
                if score.points >= score.maximumPoints, maxRaw == nil { maxRaw = reps }
            }
            return (minPass.map { "\($0)" } ?? "—", maxRaw.map { "\($0)" } ?? "—")
        }
        /// Lower-is-better timed events. `fastestMax` needs the same `nil` guard
        /// `repsRange` already has — without it the loop runs down to 1 second
        /// and every row printed "MAX 0:01".
        func timeRange(_ score: @escaping (Int) -> MarineEventScore?, limit: Int) -> (String, String) {
            var slowestPass: Int?
            var fastestMax: Int?
            for seconds in stride(from: limit, through: 1, by: -1) {
                guard let result = score(seconds) else { continue }
                if slowestPass == nil, result.passed { slowestPass = seconds }
                if result.points >= result.maximumPoints, fastestMax == nil { fastestMax = seconds }
            }
            return (slowestPass.map(mmss) ?? "—", fastestMax.map(mmss) ?? "—")
        }

        /// Higher-is-better timed events (the plank). Routing these through
        /// `timeRange` produced a minimum SLOWER than the maximum — "MIN 5:00 ·
        /// MAX 3:45" — because it latched onto the first value it probed.
        func heldTimeRange(_ score: @escaping (Int) -> MarineEventScore?, limit: Int) -> (String, String) {
            var minPass: Int?
            var maxPerformance: Int?
            for seconds in 1...limit {
                guard let result = score(seconds) else { continue }
                if minPass == nil, result.passed { minPass = seconds }
                if result.points >= result.maximumPoints, maxPerformance == nil { maxPerformance = seconds }
            }
            return (minPass.map(mmss) ?? "—", maxPerformance.map(mmss) ?? "—")
        }

        let rows = cachedRows("usmc-\(age)-\(marineSex.rawValue)") {
            let pulls = repsRange(min: { MarineCorpsScoring.scorePullUps(repetitions: $0, age: age, sex: marineSex) }, top: 40)
            let pushes = repsRange(min: { MarineCorpsScoring.scorePushUps(repetitions: $0, age: age, sex: marineSex) }, top: 130)
            let plank = heldTimeRange({ MarineCorpsScoring.scorePlank(seconds: $0) }, limit: 300)
            let run3 = timeRange({ MarineCorpsScoring.scoreThreeMileRun(seconds: $0, age: age, sex: marineSex) }, limit: 2400)
            let mtc = timeRange({ MarineCorpsScoring.scoreMovementToContact(seconds: $0, age: age, sex: marineSex) }, limit: 600)
            let ammo = repsRange(min: { MarineCorpsScoring.scoreAmmunitionLift(repetitions: $0, age: age, sex: marineSex) }, top: 140)
            let muf = timeRange({ MarineCorpsScoring.scoreManeuverUnderFire(seconds: $0, age: age, sex: marineSex) }, limit: 600)
            return [
                ("PULL", "Pull-Ups", "MIN \(pulls.0) \(MVMTheme.dot) MAX \(pulls.1) reps"),
                ("PU", "Push-Ups (2 min)", "MIN \(pushes.0) \(MVMTheme.dot) MAX \(pushes.1) reps"),
                ("PLK", "Plank", "MIN \(plank.0) \(MVMTheme.dot) MAX \(plank.1)"),
                ("3MI", "3-Mile Run", "SLOWEST PASS \(run3.0) \(MVMTheme.dot) MAX \(run3.1)"),
                ("MTC", "Movement to Contact", "SLOWEST PASS \(mtc.0) \(MVMTheme.dot) MAX \(mtc.1)"),
                ("AL", "Ammunition Lift (2 min)", "MIN \(ammo.0) \(MVMTheme.dot) MAX \(ammo.1) reps"),
                ("MUF", "Maneuver Under Fire", "SLOWEST PASS \(muf.0) \(MVMTheme.dot) MAX \(muf.1)")
            ]
        }

        return section(
            "Marine PFT / CFT",
            subtitle: "300 max \(MVMTheme.dot) 150 min + all events passed \(MVMTheme.dot) 235+ First Class",
            rows: rows
        )
    }

    // MARK: - Advanced Readiness (anchor curves — the go/no-go reference Joe asked for)

    private var advancedSection: some View {
        let curves = ReadinessScoringData.curves
        // Every event: performance worth 100, 60 (Developing floor), and 0.
        func anchorLine(_ id: String) -> String? {
            guard let curve = curves[id] else { return nil }
            let ordered = curve.anchors.sorted { $0.performance < $1.performance }
            guard let first = ordered.first, let last = ordered.last else { return nil }
            // A GO/NO-GO event has two synthetic anchors; running them through the
        // 100/60/0 maths printed the cap and the cap-plus-one, backwards.
        if curve.isGate { return curve.standardLabel }
        let hundred = curve.direction == .lowerIsBetter ? first : last
            let zero = curve.direction == .lowerIsBetter ? last : first
            // interpolate the 60-score crossing
            var at60: Double?
            for i in 0..<(ordered.count - 1) {
                let a = ordered[i], b = ordered[i + 1]
                let lo = Swift.min(a.score, b.score), hi = Swift.max(a.score, b.score)
                if lo <= 60, hi >= 60, a.score != b.score {
                    let fraction = (60 - a.score) / (b.score - a.score)
                    at60 = a.performance + fraction * (b.performance - a.performance)
                    break
                }
            }
            let fmt: (Double) -> String = { value in
                curve.unit == "seconds" ? self.mmss(Int(value)) :
                curve.unit == "pass/fail" ? (value >= 1 ? "PASS" : "FAIL") :
                "\(Int(value)) \(curve.unit)"
            }
            let sixty = at60.map(fmt) ?? "—"
            return "100 PT \(fmt(hundred.performance)) \(MVMTheme.dot) 60 PT \(sixty) \(MVMTheme.dot) 0 PT \(fmt(zero.performance))"
        }

        let ids: [(String, String)] = [
            ("swim500yd", "500 yd Swim"), ("swim1000m", "1000 m Swim"),
            ("run1_5mi", "1.5-Mile Run"), ("run3mi", "3-Mile Run"), ("run5mi", "5-Mile Run"),
            ("ruck10mi45", "10-Mile Ruck (45 lb)"), ("ruck12mi45", "12-Mile Ruck (45 lb)"),
            ("shuttle300yd", "300 yd Shuttle"), ("farmer400m106", "Farmer Carry 400 m"),
            ("pullUps", "Pull-Ups"), ("pushUps2m", "Push-Ups (2 min)"),
            ("hrPushUps2m", "HR Push-Ups (2 min)"), ("sitUps2m", "Sit-Ups (2 min)"),
            ("plank", "Plank"), ("armyFitnessTotal", "AFT Total")
        ]
        let rows: [(String, String, String)] = ids.compactMap { id, name in
            anchorLine(id).map { (shortRef(id), name, $0) }
        }

        return VStack(spacing: 10) {
            section(
                "Advanced Readiness",
                subtitle: "0\u{2013}100 weighted \(MVMTheme.dot) ELITE 90+ \(MVMTheme.dot) ADVANCED 80 \(MVMTheme.dot) STRONG 70 \(MVMTheme.dot) DEVELOPING 60 \(MVMTheme.dot) below 60 FOUNDATION",
                rows: rows
            )
        }
    }

    private func shortRef(_ id: String) -> String {
        switch id {
        case "swim500yd": return "500YD"
        case "swim1000m": return "1000M"
        case "run1_5mi": return "1.5MI"
        case "run3mi": return "3MI"
        case "run5mi": return "5MI"
        case "ruck10mi45": return "10MI"
        case "ruck12mi45": return "12MI"
        case "shuttle300yd": return "300YD"
        case "farmer400m106": return "FARMER"
        case "pullUps": return "PULL"
        case "pushUps2m": return "PU"
        case "hrPushUps2m": return "HRP"
        case "sitUps2m": return "SU"
        case "plank": return "PLK"
        case "armyFitnessTotal": return "AFT"
        default: return "EVT"
        }
    }

    // MARK: - Body composition

    /// ROTC / Service Academy applicant standards. These five programs are
    /// scored in the calculator's ROTC tab but had no entry in this sheet at all,
    /// so an applicant had no way to see what they were training toward.
    private var applicantSection: some View {
        let rows: [(String, String, String)] = ApplicantAssessmentProgram.allCases.map { program in
            (Self.applicantCode(program), Self.applicantName(program), Self.applicantStandard(program))
        }
        return VStack(spacing: 10) {
            section(
                "ROTC & Service Academy",
                subtitle: "APPLICANT \(MVMTheme.dot) PRACTICE SCALE \(MVMTheme.dot) NOT AN OFFICIAL TABLE",
                rows: rows
            )
        }
    }

    private static func applicantName(_ program: ApplicantAssessmentProgram) -> String {
        switch program {
        case .armyROTC: return "Army ROTC"
        case .airForceROTC: return "Air Force ROTC"
        case .navyROTC: return "Navy ROTC"
        case .marineOptionROTC: return "Marine Option"
        case .serviceAcademyCFA: return "Service Academy CFA"
        }
    }

    private static func applicantCode(_ program: ApplicantAssessmentProgram) -> String {
        switch program {
        case .armyROTC: return "AROTC"
        case .airForceROTC: return "AFROTC"
        case .navyROTC: return "NROTC"
        case .marineOptionROTC: return "USMC"
        case .serviceAcademyCFA: return "CFA"
        }
    }

    private static func applicantStandard(_ program: ApplicantAssessmentProgram) -> String {
        switch program {
        case .serviceAcademyCFA:
            return "6 events \(MVMTheme.dot) composite 0\u{2013}100 \(MVMTheme.dot) all events required"
        case .marineOptionROTC:
            return "Scored on the official Marine PFT tables \(MVMTheme.dot) 1st class 235+"
        default:
            return "Composite 0\u{2013}100 \(MVMTheme.dot) practice scale \(MVMTheme.dot) per-event minimums apply"
        }
    }

    private var bodyCompSection: some View {
        section(
            "Body Composition Standards",
            subtitle: "Each service assesses body composition separately from its fitness test",
            rows: [
                ("ARMY", "ABCP \(MVMTheme.dot) in this app", "Circumference-based tape \(MVMTheme.dot) AFT 465+ exempts (AD 2025-17) \(MVMTheme.dot) see Profile → ABCP"),
                ("USAF", "Waist-to-Height Ratio \(MVMTheme.dot) scored in-app", "Part of the PT composite (20 pts) per official DAF charts"),
                ("NAVY", "BCA \(MVMTheme.dot) separate program", "Official Navy BCA is not scored in this app — PRT here covers the fitness events only"),
                ("USMC", "Body Composition Program \(MVMTheme.dot) separate", "Official USMC BCP is not scored in this app — PFT/CFT here cover the fitness events only")
            ]
        )
    }
}
