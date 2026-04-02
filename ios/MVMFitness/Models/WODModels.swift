import Foundation

nonisolated enum WODHeroPreference: String, Codable, CaseIterable, Sendable, Identifiable {
    case regular = "FunctionFitness Plan"
    case mixed = "Free Weights"
    case heroOnly = "Elite Challenge Plan"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .regular: return "Standard FunctionFitness workouts"
        case .mixed: return "Strength & hypertrophy with free weights"
        case .heroOnly: return "FunctionFitness + Free Weight hybrid"
        }
    }

    var icon: String {
        switch self {
        case .regular: return "flame.fill"
        case .mixed: return "dumbbell.fill"
        case .heroOnly: return "bolt.heart.fill"
        }
    }
}

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
    case crossfit = "FunctionFitness"
    case aftStyle = "AFT-Style"
    case tactical = "Tactical"
    case bodyweight = "Bodyweight"
    case freeWeight = "Free Weight"
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

nonisolated enum IntensityGrade: String, Codable, CaseIterable, Sendable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case extreme = "Extreme"
}

nonisolated enum TrainingSplit: String, Codable, CaseIterable, Sendable {
    case fullBody = "Full Body"
    case upperBody = "Upper Body"
    case lowerBody = "Lower Body"
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case conditioning = "Conditioning"
    case mixed = "Mixed"
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
    var intensityGrade: IntensityGrade
    var trainingSplit: TrainingSplit

    init(
        title: String,
        category: WODCategory,
        format: WODFormat,
        durationMinutes: Int,
        equipment: WODEquipment,
        movements: [WODMovement],
        workoutDescription: String,
        notes: String? = nil,
        intensityGrade: IntensityGrade = .moderate,
        trainingSplit: TrainingSplit = .mixed
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
        self.intensityGrade = intensityGrade
        self.trainingSplit = trainingSplit
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        category = try container.decodeIfPresent(WODCategory.self, forKey: .category) ?? .crossfit
        format = try container.decode(WODFormat.self, forKey: .format)
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        equipment = try container.decode(WODEquipment.self, forKey: .equipment)
        movements = try container.decode([WODMovement].self, forKey: .movements)
        workoutDescription = try container.decode(String.self, forKey: .workoutDescription)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        intensityGrade = try container.decodeIfPresent(IntensityGrade.self, forKey: .intensityGrade) ?? .moderate
        trainingSplit = try container.decodeIfPresent(TrainingSplit.self, forKey: .trainingSplit) ?? .mixed
    }
}

nonisolated struct WODPlan: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var days: [WODPlanDay]
    var ptGoal: String
    var totalWeeks: Int
    var currentWeek: Int
    var weekStartDate: Date
    var heroPreference: WODHeroPreference
    var trainingFrequency: Int
    var trainingGoal: String
    var workoutStyle: String

    init(
        days: [WODPlanDay],
        ptGoal: String = "",
        totalWeeks: Int = 4,
        currentWeek: Int = 1,
        weekStartDate: Date = .now,
        heroPreference: WODHeroPreference = .regular,
        trainingFrequency: Int = 5,
        trainingGoal: String = "",
        workoutStyle: String = ""
    ) {
        self.id = UUID()
        self.days = days
        self.ptGoal = ptGoal
        self.totalWeeks = totalWeeks
        self.currentWeek = currentWeek
        self.weekStartDate = weekStartDate
        self.heroPreference = heroPreference
        self.trainingFrequency = trainingFrequency
        self.trainingGoal = trainingGoal
        self.workoutStyle = workoutStyle
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        days = try container.decode([WODPlanDay].self, forKey: .days)
        ptGoal = try container.decodeIfPresent(String.self, forKey: .ptGoal) ?? ""
        totalWeeks = try container.decodeIfPresent(Int.self, forKey: .totalWeeks) ?? 4
        currentWeek = try container.decodeIfPresent(Int.self, forKey: .currentWeek) ?? 1
        weekStartDate = try container.decodeIfPresent(Date.self, forKey: .weekStartDate) ?? .now
        heroPreference = try container.decodeIfPresent(WODHeroPreference.self, forKey: .heroPreference) ?? .regular
        trainingFrequency = try container.decodeIfPresent(Int.self, forKey: .trainingFrequency) ?? 5
        trainingGoal = try container.decodeIfPresent(String.self, forKey: .trainingGoal) ?? ""
        workoutStyle = try container.decodeIfPresent(String.self, forKey: .workoutStyle) ?? ""
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
