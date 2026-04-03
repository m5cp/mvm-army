import WidgetKit
import SwiftUI
import ActivityKit

nonisolated struct MVMWidgetEntry: TimelineEntry {
    let date: Date
    let todayWorkoutTitle: String?
    let todayExerciseCount: Int
    let aftScore: Int?
    let aftPassed: Bool?
    let streak: Int
    let stepsToday: Int
    let completedToday: Bool
    let planWeek: Int
    let planTotalWeeks: Int
}

nonisolated struct MVMWidgetProvider: TimelineProvider {
    private static let appGroupID = "group.app.rork.sf0lrvsw5r0bpccfi1669"

    func placeholder(in context: Context) -> MVMWidgetEntry {
        MVMWidgetEntry(
            date: .now,
            todayWorkoutTitle: "Upper Body Strength",
            todayExerciseCount: 6,
            aftScore: 480,
            aftPassed: true,
            streak: 5,
            stepsToday: 7200,
            completedToday: false,
            planWeek: 2,
            planTotalWeeks: 4
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MVMWidgetEntry) -> Void) {
        let entry = readEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MVMWidgetEntry>) -> Void) {
        let entry = readEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func readEntry() -> MVMWidgetEntry {
        guard let defaults = UserDefaults(suiteName: Self.appGroupID) else {
            return MVMWidgetEntry(
                date: .now,
                todayWorkoutTitle: nil,
                todayExerciseCount: 0,
                aftScore: nil,
                aftPassed: nil,
                streak: 0,
                stepsToday: 0,
                completedToday: false,
                planWeek: 0,
                planTotalWeeks: 0
            )
        }

        return MVMWidgetEntry(
            date: .now,
            todayWorkoutTitle: defaults.string(forKey: "widget_todayWorkoutTitle"),
            todayExerciseCount: defaults.integer(forKey: "widget_todayExerciseCount"),
            aftScore: defaults.object(forKey: "widget_aftScore") as? Int,
            aftPassed: defaults.object(forKey: "widget_aftPassed") as? Bool,
            streak: defaults.integer(forKey: "widget_streak"),
            stepsToday: defaults.integer(forKey: "widget_stepsToday"),
            completedToday: defaults.bool(forKey: "widget_completedToday"),
            planWeek: defaults.integer(forKey: "widget_planWeek"),
            planTotalWeeks: defaults.integer(forKey: "widget_planTotalWeeks")
        )
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    var entry: MVMWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "shield.checkered")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.green)
                Text("MVM")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            if let score = entry.aftScore {
                Text("\(score)")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.6)

                HStack(spacing: 4) {
                    Circle()
                        .fill(entry.aftPassed == true ? .green : .orange)
                        .frame(width: 6, height: 6)
                    Text(entry.aftPassed == true ? "PASS" : "NEEDS WORK")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("--")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.tertiary)
                Text("No AFT Score")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
                Text("\(entry.streak)d")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    var entry: MVMWidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "shield.checkered")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.green)
                    Text("MVM FITNESS")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(.secondary)
                }

                if let score = entry.aftScore {
                    Text("\(score)")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.6)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(entry.aftPassed == true ? .green : .orange)
                            .frame(width: 6, height: 6)
                        Text("AFT \(entry.aftPassed == true ? "PASS" : "NEEDS WORK")")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("AFT")
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(.tertiary)
                    Text("No score yet")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 10) {
                if let title = entry.todayWorkoutTitle {
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 3) {
                            if entry.completedToday {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.green)
                            }
                            Text("TODAY")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(.secondary)
                        }
                        Text(title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.trailing)
                        Text("\(entry.todayExerciseCount) exercises")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("TODAY")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.secondary)
                        Text("Rest Day")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer(minLength: 0)

                HStack(spacing: 12) {
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.orange)
                        Text("\(entry.streak)")
                            .font(.caption2.weight(.bold))
                    }

                    HStack(spacing: 3) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 10))
                            .foregroundStyle(.cyan)
                        Text(entry.stepsToday.formatted())
                            .font(.caption2.weight(.bold))
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Lock Screen Widgets

