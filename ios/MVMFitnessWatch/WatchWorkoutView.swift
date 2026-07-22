import SwiftUI
import HealthKit

struct WatchWorkoutView: View {
    @State private var manager = WatchWorkoutManager.shared
    @State private var authorized = false

    private let activities: [(String, String, HKWorkoutActivityType, Bool)] = [
        ("Outdoor Run", "figure.run", .running, true),
        ("Indoor Run", "figure.run.treadmill", .running, false),
        ("Functional", "figure.strengthtraining.functional", .functionalStrengthTraining, false),
        ("Outdoor Bike", "figure.outdoor.cycle", .cycling, true),
        ("Hike", "figure.hiking", .hiking, true)
    ]

    var body: some View {
        Group {
            if manager.isActive {
                activeView
            } else {
                List {
                    ForEach(activities, id: \.0) { activity in
                        Button {
                            Task {
                                if !authorized { authorized = await manager.requestAuthorization() }
                                if authorized { await manager.start(activityType: activity.2, isOutdoor: activity.3) }
                            }
                        } label: {
                            Label(activity.0, systemImage: activity.1)
                        }
                    }
                }
                .navigationTitle("Workout")
            }
        }
    }

    private var activeView: some View {
        VStack(spacing: 8) {
            Text(String(format: "%d:%02d", manager.elapsedSeconds / 60, manager.elapsedSeconds % 60))
                .font(.system(size: 40, weight: .heavy, design: .rounded)).monospacedDigit()
            HStack(spacing: 16) {
                Label("\(Int(manager.heartRate))", systemImage: "heart.fill")
                    .foregroundStyle(.red)
                Label("\(Int(manager.activeCalories))", systemImage: "flame.fill")
                    .foregroundStyle(.orange)
            }
            .font(.footnote.weight(.semibold))
            Button(role: .destructive) {
                Task { await manager.end() }
            } label: {
                Text("End Workout")
            }
        }
    }
}
