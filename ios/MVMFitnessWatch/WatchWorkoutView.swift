import SwiftUI
import HealthKit

struct WatchWorkoutView: View {
    @State private var manager = WatchWorkoutManager.shared
    @State private var authorized = false
    @State private var authDenied = false

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
                MetricsView(manager: manager)
            } else {
                List {
                    ForEach(activities, id: \.0) { activity in
                        Button {
                            Task {
                                if !authorized { authorized = await manager.requestAuthorization() }
                                if authorized {
                                    authDenied = false
                                    await manager.start(activityType: activity.2, isOutdoor: activity.3)
                                } else {
                                    authDenied = true
                                }
                            }
                        } label: {
                            Label(activity.0, systemImage: activity.1)
                        }
                    }

                    if authDenied {
                        Text("Health access is off. Enable it in the Watch app under Privacy to record workouts.")
                            .font(.caption2)
                            .foregroundStyle(WatchTheme.subtleText)
                    }

                    if let error = manager.lastError {
                        Text(error)
                            .font(.caption2)
                            .foregroundStyle(WatchTheme.danger)
                    }
                }
                .navigationTitle("Workout")
            }
        }
    }
}

/// Apple-Watch-style live metric stack in the Golden Hour palette:
/// elapsed to hundredths, heart rate, rolling-mile pace, average pace, distance.
private struct MetricsView: View {
    let manager: WatchWorkoutManager

    var body: some View {
        // Redraw at 100ms so the hundredths digit advances smoothly. Elapsed is
        // always derived from the start date, so a dropped frame cannot make the
        // clock drift.
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(WatchTheme.success)
                        .padding(.bottom, 2)

                    Text(Self.elapsedText(manager.elapsed(at: context.date)))
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(WatchTheme.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("\(Int(manager.heartRate.rounded()))")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(WatchTheme.accent)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(WatchTheme.danger)
                    }

                    metricRow(Self.paceText(manager.rollingMilePaceSecondsPerMile(at: context.date)), "ROLLING\nMILE")
                    metricRow(Self.paceText(manager.averagePaceSecondsPerMile(at: context.date)), "AVERAGE\nPACE")

                    Text(String(format: "%.2fMI", manager.distanceMiles))
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(WatchTheme.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    controls
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func metricRow(_ value: String, _ label: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(value)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(WatchTheme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(WatchTheme.subtleText)
                .lineLimit(2)
                .fixedSize()
        }
    }

    private var controls: some View {
        HStack(spacing: 8) {
            Button {
                if manager.isPaused { manager.resume() } else { manager.pause() }
            } label: {
                Image(systemName: manager.isPaused ? "play.fill" : "pause.fill")
            }
            .tint(WatchTheme.warning)

            Button(role: .destructive) {
                Task { await manager.end() }
            } label: {
                Image(systemName: "stop.fill")
            }
        }
        .font(.system(size: 14, weight: .bold))
    }

    /// mm:ss.hh, rolling over to h:mm:ss.hh past an hour so a long ruck does
    /// not render as "90:00".
    static func elapsedText(_ seconds: TimeInterval) -> String {
        let total = max(0, seconds)
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60
        let secs = Int(total) % 60
        let hundredths = Int((total - total.rounded(.down)) * 100)
        if hours > 0 {
            return String(format: "%d:%02d:%02d.%02d", hours, minutes, secs, hundredths)
        }
        return String(format: "%02d:%02d.%02d", minutes, secs, hundredths)
    }

    /// Pace as m'ss" per mile.
    static func paceText(_ secondsPerMile: Double?) -> String {
        guard let secondsPerMile, secondsPerMile.isFinite, secondsPerMile > 0 else { return "--'--\"" }
        let capped = min(secondsPerMile, 59 * 60 + 59)
        let minutes = Int(capped) / 60
        let seconds = Int(capped) % 60
        return String(format: "%d'%02d\"", minutes, seconds)
    }
}
