import Foundation

nonisolated struct UnitPTQRExercise: Codable, Sendable {
    var n: String
    var s: Int?
    var r: String?
    var d: String?

    init(from exercise: ArmyExercise) {
        self.n = exercise.name
        self.s = exercise.sets
        self.r = exercise.reps
        self.d = exercise.duration
    }

    func toDescription() -> String {
        var parts: [String] = [n]
        if let s { parts.append("\(s) sets") }
        if let r { parts.append("\(r) reps") }
        if let d { parts.append(d) }
        return parts.joined(separator: " · ")
    }
}

nonisolated struct UnitPTQRCodePayload: Codable, Sendable {
    var t: String
    var dt: String
    var obj: String
    var eq: String
    var wu: [UnitPTQRExercise]
    var me: [UnitPTQRExercise]
    var cd: [UnitPTQRExercise]
    var ln: String?

    init(from plan: UnitPTPlan, template: ArmyWorkoutTemplate? = nil) {
        self.t = plan.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.dt = formatter.string(from: plan.date)
        self.obj = plan.objective
        self.eq = plan.equipment

        if let template {
            self.wu = template.warmup.map { UnitPTQRExercise(from: $0) }
            self.me = template.mainEffort.map { UnitPTQRExercise(from: $0) }
            self.cd = template.cooldown.map { UnitPTQRExercise(from: $0) }
        } else {
            self.wu = []
            self.me = []
            self.cd = []
        }

        self.ln = plan.leaderNotes.isEmpty ? nil : plan.leaderNotes
    }

    init(from plan: UnitPTPlan) {
        self.t = plan.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.dt = formatter.string(from: plan.date)
        self.obj = plan.objective
        self.eq = plan.equipment
        self.wu = []
        self.me = plan.mainEffort.map { block in
            UnitPTQRExercise(from: ArmyExercise(name: block.description))
        }
        self.cd = []
        self.ln = plan.leaderNotes.isEmpty ? nil : plan.leaderNotes
    }

    var compactJSON: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = []
        return try? encoder.encode(self)
    }

    func toUnitPTPlan() -> UnitPTPlan {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dt) ?? .now

        let warmupText: String
        if wu.isEmpty {
            warmupText = "Prep Drill"
        } else {
            warmupText = wu.map { $0.toDescription() }.joined(separator: "\n")
        }

        let cooldownText: String
        if cd.isEmpty {
            cooldownText = "Recovery Drill"
        } else {
            cooldownText = cd.map { $0.toDescription() }.joined(separator: "\n")
        }

        let blocks = me.map { UnitPTBlock($0.toDescription()) }

        return UnitPTPlan(
            date: date,
            title: t,
            objective: obj,
            formationNotes: "",
            equipment: eq,
            warmup: warmupText,
            mainEffort: blocks,
            cooldown: cooldownText,
            leaderNotes: ln ?? ""
        )
    }
}
