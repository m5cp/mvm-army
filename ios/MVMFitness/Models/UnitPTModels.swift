import Foundation

nonisolated struct UnitPTDayPlan: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var date: Date
    var dayIndex: Int
    var weekIndex: Int
    var title: String
    var objective: String
    var formationNotes: String
    var equipment: String
    var warmup: String
    var mainEffort: [UnitPTBlock]
    var cooldown: String
    var leaderNotes: String
    var task: String
    var condition: String
    var standard: String
    var isCompleted: Bool

    init(
        date: Date = .now,
        dayIndex: Int = 0,
        weekIndex: Int = 0,
        title: String,
        objective: String,
        formationNotes: String,
        equipment: String,
        warmup: String,
        mainEffort: [UnitPTBlock],
        cooldown: String,
        leaderNotes: String,
        task: String = "",
        condition: String = "",
        standard: String = "",
        isCompleted: Bool = false
    ) {
        self.id = UUID()
        self.date = date
        self.dayIndex = dayIndex
        self.weekIndex = weekIndex
        self.title = title
        self.objective = objective
        self.formationNotes = formationNotes
        self.equipment = equipment
        self.warmup = warmup
        self.mainEffort = mainEffort
        self.cooldown = cooldown
        self.leaderNotes = leaderNotes
        self.task = task
        self.condition = condition
        self.standard = standard
        self.isCompleted = isCompleted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        dayIndex = try container.decodeIfPresent(Int.self, forKey: .dayIndex) ?? 0
        weekIndex = try container.decodeIfPresent(Int.self, forKey: .weekIndex) ?? 0
        title = try container.decode(String.self, forKey: .title)
        objective = try container.decode(String.self, forKey: .objective)
        formationNotes = try container.decode(String.self, forKey: .formationNotes)
        equipment = try container.decode(String.self, forKey: .equipment)
        warmup = try container.decode(String.self, forKey: .warmup)
        mainEffort = try container.decode([UnitPTBlock].self, forKey: .mainEffort)
        cooldown = try container.decode(String.self, forKey: .cooldown)
        leaderNotes = try container.decode(String.self, forKey: .leaderNotes)
        task = try container.decodeIfPresent(String.self, forKey: .task) ?? ""
        condition = try container.decodeIfPresent(String.self, forKey: .condition) ?? ""
        standard = try container.decodeIfPresent(String.self, forKey: .standard) ?? ""
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
    }

    var shareText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let blocks = mainEffort.enumerated().map { index, block in
            "\(index + 1). \(block.description)"
        }.joined(separator: "\n")

        var text = """
        \(title)
        Date: \(formatter.string(from: date))

        Objective:
        \(objective)

        Formation:
        \(formationNotes)

        Equipment:
        \(equipment)

        Warm-Up:
        \(warmup)

        Main Effort:
        \(blocks)

        Cool-Down:
        \(cooldown)

        Leader Notes:
        \(leaderNotes)
        """

        if !task.isEmpty {
            text += "\n\nTask: \(task)"
        }
        if !condition.isEmpty {
            text += "\nCondition: \(condition)"
        }
        if !standard.isEmpty {
            text += "\nStandard: \(standard)"
        }

        return text
    }
}

nonisolated struct UnitPTWeekPlan: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var weekIndex: Int
    var days: [UnitPTDayPlan]
    var weekStartDate: Date

    init(weekIndex: Int, days: [UnitPTDayPlan], weekStartDate: Date) {
        self.id = UUID()
        self.weekIndex = weekIndex
        self.days = days
        self.weekStartDate = weekStartDate
    }

    var completedCount: Int {
        days.filter(\.isCompleted).count
    }
}

nonisolated struct UnitPTFullPlan: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var goal: String
    var totalWeeks: Int
    var daysPerWeek: Int
    var weeks: [UnitPTWeekPlan]
    var createdDate: Date
    var planStartDate: Date

    init(
        goal: String,
        totalWeeks: Int,
        daysPerWeek: Int,
        weeks: [UnitPTWeekPlan],
        planStartDate: Date = .now
    ) {
        self.id = UUID()
        self.goal = goal
        self.totalWeeks = totalWeeks
        self.daysPerWeek = daysPerWeek
        self.weeks = weeks
        self.createdDate = .now
        self.planStartDate = planStartDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        goal = try container.decode(String.self, forKey: .goal)
        totalWeeks = try container.decode(Int.self, forKey: .totalWeeks)
        daysPerWeek = try container.decodeIfPresent(Int.self, forKey: .daysPerWeek) ?? 5
        weeks = try container.decode([UnitPTWeekPlan].self, forKey: .weeks)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        planStartDate = try container.decodeIfPresent(Date.self, forKey: .planStartDate) ?? .now
    }

    var allDays: [UnitPTDayPlan] {
        weeks.flatMap(\.days)
    }

    var totalCompletedDays: Int {
        weeks.map(\.completedCount).reduce(0, +)
    }

    var totalWorkoutDays: Int {
        allDays.count
    }

    var shareText: String {
        var text = "Unit PT Plan — \(goal)\n"
        text += "\(totalWeeks) Weeks · \(daysPerWeek) Days/Week\n\n"

        for week in weeks {
            text += "━━ Week \(week.weekIndex + 1) ━━\n"
            for day in week.days {
                let dateStr = day.date.formatted(date: .abbreviated, time: .omitted)
                text += "\nDay \(day.dayIndex + 1) (\(dateStr)): \(day.title)\n"
                text += "Objective: \(day.objective)\n"
                let blocks = day.mainEffort.enumerated().map { i, b in "  \(i+1). \(b.description)" }.joined(separator: "\n")
                text += "Main Effort:\n\(blocks)\n"
            }
            text += "\n"
        }

        text += "#MVMFitness"
        return text
    }
}

nonisolated struct UnitPTPlan: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var date: Date
    var title: String
    var objective: String
    var formationNotes: String
    var equipment: String
    var warmup: String
    var mainEffort: [UnitPTBlock]
    var cooldown: String
    var leaderNotes: String

    init(
        date: Date = .now,
        title: String,
        objective: String,
        formationNotes: String,
        equipment: String,
        warmup: String,
        mainEffort: [UnitPTBlock],
        cooldown: String,
        leaderNotes: String
    ) {
        self.id = UUID()
        self.date = date
        self.title = title
        self.objective = objective
        self.formationNotes = formationNotes
        self.equipment = equipment
        self.warmup = warmup
        self.mainEffort = mainEffort
        self.cooldown = cooldown
        self.leaderNotes = leaderNotes
    }

    var shareText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let blocks = mainEffort.enumerated().map { index, block in
            "\(index + 1). \(block.description)"
        }.joined(separator: "\n")

        return """
        \(title)
        Date: \(formatter.string(from: date))

        Objective:
        \(objective)

        Formation:
        \(formationNotes)

        Equipment:
        \(equipment)

        Warm-Up:
        \(warmup)

        Main Effort:
        \(blocks)

        Cool-Down:
        \(cooldown)

        Leader Notes:
        \(leaderNotes)
        """
    }

    var qrJSON: Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(self)
    }
}

nonisolated struct UnitPTBlock: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var description: String

    init(_ description: String) {
        self.id = UUID()
        self.description = description
    }
}
