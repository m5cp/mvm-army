import Foundation

nonisolated struct PTPlanQRExercise: Codable, Sendable {
    var n: String
    var s: Int
    var r: Int
    var d: Int
    var w: String?
    var c: String?

    init(from exercise: WorkoutExercise) {
        self.n = exercise.name
        self.s = exercise.sets
        self.r = exercise.reps
        self.d = exercise.durationSeconds
        self.w = exercise.weight.isEmpty ? nil : exercise.weight
        self.c = exercise.category.rawValue
    }

    func toWorkoutExercise() -> WorkoutExercise {
        WorkoutExercise(
            name: n,
            sets: s,
            reps: r,
            durationSeconds: d,
            weight: w ?? "",
            category: ExerciseCategory(rawValue: c ?? "Strength") ?? .strength
        )
    }
}

nonisolated struct PTPlanQRDay: Codable, Sendable {
    var t: String
    var rest: Bool?
    var tg: [String]?
    var ex: [PTPlanQRExercise]?

    init(from day: WorkoutDay) {
        self.t = day.title
        self.rest = day.isRestDay ? true : nil
        self.tg = day.tags.isEmpty ? nil : Array(day.tags.prefix(2))
        self.ex = day.isRestDay ? nil : day.exercises.map { PTPlanQRExercise(from: $0) }
    }
}

nonisolated struct PTPlanQRPayload: Codable, Sendable {
    var v: Int
    var tp: String
    var g: String?
    var wk: Int
    var tw: Int
    var days: [PTPlanQRDay]

    init(from plan: WeeklyPlan) {
        self.v = 1
        self.tp = "plan"
        self.g = plan.ptGoal.isEmpty ? nil : plan.ptGoal
        self.wk = plan.currentWeek
        self.tw = plan.totalWeeks
        self.days = plan.days.map { PTPlanQRDay(from: $0) }
    }

    var compactJSON: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = []
        return try? encoder.encode(self)
    }

    func toWeeklyPlan() -> WeeklyPlan {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: .now)
        let workoutDays: [WorkoutDay] = days.enumerated().map { index, qrDay in
            let date = calendar.date(byAdding: .day, value: index, to: startDate) ?? startDate
            return WorkoutDay(
                dayIndex: index,
                date: date,
                title: qrDay.t,
                exercises: qrDay.ex?.map { $0.toWorkoutExercise() } ?? [],
                isRestDay: qrDay.rest ?? false,
                tags: qrDay.tg ?? [],
                source: .imported
            )
        }

        return WeeklyPlan(
            weekStartDate: startDate,
            goal: g ?? "",
            level: "",
            equipment: "",
            minutesPerWorkout: 30,
            days: workoutDays,
            totalWeeks: tw,
            currentWeek: wk,
            ptGoal: g ?? ""
        )
    }
}
