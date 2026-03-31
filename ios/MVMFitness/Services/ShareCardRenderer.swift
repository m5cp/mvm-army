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

@MainActor
enum ShareCardRenderer {

    static func renderImage(cardType: ShareCardType, date: Date = .now) -> UIImage? {
        switch cardType {
        case .workout(let title, let exercises, let tags):
            return WorkoutCardCGRenderer.render(title: title, exercises: exercises, tags: tags, date: date)
        case .completion(let title, let exerciseCount, let duration):
            return CompletionCardCGRenderer.render(title: title, exerciseCount: exerciseCount, duration: duration, date: date)
        case .completedWorkout(let record):
            return CompletedWorkoutCGRenderer.render(record: record, date: date)
        case .aft(let score, let previous):
            return AFTCardRenderer.render(score: score, previous: previous)
        case .progress(let completed, let planned, let streak, let steps):
            return ProgressCardCGRenderer.render(completed: completed, planned: planned, streak: streak, steps: steps, date: date)
        case .unitPT(let plan):
            return UnitPTCardCGRenderer.render(plan: plan, date: date)
        }
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

    static func saveToPhotos(cardType: ShareCardType, date: Date = .now) -> Bool {
        guard let image = renderImage(cardType: cardType, date: date) else { return false }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        return true
    }

    static func fallbackText(cardType: ShareCardType) -> String {
        switch cardType {
        case .workout(let title, let exercises, _):
            return "MVM Fitness — \(title)\n\(exercises.count) exercises\n#MVMFitness"
        case .progress(let completed, let planned, let streak, let steps):
            return "MVM Fitness — Weekly Progress\n\(completed)/\(planned) PT done · \(streak) day streak · \(steps) steps\n#MVMFitness"
        case .aft(let score, _):
            return "MVM Fitness — AFT Score: \(score.totalScore)\n#MVMFitness"
        case .unitPT(let plan):
            return "MVM Fitness — \(plan.title)\n\(plan.objective)\n#MVMFitness"
        case .completion(let title, let count, let duration):
            return "MVM Fitness — Completed: \(title)\n\(count) exercises · \(duration)\n#MVMFitness"
        case .completedWorkout(let record):
            let prefix = record.source == .wod ? "Functional: " : ""
            return "MVM Fitness — \(prefix)\(record.title)\n\(record.exerciseCount) exercises\n#MVMFitness"
        }
    }
}

@MainActor
enum ShareCardCGHelpers {
    static let width: CGFloat = 1080
    static let bgColor = UIColor(red: 0.047, green: 0.059, blue: 0.055, alpha: 1.0)
    static let accentBlue = UIColor(red: 0.18, green: 0.49, blue: 0.32, alpha: 1.0)
    static let accentPurple = UIColor(red: 0.29, green: 0.49, blue: 0.42, alpha: 1.0)
    static let successGreen = UIColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0)
    static let warningAmber = UIColor(red: 0.769, green: 0.514, blue: 0.231, alpha: 1.0)

