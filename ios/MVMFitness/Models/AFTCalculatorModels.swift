import Foundation

nonisolated enum SoldierSex: String, CaseIterable, Codable, Identifiable, Sendable {
    case male = "Male"
    case female = "Female"

    var id: String { rawValue }
}

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
    case age62plus  = "Over 62"

    static func from(age: Int) -> AFTAgeGroup {
        switch age {
        case ..<17:   return .age17to21
        case 17...21: return .age17to21
        case 22...26: return .age22to26
        case 27...31: return .age27to31
        case 32...36: return .age32to36
        case 37...41: return .age37to41
        case 42...46: return .age42to46
        case 47...51: return .age47to51
        case 52...56: return .age52to56
        case 57...61: return .age57to61
        default:      return .age62plus
        }
    }

    var displayLabel: String {
        self == .age62plus ? "62+" : rawValue
    }
}

nonisolated enum AFTStandard: String, CaseIterable, Codable, Identifiable, Sendable {
    case combat = "Combat"
    case general = "General"

    var id: String { rawValue }

    var minimumPerEvent: Int {
        switch self {
        case .combat: return 60
        case .general: return 60
        }
    }

    var minimumTotal: Int {
        switch self {
        case .combat: return 350
        case .general: return 300
        }
    }
}

nonisolated struct AFTCalculatorResult: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var date: Date
    var soldierName: String
    var age: Int
    var sex: SoldierSex
    var standard: AFTStandard
    var deadliftLbs: Int
    var pushUpReps: Int
    var sdcSeconds: Int
    var plankSeconds: Int
    var runSeconds: Int
    var deadliftPoints: Int
    var pushUpPoints: Int
    var sdcPoints: Int
    var plankPoints: Int
    var runPoints: Int
    var totalScore: Int
    var passed: Bool
    var weakestEvents: [String]

    init(
        date: Date = .now,
        soldierName: String,
        age: Int,
        sex: SoldierSex,
        standard: AFTStandard,
        deadliftLbs: Int,
        pushUpReps: Int,
        sdcSeconds: Int,
        plankSeconds: Int,
        runSeconds: Int,
        deadliftPoints: Int,
        pushUpPoints: Int,
        sdcPoints: Int,
        plankPoints: Int,
        runPoints: Int,
        totalScore: Int,
        passed: Bool,
        weakestEvents: [String]
    ) {
        self.id = UUID()
        self.date = date
        self.soldierName = soldierName
        self.age = age
        self.sex = sex
        self.standard = standard
        self.deadliftLbs = deadliftLbs
        self.pushUpReps = pushUpReps
        self.sdcSeconds = sdcSeconds
        self.plankSeconds = plankSeconds
        self.runSeconds = runSeconds
        self.deadliftPoints = deadliftPoints
        self.pushUpPoints = pushUpPoints
        self.sdcPoints = sdcPoints
        self.plankPoints = plankPoints
        self.runPoints = runPoints
        self.totalScore = totalScore
        self.passed = passed
        self.weakestEvents = weakestEvents
    }
}
