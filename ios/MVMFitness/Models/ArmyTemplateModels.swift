import Foundation

nonisolated enum ArmyWorkoutMode: String, Codable, CaseIterable, Sendable {
    case onDutyIndividual = "On-Duty Individual PT"
    case offDutyIndividual = "Off-Duty Individual PT"
    case unitPT = "Unit PT"
    case workoutOfDay = "Workout of the Day"
    case randomSession = "Random Session"
}

nonisolated enum ArmyFocus: String, Codable, CaseIterable, Sendable {
    case aftPrep = "AFT Prep"
    case lowerStrength = "Lower Strength"
    case upperEndurance = "Upper Endurance"
    case workCapacity = "Work Capacity"
    case coreRun = "Core + Run"
    case endurance = "Endurance"
    case tactical = "Tactical Conditioning"
    case recovery = "Recovery"
}

nonisolated enum ArmyEquipment: String, Codable, CaseIterable, Sendable {
    case bodyweight = "Bodyweight"
    case minimal = "Minimal"
    case gym = "Gym"
    case running = "Running"
    case field = "Field"
}

nonisolated struct ArmyExercise: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var sets: Int?
    var reps: String?
    var duration: String?
    var notes: String?

    init(name: String, sets: Int? = nil, reps: String? = nil, duration: String? = nil, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.sets = sets
        self.reps = reps
        self.duration = duration
        self.notes = notes
    }
}

nonisolated struct ArmyWorkoutTemplate: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var title: String
    var mode: ArmyWorkoutMode
    var focus: ArmyFocus
    var equipment: [ArmyEquipment]
    var objective: String
    var warmup: [ArmyExercise]
    var mainEffort: [ArmyExercise]
    var cooldown: [ArmyExercise]
    var leaderNotes: String?

    init(
        title: String,
        mode: ArmyWorkoutMode,
        focus: ArmyFocus,
        equipment: [ArmyEquipment],
        objective: String,
        warmup: [ArmyExercise],
        mainEffort: [ArmyExercise],
        cooldown: [ArmyExercise],
        leaderNotes: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.mode = mode
        self.focus = focus
        self.equipment = equipment
        self.objective = objective
        self.warmup = warmup
        self.mainEffort = mainEffort
        self.cooldown = cooldown
        self.leaderNotes = leaderNotes
    }
}