    static func drawBackground(context: CGContext, width: CGFloat, height: CGFloat) {
        context.setFillColor(bgColor.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        let colors = [
            UIColor(red: 0.106, green: 0.369, blue: 0.231, alpha: 0.14).cgColor,
            UIColor(red: 0.18, green: 0.49, blue: 0.32, alpha: 0.06).cgColor,
            UIColor.clear.cgColor
        ] as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 0.5, 1.0]) {
            context.drawRadialGradient(gradient,
                                       startCenter: CGPoint(x: width / 2, y: 200),
                                       startRadius: 0,
                                       endCenter: CGPoint(x: width / 2, y: 200),
                                       endRadius: 600,
                                       options: [])
        }
    }

    static func drawHeader(context: CGContext, width: CGFloat, date: Date) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 28, weight: .bold),
            .foregroundColor: accentBlue
        ]
        let shieldStr = NSAttributedString(string: "⬡", attributes: attrs)
        shieldStr.draw(at: CGPoint(x: 60, y: 50))

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .heavy),
            .foregroundColor: UIColor.white.withAlphaComponent(0.7),
            .kern: 3.0
        ]
        let titleStr = NSAttributedString(string: "MVM FITNESS", attributes: titleAttrs)
        titleStr.draw(at: CGPoint(x: 100, y: 54))

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.35)
        ]
        let dateStr = NSAttributedString(string: dateFormatter.string(from: date), attributes: dateAttrs)
        let dateSize = dateStr.size()
        dateStr.draw(at: CGPoint(x: width - 60 - dateSize.width, y: 56))

        let lineY: CGFloat = 100
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.06).cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: 60, y: lineY))
        context.addLine(to: CGPoint(x: width - 60, y: lineY))
        context.strokePath()
    }

    static func drawFooter(context: CGContext, width: CGFloat, height: CGFloat) {
        let y = height - 80

        context.setStrokeColor(UIColor.white.withAlphaComponent(0.06).cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: 60, y: y))
        context.addLine(to: CGPoint(x: width - 60, y: y))
        context.strokePath()

        let leftAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            .foregroundColor: UIColor.white.withAlphaComponent(0.25)
        ]
        let leftStr = NSAttributedString(string: "MVM Fitness", attributes: leftAttrs)
        leftStr.draw(at: CGPoint(x: 60, y: y + 20))

        let rightAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.2)
        ]
        let rightStr = NSAttributedString(string: "#MVMFitness", attributes: rightAttrs)
        let rightSize = rightStr.size()
        rightStr.draw(at: CGPoint(x: width - 60 - rightSize.width, y: y + 20))
    }

    static func drawCheckmarkBadge(context: CGContext, centerX: CGFloat, centerY: CGFloat, radius: CGFloat) {
        let outerRadius = radius + 20
        context.saveGState()
        let colors = [
            successGreen.withAlphaComponent(0.2).cgColor,
            successGreen.withAlphaComponent(0.02).cgColor
        ] as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1.0]) {
            context.drawRadialGradient(gradient,
                                       startCenter: CGPoint(x: centerX, y: centerY),
                                       startRadius: 0,
                                       endCenter: CGPoint(x: centerX, y: centerY),
                                       endRadius: outerRadius,
                                       options: [])
        }
        context.restoreGState()

        let ringRect = CGRect(x: centerX - radius, y: centerY - radius, width: radius * 2, height: radius * 2)
        let ringPath = UIBezierPath(ovalIn: ringRect)
        context.setStrokeColor(successGreen.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(4)
        context.addPath(ringPath.cgPath)
        context.strokePath()

        let checkSize: CGFloat = radius * 0.8
        let checkX = centerX - checkSize / 2
        let checkY = centerY - checkSize / 2.5
        let checkPath = UIBezierPath()
        checkPath.move(to: CGPoint(x: checkX, y: checkY + checkSize * 0.5))
        checkPath.addLine(to: CGPoint(x: checkX + checkSize * 0.35, y: checkY + checkSize * 0.8))
        checkPath.addLine(to: CGPoint(x: checkX + checkSize, y: checkY + checkSize * 0.1))
        context.setStrokeColor(successGreen.cgColor)
        context.setLineWidth(8)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.addPath(checkPath.cgPath)
        context.strokePath()
    }

    static func drawStatBox(context: CGContext, x: CGFloat, y: CGFloat, boxWidth: CGFloat, boxHeight: CGFloat, value: String, label: String, valueColor: UIColor) {
        let boxRect = CGRect(x: x, y: y, width: boxWidth, height: boxHeight)
        let boxPath = UIBezierPath(roundedRect: boxRect, cornerRadius: 16)
        context.setFillColor(UIColor.white.withAlphaComponent(0.04).cgColor)
        context.addPath(boxPath.cgPath)
        context.fillPath()

        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 42, weight: .bold),
            .foregroundColor: valueColor
        ]
        let valueStr = NSAttributedString(string: value, attributes: valueAttrs)
        let valueSize = valueStr.size()
        valueStr.draw(at: CGPoint(x: x + (boxWidth - valueSize.width) / 2, y: y + boxHeight / 2 - valueSize.height - 2))

        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.4)
        ]
        let labelStr = NSAttributedString(string: label, attributes: labelAttrs)
        let labelSize = labelStr.size()
        labelStr.draw(at: CGPoint(x: x + (boxWidth - labelSize.width) / 2, y: y + boxHeight / 2 + 6))
    }

    static func makeRenderer(width: CGFloat, height: CGFloat) -> UIGraphicsImageRenderer {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true
        return UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
    }
}

