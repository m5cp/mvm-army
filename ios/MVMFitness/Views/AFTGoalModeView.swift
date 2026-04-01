import SwiftUI
import UIKit

struct AFTGoalModeView: View {
    let age: Int
    let sex: SoldierSex
    let standard: AFTStandard
    let soldierName: String

    @State private var targetScore: Double = 400
    @State private var showShareSheet: Bool = false
    @State private var renderedImage: UIImage?
    @State private var showSavedToast: Bool = false

    private var perEventTarget: Int {
        let raw = Int(targetScore) / 5
        return max(60, min(100, raw))
    }

    private var computedTotalScore: Int {
        perEventTarget * 5
    }

    private var passed: Bool {
        let minPer = standard.minimumPerEvent
        let minTotal = standard.minimumTotal
        return perEventTarget >= minPer && computedTotalScore >= minTotal
    }

    private var deadliftNeeded: Int {
        AFTScoringTables.deadliftNeeded(points: perEventTarget, age: age, sex: sex, standard: standard)
    }

    private var pushUpNeeded: Int {
        AFTScoringTables.pushUpNeeded(points: perEventTarget, age: age, sex: sex, standard: standard)
    }

    private var sdcNeeded: Int {
        AFTScoringTables.sdcNeeded(points: perEventTarget, age: age, sex: sex, standard: standard)
    }

    private var plankNeeded: Int {
        AFTScoringTables.plankNeeded(points: perEventTarget, age: age, sex: sex, standard: standard)
    }

    private var runNeeded: Int {
        AFTScoringTables.runNeeded(points: perEventTarget, age: age, sex: sex, standard: standard)
    }

    var body: some View {
        VStack(spacing: 18) {
            goalSliderCard
            totalScoreCard
            eventTargetsCard
            passFailCard
            shareButtons
        }
    }

    private var goalSliderCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .foregroundStyle(MVMTheme.accent)
                Text("Goal Mode")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
                Spacer()
                Text("\(computedTotalScore)")
                    .font(.title2.weight(.bold).monospacedDigit())
                    .foregroundStyle(MVMTheme.accent)
                    .contentTransition(.numericText())
            }

            Text("Slide to set your target total score. See what you need in each event to hit your goal.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)

            VStack(spacing: 6) {
                Slider(value: $targetScore, in: 300...500, step: 5)
                    .tint(MVMTheme.accent)

                HStack {
                    Text("300")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                    Spacer()
                    Text("Per event: \(perEventTarget) pts")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)
                    Spacer()
                    Text("500")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            }
        }
        .padding(18)
        .premiumCard()
    }

    private var totalScoreCard: some View {
        VStack(spacing: 8) {
            Text("Target Total Score")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)

            Text("\(computedTotalScore)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(MVMTheme.primaryText)
                .contentTransition(.numericText())

            Text("/ 500")
                .font(.title3.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.top, -8)

            HStack(spacing: 8) {
                ForEach(["MDL", "HRP", "SDC", "PLK", "2MR"], id: \.self) { label in
                    VStack(spacing: 4) {
                        Text(label)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(MVMTheme.secondaryText)
                        Text("\(perEventTarget)")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(pillColor(perEventTarget))
                            .contentTransition(.numericText())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border)
                    }
                }
            }
        }
        .padding(18)
        .premiumCard()
    }

    private var eventTargetsCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.clipboard")
                    .foregroundStyle(MVMTheme.accent)
                Text("What You Need")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            eventTargetRow(
                icon: "figure.strengthtraining.traditional",
                abbr: "MDL",
                title: "3RM Deadlift",
                value: "\(deadliftNeeded) lbs"
            )

            eventTargetRow(
                icon: "figure.core.training",
                abbr: "HRP",
                title: "Push-Ups",
                value: "\(pushUpNeeded) reps"
            )

            eventTargetRow(
                icon: "figure.run",
                abbr: "SDC",
                title: "Sprint-Drag-Carry",
                value: formatTime(sdcNeeded)
            )

            eventTargetRow(
                icon: "figure.pilates",
                abbr: "PLK",
                title: "Plank",
                value: formatTime(plankNeeded)
            )

            eventTargetRow(
                icon: "figure.run.circle",
                abbr: "2MR",
                title: "2-Mile Run",
                value: formatTime(runNeeded)
            )
        }
        .padding(18)
        .premiumCard()
    }

    private func eventTargetRow(icon: String, abbr: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(MVMTheme.accent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)
                Text(abbr)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
            }

            Spacer()

            Text(value)
                .font(.title3.weight(.bold).monospacedDigit())
                .foregroundStyle(MVMTheme.primaryText)
        }
        .padding(14)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(MVMTheme.border)
        }
    }

    private var passFailCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(passed ? MVMTheme.success.opacity(0.18) : MVMTheme.danger.opacity(0.18))
                    .frame(width: 50, height: 50)

                Image(systemName: passed ? "checkmark.shield.fill" : "xmark.shield.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(passed ? MVMTheme.success : MVMTheme.danger)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(passed ? "PASS" : "NO GO")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(passed ? MVMTheme.success : MVMTheme.danger)

                Text("\(standard.rawValue) Standard — Min \(standard.minimumPerEvent)/evt, \(standard.minimumTotal) total")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            Spacer()
        }
        .padding(18)
        .premiumCard()
    }

    private var shareButtons: some View {
        VStack(spacing: 12) {
            Button {
                renderedImage = AFTGoalCardRenderer.render(
                    targetScore: computedTotalScore,
                    perEvent: perEventTarget,
                    deadlift: deadliftNeeded,
                    pushUps: pushUpNeeded,
                    sdcSeconds: sdcNeeded,
                    plankSeconds: plankNeeded,
                    runSeconds: runNeeded,
                    passed: passed,
                    standard: standard,
                    soldierName: soldierName
                )
                showShareSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Goal Card")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#4F8CFF"), Color(hex: "#7C5CFF")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ).opacity(0.85)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .sheet(isPresented: $showShareSheet) {
            AFTGoalShareSheet(
                image: renderedImage,
                totalScore: computedTotalScore
            )
        }
    }

    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func pillColor(_ value: Int) -> Color {
        if value >= 80 { return MVMTheme.success }
        if value >= 60 { return MVMTheme.accent }
        if value >= 40 { return MVMTheme.warning }
        return MVMTheme.danger
    }
}

