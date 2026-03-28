import Foundation

nonisolated enum TrainingGoal: String, CaseIterable, Codable, Identifiable, Sendable {
    case muscleBuilding = "Muscle Building"
    case generalFitness = "General Fitness"
    case sportsTraining = "Sports Training"
    case militaryFitness = "Military Fitness"
    case policeFitness = "Police Fitness"
    case fireRescue = "Fire / Rescue"
    case distanceRunning = "Distance Running"
    case conditioning = "Conditioning"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .muscleBuilding: return "figure.strengthtraining.traditional"
        case .generalFitness: return "figure.mixed.cardio"
        case .sportsTraining: return "sportscourt.fill"
        case .militaryFitness: return "shield.fill"
        case .policeFitness: return "star.shield.fill"
        case .fireRescue: return "flame.fill"
        case .distanceRunning: return "figure.run"
        case .conditioning: return "bolt.heart.fill"
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
    case dumbbells = "Dumbbells"
    case gym = "Full Gym"
    case outdoor = "Outdoor / Running"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .bodyweight: return "figure.stand"
        case .dumbbells: return "dumbbell.fill"
        case .gym: return "building.2.fill"
        case .outdoor: return "sun.max.fill"
        }
    }
}
