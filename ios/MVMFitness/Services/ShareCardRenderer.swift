import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins

enum ShareCardType {
    case workout(title: String, exercises: [WorkoutExercise], tags: [String])
    case progress(completed: Int, planned: Int, streak: Int, steps: Int)
    case aft(score: AFTScoreRecord, previous: AFTScoreRecord?)
    case unitPT(plan: UnitPTPlan)
    case completion(title: String, exerciseCount: Int, duration: String)
    case completedWorkout(record: CompletedWorkoutRecord)
    case quickStart(record: QuickStartRecord)
}

@MainActor
enum ShareCardRenderer {

    static func renderImage(cardType: ShareCardType, date: Date = .now) -> UIImage? {
        // All cards render through the photo-backed Golden Hour system.
        StyledCardRenderer.render(cardType: cardType, background: .goldenHour, date: date)
    }

    static func shareItems(cardType: ShareCardType, date: Date = .now) -> [Any] {
        if let image = renderImage(cardType: cardType, date: date) {
            return [image, fallbackText(cardType: cardType)]
        }
        return [fallbackText(cardType: cardType)]
    }

    static func presentShareSheet(cardType: ShareCardType, date: Date = .now) {
        UserDefaults.standard.set(true, forKey: "hasSharedOnce")
        AnalyticsService.track(.shareCardShared)

        // Present the styled share sheet (background picker: bundled photos,
        // black, the user's own photo, or camera) instead of a bare activity
        // controller with a pre-rendered image.
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        var presenter = rootVC
        while let presented = presenter.presentedViewController {
            presenter = presented
        }

        let host = UIHostingController(rootView: StyledShareSheet(cardType: cardType))
        host.overrideUserInterfaceStyle = .dark
        host.view.backgroundColor = .clear
        presenter.present(host, animated: true)
    }

    static func saveToPhotos(cardType: ShareCardType, date: Date = .now) -> Bool {
        guard let image = renderImage(cardType: cardType, date: date) else { return false }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        return true
    }

    static func fallbackText(cardType: ShareCardType) -> String {
        switch cardType {
        case .workout(let title, let exercises, _):
            return "MVM Fitness — \(title)\n\(exercises.count) exercises\n#MVMFitness\(AppLinks.shareSuffix)"
        case .progress(let completed, let planned, let streak, let steps):
            return "MVM Fitness — Weekly Progress\n\(completed)/\(planned) PT done · \(streak) day streak · \(steps) steps\n#MVMFitness\(AppLinks.shareSuffix)"
        case .aft(let score, _):
            return "MVM Fitness — AFT Score: \(score.totalScore)\n#MVMFitness\(AppLinks.shareSuffix)"
        case .unitPT(let plan):
            return "MVM Fitness — \(plan.title)\n\(plan.objective)\n#MVMFitness\(AppLinks.shareSuffix)"
        case .completion(let title, let count, let duration):
            return "MVM Fitness — Completed: \(title)\n\(count) exercises · \(duration)\n#MVMFitness\(AppLinks.shareSuffix)"
        case .completedWorkout(let record):
            let prefix = record.source == .wod ? "FunctionFitness: " : ""
            return "MVM Fitness — \(prefix)\(record.title)\n\(record.exerciseCount) exercises\n#MVMFitness\(AppLinks.shareSuffix)"
        case .quickStart(let record):
            return "MVM Fitness — \(record.activity.rawValue)\nDuration: \(record.formattedDuration)\n#MVMFitness\(AppLinks.shareSuffix)"
        }
    }
}

@MainActor
enum ShareCardCGHelpers {
    static let width: CGFloat = 1080
    static let bgColor = UIColor(red: 0.047, green: 0.059, blue: 0.055, alpha: 1.0)
    // Golden Hour green sweep — mirrors MVMTheme.amber (#E8A33D). Name kept to
    // avoid touching every call site across the share-card renderers.
    static let accentBlue = UIColor(red: 0.910, green: 0.639, blue: 0.239, alpha: 1.0)
    static let accentPurple = UIColor(red: 0.29, green: 0.49, blue: 0.42, alpha: 1.0)
    static let successGreen = UIColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0)
    static let warningAmber = UIColor(red: 0.769, green: 0.514, blue: 0.231, alpha: 1.0)

    static func drawBackground(context: CGContext, width: CGFloat, height: CGFloat) {
        context.setFillColor(bgColor.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        let colors = [
            UIColor(red: 0.910, green: 0.639, blue: 0.239, alpha: 0.14).cgColor,
            UIColor(red: 0.910, green: 0.639, blue: 0.239, alpha: 0.06).cgColor,
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

        drawAppQRFooter(context: context, width: width, footerTopY: y)
    }

    /// Renders a small "GET THE APP" QR code pointing at the App Store listing,
    /// used on the right side of every share-card footer strip.
    static func drawAppQRFooter(context: CGContext, width: CGFloat, footerTopY: CGFloat) {
        let qrSize: CGFloat = 48
        let qrX = width - 60 - qrSize
        let qrY = footerTopY + 16

        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 11, weight: .bold),
            .foregroundColor: UIColor.white.withAlphaComponent(0.35),
            .kern: 1.2
        ]
        let labelStr = NSAttributedString(string: "GET THE\nAPP", attributes: labelAttrs)
        let labelBounds = labelStr.boundingRect(with: CGSize(width: 90, height: 40), options: [.usesLineFragmentOrigin], context: nil)
        labelStr.draw(with: CGRect(x: qrX - labelBounds.width - 14, y: qrY + qrSize / 2 - labelBounds.height / 2, width: labelBounds.width, height: labelBounds.height), options: [.usesLineFragmentOrigin], context: nil)

        drawQRCode(context: context, x: qrX, y: qrY, size: qrSize)
    }

    /// Draws a scannable QR code (white plate + module image) at the given origin.
    static func drawQRCode(context: CGContext, x: CGFloat, y: CGFloat, size: CGFloat) {
        let pad: CGFloat = 6
        let plateRect = CGRect(x: x - pad, y: y - pad, width: size + pad * 2, height: size + pad * 2)
        let platePath = UIBezierPath(roundedRect: plateRect, cornerRadius: 8)
        context.setFillColor(UIColor.white.cgColor)
        context.addPath(platePath.cgPath)
        context.fillPath()

        guard let qrImage = qrCodeImage(string: AppLinks.appStoreURLString, pixelSize: size) else { return }
        qrImage.draw(in: CGRect(x: x, y: y, width: size, height: size))
    }

    private static func qrCodeImage(string: String, pixelSize: CGFloat) -> UIImage? {
        let ciContext = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scale = pixelSize / output.extent.width
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cgImage = ciContext.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
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
