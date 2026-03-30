import Foundation

nonisolated enum AFTAgeGroup: String, CaseIterable, Sendable {
    case age17to21 = "17-21"
    case age22to26 = "22-26"
    case age27to31 = "27-31"
    case age32to36 = "32-36"
    case age37to41 = "37-41"
    case age42to46 = "42-46"
    case age47to51 = "47-51"
    case age52to56 = "52-56"
    case age57to61 = "57-61"
    case age62plus = "62+"

    static func from(age: Int) -> AFTAgeGroup {
        switch age {
        case ..<17: return .age17to21
        case 17...21: return .age17to21
        case 22...26: return .age22to26
        case 27...31: return .age27to31
        case 32...36: return .age32to36
        case 37...41: return .age37to41
        case 42...46: return .age42to46
        case 47...51: return .age47to51
        case 52...56: return .age52to56
        case 57...61: return .age57to61
        default: return .age62plus
        }
    }
}

nonisolated struct AFTEventBounds: Sendable {
    let max100: Double
    let min60: Double
}

nonisolated enum AFTScoringTables: Sendable {

    // MARK: - MDL (3-Rep Max Deadlift) — lbs, higher is better

    static func deadliftBounds(age: Int, sex: SoldierSex) -> AFTEventBounds {
        let group = AFTAgeGroup.from(age: age)
        switch sex {
        case .male:
            switch group {
            case .age17to21: return AFTEventBounds(max100: 340, min60: 140)
            case .age22to26: return AFTEventBounds(max100: 370, min60: 140)
            case .age27to31: return AFTEventBounds(max100: 370, min60: 140)
            case .age32to36: return AFTEventBounds(max100: 370, min60: 140)
            case .age37to41: return AFTEventBounds(max100: 340, min60: 140)
            case .age42to46: return AFTEventBounds(max100: 340, min60: 140)
            case .age47to51: return AFTEventBounds(max100: 320, min60: 120)
            case .age52to56: return AFTEventBounds(max100: 280, min60: 100)
            case .age57to61: return AFTEventBounds(max100: 250, min60: 80)
            case .age62plus:  return AFTEventBounds(max100: 230, min60: 80)
            }
        case .female:
            switch group {
            case .age17to21: return AFTEventBounds(max100: 210, min60: 120)
            case .age22to26: return AFTEventBounds(max100: 210, min60: 120)
            case .age27to31: return AFTEventBounds(max100: 210, min60: 120)
            case .age32to36: return AFTEventBounds(max100: 210, min60: 120)
            case .age37to41: return AFTEventBounds(max100: 190, min60: 120)
            case .age42to46: return AFTEventBounds(max100: 190, min60: 120)
            case .age47to51: return AFTEventBounds(max100: 170, min60: 100)
            case .age52to56: return AFTEventBounds(max100: 150, min60: 80)
            case .age57to61: return AFTEventBounds(max100: 130, min60: 80)
            case .age62plus:  return AFTEventBounds(max100: 120, min60: 80)
            }
        }
    }

    // MARK: - HRP (Hand-Release Push-Up) — reps, higher is better

    static func pushUpBounds(age: Int, sex: SoldierSex) -> AFTEventBounds {
        let group = AFTAgeGroup.from(age: age)
        switch sex {
        case .male:
            switch group {
            case .age17to21: return AFTEventBounds(max100: 57, min60: 10)
            case .age22to26: return AFTEventBounds(max100: 61, min60: 10)
            case .age27to31: return AFTEventBounds(max100: 62, min60: 10)
            case .age32to36: return AFTEventBounds(max100: 60, min60: 10)
            case .age37to41: return AFTEventBounds(max100: 57, min60: 10)
            case .age42to46: return AFTEventBounds(max100: 54, min60: 10)
            case .age47to51: return AFTEventBounds(max100: 50, min60: 10)
            case .age52to56: return AFTEventBounds(max100: 46, min60: 10)
            case .age57to61: return AFTEventBounds(max100: 43, min60: 10)
            case .age62plus:  return AFTEventBounds(max100: 40, min60: 10)
            }
        case .female:
            switch group {
            case .age17to21: return AFTEventBounds(max100: 40, min60: 10)
            case .age22to26: return AFTEventBounds(max100: 42, min60: 10)
            case .age27to31: return AFTEventBounds(max100: 42, min60: 10)
            case .age32to36: return AFTEventBounds(max100: 40, min60: 10)
            case .age37to41: return AFTEventBounds(max100: 37, min60: 10)
            case .age42to46: return AFTEventBounds(max100: 34, min60: 10)
            case .age47to51: return AFTEventBounds(max100: 30, min60: 10)
            case .age52to56: return AFTEventBounds(max100: 26, min60: 10)
            case .age57to61: return AFTEventBounds(max100: 22, min60: 10)
            case .age62plus:  return AFTEventBounds(max100: 18, min60: 10)
            }
        }
    }

    // MARK: - SDC (Sprint-Drag-Carry) — seconds, lower is better

    static func sdcBounds(age: Int, sex: SoldierSex) -> AFTEventBounds {
        let group = AFTAgeGroup.from(age: age)
        switch sex {
        case .male:
            switch group {
            case .age17to21: return AFTEventBounds(max100: 89, min60: 208)
            case .age22to26: return AFTEventBounds(max100: 90, min60: 208)
            case .age27to31: return AFTEventBounds(max100: 90, min60: 208)
            case .age32to36: return AFTEventBounds(max100: 93, min60: 212)
            case .age37to41: return AFTEventBounds(max100: 96, min60: 216)
            case .age42to46: return AFTEventBounds(max100: 100, min60: 220)
            case .age47to51: return AFTEventBounds(max100: 105, min60: 228)
            case .age52to56: return AFTEventBounds(max100: 113, min60: 236)
            case .age57to61: return AFTEventBounds(max100: 120, min60: 248)
            case .age62plus:  return AFTEventBounds(max100: 129, min60: 260)
            }
        case .female:
            switch group {
            case .age17to21: return AFTEventBounds(max100: 114, min60: 248)
            case .age22to26: return AFTEventBounds(max100: 113, min60: 248)
            case .age27to31: return AFTEventBounds(max100: 115, min60: 250)
            case .age32to36: return AFTEventBounds(max100: 118, min60: 254)
            case .age37to41: return AFTEventBounds(max100: 122, min60: 260)
            case .age42to46: return AFTEventBounds(max100: 128, min60: 268)
            case .age47to51: return AFTEventBounds(max100: 136, min60: 280)
            case .age52to56: return AFTEventBounds(max100: 145, min60: 296)
            case .age57to61: return AFTEventBounds(max100: 155, min60: 312)
            case .age62plus:  return AFTEventBounds(max100: 168, min60: 330)
            }
        }
    }

    // MARK: - PLK (Plank) — seconds, higher is better

    static func plankBounds(age: Int, sex: SoldierSex) -> AFTEventBounds {
        let group = AFTAgeGroup.from(age: age)
        switch sex {
        case .male:
            switch group {
            case .age17to21: return AFTEventBounds(max100: 220, min60: 110)
            case .age22to26: return AFTEventBounds(max100: 215, min60: 110)
            case .age27to31: return AFTEventBounds(max100: 210, min60: 110)
            case .age32to36: return AFTEventBounds(max100: 205, min60: 110)
            case .age37to41: return AFTEventBounds(max100: 200, min60: 100)
            case .age42to46: return AFTEventBounds(max100: 195, min60: 100)
            case .age47to51: return AFTEventBounds(max100: 190, min60: 90)
            case .age52to56: return AFTEventBounds(max100: 185, min60: 90)
            case .age57to61: return AFTEventBounds(max100: 180, min60: 80)
            case .age62plus:  return AFTEventBounds(max100: 170, min60: 70)
            }
        case .female:
            switch group {
            case .age17to21: return AFTEventBounds(max100: 220, min60: 110)
            case .age22to26: return AFTEventBounds(max100: 215, min60: 110)
            case .age27to31: return AFTEventBounds(max100: 210, min60: 110)
            case .age32to36: return AFTEventBounds(max100: 205, min60: 110)
            case .age37to41: return AFTEventBounds(max100: 200, min60: 100)
            case .age42to46: return AFTEventBounds(max100: 195, min60: 100)
            case .age47to51: return AFTEventBounds(max100: 190, min60: 90)
            case .age52to56: return AFTEventBounds(max100: 185, min60: 90)
            case .age57to61: return AFTEventBounds(max100: 180, min60: 80)
            case .age62plus:  return AFTEventBounds(max100: 170, min60: 70)
            }
        }
    }

    // MARK: - 2MR (2-Mile Run) — seconds, lower is better

    static func runBounds(age: Int, sex: SoldierSex) -> AFTEventBounds {
        let group = AFTAgeGroup.from(age: age)
        switch sex {
        case .male:
            switch group {
            case .age17to21: return AFTEventBounds(max100: 802, min60: 1316)
            case .age22to26: return AFTEventBounds(max100: 807, min60: 1326)
            case .age27to31: return AFTEventBounds(max100: 811, min60: 1338)
            case .age32to36: return AFTEventBounds(max100: 823, min60: 1356)
            case .age37to41: return AFTEventBounds(max100: 842, min60: 1386)
            case .age42to46: return AFTEventBounds(max100: 867, min60: 1416)
            case .age47to51: return AFTEventBounds(max100: 898, min60: 1452)
            case .age52to56: return AFTEventBounds(max100: 935, min60: 1500)
            case .age57to61: return AFTEventBounds(max100: 978, min60: 1560)
            case .age62plus:  return AFTEventBounds(max100: 1028, min60: 1620)
            }
        case .female:
            switch group {
            case .age17to21: return AFTEventBounds(max100: 882, min60: 1476)
            case .age22to26: return AFTEventBounds(max100: 888, min60: 1488)
            case .age27to31: return AFTEventBounds(max100: 900, min60: 1506)
            case .age32to36: return AFTEventBounds(max100: 918, min60: 1530)
            case .age37to41: return AFTEventBounds(max100: 942, min60: 1560)
            case .age42to46: return AFTEventBounds(max100: 972, min60: 1596)
            case .age47to51: return AFTEventBounds(max100: 1008, min60: 1644)
            case .age52to56: return AFTEventBounds(max100: 1050, min60: 1704)
            case .age57to61: return AFTEventBounds(max100: 1098, min60: 1776)
            case .age62plus:  return AFTEventBounds(max100: 1152, min60: 1860)
            }
        }
    }

    // MARK: - Point Calculation

    static func scoreHigherIsBetter(rawValue: Int, bounds: AFTEventBounds) -> Int {
        let value = Double(rawValue)
        guard value >= bounds.min60 else { return 0 }
        guard value < bounds.max100 else { return 100 }
        let fraction = (value - bounds.min60) / (bounds.max100 - bounds.min60)
        return 60 + Int((fraction * 40.0).rounded())
    }

    static func scoreLowerIsBetter(rawValue: Int, bounds: AFTEventBounds) -> Int {
        let value = Double(rawValue)
        guard value <= bounds.min60 else { return 0 }
        guard value > bounds.max100 else { return 100 }
        let fraction = (bounds.min60 - value) / (bounds.min60 - bounds.max100)
        return 60 + Int((fraction * 40.0).rounded())
    }

    static func scoreDeadlift(lbs: Int, age: Int, sex: SoldierSex) -> Int {
        let bounds = deadliftBounds(age: age, sex: sex)
        return scoreHigherIsBetter(rawValue: lbs, bounds: bounds)
    }

    static func scorePushUp(reps: Int, age: Int, sex: SoldierSex) -> Int {
        let bounds = pushUpBounds(age: age, sex: sex)
        return scoreHigherIsBetter(rawValue: reps, bounds: bounds)
    }

    static func scoreSDC(seconds: Int, age: Int, sex: SoldierSex) -> Int {
        let bounds = sdcBounds(age: age, sex: sex)
        return scoreLowerIsBetter(rawValue: seconds, bounds: bounds)
    }

    static func scorePlank(seconds: Int, age: Int, sex: SoldierSex) -> Int {
        let bounds = plankBounds(age: age, sex: sex)
        return scoreHigherIsBetter(rawValue: seconds, bounds: bounds)
    }

    static func scoreRun(seconds: Int, age: Int, sex: SoldierSex) -> Int {
        let bounds = runBounds(age: age, sex: sex)
        return scoreLowerIsBetter(rawValue: seconds, bounds: bounds)
    }

    // MARK: - Reverse Lookup (points → raw value needed)

    static func rawForHigherIsBetter(targetPoints: Int, bounds: AFTEventBounds) -> Int {
        let clamped = max(60, min(100, targetPoints))
        let fraction = Double(clamped - 60) / 40.0
        return Int((bounds.min60 + fraction * (bounds.max100 - bounds.min60)).rounded(.up))
    }

    static func rawForLowerIsBetter(targetPoints: Int, bounds: AFTEventBounds) -> Int {
        let clamped = max(60, min(100, targetPoints))
        let fraction = Double(clamped - 60) / 40.0
        return Int((bounds.min60 - fraction * (bounds.min60 - bounds.max100)).rounded(.down))
    }

    static func deadliftNeeded(points: Int, age: Int, sex: SoldierSex) -> Int {
        rawForHigherIsBetter(targetPoints: points, bounds: deadliftBounds(age: age, sex: sex))
    }

    static func pushUpNeeded(points: Int, age: Int, sex: SoldierSex) -> Int {
        rawForHigherIsBetter(targetPoints: points, bounds: pushUpBounds(age: age, sex: sex))
    }

    static func sdcNeeded(points: Int, age: Int, sex: SoldierSex) -> Int {
        rawForLowerIsBetter(targetPoints: points, bounds: sdcBounds(age: age, sex: sex))
    }

    static func plankNeeded(points: Int, age: Int, sex: SoldierSex) -> Int {
        rawForHigherIsBetter(targetPoints: points, bounds: plankBounds(age: age, sex: sex))
    }

    static func runNeeded(points: Int, age: Int, sex: SoldierSex) -> Int {
        rawForLowerIsBetter(targetPoints: points, bounds: runBounds(age: age, sex: sex))
    }
}
