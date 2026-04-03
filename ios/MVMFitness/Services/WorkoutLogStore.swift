import Foundation

@Observable
final class WorkoutLogStore {
    static let shared = WorkoutLogStore()

    private init() {}

    func logWorkout(name: String, sets: Int, reps: Int, weight: String) {
        let exercise = WorkoutExercise(
            name: name,
            sets: sets,
            reps: reps,
            weight: weight,
            isCompleted: true,
            category: ExerciseLibrary.isWeightedExercise(name) ? .strength : .bodyweight
        )

        let record = CompletedWorkoutRecord(
            title: name,
            exerciseCount: 1,
            exercises: [exercise]
        )

        var records = LocalStore.load([CompletedWorkoutRecord].self, forKey: "completedRecords", fallback: [])
        records.insert(record, at: 0)
        LocalStore.save(records, forKey: "completedRecords")

        NotificationCenter.default.post(name: .workoutLoggedViaSiri, object: nil)
    }
}

extension Notification.Name {
    static let workoutLoggedViaSiri = Notification.Name("workoutLoggedViaSiri")
}
