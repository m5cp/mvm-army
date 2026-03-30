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

nonisolated enum PTGoal: String, CaseIterable, Codable, Identifiable, Sendable {
    case aftScoreImprovement = "AFT Score Improvement"
    case endurance = "Endurance"
    case power = "Power"
    case speed = "Speed"
    case cardio = "Cardio"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .aftScoreImprovement: return "shield.checkered"
        case .endurance: return "figure.run"
        case .power: return "figure.strengthtraining.traditional"
        case .speed: return "bolt.fill"
        case .cardio: return "heart.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .aftScoreImprovement: return "Maximize your ACFT score across all events"
        case .endurance: return "Build stamina for long-distance and sustained effort"
        case .power: return "Increase explosive strength and max lifts"
        case .speed: return "Improve sprint times, agility, and quickness"
        case .cardio: return "Strengthen cardiovascular fitness and recovery"
        }
    }

    var armyFocuses: [ArmyFocus] {
        switch self {
        case .aftScoreImprovement:
            return [.lowerStrength, .upperEndurance, .workCapacity, .coreRun, .aftPrep, .endurance]
        case .endurance:
            return [.endurance, .coreRun, .endurance, .workCapacity, .endurance, .recovery]
        case .power:
            return [.lowerStrength, .lowerStrength, .upperEndurance, .workCapacity, .lowerStrength, .coreRun]
        case .speed:
            return [.workCapacity, .endurance, .tactical, .workCapacity, .coreRun, .endurance]
        case .cardio:
            return [.endurance, .coreRun, .endurance, .coreRun, .recovery, .endurance]
        }
    }
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