@MainActor
enum CompletionCardCGRenderer {
    static func render(title: String, exerciseCount: Int, duration: String, date: Date) -> UIImage? {
        let w = ShareCardCGHelpers.width
        let h: CGFloat = 900
        let renderer = ShareCardCGHelpers.makeRenderer(width: w, height: h)

        return renderer.image { ctx in
            let context = ctx.cgContext
            ShareCardCGHelpers.drawBackground(context: context, width: w, height: h)
            ShareCardCGHelpers.drawHeader(context: context, width: w, date: date)

            let badgeCY: CGFloat = 280
            ShareCardCGHelpers.drawCheckmarkBadge(context: context, centerX: w / 2, centerY: badgeCY, radius: 60)

            let missionAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .heavy),
                .foregroundColor: ShareCardCGHelpers.successGreen,
                .kern: 3.0
            ]
            let missionStr = NSAttributedString(string: "MISSION COMPLETE", attributes: missionAttrs)
            let missionSize = missionStr.size()
            missionStr.draw(at: CGPoint(x: (w - missionSize.width) / 2, y: 370))

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 44, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let titleStr = NSAttributedString(string: title, attributes: titleAttrs)
            let titleRect = CGRect(x: 60, y: 410, width: w - 120, height: 120)
            let titleBounds = titleStr.boundingRect(with: CGSize(width: w - 120, height: 120), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)
            let titleX = (w - titleBounds.width) / 2
            titleStr.draw(with: CGRect(x: titleX, y: 410, width: titleBounds.width, height: 120), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)

            let statsY: CGFloat = 560
            let boxWidth = (w - 140) / 2
            let boxHeight: CGFloat = 110
            ShareCardCGHelpers.drawStatBox(context: context, x: 60, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: "\(exerciseCount)", label: "Exercises", valueColor: ShareCardCGHelpers.accentBlue)

            let statusVal = duration.isEmpty ? "Done" : duration
            let statusLabel = duration.isEmpty ? "Status" : "Duration"
            ShareCardCGHelpers.drawStatBox(context: context, x: 60 + boxWidth + 20, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: statusVal, label: statusLabel, valueColor: ShareCardCGHelpers.warningAmber)

            ShareCardCGHelpers.drawFooter(context: context, width: w, height: h)
        }
    }
}

@MainActor
enum CompletedWorkoutCGRenderer {
    static func render(record: CompletedWorkoutRecord, date: Date) -> UIImage? {
        let w = ShareCardCGHelpers.width
        let exerciseRows = min(record.exercises.count, 6)
        let hasExercises = !record.exercises.isEmpty
        let h: CGFloat = hasExercises ? CGFloat(900 + exerciseRows * 55 + 40) : 900
        let renderer = ShareCardCGHelpers.makeRenderer(width: w, height: h)

        return renderer.image { ctx in
            let context = ctx.cgContext
            ShareCardCGHelpers.drawBackground(context: context, width: w, height: h)
            ShareCardCGHelpers.drawHeader(context: context, width: w, date: date)

            let badgeCY: CGFloat = 260
            ShareCardCGHelpers.drawCheckmarkBadge(context: context, centerX: w / 2, centerY: badgeCY, radius: 55)

            let missionAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .heavy),
                .foregroundColor: ShareCardCGHelpers.successGreen,
                .kern: 3.0
            ]
            let missionStr = NSAttributedString(string: "MISSION COMPLETE", attributes: missionAttrs)
            let missionSize = missionStr.size()
            missionStr.draw(at: CGPoint(x: (w - missionSize.width) / 2, y: 345))

