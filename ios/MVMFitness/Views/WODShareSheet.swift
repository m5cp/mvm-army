import SwiftUI
import UIKit

struct WODShareSheet: View {
    let template: WODTemplate
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
                                let text = "MVM Army — WOD: \(template.title)\n#MVMArmy #ArmyFitness"
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
            .navigationTitle("WOD Share Card")
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
                renderedImage = WODCardRenderer.render(template: template)
            }
        }
    }
}

@MainActor
enum WODCardRenderer {
    static func render(template: WODTemplate) -> UIImage? {
        let w: CGFloat = 1080
        let movementRows = min(template.movements.count, 6)
        let h: CGFloat = CGFloat(820 + movementRows * 60)
        let renderer = ShareCardCGHelpers.makeRenderer(width: w, height: h)

        return renderer.image { ctx in
            let context = ctx.cgContext

            ShareCardCGHelpers.drawBackground(context: context, width: w, height: h)
            ShareCardCGHelpers.drawHeader(context: context, width: w, date: .now)

            drawWODBadge(context: context, width: w)
            drawFormatPill(context: context, format: template.format.rawValue, width: w)
            drawTitle(context: context, title: template.title, width: w)
            drawDescription(context: context, desc: template.workoutDescription, width: w)
            drawStats(context: context, template: template, width: w)
            drawMovements(context: context, movements: template.movements, width: w)

            ShareCardCGHelpers.drawFooter(context: context, width: w, height: h)
        }
    }

    private static func drawWODBadge(context: CGContext, width: CGFloat) {
        let starAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .heavy),
            .foregroundColor: ShareCardCGHelpers.warningAmber
        ]
        let starStr = NSAttributedString(string: "★  WOD", attributes: starAttrs)
        let starSize = starStr.size()
        let pillRect = CGRect(x: 60, y: 130, width: starSize.width + 28, height: 36)
        let pillPath = UIBezierPath(roundedRect: pillRect, cornerRadius: 18)
        context.setFillColor(ShareCardCGHelpers.warningAmber.withAlphaComponent(0.15).cgColor)
        context.addPath(pillPath.cgPath)
        context.fillPath()
        starStr.draw(at: CGPoint(x: pillRect.midX - starSize.width / 2, y: pillRect.midY - starSize.height / 2))
    }

    private static func drawFormatPill(context: CGContext, format: String, width: CGFloat) {
        let formatAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: ShareCardCGHelpers.accentPurple
        ]
        let formatStr = NSAttributedString(string: format, attributes: formatAttrs)
        let formatSize = formatStr.size()
        let pillRect = CGRect(x: width - 60 - formatSize.width - 28, y: 130, width: formatSize.width + 28, height: 36)
        let pillPath = UIBezierPath(roundedRect: pillRect, cornerRadius: 18)
        context.setFillColor(ShareCardCGHelpers.accentPurple.withAlphaComponent(0.15).cgColor)
        context.addPath(pillPath.cgPath)
        context.fillPath()
        formatStr.draw(at: CGPoint(x: pillRect.midX - formatSize.width / 2, y: pillRect.midY - formatSize.height / 2))
    }

    private static func drawTitle(context: CGContext, title: String, width: CGFloat) {
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 52, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        let titleStr = NSAttributedString(string: title, attributes: titleAttrs)
        titleStr.draw(with: CGRect(x: 60, y: 190, width: width - 120, height: 130), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)
    }

    private static func drawDescription(context: CGContext, desc: String, width: CGFloat) {
        let descAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(0.55)
        ]
        let descStr = NSAttributedString(string: desc, attributes: descAttrs)
        descStr.draw(with: CGRect(x: 60, y: 310, width: width - 120, height: 70), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)
    }

    private static func drawStats(context: CGContext, template: WODTemplate, width: CGFloat) {
        let statsY: CGFloat = 400
        let boxWidth = (width - 160) / 3
        let boxHeight: CGFloat = 100

        ShareCardCGHelpers.drawStatBox(context: context, x: 60, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: "~\(template.durationMinutes)m", label: "Duration", valueColor: ShareCardCGHelpers.accentBlue)
        ShareCardCGHelpers.drawStatBox(context: context, x: 60 + boxWidth + 20, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: template.category.rawValue, label: "Type", valueColor: ShareCardCGHelpers.warningAmber)
        ShareCardCGHelpers.drawStatBox(context: context, x: 60 + (boxWidth + 20) * 2, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: "\(template.movements.count)", label: "Movements", valueColor: ShareCardCGHelpers.successGreen)
    }

    private static func drawMovements(context: CGContext, movements: [WODMovement], width: CGFloat) {
        var rowY: CGFloat = 530

        let sectionAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .heavy),
            .foregroundColor: UIColor.white.withAlphaComponent(0.4),
            .kern: 2.0
        ]
        let sectionStr = NSAttributedString(string: "MOVEMENTS", attributes: sectionAttrs)
        sectionStr.draw(at: CGPoint(x: 60, y: rowY))
        rowY += 40

        context.setStrokeColor(UIColor.white.withAlphaComponent(0.06).cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: 60, y: rowY))
        context.addLine(to: CGPoint(x: width - 60, y: rowY))
        context.strokePath()
        rowY += 16

        for movement in movements.prefix(6) {
            let dotRect = CGRect(x: 70, y: rowY + 12, width: 10, height: 10)
            context.setFillColor(ShareCardCGHelpers.accentBlue.withAlphaComponent(0.6).cgColor)
            context.fillEllipse(in: dotRect)

            let nameAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85)
            ]
            let nameStr = NSAttributedString(string: movement.name, attributes: nameAttrs)
            nameStr.draw(at: CGPoint(x: 95, y: rowY + 4))

            let detail = movement.reps ?? movement.duration ?? ""
            if !detail.isEmpty {
                let detailAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 20, weight: .medium),
                    .foregroundColor: ShareCardCGHelpers.accentBlue.withAlphaComponent(0.7)
                ]
                let detailStr = NSAttributedString(string: detail, attributes: detailAttrs)
                let detailSize = detailStr.size()
                detailStr.draw(at: CGPoint(x: width - 60 - detailSize.width, y: rowY + 7))
            }

            rowY += 60
        }

        if movements.count > 6 {
            let moreAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.3)
            ]
            let moreStr = NSAttributedString(string: "+\(movements.count - 6) more", attributes: moreAttrs)
            moreStr.draw(at: CGPoint(x: 95, y: rowY + 4))
        }
    }
}
