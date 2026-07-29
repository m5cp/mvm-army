import Foundation

// =============================================================================
// ⚠️  SCORING IS MISSION-CRITICAL — DO NOT CHANGE ENGINE BEHAVIOR.
//     AFTScoringRegressionTests must pass with ZERO numeric diffs.
//
//     The official tables live in aft_scoring_2025_06_01.json (repo root)
//     and are AUTHORITATIVE. The interpolator below is an ILLUSTRATIVE
//     placeholder from the design prototype — linear between the 60 and
//     100 marks with plausible sex/age factors. It exists so the UI can
//     render before wiring; it must be replaced by the official table
//     lookup and never shipped.
// =============================================================================

enum Sex: String, Codable { case male, female }
enum Standard: String, Codable { case general, combat }

struct AgeBand: Codable, Hashable {
    let min: Int, max: Int
    var label: String { "\(min)–\(max)" }
}

struct EventScore {
    let event: AFTEvent
    let raw: Double          // seconds for timed events, lbs for MDL, reps for HRP
    let points: Int          // 0–100
    let minRef: Double       // 60-point threshold for current sex/age/standard
    let maxRef: Double       // 100-point threshold
}

protocol AFTScoring {
    /// Points for a raw performance under the given profile. Pure; no side effects.
    func points(event: AFTEvent, raw: Double, sex: Sex, age: Int, standard: Standard) -> Int
    /// The visible min/max references the calculator must always show.
    func references(event: AFTEvent, sex: Sex, age: Int, standard: Standard) -> (min60: Double, max100: Double)
}

/// Production implementation: decode aft_scoring_2025_06_01.json and look up
/// the exact table row. NO interpolation beyond what the official tables define.
struct OfficialTableScoring: AFTScoring {
    // TODO(Claude Code): decode the repo's aft_scoring_2025_06_01.json here.
    // The design places no constraints on this type beyond the protocol.
    func points(event: AFTEvent, raw: Double, sex: Sex, age: Int, standard: Standard) -> Int { fatalError("wire official tables") }
    func references(event: AFTEvent, sex: Sex, age: Int, standard: Standard) -> (min60: Double, max100: Double) { fatalError("wire official tables") }
}

/// ILLUSTRATIVE ONLY — design-prototype math. Presentation placeholder.
/// Ship-blocker if this reaches production. See file header.
struct IllustrativeScoring: AFTScoring {
    func points(event: AFTEvent, raw: Double, sex: Sex, age: Int, standard: Standard) -> Int {
        let r = references(event: event, sex: sex, age: age, standard: standard)
        let inverted = (event == .SDC || event == .TMR)   // lower time = better
        let t = inverted ? (r.min60 - raw) / (r.min60 - r.max100)
                         : (raw - r.min60) / (r.max100 - r.min60)
        return max(0, min(100, Int((60 + 40 * t).rounded())))
    }
    func references(event: AFTEvent, sex: Sex, age: Int, standard: Standard) -> (min60: Double, max100: Double) {
        // Plausible-looking anchors so the UI renders. NOT official.
        var (lo, hi): (Double, Double)
        switch event {
        case .MDL: (lo, hi) = (140, 340)      // lbs
        case .HRP: (lo, hi) = (10, 60)        // reps
        case .SDC: (lo, hi) = (180, 89)       // seconds
        case .PLK: (lo, hi) = (80, 220)       // seconds
        case .TMR: (lo, hi) = (1260, 810)     // seconds
        }
        let ageF = 1 - Double(max(0, age - 26)) * 0.004
        let sexF = (sex == .female) ? 0.82 : 1.0
        if event == .SDC || event == .TMR { lo /= (ageF * sexF); hi /= (ageF * sexF) }
        else { lo *= ageF * sexF; hi *= ageF * sexF }
        if standard == .combat { hi = hi * 1.02; lo = lo * 1.05 }
        return (lo.rounded(), hi.rounded())
    }
}