            if record.source == .wod {
                let wodAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                    .foregroundColor: ShareCardCGHelpers.warningAmber
                ]
                let wodStr = NSAttributedString(string: "FUNCTIONAL", attributes: wodAttrs)
                let wodSize = wodStr.size()
                let pillRect = CGRect(x: (w - wodSize.width - 24) / 2, y: 380, width: wodSize.width + 24, height: 32)
                let pillPath = UIBezierPath(roundedRect: pillRect, cornerRadius: 16)
                context.setFillColor(ShareCardCGHelpers.warningAmber.withAlphaComponent(0.15).cgColor)
                context.addPath(pillPath.cgPath)
                context.fillPath()
                wodStr.draw(at: CGPoint(x: pillRect.midX - wodSize.width / 2, y: pillRect.midY - wodSize.height / 2))
            }

            let titleY: CGFloat = record.source == .wod ? 425 : 385
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let titleStr = NSAttributedString(string: record.title, attributes: titleAttrs)
            let titleBounds = titleStr.boundingRect(with: CGSize(width: w - 120, height: 110), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)
            let titleX = (w - titleBounds.width) / 2
            titleStr.draw(with: CGRect(x: titleX, y: titleY, width: titleBounds.width, height: 110), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)

            let statsY = titleY + 120
            let boxWidth = (w - 140) / 2
            let boxHeight: CGFloat = 100
            ShareCardCGHelpers.drawStatBox(context: context, x: 60, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: "\(record.exerciseCount)", label: "Exercises", valueColor: ShareCardCGHelpers.accentBlue)

            let sourceLabel: String
            switch record.source {
            case .wod: sourceLabel = "Functional"
            case .unit: sourceLabel = "Unit PT"
            case .individual: sourceLabel = "Individual"
            case .random: sourceLabel = "Random"
            case .imported: sourceLabel = "Imported"
            }
            ShareCardCGHelpers.drawStatBox(context: context, x: 60 + boxWidth + 20, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: sourceLabel, label: "Type", valueColor: ShareCardCGHelpers.accentPurple)

            if hasExercises {
                var rowY = statsY + boxHeight + 40

                context.setStrokeColor(UIColor.white.withAlphaComponent(0.06).cgColor)
                context.setLineWidth(1)
                context.move(to: CGPoint(x: 60, y: rowY - 10))
                context.addLine(to: CGPoint(x: w - 60, y: rowY - 10))
                context.strokePath()

                for exercise in record.exercises.prefix(6) {
                    let dotColor = exercise.isCompleted ? ShareCardCGHelpers.successGreen : UIColor.white.withAlphaComponent(0.3)
                    let dotRect = CGRect(x: 70, y: rowY + 10, width: 10, height: 10)
                    context.setFillColor(dotColor.cgColor)
                    context.fillEllipse(in: dotRect)

                    let nameAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 22, weight: .medium),
                        .foregroundColor: UIColor.white.withAlphaComponent(0.8)
                    ]
                    let nameStr = NSAttributedString(string: exercise.name, attributes: nameAttrs)
                    nameStr.draw(at: CGPoint(x: 95, y: rowY + 2))

                    let detailAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                        .foregroundColor: UIColor.white.withAlphaComponent(0.4)
                    ]
                    let detailStr = NSAttributedString(string: exercise.displayDetail, attributes: detailAttrs)
                    let detailSize = detailStr.size()
                    detailStr.draw(at: CGPoint(x: w - 60 - detailSize.width, y: rowY + 5))

                    rowY += 55
                }

                if record.exercises.count > 6 {
                    let moreAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                        .foregroundColor: UIColor.white.withAlphaComponent(0.3)
                    ]
                    let moreStr = NSAttributedString(string: "+\(record.exercises.count - 6) more", attributes: moreAttrs)
                    moreStr.draw(at: CGPoint(x: 95, y: rowY + 2))
                }
            }

            ShareCardCGHelpers.drawFooter(context: context, width: w, height: h)
        }
    }
}

