import Foundation

nonisolated enum CardioType: String, Codable, CaseIterable, Identifiable, Sendable {
    case run = "Run"
    case bike = "Bike"
    case stationaryBike = "Stationary Bike"
    case row = "Row"
    case swim = "Swim"
    case walk = "Walk"
    case elliptical = "Elliptical"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .run: return "figure.run"
        case .bike: return "bicycle"
        case .stationaryBike: return "figure.indoor.cycle"
        case .row: return "figure.rowing"
        case .swim: return "figure.pool.swim"
        case .walk: return "figure.walk"
        case .elliptical: return "figure.elliptical"
        }
    }
}

nonisolated enum ExerciseCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case strength = "Strength"
    case cardio = "Cardio"
    case timed = "Timed"
    case bodyweight = "Bodyweight"

    var id: String { rawValue }
}

nonisolated struct WorkoutExercise: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var sets: Int
    var reps: Int
    var durationSeconds: Int
    var weight: String
    var notes: String
    var isCompleted: Bool
    var category: ExerciseCategory
    var cardioType: CardioType?
    var speedMph: Double?
    var distanceMiles: Double?
    var caloriesBurned: Int?
    var stepsLogged: Int?

    var isTimeBased: Bool { reps == 0 && durationSeconds > 0 }

    var isCardio: Bool { category == .cardio }

    var displayDetail: String {
        if isCardio {
            var parts: [String] = []
            if let dist = distanceMiles, dist > 0 {
                parts.append(String(format: "%.1f mi", dist))
            }
            if durationSeconds > 0 {
                let mins = durationSeconds / 60
                parts.append("\(mins) min")
            }
            if let spd = speedMph, spd > 0 {
                parts.append(String(format: "%.1f mph", spd))
            }
            if parts.isEmpty {
                return "\(sets) x \(durationSeconds / 60) min"
            }
            return parts.joined(separator: " · ")
        }
        if isTimeBased {
            let mins = durationSeconds / 60
            let secs = durationSeconds % 60
            if secs == 0 {
                return "\(sets) x \(mins) min"
            }
            return "\(sets) x \(mins)m \(secs)s"
        }
        var detail = "\(sets) x \(reps) reps"
        if !weight.isEmpty {
            detail += " @ \(weight)"
        }
        return detail
    }

    init(
        name: String,
        sets: Int,
        reps: Int = 0,
        durationSeconds: Int = 0,
        weight: String = "",
        notes: String = "",
        isCompleted: Bool = false,
        category: ExerciseCategory = .strength,
        cardioType: CardioType? = nil,
        speedMph: Double? = nil,
        distanceMiles: Double? = nil,
        caloriesBurned: Int? = nil,
        stepsLogged: Int? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.sets = sets
        self.reps = reps
        self.durationSeconds = durationSeconds
        self.weight = weight
        self.notes = notes
        self.isCompleted = isCompleted
        self.category = category
        self.cardioType = cardioType
        self.speedMph = speedMph
        self.distanceMiles = distanceMiles
        self.caloriesBurned = caloriesBurned
        self.stepsLogged = stepsLogged
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        sets = try container.decode(Int.self, forKey: .sets)
        reps = try container.decode(Int.self, forKey: .reps)
        durationSeconds = try container.decode(Int.self, forKey: .durationSeconds)
        weight = try container.decode(String.self, forKey: .weight)
        notes = try container.decode(String.self, forKey: .notes)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        category = try container.decodeIfPresent(ExerciseCategory.self, forKey: .category) ?? .strength
        cardioType = try container.decodeIfPresent(CardioType.self, forKey: .cardioType)
        speedMph = try container.decodeIfPresent(Double.self, forKey: .speedMph)
        distanceMiles = try container.decodeIfPresent(Double.self, forKey: .distanceMiles)
        caloriesBurned = try container.decodeIfPresent(Int.self, forKey: .caloriesBurned)
        stepsLogged = try container.decodeIfPresent(Int.self, forKey: .stepsLogged)
    }
}

nonisolated struct WorkoutDay: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var dayIndex: Int
    var date: Date
    var title: String
    var exercises: [WorkoutExercise]
    var isCompleted: Bool
    var isRestDay: Bool
    var templateTag: String

    var completedExerciseCount: Int {
        exercises.filter(\.isCompleted).count
    }

    var totalSteps: Int {
        exercises.compactMap(\.stepsLogged).reduce(0, +)
    }

    init(
        dayIndex: Int,
        date: Date = .now,
        title: String,
        exercises: [WorkoutExercise],
        isCompleted: Bool = false,
        isRestDay: Bool = false,
        templateTag: String = ""
    ) {
        self.id = UUID()
        self.dayIndex = dayIndex
        self.date = date
        self.title = title
        self.exercises = exercises
        self.isCompleted = isCompleted
        self.isRestDay = isRestDay
        self.templateTag = templateTag
    }
}

nonisolated struct WeeklyPlan: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var weekStartDate: Date
    var goal: String
    var level: String
    var equipment: String
    var minutesPerWorkout: Int
    var days: [WorkoutDay]

    init(
        weekStartDate: Date = .now,
        goal: String,
        level: String,
        equipment: String,
        minutesPerWorkout: Int,
        days: [WorkoutDay]
    ) {
        self.id = UUID()
        self.weekStartDate = weekStartDate
        self.goal = goal
        self.level = level
        self.equipment = equipment
        self.minutesPerWorkout = minutesPerWorkout
        self.days = days
    }

    var completedCount: Int {
        days.filter(\.isCompleted).count
    }

    var totalWorkoutDays: Int {
        days.filter { !$0.isRestDay }.count
    }
}

nonisolated struct CompletedWorkoutRecord: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var date: Date
    var title: String
    var exerciseCount: Int

    init(date: Date = .now, title: String, exerciseCount: Int) {
        self.id = UUID()
        self.date = date
        self.title = title
        self.exerciseCount = exerciseCount
    }
}