struct AccessoryCircularView: View {
    var entry: MVMWidgetEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            if let score = entry.aftScore {
                VStack(spacing: 0) {
                    Text("\(score)")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                    Text("AFT")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            } else {
                VStack(spacing: 0) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 16, weight: .bold))
                    Text("AFT")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct AccessoryRectangularView: View {
    var entry: MVMWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 9, weight: .bold))
                Text("MVM FITNESS")
                    .font(.system(size: 9, weight: .heavy))
            }

            if let title = entry.todayWorkoutTitle {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .lineLimit(1)
                HStack(spacing: 8) {
                    if entry.completedToday {
                        Label("Done", systemImage: "checkmark.circle.fill")
                    } else {
                        Label("\(entry.todayExerciseCount) exercises", systemImage: "figure.run")
                    }

                    if entry.streak > 0 {
                        Label("\(entry.streak)d streak", systemImage: "flame.fill")
                    }
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
            } else {
                Text("Rest Day")
                    .font(.headline.weight(.semibold))
                if let score = entry.aftScore {
                    Text("AFT: \(score)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct AccessoryInlineView: View {
    var entry: MVMWidgetEntry

    var body: some View {
        if let title = entry.todayWorkoutTitle {
            if entry.completedToday {
                Label("\(title) ✓", systemImage: "checkmark.circle.fill")
            } else {
                Label(title, systemImage: "figure.run")
            }
        } else if let score = entry.aftScore {
            Label("AFT: \(score)", systemImage: "shield.checkered")
        } else {
            Label("MVM Fitness", systemImage: "shield.checkered")
        }
    }
}

// MARK: - Widget View Router

struct MVMWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: MVMWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Definitions

struct MVMFitnessWidget: Widget {
    let kind: String = "MVMFitnessWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MVMWidgetProvider()) { entry in
            MVMWidgetView(entry: entry)
                .containerBackground(Color(red: 0.05, green: 0.06, blue: 0.055), for: .widget)
        }
        .configurationDisplayName("MVM Fitness")
        .description("Today's workout and AFT score at a glance.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Live Activity Widget

struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "shield.checkered")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.green)
                        Text("MVM FITNESS")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.secondary)
                    }

                    Text(context.attributes.workoutTitle)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(context.state.exerciseName)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(context.state.exerciseIndex)/\(context.state.totalExercises)")
                        .font(.title3.weight(.heavy).monospacedDigit())
                        .foregroundStyle(.white)

                    if context.state.timeRemaining > 0 {
                        let mins = context.state.timeRemaining / 60
                        let secs = context.state.timeRemaining % 60
                        Text(String(format: "%02d:%02d", mins, secs))
                            .font(.caption.weight(.bold).monospacedDigit())
                            .foregroundStyle(.green)
                    }

                    ProgressView(value: context.state.workoutProgress)
                        .tint(.green)
                }
                .frame(width: 80)
            }
            .padding(16)
            .background(Color(red: 0.05, green: 0.06, blue: 0.055))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Image(systemName: "figure.run")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.green)
                        Text(context.attributes.workoutTitle)
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(context.state.exerciseIndex)/\(context.state.totalExercises)")
                            .font(.title2.weight(.heavy).monospacedDigit())
                        if context.state.timeRemaining > 0 {
                            let mins = context.state.timeRemaining / 60
                            let secs = context.state.timeRemaining % 60
                            Text(String(format: "%02d:%02d", mins, secs))
                                .font(.caption.weight(.bold).monospacedDigit())
                                .foregroundStyle(.green)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 4) {
                        Text(context.state.exerciseName)
                            .font(.caption.weight(.medium))
                            .lineLimit(1)
                        ProgressView(value: context.state.workoutProgress)
                            .tint(.green)
                    }
                }
            } compactLeading: {
                Image(systemName: "figure.run")
                    .foregroundStyle(.green)
            } compactTrailing: {
                Text("\(context.state.exerciseIndex)/\(context.state.totalExercises)")
                    .font(.caption2.weight(.bold).monospacedDigit())
            } minimal: {
                Image(systemName: "figure.run")
                    .foregroundStyle(.green)
            }
        }
    }
}