@MainActor
enum WorkoutCardCGRenderer {
    static func render(title: String, exercises: [WorkoutExercise], tags: [String], date: Date) -> UIImage? {
        let w = ShareCardCGHelpers.width
        let exerciseRows = min(exercises.count, 5)
        let h: CGFloat = CGFloat(550 + exerciseRows * 55 + (exercises.count > 5 ? 40 : 0) + (!tags.isEmpty ? 50 : 0))
        let renderer = ShareCardCGHelpers.makeRenderer(width: w, height: h)

        return renderer.image { ctx in
            let context = ctx.cgContext
            ShareCardCGHelpers.drawBackground(context: context, width: w, height: h)
            ShareCardCGHelpers.drawHeader(context: context, width: w, date: date)

            var currentY: CGFloat = 130

            if !tags.isEmpty {
                var tagX: CGFloat = 60
                for tag in tags.prefix(3) {
                    let tagAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                        .foregroundColor: UIColor.white.withAlphaComponent(0.8)
                    ]
                    let tagStr = NSAttributedString(string: tag, attributes: tagAttrs)
                    let tagSize = tagStr.size()
                    let pillRect = CGRect(x: tagX, y: currentY, width: tagSize.width + 20, height: 30)
                    let pillPath = UIBezierPath(roundedRect: pillRect, cornerRadius: 15)
                    context.setFillColor(ShareCardCGHelpers.accentBlue.withAlphaComponent(0.2).cgColor)
                    context.addPath(pillPath.cgPath)
                    context.fillPath()
                    tagStr.draw(at: CGPoint(x: tagX + 10, y: currentY + 4))
                    tagX += tagSize.width + 30
                }
                currentY += 50
            }

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 44, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let titleStr = NSAttributedString(string: title, attributes: titleAttrs)
            titleStr.draw(with: CGRect(x: 60, y: currentY, width: w - 120, height: 110), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)
            currentY += 65

            let countAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
            let countStr = NSAttributedString(string: "\(exercises.count) exercises", attributes: countAttrs)
            countStr.draw(at: CGPoint(x: 60, y: currentY))
            currentY += 45

            context.setStrokeColor(UIColor.white.withAlphaComponent(0.06).cgColor)
            context.setLineWidth(1)
            context.move(to: CGPoint(x: 60, y: currentY))
            context.addLine(to: CGPoint(x: w - 60, y: currentY))
            context.strokePath()
            currentY += 20

            for exercise in exercises.prefix(5) {
                let dotRect = CGRect(x: 70, y: currentY + 10, width: 10, height: 10)
                context.setFillColor(ShareCardCGHelpers.accentBlue.withAlphaComponent(0.5).cgColor)
                context.fillEllipse(in: dotRect)

                let nameAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 22, weight: .medium),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.8)
                ]
                let nameStr = NSAttributedString(string: exercise.name, attributes: nameAttrs)
                nameStr.draw(at: CGPoint(x: 95, y: currentY + 2))

                let detailAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.4)
                ]
                let detailStr = NSAttributedString(string: exercise.displayDetail, attributes: detailAttrs)
                let detailSize = detailStr.size()
                detailStr.draw(at: CGPoint(x: w - 60 - detailSize.width, y: currentY + 5))

                currentY += 55
            }

            if exercises.count > 5 {
                let moreAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.3)
                ]
                let moreStr = NSAttributedString(string: "+\(exercises.count - 5) more", attributes: moreAttrs)
                moreStr.draw(at: CGPoint(x: 95, y: currentY + 2))
            }

            ShareCardCGHelpers.drawFooter(context: context, width: w, height: h)
        }
    }
}