struct AFTGoalShareSheet: View {
    let image: UIImage?
    let totalScore: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showSavedToast: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if let image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                                .padding(.horizontal, 30)
                        } else {
                            ProgressView()
                                .tint(.white)
                                .frame(height: 300)
                        }

                        Button {
                            if let image {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                showSavedToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showSavedToast = false
                                }
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("Save to Photos")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .background(MVMTheme.heroGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: MVMTheme.accent.opacity(0.28), radius: 18, y: 10)
                        }
                        .buttonStyle(PressScaleButtonStyle())
                        .padding(.horizontal, 20)
                        .disabled(image == nil)

                        Button {
                            if let image {
                                let text = "MVM Army — AFT Goal: \(totalScore)/500\n#MVMArmy #ArmyFitness"
                                let activityVC = UIActivityViewController(activityItems: [image, text], applicationActivities: nil)
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
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .font(.headline)
                            .foregroundStyle(MVMTheme.accent)
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .background(MVMTheme.accent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(PressScaleButtonStyle())
                        .padding(.horizontal, 20)
                        .disabled(image == nil)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Goal Score Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .overlay {
                if showSavedToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(MVMTheme.success)
                            Text("Saved to Photos")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.bottom, 40)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSavedToast)
                }
            }
        }
    }
}

@MainActor
enum AFTGoalCardRenderer {
    static func render(
        targetScore: Int,
        perEvent: Int,
        deadlift: Int,
        pushUps: Int,
        sdcSeconds: Int,
        plankSeconds: Int,
        runSeconds: Int,
        passed: Bool,
        standard: AFTStandard,
        soldierName: String
    ) -> UIImage? {
        let width: CGFloat = 1080
        let height: CGFloat = 1350
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)

        return renderer.image { ctx in
            let context = ctx.cgContext

            let bgColor = UIColor(red: 0.035, green: 0.035, blue: 0.047, alpha: 1.0)
            context.setFillColor(bgColor.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))

