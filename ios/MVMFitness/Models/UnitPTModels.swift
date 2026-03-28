import Foundation

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