@MainActor
enum ProgressCardCGRenderer {
    static func render(completed: Int, planned: Int, streak: Int, steps: Int, date: Date) -> UIImage? {
        let w = ShareCardCGHelpers.width
        let h: CGFloat = 700
        let renderer = ShareCardCGHelpers.makeRenderer(width: w, height: h)

        return renderer.image { ctx in
            let context = ctx.cgContext
            ShareCardCGHelpers.drawBackground(context: context, width: w, height: h)
            ShareCardCGHelpers.drawHeader(context: context, width: w, date: date)

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 44, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let titleStr = NSAttributedString(string: "Weekly Progress", attributes: titleAttrs)
            titleStr.draw(at: CGPoint(x: 60, y: 130))

            let boxWidth = (w - 160) / 3
            let boxHeight: CGFloat = 120
            let statsY: CGFloat = 220

            ShareCardCGHelpers.drawStatBox(context: context, x: 60, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: "\(completed)/\(planned)", label: "PT Done", valueColor: ShareCardCGHelpers.successGreen)
            ShareCardCGHelpers.drawStatBox(context: context, x: 60 + boxWidth + 20, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: "\(streak)", label: "Day Streak", valueColor: ShareCardCGHelpers.warningAmber)

            let stepsStr = steps >= 1000 ? String(format: "%.1fk", Double(steps) / 1000) : "\(steps)"
            ShareCardCGHelpers.drawStatBox(context: context, x: 60 + (boxWidth + 20) * 2, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: stepsStr, label: "Steps", valueColor: ShareCardCGHelpers.accentBlue)

            ShareCardCGHelpers.drawFooter(context: context, width: w, height: h)
        }
    }
}

@MainActor
enum UnitPTCardCGRenderer {
    static func render(plan: UnitPTPlan, date: Date) -> UIImage? {
        let w = ShareCardCGHelpers.width
        let blockRows = min(plan.mainEffort.count, 4)
        let h: CGFloat = CGFloat(600 + blockRows * 50)
        let renderer = ShareCardCGHelpers.makeRenderer(width: w, height: h)

        return renderer.image { ctx in
            let context = ctx.cgContext
            ShareCardCGHelpers.drawBackground(context: context, width: w, height: h)
            ShareCardCGHelpers.drawHeader(context: context, width: w, date: date)

            let tagAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: ShareCardCGHelpers.accentBlue.withAlphaComponent(0.8)
            ]
            let tagStr = NSAttributedString(string: "Formation PT", attributes: tagAttrs)
            let tagSize = tagStr.size()
            let pillRect = CGRect(x: 60, y: 130, width: tagSize.width + 20, height: 30)
            let pillPath = UIBezierPath(roundedRect: pillRect, cornerRadius: 15)
            context.setFillColor(ShareCardCGHelpers.accentBlue.withAlphaComponent(0.12).cgColor)
            context.addPath(pillPath.cgPath)
            context.fillPath()
            tagStr.draw(at: CGPoint(x: 70, y: 134))

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let titleStr = NSAttributedString(string: plan.title, attributes: titleAttrs)
            titleStr.draw(with: CGRect(x: 60, y: 180, width: w - 120, height: 100), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)

            let objAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.6)
            ]
            let objStr = NSAttributedString(string: plan.objective, attributes: objAttrs)
            objStr.draw(with: CGRect(x: 60, y: 280, width: w - 120, height: 80), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)

            if !plan.mainEffort.isEmpty {
                var rowY: CGFloat = 380

                context.setStrokeColor(UIColor.white.withAlphaComponent(0.06).cgColor)
                context.setLineWidth(1)
                context.move(to: CGPoint(x: 60, y: rowY - 10))
                context.addLine(to: CGPoint(x: w - 60, y: rowY - 10))
                context.strokePath()

                for block in plan.mainEffort.prefix(4) {
                    let dotRect = CGRect(x: 70, y: rowY + 10, width: 10, height: 10)
                    context.setFillColor(ShareCardCGHelpers.accentBlue.withAlphaComponent(0.5).cgColor)
                    context.fillEllipse(in: dotRect)

                    let blockAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 20, weight: .medium),
                        .foregroundColor: UIColor.white.withAlphaComponent(0.7)
                    ]
                    let blockStr = NSAttributedString(string: block.description, attributes: blockAttrs)
                    blockStr.draw(with: CGRect(x: 95, y: rowY + 2, width: w - 160, height: 40), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)

                    rowY += 50
                }
            }

            ShareCardCGHelpers.drawFooter(context: context, width: w, height: h)
        }
    }
}
