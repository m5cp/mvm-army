import SwiftUI
import UIKit

struct AFTShareSheet: View {
    let score: AFTScoreRecord
    let previous: AFTScoreRecord?
    @Environment(\.dismiss) private var dismiss
    @State private var renderedImage: UIImage?
    @State private var showSavedToast: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if let image = renderedImage {
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
                            if let image = renderedImage {
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
                        .disabled(renderedImage == nil)

                        Button {
                            if let image = renderedImage {
                                let text = "MVM Army — AFT Score: \(score.totalScore)/500\n#MVMArmy #ArmyFitness"
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
                        .disabled(renderedImage == nil)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("AFT Score Card")
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
            .task {
                renderedImage = AFTCardRenderer.render(score: score, previous: previous)
            }
        }
    }
}

@MainActor
enum AFTCardRenderer {
    static func render(score: AFTScoreRecord, previous: AFTScoreRecord?) -> UIImage? {
        let width: CGFloat = 1080
        let height: CGFloat = 1350
        let scale: CGFloat = 1.0

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)

        return renderer.image { ctx in
            let context = ctx.cgContext

            drawBackground(context: context, width: width, height: height)
            drawHeader(context: context, width: width)
            drawTotalScore(context: context, score: score, previous: previous, width: width)
            drawEventBreakdown(context: context, score: score, width: width)
            drawPassFail(context: context, score: score, width: width)
            drawFooter(context: context, width: width, height: height)
        }
    }

    private static func drawBackground(context: CGContext, width: CGFloat, height: CGFloat) {
        let bgColor = UIColor(red: 0.035, green: 0.035, blue: 0.047, alpha: 1.0)
        context.setFillColor(bgColor.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        let colors = [
            UIColor(red: 0.31, green: 0.55, blue: 1.0, alpha: 0.12).cgColor,
            UIColor(red: 0.49, green: 0.36, blue: 1.0, alpha: 0.06).cgColor,
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

    private static func drawHeader(context: CGContext, width: CGFloat) {
        let shieldIcon = "⬡"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 28, weight: .bold),
            .foregroundColor: UIColor(red: 0.31, green: 0.55, blue: 1.0, alpha: 1.0)
        ]
        let shieldStr = NSAttributedString(string: shieldIcon, attributes: attrs)
        shieldStr.draw(at: CGPoint(x: 60, y: 50))

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .heavy),
            .foregroundColor: UIColor.white.withAlphaComponent(0.7),
            .kern: 3.0
        ]
        let titleStr = NSAttributedString(string: "MVM ARMY", attributes: titleAttrs)
        titleStr.draw(at: CGPoint(x: 100, y: 54))

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.35)
        ]
        let dateStr = NSAttributedString(string: dateFormatter.string(from: .now), attributes: dateAttrs)
        let dateSize = dateStr.size()
        dateStr.draw(at: CGPoint(x: width - 60 - dateSize.width, y: 56))

        let lineY: CGFloat = 100
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.06).cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: 60, y: lineY))
        context.addLine(to: CGPoint(x: width - 60, y: lineY))
        context.strokePath()
    }

    private static func drawTotalScore(context: CGContext, score: AFTScoreRecord, previous: AFTScoreRecord?, width: CGFloat) {
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 26, weight: .semibold),
            .foregroundColor: UIColor.white.withAlphaComponent(0.5)
        ]
        let label = NSAttributedString(string: "AFT TOTAL SCORE", attributes: labelAttrs)
        let labelSize = label.size()
        label.draw(at: CGPoint(x: (width - labelSize.width) / 2, y: 140))

        let scoreFont = UIFont.systemFont(ofSize: 160, weight: .bold)
        let scoreAttrs: [NSAttributedString.Key: Any] = [
            .font: scoreFont,
            .foregroundColor: UIColor.white
        ]
        let scoreStr = NSAttributedString(string: "\(score.totalScore)", attributes: scoreAttrs)
        let scoreSize = scoreStr.size()
        scoreStr.draw(at: CGPoint(x: (width - scoreSize.width) / 2, y: 180))

        let maxAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 36, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.3)
        ]
        let maxStr = NSAttributedString(string: "/ 500", attributes: maxAttrs)
        let maxSize = maxStr.size()
        maxStr.draw(at: CGPoint(x: (width - maxSize.width) / 2, y: 360))

        if let prev = previous {
            let diff = score.totalScore - prev.totalScore
            let diffColor: UIColor = diff >= 0
                ? UIColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0)
                : UIColor(red: 0.937, green: 0.267, blue: 0.267, alpha: 1.0)
            let arrow = diff >= 0 ? "▲" : "▼"
            let diffText = diff >= 0 ? "+\(diff)" : "\(diff)"
            let diffAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 30, weight: .bold),
                .foregroundColor: diffColor
            ]
            let diffStr = NSAttributedString(string: "\(arrow) \(diffText) from last", attributes: diffAttrs)
            let diffSize = diffStr.size()
            diffStr.draw(at: CGPoint(x: (width - diffSize.width) / 2, y: 410))
        }
    }

    private static func formatTime(seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private static func drawEventBreakdown(context: CGContext, score: AFTScoreRecord, width: CGFloat) {
        let startY: CGFloat = 480
        let sectionLabel: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .heavy),
            .foregroundColor: UIColor.white.withAlphaComponent(0.4),
            .kern: 2.0
        ]
        let sectionStr = NSAttributedString(string: "EVENT BREAKDOWN", attributes: sectionLabel)
        let sectionSize = sectionStr.size()
        sectionStr.draw(at: CGPoint(x: (width - sectionSize.width) / 2, y: startY))

        let events: [(abbr: String, name: String, rawValue: String, points: Int)] = [
            ("MDL", "3RM Deadlift", "\(score.deadliftLbs) lbs", score.deadliftPoints),
            ("HRP", "Push-Up", "\(score.pushUpReps) reps", score.pushUpPoints),
            ("SDC", "Sprint-Drag-Carry", formatTime(seconds: score.sdcSeconds), score.sdcPoints),
            ("PLK", "Plank", formatTime(seconds: score.plankSeconds), score.plankPoints),
            ("2MR", "2-Mile Run", formatTime(seconds: score.runSeconds), score.runPoints)
        ]

        let rowHeight: CGFloat = 90
        let rowStartY: CGFloat = startY + 50
        let marginX: CGFloat = 60

        for (index, event) in events.enumerated() {
            let y = rowStartY + CGFloat(index) * rowHeight

            let pillColor = eventColor(event.points)
            let pillRect = CGRect(x: marginX, y: y + 8, width: 70, height: 40)
            let pillPath = UIBezierPath(roundedRect: pillRect, cornerRadius: 10)
            context.setFillColor(pillColor.withAlphaComponent(0.18).cgColor)
            context.addPath(pillPath.cgPath)
            context.fillPath()

            let abbrAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .heavy),
                .foregroundColor: pillColor
            ]
            let abbrStr = NSAttributedString(string: event.abbr, attributes: abbrAttrs)
            let abbrSize = abbrStr.size()
            abbrStr.draw(at: CGPoint(x: pillRect.midX - abbrSize.width / 2, y: pillRect.midY - abbrSize.height / 2))

            let nameAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let nameStr = NSAttributedString(string: event.name, attributes: nameAttrs)
            nameStr.draw(at: CGPoint(x: marginX + 85, y: y + 6))

            let rawAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.4)
            ]
            let rawStr = NSAttributedString(string: event.rawValue, attributes: rawAttrs)
            rawStr.draw(at: CGPoint(x: marginX + 85, y: y + 34))

            let pointsAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36, weight: .bold),
                .foregroundColor: pillColor
            ]
            let pointsStr = NSAttributedString(string: "\(event.points)", attributes: pointsAttrs)
            let pointsSize = pointsStr.size()
            pointsStr.draw(at: CGPoint(x: width - marginX - pointsSize.width, y: y + 6))

            let barY = y + 64
            let barWidth = width - marginX * 2
            let barHeight: CGFloat = 6
            let barBgRect = CGRect(x: marginX, y: barY, width: barWidth, height: barHeight)
            let barBgPath = UIBezierPath(roundedRect: barBgRect, cornerRadius: 3)
            context.setFillColor(UIColor.white.withAlphaComponent(0.06).cgColor)
            context.addPath(barBgPath.cgPath)
            context.fillPath()

            let fillWidth = barWidth * CGFloat(min(event.points, 100)) / 100.0
            let barFillRect = CGRect(x: marginX, y: barY, width: fillWidth, height: barHeight)
            let barFillPath = UIBezierPath(roundedRect: barFillRect, cornerRadius: 3)
            context.setFillColor(pillColor.cgColor)
            context.addPath(barFillPath.cgPath)
            context.fillPath()
        }
    }

    private static func drawPassFail(context: CGContext, score: AFTScoreRecord, width: CGFloat) {
        let y: CGFloat = 1040
        let passed = score.totalScore >= 360 && score.deadliftPoints >= 60 && score.pushUpPoints >= 60 && score.sdcPoints >= 60 && score.plankPoints >= 60 && score.runPoints >= 60
        let statusColor: UIColor = passed
            ? UIColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0)
            : UIColor(red: 0.937, green: 0.267, blue: 0.267, alpha: 1.0)

        let boxRect = CGRect(x: 60, y: y, width: width - 120, height: 80)
        let boxPath = UIBezierPath(roundedRect: boxRect, cornerRadius: 16)
        context.setFillColor(statusColor.withAlphaComponent(0.1).cgColor)
        context.addPath(boxPath.cgPath)
        context.fillPath()

        context.setStrokeColor(statusColor.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(2)
        context.addPath(boxPath.cgPath)
        context.strokePath()

        let statusText = passed ? "✓  PASS" : "✗  NO GO"
        let statusAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 32, weight: .heavy),
            .foregroundColor: statusColor
        ]
        let statusStr = NSAttributedString(string: statusText, attributes: statusAttrs)
        let statusSize = statusStr.size()
        statusStr.draw(at: CGPoint(x: boxRect.midX - statusSize.width / 2, y: boxRect.midY - statusSize.height / 2))
    }

    private static func drawFooter(context: CGContext, width: CGFloat, height: CGFloat) {
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
        let leftStr = NSAttributedString(string: "Me vs Me", attributes: leftAttrs)
        leftStr.draw(at: CGPoint(x: 60, y: y + 20))

        let rightAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.2)
        ]
        let rightStr = NSAttributedString(string: "#MVMArmy", attributes: rightAttrs)
        let rightSize = rightStr.size()
        rightStr.draw(at: CGPoint(x: width - 60 - rightSize.width, y: y + 20))
    }

    private static func eventColor(_ points: Int) -> UIColor {
        if points >= 80 { return UIColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0) }
        if points >= 60 { return UIColor(red: 0.31, green: 0.55, blue: 1.0, alpha: 1.0) }
        if points >= 40 { return UIColor(red: 0.961, green: 0.62, blue: 0.043, alpha: 1.0) }
        return UIColor(red: 0.937, green: 0.267, blue: 0.267, alpha: 1.0)
    }
}
