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

nonisolated struct WODPlan: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var days: [WODPlanDay]
    var ptGoal: String
    var totalWeeks: Int
    var currentWeek: Int
    var weekStartDate: Date

    init(
        days: [WODPlanDay],
        ptGoal: String = "",
        totalWeeks: Int = 4,
        currentWeek: Int = 1,
        weekStartDate: Date = .now
    ) {
        self.id = UUID()
        self.days = days
        self.ptGoal = ptGoal
        self.totalWeeks = totalWeeks
        self.currentWeek = currentWeek
        self.weekStartDate = weekStartDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        days = try container.decode([WODPlanDay].self, forKey: .days)
        ptGoal = try container.decodeIfPresent(String.self, forKey: .ptGoal) ?? ""
        totalWeeks = try container.decodeIfPresent(Int.self, forKey: .totalWeeks) ?? 4
        currentWeek = try container.decodeIfPresent(Int.self, forKey: .currentWeek) ?? 1
        weekStartDate = try container.decodeIfPresent(Date.self, forKey: .weekStartDate) ?? .now
    }
}

nonisolated struct WODPlanDay: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var date: Date
    var template: WODTemplate
    var isRestDay: Bool
    var isCompleted: Bool

    init(
        date: Date,
        template: WODTemplate,
        isRestDay: Bool = false,
        isCompleted: Bool = false
    ) {
        self.id = UUID()
        self.date = date
        self.template = template
        self.isRestDay = isRestDay
        self.isCompleted = isCompleted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        template = try container.decode(WODTemplate.self, forKey: .template)
        isRestDay = try container.decodeIfPresent(Bool.self, forKey: .isRestDay) ?? false
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
    }
}
