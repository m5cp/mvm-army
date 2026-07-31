import SwiftUI
import UIKit
import PhotosUI

/// Share sheet for an AFT score — renders a Strava/IG-style score card the
/// user can put over the bundled golden-hour photo OR their own photo/selfie
/// from the actual test. Every text block sits on a translucent dark plate so
/// the numbers stay readable no matter what photo is behind them.
/// User photos never leave the device except in the image the user
/// explicitly shares.
struct AFTShareSheet: View {
    let score: AFTScoreRecord
    let previous: AFTScoreRecord?
    @Environment(\.dismiss) private var dismiss

    @State private var renderedImage: UIImage?
    @State private var showSavedToast: Bool = false
    @State private var backgroundImage: UIImage?
    @State private var libraryItem: PhotosPickerItem?
    @State private var showCamera: Bool = false
    @State private var rerenderTask: Task<Void, Never>?

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

                        backgroundPickerRow

                        actionButtons
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
            .overlay { savedToast }
            .task { rerender() }
            .onChange(of: libraryItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        backgroundImage = image
                        rerender()
                    }
                    libraryItem = nil
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { image in
                    if let image {
                        backgroundImage = image
                        rerender()
                    }
                }
                .ignoresSafeArea()
            }
        }
    }

    private func rerender() {
        renderedImage = nil
        let bg = backgroundImage
        rerenderTask?.cancel()
        rerenderTask = Task {
            let image = AFTCardRenderer.render(score: score, previous: previous, background: bg)
            if !Task.isCancelled {
                renderedImage = image
            }
        }
    }

    // MARK: - Background picker (Golden Hour / your photo / camera)

    private var backgroundPickerRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BACKGROUND")
                .font(MVMTheme.mono(10))
                .kerning(1.4)
                .foregroundStyle(MVMTheme.textFaint)
                .padding(.leading, 4)

            HStack(spacing: 10) {
                backgroundOption(
                    label: "Golden Hour",
                    icon: "sunrise.fill",
                    isSelected: backgroundImage == nil
                ) {
                    backgroundImage = nil
                    rerender()
                }

                PhotosPicker(selection: $libraryItem, matching: .images) {
                    backgroundOptionLabel(
                        label: "My Photo",
                        icon: "photo.on.rectangle.angled",
                        isSelected: false
                    )
                }
                .buttonStyle(PressScaleButtonStyle())

                backgroundOption(
                    label: "Camera",
                    icon: "camera.fill",
                    isSelected: false
                ) {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        showCamera = true
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func backgroundOption(label: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            backgroundOptionLabel(label: label, icon: icon, isSelected: isSelected)
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func backgroundOptionLabel(label: String, icon: String, isSelected: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
            Text(label)
                .font(.caption2.weight(.bold))
                .lineLimit(1)
                .fixedSize()
        }
        .foregroundStyle(isSelected ? MVMTheme.onAmber : MVMTheme.secondaryText)
        .frame(maxWidth: .infinity)
        .frame(height: 62)
        .background(isSelected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(MVMTheme.card))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? MVMTheme.amber.opacity(0.5) : MVMTheme.border, lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Save / Share

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
                .shadow(color: MVMTheme.amberBtnBot.opacity(0.35), radius: 18, y: 10)
                .contentShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(PressScaleButtonStyle())
            .disabled(renderedImage == nil)

            Button {
                if let image = renderedImage {
                    let text = shareCaption(for: score)
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

    private func shareCaption(for score: AFTScoreRecord) -> String {
        let appStoreURL = AppLinks.appStoreURLString
        let passStatus = score.totalScore >= 300 ? "PASSED ✅" : "in training 💪"
        return """
        Just scored \(score.totalScore) on my Army Fitness Test — \(passStatus) 🎯

        MDL: \(score.deadliftLbs) lbs (\(score.deadliftPoints) pts)
        HRP: \(score.pushUpReps) reps (\(score.pushUpPoints) pts)
        SDC: \(AFTCalculatorService.formatTime(score.sdcSeconds)) (\(score.sdcPoints) pts)
        PLK: \(AFTCalculatorService.formatTime(score.plankSeconds)) (\(score.plankPoints) pts)
        2MR: \(AFTCalculatorService.formatTime(score.runSeconds)) (\(score.runPoints) pts)

        Tracked with MVM Fitness
        \(appStoreURL)
        """
    }
}

// MARK: - Camera capture (photo/selfie for the card background)

/// Minimal UIImagePickerController wrapper. The captured photo is used only as
/// the share-card background and is never persisted by the app.
struct CameraPicker: UIViewControllerRepresentable {
    let onCapture: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .front
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage?) -> Void
        init(onCapture: @escaping (UIImage?) -> Void) { self.onCapture = onCapture }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
            onCapture(image)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onCapture(nil)
        }
    }
}

// MARK: - Card renderer (Golden Hour, photo-backed, Strava/IG style)

@MainActor
enum AFTCardRenderer {

    // Golden Hour palette (mirrors MVMTheme)
    private static let amber = UIColor(red: 0.910, green: 0.639, blue: 0.239, alpha: 1.0)      // #E8A33D
    private static let amberLight = UIColor(red: 0.949, green: 0.702, blue: 0.345, alpha: 1.0) // #F2B358
    private static let cream = UIColor(red: 0.949, green: 0.929, blue: 0.894, alpha: 1.0)      // #F2EDE4
    private static let successGreen = UIColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0)
    private static let dangerRed = UIColor(red: 0.937, green: 0.267, blue: 0.267, alpha: 1.0)
    private static let plate = UIColor(red: 0.043, green: 0.035, blue: 0.031, alpha: 0.62)     // scrim plate

    /// Renders the score card. `background` is the user's own photo (library or
    /// camera); nil falls back to the bundled golden-hour silhouette.
    static func render(score: AFTScoreRecord, previous: AFTScoreRecord?, background: UIImage? = nil) -> UIImage? {
        let width: CGFloat = 1080
        let height: CGFloat = 1350

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)

        return renderer.image { ctx in
            let context = ctx.cgContext

            drawBackground(context: context, background: background, width: width, height: height)
            drawHeader(context: context, width: width)
            drawScoreBlock(context: context, score: score, previous: previous, width: width)
            drawEventChips(context: context, score: score, width: width)
            drawFooter(context: context, width: width, height: height)
        }
    }

    // MARK: Background photo + scrims

    private static func drawBackground(context: CGContext, background: UIImage?, width: CGFloat, height: CGFloat) {
        // Base fill in case the photo has transparency or fails to load.
        context.setFillColor(UIColor(red: 0.043, green: 0.035, blue: 0.031, alpha: 1.0).cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        let photo = background ?? UIImage(named: "photo-run-silhouette-sunrise")
        if let photo {
            drawAspectFill(image: photo, in: CGRect(x: 0, y: 0, width: width, height: height))
        }

        // Top + bottom scrims — Strava-style, so the header and footer always
        // read over any user photo. The middle stays open for the photo.
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let topColors = [
            UIColor.black.withAlphaComponent(0.66).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor
        ] as CFArray
        if let g = CGGradient(colorsSpace: colorSpace, colors: topColors, locations: [0, 1]) {
            context.saveGState()
            context.clip(to: CGRect(x: 0, y: 0, width: width, height: 260))
            context.drawLinearGradient(g, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 260), options: [])
            context.restoreGState()
        }

        let bottomColors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.78).cgColor
        ] as CFArray
        if let g = CGGradient(colorsSpace: colorSpace, colors: bottomColors, locations: [0, 1]) {
            context.saveGState()
            context.clip(to: CGRect(x: 0, y: height - 560, width: width, height: 560))
            context.drawLinearGradient(g, start: CGPoint(x: 0, y: height - 560), end: CGPoint(x: 0, y: height), options: [])
            context.restoreGState()
        }
    }

    private static func drawAspectFill(image: UIImage, in rect: CGRect) {
        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0 else { return }
        let scale = max(rect.width / imageSize.width, rect.height / imageSize.height)
        let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let origin = CGPoint(
            x: rect.midX - drawSize.width / 2,
            y: rect.midY - drawSize.height / 2
        )
        UIGraphicsGetCurrentContext()?.saveGState()
        UIBezierPath(rect: rect).addClip()
        image.draw(in: CGRect(origin: origin, size: drawSize))
        UIGraphicsGetCurrentContext()?.restoreGState()
    }

    // MARK: Rounded text plate helper

    /// Draws a rounded translucent plate — the trick that keeps every piece of
    /// text readable over an arbitrary photo (IG/Snapchat text-background style).
    private static func drawPlate(context: CGContext, rect: CGRect, cornerRadius: CGFloat, color: UIColor = plate) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        context.setFillColor(color.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
    }

    private static func scoreFont(_ size: CGFloat) -> UIFont {
        UIFont(name: "Archivo-Bold", size: size)
            ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }

    // MARK: Header

    private static func drawHeader(context: CGContext, width: CGFloat) {
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 26, weight: .heavy),
            .foregroundColor: cream,
            .kern: 4.0
        ]
        let titleStr = NSAttributedString(string: "MVM FITNESS", attributes: titleAttrs)
        titleStr.draw(at: CGPoint(x: 60, y: 56))

        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: amber,
            .kern: 2.5
        ]
        let subStr = NSAttributedString(string: "ARMY FITNESS TEST", attributes: subAttrs)
        subStr.draw(at: CGPoint(x: 60, y: 96))

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            .foregroundColor: cream.withAlphaComponent(0.8)
        ]
        let dateStr = NSAttributedString(string: dateFormatter.string(from: .now), attributes: dateAttrs)
        let dateSize = dateStr.size()
        dateStr.draw(at: CGPoint(x: width - 60 - dateSize.width, y: 60))
    }

    // MARK: Score block (big number on a plate, GO seal, delta)

    private static func drawScoreBlock(context: CGContext, score: AFTScoreRecord, previous: AFTScoreRecord?, width: CGFloat) {
        let passed = score.deadliftPoints >= 60 && score.pushUpPoints >= 60 && score.sdcPoints >= 60
            && score.plankPoints >= 60 && score.runPoints >= 60 && score.totalScore >= 300

        // Score plate — centered, generous, rounded.
        let plateRect = CGRect(x: width / 2 - 300, y: 560, width: 600, height: 330)
        drawPlate(context: context, rect: plateRect, cornerRadius: 44)

        // Amber hairline around the plate for the "plaque" feel.
        let strokePath = UIBezierPath(roundedRect: plateRect, cornerRadius: 44)
        context.setStrokeColor(amber.withAlphaComponent(0.45).cgColor)
        context.setLineWidth(2)
        context.addPath(strokePath.cgPath)
        context.strokePath()

        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 20, weight: .bold),
            .foregroundColor: cream.withAlphaComponent(0.75),
            .kern: 3.5
        ]
        let label = NSAttributedString(string: "TOTAL SCORE", attributes: labelAttrs)
        let labelSize = label.size()
        label.draw(at: CGPoint(x: (width - labelSize.width) / 2, y: plateRect.minY + 34))

        // The big number — display face, amber, the hero of the card.
        let scoreAttrs: [NSAttributedString.Key: Any] = [
            .font: scoreFont(170),
            .foregroundColor: amberLight
        ]
        let scoreStr = NSAttributedString(string: "\(score.totalScore)", attributes: scoreAttrs)
        let scoreSize = scoreStr.size()
        let maxAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 34, weight: .semibold),
            .foregroundColor: cream.withAlphaComponent(0.55)
        ]
        let maxStr = NSAttributedString(string: "/500", attributes: maxAttrs)
        let maxSize = maxStr.size()

        let comboWidth = scoreSize.width + 14 + maxSize.width
        let scoreX = (width - comboWidth) / 2
        let scoreY = plateRect.minY + 62
        scoreStr.draw(at: CGPoint(x: scoreX, y: scoreY))
        maxStr.draw(at: CGPoint(x: scoreX + scoreSize.width + 14, y: scoreY + scoreSize.height - maxSize.height - 34))

        // GO / NO GO pill + delta, side by side under the number.
        let pillY = plateRect.maxY - 74

        let statusColor: UIColor = passed ? successGreen : dangerRed
        let statusText = passed ? "GO" : "NO GO"
        let statusAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 26, weight: .heavy),
            .foregroundColor: UIColor.black.withAlphaComponent(0.85),
            .kern: 1.5
        ]
        let statusStr = NSAttributedString(string: statusText, attributes: statusAttrs)
        let statusSize = statusStr.size()

        var deltaStr: NSAttributedString?
        if let prev = previous {
            let diff = score.totalScore - prev.totalScore
            let arrow = diff >= 0 ? "▲" : "▼"
            let text = diff >= 0 ? "+\(diff) VS LAST" : "\(diff) VS LAST"
            deltaStr = NSAttributedString(string: "\(arrow) \(text)", attributes: [
                .font: UIFont.monospacedSystemFont(ofSize: 22, weight: .bold),
                .foregroundColor: diff >= 0 ? amberLight : cream.withAlphaComponent(0.7),
                .kern: 1.0
            ])
        }

        let statusPillWidth = statusSize.width + 56
        let deltaWidth = deltaStr.map { $0.size().width + 40 } ?? 0
        let gap: CGFloat = deltaStr == nil ? 0 : 18
        let totalWidth = statusPillWidth + gap + deltaWidth
        var x = (width - totalWidth) / 2

        let statusPillRect = CGRect(x: x, y: pillY, width: statusPillWidth, height: 48)
        let statusPill = UIBezierPath(roundedRect: statusPillRect, cornerRadius: 24)
        context.setFillColor(statusColor.cgColor)
        context.addPath(statusPill.cgPath)
        context.fillPath()
        statusStr.draw(at: CGPoint(x: statusPillRect.midX - statusSize.width / 2, y: statusPillRect.midY - statusSize.height / 2))
        x += statusPillWidth + gap

        if let deltaStr {
            let deltaSize = deltaStr.size()
            let deltaRect = CGRect(x: x, y: pillY, width: deltaWidth, height: 48)
            drawPlate(context: context, rect: deltaRect, cornerRadius: 24)
            deltaStr.draw(at: CGPoint(x: deltaRect.midX - deltaSize.width / 2, y: deltaRect.midY - deltaSize.height / 2))
        }
    }

    // MARK: Event chips

    private static func formatTime(seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private static func drawEventChips(context: CGContext, score: AFTScoreRecord, width: CGFloat) {
        let events: [(code: String, raw: String, points: Int)] = [
            ("MDL", "\(score.deadliftLbs) LB", score.deadliftPoints),
            ("HRP", "\(score.pushUpReps) REPS", score.pushUpPoints),
            ("SDC", formatTime(seconds: score.sdcSeconds), score.sdcPoints),
            ("PLK", formatTime(seconds: score.plankSeconds), score.plankPoints),
            ("2MR", formatTime(seconds: score.runSeconds), score.runPoints)
        ]

        let margin: CGFloat = 60
        let gap: CGFloat = 14
        let chipWidth = (width - margin * 2 - gap * 4) / 5
        let chipHeight: CGFloat = 148
        let y: CGFloat = 928

        for (index, event) in events.enumerated() {
            let x = margin + CGFloat(index) * (chipWidth + gap)
            let chipRect = CGRect(x: x, y: y, width: chipWidth, height: chipHeight)
            drawPlate(context: context, rect: chipRect, cornerRadius: 22)

            let passColor: UIColor = event.points >= 60 ? amberLight : dangerRed

            let codeAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 17, weight: .bold),
                .foregroundColor: cream.withAlphaComponent(0.65),
                .kern: 1.5
            ]
            let codeStr = NSAttributedString(string: event.code, attributes: codeAttrs)
            let codeSize = codeStr.size()
            codeStr.draw(at: CGPoint(x: chipRect.midX - codeSize.width / 2, y: y + 18))

            let ptsAttrs: [NSAttributedString.Key: Any] = [
                .font: scoreFont(44),
                .foregroundColor: passColor
            ]
            let ptsStr = NSAttributedString(string: "\(event.points)", attributes: ptsAttrs)
            let ptsSize = ptsStr.size()
            ptsStr.draw(at: CGPoint(x: chipRect.midX - ptsSize.width / 2, y: y + 44))

            let rawAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 15, weight: .semibold),
                .foregroundColor: cream.withAlphaComponent(0.55)
            ]
            let rawStr = NSAttributedString(string: event.raw, attributes: rawAttrs)
            let rawSize = rawStr.size()
            rawStr.draw(at: CGPoint(x: chipRect.midX - rawSize.width / 2, y: y + chipHeight - rawSize.height - 16))
        }
    }

    // MARK: Footer

    private static func drawFooter(context: CGContext, width: CGFloat, height: CGFloat) {
        let y = height - 130

        let mottoAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 30, weight: .heavy),
            .foregroundColor: cream,
            .kern: 1.0
        ]
        let mottoStr = NSAttributedString(string: "Me vs Me.", attributes: mottoAttrs)
        mottoStr.draw(at: CGPoint(x: 60, y: y))

        let taglineAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: amber,
            .kern: 2.0
        ]
        let taglineStr = NSAttributedString(string: "MVM FITNESS", attributes: taglineAttrs)
        taglineStr.draw(at: CGPoint(x: 60, y: y + 44))

        ShareCardCGHelpers.drawAppQRFooter(context: context, width: width, footerTopY: y - 16)
    }
}
