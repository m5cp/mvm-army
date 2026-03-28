import Foundation

nonisolated enum PTMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case individual = "Individual PT"
    case unit = "Unit PT"
    case both = "Both"

    var id: String { rawValue }
}

nonisolated enum DutyType: String, CaseIterable, Codable, Identifiable, Sendable {
    case onDuty = "On-Duty"
    case offDuty = "Off-Duty"
    case both = "Both"

    var id: String { rawValue }
}

nonisolated enum TrainingFocus: String, CaseIterable, Codable, Identifiable, Sendable {
    case aftPrep = "AFT Prep"
    case strength = "Strength"
    case endurance = "Endurance"
    case tacticalConditioning = "Tactical Conditioning"
    case recovery = "Recovery"
    case generalArmyFitness = "General Army Fitness"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .aftPrep: return "shield.fill"
        case .strength: return "figure.strengthtraining.traditional"
        case .endurance: return "figure.run"
        case .tacticalConditioning: return "bolt.heart.fill"
        case .recovery: return "figure.cooldown"
        case .generalArmyFitness: return "figure.mixed.cardio"
        }
    }
}

nonisolated enum FitnessLevel: String, CaseIterable, Codable, Identifiable, Sendable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var id: String { rawValue }
}

nonisolated enum EquipmentOption: String, CaseIterable, Codable, Identifiable, Sendable {
    case bodyweight = "Bodyweight"
    case minimal = "Minimal"
    case gym = "Full Gym"
    case running = "Running"
    case field = "Field"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .bodyweight: return "figure.stand"
        case .minimal: return "dumbbell.fill"
        case .gym: return "building.2.fill"
        case .running: return "figure.run"
        case .field: return "leaf.fill"
        }
    }
}
