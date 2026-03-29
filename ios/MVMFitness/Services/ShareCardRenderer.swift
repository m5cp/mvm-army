import SwiftUI
import UIKit

enum ShareCardType {
    case workout(title: String, exercises: [WorkoutExercise], tags: [String])
    case progress(completed: Int, planned: Int, streak: Int, steps: Int)
    case aft(score: AFTScoreRecord, previous: AFTScoreRecord?)
    case unitPT(plan: UnitPTPlan)
    case completion(title: String, exerciseCount: Int, duration: String)
    case completedWorkout(record: CompletedWorkoutRecord)
}

struct ShareCardView: View {
    let cardType: ShareCardType
    let date: Date

    var body: some View {
        VStack(spacing: 0) {
            cardHeader

            switch cardType {
            case .workout(let title, let exercises, let tags):
                workoutCard(title: title, exercises: exercises, tags: tags)
            case .progress(let completed, let planned, let streak, let steps):
                progressCard(completed: completed, planned: planned, streak: streak, steps: steps)
            case .aft(let score, let previous):
                aftCard(score: score, previous: previous)
            case .unitPT(let plan):
                unitPTCard(plan: plan)
            case .completion(let title, let exerciseCount, let duration):
                completionCard(title: title, exerciseCount: exerciseCount, duration: duration)
            case .completedWorkout(let record):
                completedWorkoutCard(record: record)
            }

            cardFooter
        }
        .frame(width: 360)
        .background(Color(red: 13/255, green: 13/255, blue: 18/255))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.08))
        }
    }

    private var cardHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "shield.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(
                    LinearGradient(colors: [Color(red: 79/255, green: 140/255, blue: 255/255), Color(red: 124/255, green: 92/255, blue: 255/255)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            Text("MVM ARMY")
                .font(.caption.weight(.heavy))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.7))

            Spacer()

            Text(formattedDate)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 12)
    }

    private var cardFooter: some View {
        HStack {
            Text("Me vs Me")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.3))
            Spacer()
            Text("mvmarmy.app")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white.opacity(0.25))
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: date)
    }

    private func workoutCard(title: String, exercises: [WorkoutExercise], tags: [String]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if !tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(red: 79/255, green: 140/255, blue: 255/255).opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
            }

            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(2)

            Text("\(exercises.count) exercises")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))

            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)

            VStack(spacing: 8) {
                ForEach(exercises.prefix(5)) { exercise in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color(red: 79/255, green: 140/255, blue: 255/255).opacity(0.4))
                            .frame(width: 6, height: 6)
                        Text(exercise.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(1)
                        Spacer()
                        Text(exercise.displayDetail)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.white.opacity(0.4))
                            .lineLimit(1)
                    }
                }

                if exercises.count > 5 {
                    Text("+\(exercises.count - 5) more")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.3))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func progressCard(completed: Int, planned: Int, streak: Int, steps: Int) -> some View {
        VStack(spacing: 18) {
            Text("Weekly Progress")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                shareStatColumn(value: "\(completed)/\(planned)", label: "PT Done", icon: "checkmark.circle.fill", color: Color(red: 34/255, green: 197/255, blue: 94/255))
                shareDivider
                shareStatColumn(value: "\(streak)", label: "Day Streak", icon: "flame.fill", color: Color(red: 245/255, green: 158/255, blue: 11/255))
                shareDivider
                shareStatColumn(value: formatSteps(steps), label: "Steps", icon: "figure.walk", color: Color(red: 79/255, green: 140/255, blue: 255/255))
            }
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func aftCard(score: AFTScoreRecord, previous: AFTScoreRecord?) -> some View {
        VStack(spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AFT Score")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                    Text("\(score.totalScore)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                if let prev = previous {
                    let diff = score.totalScore - prev.totalScore
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Change")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.4))
                        HStack(spacing: 4) {
                            Image(systemName: diff >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.caption.weight(.bold))
                            Text(diff >= 0 ? "+\(diff)" : "\(diff)")
                                .font(.title3.weight(.bold))
                        }
                        .foregroundStyle(diff >= 0 ? Color(red: 34/255, green: 197/255, blue: 94/255) : Color(red: 239/255, green: 68/255, blue: 68/255))
                    }
                }
            }

            HStack(spacing: 6) {
                aftSharePill("MDL", score.deadliftPoints)
                aftSharePill("HRP", score.pushUpPoints)
                aftSharePill("SDC", score.sdcPoints)
                aftSharePill("PLK", score.plankPoints)
                aftSharePill("2MR", score.runPoints)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func aftSharePill(_ label: String, _ value: Int) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.5))
            Text("\(value)")
                .font(.caption.weight(.bold))
                .foregroundStyle(aftColor(value))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func aftColor(_ value: Int) -> Color {
        if value >= 80 { return Color(red: 34/255, green: 197/255, blue: 94/255) }
        if value >= 60 { return Color(red: 79/255, green: 140/255, blue: 255/255) }
        if value >= 40 { return Color(red: 245/255, green: 158/255, blue: 11/255) }
        return Color(red: 239/255, green: 68/255, blue: 68/255)
    }

    private func unitPTCard(plan: UnitPTPlan) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Formation PT")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 79/255, green: 140/255, blue: 255/255).opacity(0.8))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 79/255, green: 140/255, blue: 255/255).opacity(0.12))
                .clipShape(Capsule())

            Text(plan.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(2)

            Text(plan.objective)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(3)

            if !plan.mainEffort.isEmpty {
                Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(plan.mainEffort.prefix(4)) { block in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(red: 79/255, green: 140/255, blue: 255/255).opacity(0.4))
                                .frame(width: 6, height: 6)
                            Text(block.description)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func completionCard(title: String, exerciseCount: Int, duration: String) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 34/255, green: 197/255, blue: 94/255).opacity(0.2), Color(red: 34/255, green: 197/255, blue: 94/255).opacity(0.02)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)

                Circle()
                    .stroke(Color(red: 34/255, green: 197/255, blue: 94/255).opacity(0.3), lineWidth: 2.5)
                    .frame(width: 68, height: 68)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(Color(red: 34/255, green: 197/255, blue: 94/255))
            }

            VStack(spacing: 6) {
                Text("MISSION COMPLETE")
                    .font(.caption.weight(.heavy))
                    .tracking(2.0)
                    .foregroundStyle(Color(red: 34/255, green: 197/255, blue: 94/255))

                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            HStack(spacing: 0) {
                shareStatColumn(value: "\(exerciseCount)", label: "Exercises", icon: "list.bullet", color: Color(red: 79/255, green: 140/255, blue: 255/255))
                shareDivider
                shareStatColumn(value: duration.isEmpty ? "Done" : duration, label: duration.isEmpty ? "Status" : "Duration", icon: duration.isEmpty ? "flame.fill" : "clock", color: Color(red: 245/255, green: 158/255, blue: 11/255))
            }
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            HStack {
                Spacer()
                Text("#MVMArmy")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(red: 79/255, green: 140/255, blue: 255/255).opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func completedWorkoutCard(record: CompletedWorkoutRecord) -> some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 34/255, green: 197/255, blue: 94/255).opacity(0.2), Color(red: 34/255, green: 197/255, blue: 94/255).opacity(0.02)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 45
                        )
                    )
                    .frame(width: 90, height: 90)

                Circle()
                    .stroke(Color(red: 34/255, green: 197/255, blue: 94/255).opacity(0.3), lineWidth: 2.5)
                    .frame(width: 60, height: 60)

                Image(systemName: record.source == .wod ? "bolt.fill" : "checkmark.seal.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color(red: 34/255, green: 197/255, blue: 94/255))
            }

            VStack(spacing: 6) {
                Text("MISSION COMPLETE")
                    .font(.caption.weight(.heavy))
                    .tracking(2.0)
                    .foregroundStyle(Color(red: 34/255, green: 197/255, blue: 94/255))

                if record.source == .wod {
                    Text("WOD")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color(red: 245/255, green: 158/255, blue: 11/255))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Color(red: 245/255, green: 158/255, blue: 11/255).opacity(0.15))
                        .clipShape(Capsule())
                }

                Text(record.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            HStack(spacing: 0) {
                shareStatColumn(value: "\(record.exerciseCount)", label: "Exercises", icon: "list.bullet", color: Color(red: 79/255, green: 140/255, blue: 255/255))
                shareDivider
                shareStatColumn(value: sourceLabel(record.source), label: "Type", icon: sourceIconName(record.source), color: Color(red: 124/255, green: 92/255, blue: 255/255))
            }
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            if !record.exercises.isEmpty {
                Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)

                VStack(spacing: 7) {
                    ForEach(record.exercises.prefix(6)) { exercise in
                        HStack(spacing: 10) {
                            Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.caption2)
                                .foregroundStyle(exercise.isCompleted ? Color(red: 34/255, green: 197/255, blue: 94/255) : .white.opacity(0.3))
                            Text(exercise.name)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(1)
                            Spacer()
                            Text(exercise.displayDetail)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.white.opacity(0.4))
                                .lineLimit(1)
                        }
                    }

                    if record.exercises.count > 6 {
                        Text("+\(record.exercises.count - 6) more")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.white.opacity(0.3))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            HStack {
                Spacer()
                Text("#MVMArmy")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(red: 79/255, green: 140/255, blue: 255/255).opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func sourceLabel(_ source: WorkoutSource) -> String {
        switch source {
        case .wod: return "WOD"
        case .unit: return "Unit PT"
        case .individual: return "Individual"
        case .random: return "Random"
        case .imported: return "Imported"
        }
    }

    private func sourceIconName(_ source: WorkoutSource) -> String {
        switch source {
        case .wod: return "bolt.fill"
        case .unit: return "person.3.fill"
        case .individual: return "figure.strengthtraining.traditional"
        case .random: return "shuffle"
        case .imported: return "square.and.arrow.down"
        }
    }

    private func shareStatColumn(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    private var shareDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(width: 1, height: 36)
    }

    private func formatSteps(_ steps: Int) -> String {
        if steps >= 1000 { return String(format: "%.1fk", Double(steps) / 1000) }
        return "\(steps)"
    }
}

