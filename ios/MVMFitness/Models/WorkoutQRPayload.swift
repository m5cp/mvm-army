import Foundation

nonisolated struct WorkoutQRExercise: Codable, Sendable {
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

nonisolated struct WorkoutQRPayload: Codable, Sendable {
    var v: Int
    var tp: String
    var t: String
    var tg: [String]?
    var ex: [WorkoutQRExercise]

    init(from workout: WorkoutDay, type: String = "individual") {
        self.v = 1
        self.tp = type
        self.t = workout.title
        self.tg = workout.tags.isEmpty ? nil : Array(workout.tags.prefix(3))
        self.ex = workout.exercises.map { WorkoutQRExercise(from: $0) }
    }

    var compactJSON: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = []
        return try? encoder.encode(self)
    }

    func toWorkoutDay() -> WorkoutDay {
        WorkoutDay(
            dayIndex: -1,
            date: Calendar.current.startOfDay(for: .now),
            title: t,
            exercises: ex.map { $0.toWorkoutExercise() },
            templateTag: "imported_qr",
            tags: tg ?? []
        )
    }
}
