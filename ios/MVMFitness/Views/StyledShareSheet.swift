import SwiftUI
import UIKit
import PhotosUI

// The unified share experience for workouts, progress, completions, Quick
// Start sessions, and unit PT — same photo-backed Golden Hour style as the
// AFT card, with a background picker: bundled photography, solid black, the
// user's own photo, or the camera. Every text block sits on a translucent
// plate so it stays readable over any background.

// MARK: - Backgrounds

enum ShareCardBackground: Equatable {
    case goldenHour       // sunrise runner silhouette
    case nightRuck        // hero-rucker-night
    case coldRuck         // photo-ruck-man-coldbreath
    case black            // solid black
    case custom(UIImage)  // user photo / camera

    /// The image drawn behind the card; nil = solid black.
    var image: UIImage? {
        switch self {
        case .goldenHour: return UIImage(named: "photo-run-silhouette-sunrise")
        case .nightRuck: return UIImage(named: "hero-rucker-night")
        case .coldRuck: return UIImage(named: "photo-ruck-man-coldbreath")
        case .black: return nil
        case .custom(let image): return image
        }
    }
}

// MARK: - Share sheet

struct StyledShareSheet: View {
    let cardType: ShareCardType
    @Environment(\.dismiss) private var dismiss

    @State private var background: ShareCardBackground = .goldenHour
    @State private var renderedImage: UIImage?
    @State private var showSavedToast = false
    @State private var libraryItem: PhotosPickerItem?
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
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

                        backgroundPicker
                        actionButtons
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Share Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .overlay { savedToast }
            .task { rerender() }
            .onChange(of: libraryItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        background = .custom(image)
                        rerender()
                    }
                    libraryItem = nil
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { image in
                    if let image {
                        background = .custom(image)
                        rerender()
                    }
                }
                .ignoresSafeArea()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func rerender() {
        renderedImage = nil
        let bg = background
        Task {
            renderedImage = StyledCardRenderer.render(cardType: cardType, background: bg)
        }
    }

    private var backgroundPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BACKGROUND")
                .font(MVMTheme.mono(10))
                .kerning(1.4)
                .foregroundStyle(MVMTheme.textFaint)
                .padding(.leading, 4)

            HStack(spacing: 8) {
                option("Golden", icon: "sunrise.fill", value: .goldenHour)
                option("Night", icon: "moon.stars.fill", value: .nightRuck)
                option("Ruck", icon: "figure.hiking", value: .coldRuck)
                option("Black", icon: "circle.fill", value: .black)
            }

            HStack(spacing: 8) {
                PhotosPicker(selection: $libraryItem, matching: .images) {
                    optionLabel("My Photo", icon: "photo.on.rectangle.angled", selected: false)
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        showCamera = true
                    }
                } label: {
                    optionLabel("Camera", icon: "camera.fill", selected: false)
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(.horizontal, 20)
    }

