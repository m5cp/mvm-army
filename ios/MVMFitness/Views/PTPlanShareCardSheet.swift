import SwiftUI

struct PTPlanShareCardSheet: View {
    @Environment(\.dismiss) private var dismiss

    let plan: WeeklyPlan
    let shareText: String

    @State private var renderedImage: UIImage?
    @State private var showSavedAlert: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            if let image = renderedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                                    .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .tint(MVMTheme.accent)
                                    Text("Generating share card...")
                                        .font(.caption)
                                        .foregroundStyle(MVMTheme.secondaryText)
                                }
                                .frame(height: 300)
                            }

                            VStack(spacing: 6) {
                                Text(plan.ptGoal.isEmpty ? "Individual PT Plan" : plan.ptGoal)
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(MVMTheme.primaryText)

                                Text("Week \(plan.currentWeek) of \(plan.totalWeeks) \u{00b7} \(plan.totalWorkoutDays) Workouts")
                                    .font(.subheadline)
                                    .foregroundStyle(MVMTheme.secondaryText)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        if renderedImage != nil {
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    if let image = renderedImage {
                                        ShareLink(
                                            item: Image(uiImage: image),
                                            preview: SharePreview("Individual PT Plan", image: Image(uiImage: image))
                                        ) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "square.and.arrow.up")
                                                Text("Share")
                                            }
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                            .frame(height: 52)
                                            .frame(maxWidth: .infinity)
                                            .background(MVMTheme.heroGradient)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                        }
                                        .buttonStyle(PressScaleButtonStyle())
                                    }

                                    Button {
                                        if let image = renderedImage {
                                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                            showSavedAlert = true
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "photo.on.rectangle.angled")
                                            Text("Save")
                                        }
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(height: 52)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(hex: "#2563EB"))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                    .buttonStyle(PressScaleButtonStyle())
                                }

                                ShareLink(item: shareText) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "doc.text")
                                        Text("Share as Text")
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(MVMTheme.accent)
                                    .frame(height: 44)
                                    .frame(maxWidth: .infinity)
                                    .background(MVMTheme.accent.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .buttonStyle(PressScaleButtonStyle())
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Share PT Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Saved", isPresented: $showSavedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Share card saved to your photo library.")
            }
        }
        .task {
            renderedImage = PTPlanCardRenderer.render(plan: plan)
        }
    }
}

@MainActor
enum PTPlanCardRenderer {
    private static let accentGreen = UIColor(red: 0.18, green: 0.49, blue: 0.32, alpha: 1.0)

    static func render(plan: WeeklyPlan) -> UIImage? {
        let w: CGFloat = 1080
        let workoutDays = plan.days.filter { !$0.isRestDay }
        let dayRows = min(workoutDays.count, 5)
        let h: CGFloat = CGFloat(560 + dayRows * 80)
        let renderer = ShareCardCGHelpers.makeRenderer(width: w, height: h)

        return renderer.image { ctx in
            let context = ctx.cgContext

            ShareCardCGHelpers.drawBackground(context: context, width: w, height: h)
            ShareCardCGHelpers.drawHeader(context: context, width: w, date: .now)

            let badgeAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .heavy),
                .foregroundColor: accentGreen,
                .kern: 2.0
            ]
            let badgeStr = NSAttributedString(string: "INDIVIDUAL PT PLAN", attributes: badgeAttrs)
            badgeStr.draw(at: CGPoint(x: 60, y: 130))

            let weekAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
            let weekStr = NSAttributedString(string: "Week \(plan.currentWeek) of \(plan.totalWeeks)", attributes: weekAttrs)
            let weekSize = weekStr.size()
            let weekPillRect = CGRect(x: w - 60 - weekSize.width - 24, y: 126, width: weekSize.width + 24, height: 32)
            let weekPillPath = UIBezierPath(roundedRect: weekPillRect, cornerRadius: 16)
            context.setFillColor(UIColor.white.withAlphaComponent(0.08).cgColor)
            context.addPath(weekPillPath.cgPath)
            context.fillPath()
            weekStr.draw(at: CGPoint(x: weekPillRect.midX - weekSize.width / 2, y: weekPillRect.midY - weekSize.height / 2))

            let goalLabel = plan.ptGoal.isEmpty ? "Individual PT Plan" : plan.ptGoal
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 44, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let titleStr = NSAttributedString(string: goalLabel, attributes: titleAttrs)
            titleStr.draw(with: CGRect(x: 60, y: 180, width: w - 120, height: 110), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)

            let statsY: CGFloat = 300
            let boxWidth = (w - 160) / 3
            let boxHeight: CGFloat = 90

            ShareCardCGHelpers.drawStatBox(context: context, x: 60, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: "\(workoutDays.count)", label: "Sessions", valueColor: accentGreen)
            ShareCardCGHelpers.drawStatBox(context: context, x: 60 + boxWidth + 20, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: "\(plan.days.flatMap(\.exercises).count)", label: "Exercises", valueColor: ShareCardCGHelpers.accentBlue)
            let restDays = plan.days.filter(\.isRestDay).count
            ShareCardCGHelpers.drawStatBox(context: context, x: 60 + (boxWidth + 20) * 2, y: statsY, boxWidth: boxWidth, boxHeight: boxHeight, value: "\(restDays)", label: "Rest Days", valueColor: ShareCardCGHelpers.warningAmber)

            var rowY: CGFloat = statsY + boxHeight + 30

            context.setStrokeColor(UIColor.white.withAlphaComponent(0.06).cgColor)
            context.setLineWidth(1)
            context.move(to: CGPoint(x: 60, y: rowY))
            context.addLine(to: CGPoint(x: w - 60, y: rowY))
            context.strokePath()
            rowY += 16

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE"

            for day in workoutDays.prefix(5) {
                let dayName = dateFormatter.string(from: day.date).uppercased()

                let dayAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                    .foregroundColor: accentGreen
                ]
                let dayStr = NSAttributedString(string: dayName, attributes: dayAttrs)
                dayStr.draw(at: CGPoint(x: 70, y: rowY + 8))

                let nameAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.85)
                ]
                let nameStr = NSAttributedString(string: day.title, attributes: nameAttrs)
                nameStr.draw(with: CGRect(x: 140, y: rowY + 4, width: w - 340, height: 30), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)

                let countAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.35)
                ]
                let countStr = NSAttributedString(string: "\(day.exercises.count) exercises", attributes: countAttrs)
                let countSize = countStr.size()
                countStr.draw(at: CGPoint(x: w - 60 - countSize.width, y: rowY + 10))

                rowY += 60

                context.setStrokeColor(UIColor.white.withAlphaComponent(0.03).cgColor)
                context.setLineWidth(1)
                context.move(to: CGPoint(x: 140, y: rowY - 8))
                context.addLine(to: CGPoint(x: w - 60, y: rowY - 8))
                context.strokePath()
            }

            if workoutDays.count > 5 {
                let moreAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.3)
                ]
                let moreStr = NSAttributedString(string: "+\(workoutDays.count - 5) more sessions", attributes: moreAttrs)
                moreStr.draw(at: CGPoint(x: 140, y: rowY + 2))
            }

            ShareCardCGHelpers.drawFooter(context: context, width: w, height: h)
        }
    }
}
