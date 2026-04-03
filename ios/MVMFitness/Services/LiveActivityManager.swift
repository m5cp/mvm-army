import ActivityKit
import Foundation

enum LiveActivityManager {
    private static var currentActivity: Activity<WorkoutActivityAttributes>?

    static func startWorkout(title: String, exerciseName: String, totalExercises: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = WorkoutActivityAttributes(workoutTitle: title)
        let state = WorkoutActivityAttributes.ContentState(
            exerciseName: exerciseName,
            exerciseIndex: 1,
            totalExercises: totalExercises,
            timeRemaining: 0,
            isRunning: true,
            workoutProgress: 0
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
        } catch {
        }
    }

    static func updateWorkout(
        exerciseName: String,
        exerciseIndex: Int,
        totalExercises: Int,
        timeRemaining: Int,
        isRunning: Bool
    ) {
        guard let activity = currentActivity else { return }

        let progress = totalExercises > 0 ? Double(exerciseIndex - 1) / Double(totalExercises) : 0

        let state = WorkoutActivityAttributes.ContentState(
            exerciseName: exerciseName,
            exerciseIndex: exerciseIndex,
            totalExercises: totalExercises,
            timeRemaining: timeRemaining,
            isRunning: isRunning,
            workoutProgress: progress
        )

        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    static func endWorkout() {
        guard let activity = currentActivity else { return }

        let finalState = WorkoutActivityAttributes.ContentState(
            exerciseName: "Complete",
            exerciseIndex: 0,
            totalExercises: 0,
            timeRemaining: 0,
            isRunning: false,
            workoutProgress: 1.0
        )

        Task {
            await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .default)
        }
        currentActivity = nil
    }

    static var isActive: Bool {
        currentActivity != nil
    }
}