    private func option(_ label: String, icon: String, value: ShareCardBackground) -> some View {
        Button {
            background = value
            rerender()
        } label: {
            optionLabel(label, icon: icon, selected: background == value)
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func optionLabel(_ label: String, icon: String, selected: Bool) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
            Text(label)
                .font(.caption2.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(selected ? MVMTheme.onAmber : MVMTheme.secondaryText)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(selected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(MVMTheme.card))
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .overlay {
            RoundedRectangle(cornerRadius: 13)
                .stroke(selected ? MVMTheme.amber.opacity(0.5) : MVMTheme.border, lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 13))
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
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
                .foregroundStyle(MVMTheme.onAmber)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(MVMTheme.amberButtonGradient)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .contentShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(PressScaleButtonStyle())
            .disabled(renderedImage == nil)

            Button {
                if let image = renderedImage {
                    let items: [Any] = [image, ShareCardRenderer.fallbackText(cardType: cardType)]
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
                .contentShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(PressScaleButtonStyle())
            .disabled(renderedImage == nil)
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var savedToast: some View {
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

// MARK: - Renderer

@MainActor
enum StyledCardRenderer {

    private static let amber = UIColor(red: 0.910, green: 0.639, blue: 0.239, alpha: 1.0)
    private static let amberLight = UIColor(red: 0.949, green: 0.702, blue: 0.345, alpha: 1.0)
    private static let cream = UIColor(red: 0.949, green: 0.929, blue: 0.894, alpha: 1.0)
    private static let successGreen = UIColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0)
    private static let plate = UIColor(red: 0.043, green: 0.035, blue: 0.031, alpha: 0.62)

    /// Everything a card needs to draw, extracted from the ShareCardType.
    private struct Content {
        var typeLabel: String       // "WORKOUT" / "MISSION COMPLETE" / …
        var title: String
        var subtitle: String?       // objective / date line etc.
        var stats: [(value: String, label: String)]
        var rows: [(name: String, detail: String)]
        var showCheckSeal: Bool
    }

    static func render(cardType: ShareCardType, background: ShareCardBackground = .goldenHour, date: Date = .now) -> UIImage? {
        // The AFT card has its own dedicated renderer (kept identical).
        if case .aft(let score, let previous) = cardType {
            let bg = background.image ?? blackImage()
            return AFTCardRenderer.render(score: score, previous: previous, background: bg)
        }

        let content = extract(cardType, date: date)
        let width: CGFloat = 1080
        let height: CGFloat = 1350

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)

        return renderer.image { ctx in
            let context = ctx.cgContext

            drawBackground(context: context, background: background, width: width, height: height)
            drawHeader(context: context, typeLabel: content.typeLabel, width: width, date: date)

            var y: CGFloat = 560

            if content.showCheckSeal {
                drawSeal(context: context, centerX: width / 2, centerY: 420)
            }

            // Title plate
            let titleFont = UIFont.systemFont(ofSize: 52, weight: .bold)
            let titleAttrs: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: cream]
            let titleStr = NSAttributedString(string: content.title, attributes: titleAttrs)
            let titleBounds = titleStr.boundingRect(
                with: CGSize(width: width - 260, height: 140),
                options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                context: nil
            )
            let titlePlateRect = CGRect(
                x: width / 2 - titleBounds.width / 2 - 44,
                y: y - 30,
                width: titleBounds.width + 88,
                height: titleBounds.height + 60 + (content.subtitle != nil ? 42 : 0)
            )
            drawPlate(context: context, rect: titlePlateRect, cornerRadius: 34)
            titleStr.draw(
                with: CGRect(x: width / 2 - titleBounds.width / 2, y: y, width: titleBounds.width, height: titleBounds.height + 4),
                options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                context: nil
            )
            if let subtitle = content.subtitle {
                let subAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: 20, weight: .semibold),
                    .foregroundColor: amber
                ]
                let subStr = NSAttributedString(string: subtitle, attributes: subAttrs)
                let subSize = subStr.size()
                subStr.draw(at: CGPoint(x: width / 2 - subSize.width / 2, y: y + titleBounds.height + 14))
            }
            y = titlePlateRect.maxY + 28

            // Stat chips
            if !content.stats.isEmpty {
                let margin: CGFloat = 90
                let gap: CGFloat = 16
                let count = CGFloat(content.stats.count)
                let chipWidth = (width - margin * 2 - gap * (count - 1)) / count
                let chipHeight: CGFloat = 132
                for (index, stat) in content.stats.enumerated() {
                    let x = margin + CGFloat(index) * (chipWidth + gap)
                    let rect = CGRect(x: x, y: y, width: chipWidth, height: chipHeight)
                    drawPlate(context: context, rect: rect, cornerRadius: 24)

                    let valueSize: CGFloat = stat.value.count > 6 ? 34 : 46
                    let valueAttrs: [NSAttributedString.Key: Any] = [
                        .font: scoreFont(valueSize),
                        .foregroundColor: amberLight
                    ]
                    let valueStr = NSAttributedString(string: stat.value, attributes: valueAttrs)
                    let vSize = valueStr.size()
                    valueStr.draw(at: CGPoint(x: rect.midX - vSize.width / 2, y: rect.minY + 22 + (valueSize == 34 ? 8 : 0)))

                    let labelAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.monospacedSystemFont(ofSize: 16, weight: .semibold),
                        .foregroundColor: cream.withAlphaComponent(0.6),
                        .kern: 1.2
                    ]
                    let labelStr = NSAttributedString(string: stat.label, attributes: labelAttrs)
                    let lSize = labelStr.size()
                    labelStr.draw(at: CGPoint(x: rect.midX - lSize.width / 2, y: rect.maxY - lSize.height - 18))
                }
                y += chipHeight + 28
            }

            // Detail rows on one tall plate
            if !content.rows.isEmpty {
                let rowHeight: CGFloat = 62
                let maxRows = min(content.rows.count, 5)
                let plateRect = CGRect(x: 90, y: y, width: width - 180, height: CGFloat(maxRows) * rowHeight + 36)
                if plateRect.maxY < height - 170 {
                    drawPlate(context: context, rect: plateRect, cornerRadius: 28)
                    var rowY = plateRect.minY + 20
                    for row in content.rows.prefix(maxRows) {
                        context.setFillColor(amber.cgColor)
                        context.fillEllipse(in: CGRect(x: plateRect.minX + 30, y: rowY + 16, width: 10, height: 10))

                        let nameAttrs: [NSAttributedString.Key: Any] = [
                            .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                            .foregroundColor: cream.withAlphaComponent(0.92)
                        ]
                        NSAttributedString(string: row.name, attributes: nameAttrs)
                            .draw(with: CGRect(x: plateRect.minX + 58, y: rowY + 4, width: plateRect.width - 300, height: 34),
                                  options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)

                        let detailAttrs: [NSAttributedString.Key: Any] = [
                            .font: UIFont.monospacedSystemFont(ofSize: 19, weight: .semibold),
                            .foregroundColor: amberLight
                        ]
                        let detailStr = NSAttributedString(string: row.detail, attributes: detailAttrs)
                        let dSize = detailStr.size()
                        detailStr.draw(at: CGPoint(x: plateRect.maxX - 30 - dSize.width, y: rowY + 8))

                        rowY += rowHeight
                    }
                    if content.rows.count > maxRows {
                        let moreAttrs: [NSAttributedString.Key: Any] = [
                            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                            .foregroundColor: cream.withAlphaComponent(0.5)
                        ]
                        NSAttributedString(string: "+\(content.rows.count - maxRows) more", attributes: moreAttrs)
                            .draw(at: CGPoint(x: plateRect.minX + 58, y: plateRect.maxY - 4))
                    }
                }
            }

            drawFooter(context: context, width: width, height: height)
        }
    }

    // MARK: Content extraction

    private static func extract(_ cardType: ShareCardType, date: Date) -> Content {
        switch cardType {
        case .workout(let title, let exercises, let tags):
            return Content(
                typeLabel: tags.first.map { $0.uppercased() } ?? "WORKOUT",
                title: title,
                subtitle: "\(exercises.count) EXERCISES",
                stats: [],
                rows: exercises.prefix(8).map { ($0.name, $0.displayDetail) },
                showCheckSeal: false
            )
        case .completion(let title, let exerciseCount, let duration):
            return Content(
                typeLabel: "MISSION COMPLETE",
                title: title,
                subtitle: nil,
                stats: duration.isEmpty
                    ? [("\(exerciseCount)", "EXERCISES")]
                    : [("\(exerciseCount)", "EXERCISES"), (duration, "DURATION")],
                rows: [],
                showCheckSeal: true
            )
        case .completedWorkout(let record):
            return Content(
                typeLabel: record.source == .wod ? "FUNCTIONFITNESS \u{00B7} COMPLETE" : "MISSION COMPLETE",
                title: record.title,
                subtitle: nil,
                stats: [("\(record.exerciseCount)", "EXERCISES"), (record.source.rawValue.uppercased(), "TYPE")],
                rows: record.exercises.prefix(8).map { ($0.name, $0.displayDetail) },
                showCheckSeal: true
            )
        case .quickStart(let record):
            var stats: [(String, String)] = [(record.formattedDuration, "DURATION")]
            if record.activity.usesGPS {
                stats.append((record.formattedDistance, "DISTANCE"))
                stats.append((record.formattedPace, "AVG PACE"))
            }
            return Content(
                typeLabel: "ACTIVITY COMPLETE",
                title: record.activity.rawValue,
                subtitle: nil,
                stats: stats,
                rows: [],
                showCheckSeal: true
            )
        case .progress(let completed, let planned, let streak, let steps):
            let stepsStr = steps >= 1000 ? String(format: "%.1fk", Double(steps) / 1000) : "\(steps)"
            return Content(
                typeLabel: "WEEKLY PROGRESS",
                title: "Me vs Me.",
                subtitle: nil,
                stats: [("\(completed)/\(planned)", "PT DONE"), ("\(streak)", "STREAK"), (stepsStr, "STEPS")],
                rows: [],
                showCheckSeal: false
            )
        case .unitPT(let plan):
            return Content(
                typeLabel: "FORMATION PT",
                title: plan.title,
                subtitle: nil,
                stats: [],
                rows: plan.mainEffort.prefix(6).map { ($0.description, "") },
                showCheckSeal: false
            )
        case .aft:
            return Content(typeLabel: "", title: "", subtitle: nil, stats: [], rows: [], showCheckSeal: false)
        }
    }

    // MARK: Drawing pieces

    private static func blackImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8))
        return renderer.image { ctx in
            UIColor.black.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 8, height: 8))
        }
    }

    private static func drawBackground(context: CGContext, background: ShareCardBackground, width: CGFloat, height: CGFloat) {
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        if let photo = background.image {
            drawAspectFill(image: photo, in: CGRect(x: 0, y: 0, width: width, height: height))
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let topColors = [
            UIColor.black.withAlphaComponent(0.66).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor
        ] as CFArray
        if let g = CGGradient(colorsSpace: colorSpace, colors: topColors, locations: [0, 1]) {
            context.saveGState()
            context.clip(to: CGRect(x: 0, y: 0, width: width, height: 260))
            context.drawLinearGradient(g, start: .zero, end: CGPoint(x: 0, y: 260), options: [])
            context.restoreGState()
        }
        let bottomColors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.78).cgColor
        ] as CFArray
        if let g = CGGradient(colorsSpace: colorSpace, colors: bottomColors, locations: [0, 1]) {
            context.saveGState()
            context.clip(to: CGRect(x: 0, y: height - 480, width: width, height: 480))
            context.drawLinearGradient(g, start: CGPoint(x: 0, y: height - 480), end: CGPoint(x: 0, y: height), options: [])
            context.restoreGState()
        }
    }

    private static func drawAspectFill(image: UIImage, in rect: CGRect) {
        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0 else { return }
        let scale = max(rect.width / imageSize.width, rect.height / imageSize.height)
        let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let origin = CGPoint(x: rect.midX - drawSize.width / 2, y: rect.midY - drawSize.height / 2)
        UIGraphicsGetCurrentContext()?.saveGState()
        UIBezierPath(rect: rect).addClip()
        image.draw(in: CGRect(origin: origin, size: drawSize))
        UIGraphicsGetCurrentContext()?.restoreGState()
    }

    private static func drawPlate(context: CGContext, rect: CGRect, cornerRadius: CGFloat) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        context.setFillColor(plate.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
    }

    private static func scoreFont(_ size: CGFloat) -> UIFont {
        UIFont(name: "Archivo-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }

    private static func drawHeader(context: CGContext, typeLabel: String, width: CGFloat, date: Date) {
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 26, weight: .heavy),
            .foregroundColor: cream,
            .kern: 4.0
        ]
        NSAttributedString(string: "MVM FITNESS", attributes: titleAttrs)
            .draw(at: CGPoint(x: 60, y: 56))

        if !typeLabel.isEmpty {
            let subAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold),
                .foregroundColor: amber,
                .kern: 2.5
            ]
            NSAttributedString(string: typeLabel, attributes: subAttrs)
                .draw(at: CGPoint(x: 60, y: 96))
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            .foregroundColor: cream.withAlphaComponent(0.8)
        ]
        let dateStr = NSAttributedString(string: dateFormatter.string(from: date), attributes: dateAttrs)
        let dateSize = dateStr.size()
        dateStr.draw(at: CGPoint(x: width - 60 - dateSize.width, y: 60))
    }

    /// Amber ring + check — the completion seal, drawn plate-backed.
    private static func drawSeal(context: CGContext, centerX: CGFloat, centerY: CGFloat) {
        let radius: CGFloat = 74
        drawPlate(context: context,
                  rect: CGRect(x: centerX - radius - 26, y: centerY - radius - 26, width: (radius + 26) * 2, height: (radius + 26) * 2),
                  cornerRadius: radius + 26)

        context.setStrokeColor(successGreen.cgColor)
        context.setLineWidth(6)
        context.strokeEllipse(in: CGRect(x: centerX - radius, y: centerY - radius, width: radius * 2, height: radius * 2))

        let checkSize: CGFloat = radius * 0.9
        let checkX = centerX - checkSize / 2
        let checkY = centerY - checkSize / 2.6
        let path = UIBezierPath()
        path.move(to: CGPoint(x: checkX, y: checkY + checkSize * 0.5))
        path.addLine(to: CGPoint(x: checkX + checkSize * 0.35, y: checkY + checkSize * 0.8))
        path.addLine(to: CGPoint(x: checkX + checkSize, y: checkY + checkSize * 0.1))
        context.setStrokeColor(successGreen.cgColor)
        context.setLineWidth(10)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.addPath(path.cgPath)
        context.strokePath()
    }

    private static func drawFooter(context: CGContext, width: CGFloat, height: CGFloat) {
        let y = height - 130

        let mottoAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 30, weight: .heavy),
            .foregroundColor: cream,
            .kern: 1.0
        ]
        NSAttributedString(string: "Me vs Me.", attributes: mottoAttrs)
            .draw(at: CGPoint(x: 60, y: y))

        let taglineAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: amber,
            .kern: 2.0
        ]
        NSAttributedString(string: "MVM FITNESS", attributes: taglineAttrs)
            .draw(at: CGPoint(x: 60, y: y + 44))

        ShareCardCGHelpers.drawAppQRFooter(context: context, width: width, footerTopY: y - 16)
    }
}
