import ActivityKit
import Foundation

struct WorkoutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        var exerciseName: String
        var exerciseIndex: Int
        var totalExercises: Int
        var timeRemaining: Int
        var isRunning: Bool
        var workoutProgress: Double
    }

    var workoutTitle: String
}