            let colors = [
                UIColor(red: 0.49, green: 0.36, blue: 1.0, alpha: 0.15).cgColor,
                UIColor(red: 0.31, green: 0.55, blue: 1.0, alpha: 0.06).cgColor,
                UIColor.clear.cgColor
            ] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 0.5, 1.0]) {
                context.drawRadialGradient(gradient,
                                           startCenter: CGPoint(x: width / 2, y: 250),
                                           startRadius: 0,
                                           endCenter: CGPoint(x: width / 2, y: 250),
                                           endRadius: 600,
                                           options: [])
            }

            let headerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .heavy),
                .foregroundColor: UIColor.white.withAlphaComponent(0.7),
                .kern: 3.0
            ]
            let headerStr = NSAttributedString(string: "MVM ARMY", attributes: headerAttrs)
            headerStr.draw(at: CGPoint(x: 60, y: 50))

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            let dateAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.35)
            ]
            let dateStr = NSAttributedString(string: dateFormatter.string(from: .now), attributes: dateAttrs)
            let dateSize = dateStr.size()
            dateStr.draw(at: CGPoint(x: width - 60 - dateSize.width, y: 52))

            context.setStrokeColor(UIColor.white.withAlphaComponent(0.06).cgColor)
            context.setLineWidth(1)
            context.move(to: CGPoint(x: 60, y: 95))
            context.addLine(to: CGPoint(x: width - 60, y: 95))
            context.strokePath()

            let goalBadgeAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .heavy),
                .foregroundColor: UIColor(red: 0.49, green: 0.36, blue: 1.0, alpha: 1.0),
                .kern: 2.0
            ]
            let goalBadge = NSAttributedString(string: "◎  GOAL MODE", attributes: goalBadgeAttrs)
            let goalBadgeSize = goalBadge.size()
            goalBadge.draw(at: CGPoint(x: (width - goalBadgeSize.width) / 2, y: 120))

            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 26, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
            let label = NSAttributedString(string: "TARGET TOTAL SCORE", attributes: labelAttrs)
            let labelSize = label.size()
            label.draw(at: CGPoint(x: (width - labelSize.width) / 2, y: 170))

            let scoreFont = UIFont.systemFont(ofSize: 150, weight: .bold)
            let scoreAttrs: [NSAttributedString.Key: Any] = [
                .font: scoreFont,
                .foregroundColor: UIColor.white
            ]
            let scoreStr = NSAttributedString(string: "\(targetScore)", attributes: scoreAttrs)
            let scoreSize = scoreStr.size()
            scoreStr.draw(at: CGPoint(x: (width - scoreSize.width) / 2, y: 210))

            let maxAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.3)
            ]
            let maxStr = NSAttributedString(string: "/ 500", attributes: maxAttrs)
            let maxSize = maxStr.size()
            maxStr.draw(at: CGPoint(x: (width - maxSize.width) / 2, y: 380))

            if !soldierName.isEmpty {
                let nameAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 22, weight: .medium),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.4)
                ]
                let nameStr = NSAttributedString(string: soldierName.uppercased(), attributes: nameAttrs)
                let nameSize = nameStr.size()
                nameStr.draw(at: CGPoint(x: (width - nameSize.width) / 2, y: 430))
            }

            let sectionY: CGFloat = 480
            let sectionLabel: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .heavy),
                .foregroundColor: UIColor.white.withAlphaComponent(0.4),
                .kern: 2.0
            ]
            let sectionStr = NSAttributedString(string: "WHAT YOU NEED", attributes: sectionLabel)
            let sectionSize = sectionStr.size()
            sectionStr.draw(at: CGPoint(x: (width - sectionSize.width) / 2, y: sectionY))

            let events: [(String, String, String)] = [
                ("MDL", "3RM Deadlift", "\(deadlift) lbs"),
                ("HRP", "Push-Ups", "\(pushUps) reps"),
                ("SDC", "Sprint-Drag-Carry", formatTime(sdcSeconds)),
                ("PLK", "Plank", formatTime(plankSeconds)),
                ("2MR", "2-Mile Run", formatTime(runSeconds))
            ]

            let rowHeight: CGFloat = 90
            let rowStartY: CGFloat = sectionY + 50
            let marginX: CGFloat = 60
            let accentBlue = UIColor(red: 0.31, green: 0.55, blue: 1.0, alpha: 1.0)
            let accentPurple = UIColor(red: 0.49, green: 0.36, blue: 1.0, alpha: 1.0)

            for (index, event) in events.enumerated() {
                let y = rowStartY + CGFloat(index) * rowHeight

                let pillRect = CGRect(x: marginX, y: y + 8, width: 70, height: 40)
                let pillPath = UIBezierPath(roundedRect: pillRect, cornerRadius: 10)
                context.setFillColor(accentPurple.withAlphaComponent(0.18).cgColor)
                context.addPath(pillPath.cgPath)
                context.fillPath()

                let abbrAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .heavy),
                    .foregroundColor: accentPurple
                ]
                let abbrStr = NSAttributedString(string: event.0, attributes: abbrAttrs)
                let abbrSize = abbrStr.size()
                abbrStr.draw(at: CGPoint(x: pillRect.midX - abbrSize.width / 2, y: pillRect.midY - abbrSize.height / 2))

                let nameAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.8)
                ]
                let nameStr = NSAttributedString(string: event.1, attributes: nameAttrs)
                nameStr.draw(at: CGPoint(x: marginX + 85, y: y + 14))

                let valueAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 30, weight: .bold),
                    .foregroundColor: accentBlue
                ]
                let valueStr = NSAttributedString(string: event.2, attributes: valueAttrs)
                let valueSize = valueStr.size()
                valueStr.draw(at: CGPoint(x: width - marginX - valueSize.width, y: y + 10))

                let barY = y + 56
                let barWidth = width - marginX * 2
                let barHeight: CGFloat = 6
                let barBgRect = CGRect(x: marginX, y: barY, width: barWidth, height: barHeight)
                let barBgPath = UIBezierPath(roundedRect: barBgRect, cornerRadius: 3)
                context.setFillColor(UIColor.white.withAlphaComponent(0.06).cgColor)
                context.addPath(barBgPath.cgPath)
                context.fillPath()

                let fillWidth = barWidth * CGFloat(min(perEvent, 100)) / 100.0
                let barFillRect = CGRect(x: marginX, y: barY, width: fillWidth, height: barHeight)
                let barFillPath = UIBezierPath(roundedRect: barFillRect, cornerRadius: 3)
                context.setFillColor(accentPurple.cgColor)
                context.addPath(barFillPath.cgPath)
                context.fillPath()
            }

            let statusY: CGFloat = 1020
            let statusColor: UIColor = passed
                ? UIColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0)
                : UIColor(red: 0.937, green: 0.267, blue: 0.267, alpha: 1.0)

            let boxRect = CGRect(x: 60, y: statusY, width: width - 120, height: 80)
            let boxPath = UIBezierPath(roundedRect: boxRect, cornerRadius: 16)
            context.setFillColor(statusColor.withAlphaComponent(0.1).cgColor)
            context.addPath(boxPath.cgPath)
            context.fillPath()

            context.setStrokeColor(statusColor.withAlphaComponent(0.3).cgColor)
            context.setLineWidth(2)
            context.addPath(boxPath.cgPath)
            context.strokePath()

            let statusText = passed ? "✓  PASS — \(standard.rawValue)" : "✗  NO GO — \(standard.rawValue)"
            let statusAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 30, weight: .heavy),
                .foregroundColor: statusColor
            ]
            let statusStr = NSAttributedString(string: statusText, attributes: statusAttrs)
            let statusSize = statusStr.size()
            statusStr.draw(at: CGPoint(x: boxRect.midX - statusSize.width / 2, y: boxRect.midY - statusSize.height / 2))

            let perEventLabelY: CGFloat = 1120
            let perEventAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.4)
            ]
            let perEventStr = NSAttributedString(string: "\(perEvent) pts per event  •  \(standard.rawValue) Standard", attributes: perEventAttrs)
            let perEventSize = perEventStr.size()
            perEventStr.draw(at: CGPoint(x: (width - perEventSize.width) / 2, y: perEventLabelY))

            let footerY = height - 80
            context.setStrokeColor(UIColor.white.withAlphaComponent(0.06).cgColor)
            context.setLineWidth(1)
            context.move(to: CGPoint(x: 60, y: footerY))
            context.addLine(to: CGPoint(x: width - 60, y: footerY))
            context.strokePath()

            let leftAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.25)
            ]
            let leftStr = NSAttributedString(string: "Me vs Me", attributes: leftAttrs)
            leftStr.draw(at: CGPoint(x: 60, y: footerY + 20))

            let rightAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.2)
            ]
            let rightStr = NSAttributedString(string: "#MVMArmy", attributes: rightAttrs)
            let rightSize = rightStr.size()
            rightStr.draw(at: CGPoint(x: width - 60 - rightSize.width, y: footerY + 20))
        }
    }

    private static func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