@MainActor
enum ShareCardRenderer {
    @MainActor
    static func renderImage(cardType: ShareCardType, date: Date = .now) -> UIImage? {
        let cardView = ShareCardView(cardType: cardType, date: date)
            .environment(\.colorScheme, .dark)

        let controller = UIHostingController(rootView: cardView)
        controller.view.backgroundColor = .clear

        let targetSize = controller.view.intrinsicContentSize
        let size = CGSize(
            width: max(targetSize.width, 360),
            height: max(targetSize.height, 100)
        )
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.frame = CGRect(origin: .zero, size: size)

        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        let finalSize = controller.view.systemLayoutSizeFitting(
            CGSize(width: 360, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        let renderSize = CGSize(
            width: max(finalSize.width, 360),
            height: max(finalSize.height, 200)
        )
        controller.view.bounds = CGRect(origin: .zero, size: renderSize)
        controller.view.frame = CGRect(origin: .zero, size: renderSize)
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        let scale: CGFloat = 3.0
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: renderSize, format: format)
        let image = renderer.image { context in
            controller.view.drawHierarchy(in: CGRect(origin: .zero, size: renderSize), afterScreenUpdates: true)
        }

        return image
    }

    static func shareItems(cardType: ShareCardType, date: Date = .now) -> [Any] {
        if let image = renderImage(cardType: cardType, date: date) {
            return [image, fallbackText(cardType: cardType)]
        }
        return [fallbackText(cardType: cardType)]
    }

    static func presentShareSheet(cardType: ShareCardType, date: Date = .now) {
        let items = shareItems(cardType: cardType, date: date)
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        var presenter = rootVC
        while let presented = presenter.presentedViewController {
            presenter = presented
        }

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        presenter.present(activityVC, animated: true)
    }

    static func fallbackText(cardType: ShareCardType) -> String {
        switch cardType {
        case .workout(let title, let exercises, _):
            return "MVM Army — \(title)\n\(exercises.count) exercises\n#MVMArmy"
        case .progress(let completed, let planned, let streak, let steps):
            return "MVM Army — Weekly Progress\n\(completed)/\(planned) PT done · \(streak) day streak · \(steps) steps\n#MVMArmy"
        case .aft(let score, _):
            return "MVM Army — AFT Score: \(score.totalScore)\n#MVMArmy"
        case .unitPT(let plan):
            return "MVM Army — \(plan.title)\n\(plan.objective)\n#MVMArmy"
        case .completion(let title, let count, let duration):
            return "MVM Army — Completed: \(title)\n\(count) exercises · \(duration)\n#MVMArmy"
        case .completedWorkout(let record):
            let prefix = record.source == .wod ? "WOD: " : ""
            return "MVM Army — \(prefix)\(record.title)\n\(record.exerciseCount) exercises\n#MVMArmy"
        }
    }
}
