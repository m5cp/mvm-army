import Foundation

nonisolated enum WODFormat: String, Codable, CaseIterable, Sendable {
    case amrap = "AMRAP"
    case emom = "EMOM"
    case forTime = "For Time"
    case interval = "Interval"
    case chipper = "Chipper"
    case ladder = "Ladder"
    case tabata = "Tabata"
    case circuit = "Circuit"
}

nonisolated enum WODCategory: String, Codable, CaseIterable, Sendable {
    case crossfit = "CrossFit-Style"
    case aftStyle = "AFT-Style"
    case tactical = "Tactical"
    case bodyweight = "Bodyweight"
}

nonisolated enum WODEquipment: String, Codable, Sendable {
    case none = "No Equipment"
    case minimal = "Minimal"
    case gym = "Gym"
}

nonisolated struct WODMovement: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var reps: String?
    var duration: String?
    var notes: String?

    init(name: String, reps: String? = nil, duration: String? = nil, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.reps = reps
        self.duration = duration
        self.notes = notes
    }
}

nonisolated struct WODTemplate: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var title: String
    var category: WODCategory
    var format: WODFormat
    var durationMinutes: Int
    var equipment: WODEquipment
    var movements: [WODMovement]
    var workoutDescription: String
    var notes: String?

    init(
        title: String,
        category: WODCategory,
        format: WODFormat,
        durationMinutes: Int,
        equipment: WODEquipment,
        movements: [WODMovement],
        workoutDescription: String,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.format = format
        self.durationMinutes = durationMinutes
        self.equipment = equipment
        self.movements = movements
        self.workoutDescription = workoutDescription
        self.notes = notes
    }
}
