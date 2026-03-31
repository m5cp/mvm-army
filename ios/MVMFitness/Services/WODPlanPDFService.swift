import UIKit

enum WODPlanPDFService {

    static func generatePDF(from plan: WODPlan) -> Data? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 36
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { context in
            context.beginPage()

            var y: CGFloat = margin

            y = drawHeader(in: context.cgContext, at: y, margin: margin, contentWidth: contentWidth, pageWidth: pageWidth, plan: plan)

            for (index, day) in plan.days.enumerated() {
                let estimatedHeight: CGFloat = day.isRestDay ? 40 : CGFloat(60 + day.template.movements.count * 18)
                if y + estimatedHeight > pageHeight - margin - 30 {
                    drawFooter(in: context.cgContext, margin: margin, pageWidth: pageWidth, pageHeight: pageHeight)
                    context.beginPage()
                    y = margin
                }
                y = drawDaySection(in: context.cgContext, at: y, margin: margin, contentWidth: contentWidth, day: day, dayNumber: index + 1)
            }

            drawFooter(in: context.cgContext, margin: margin, pageWidth: pageWidth, pageHeight: pageHeight)
        }
    }

    static func savePDFToTemp(data: Data, goalName: String) -> URL? {
        let sanitized = goalName.isEmpty ? "WOD_Plan" : goalName.replacingOccurrences(of: " ", with: "_")
        let dateStr = fileDateFormatter.string(from: .now)
        let fileName = "WOD_Plan_\(sanitized)_\(dateStr).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    private static let fileDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static func drawHeader(in ctx: CGContext, at y: CGFloat, margin: CGFloat, contentWidth: CGFloat, pageWidth: CGFloat, plan: WODPlan) -> CGFloat {
        var currentY = y

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        let title = "FUNCTIONAL WOD PLAN"
        let titleSize = (title as NSString).size(withAttributes: titleAttrs)
        let titleX = (pageWidth - titleSize.width) / 2
        (title as NSString).draw(at: CGPoint(x: titleX, y: currentY), withAttributes: titleAttrs)
        currentY += titleSize.height + 4

        let goalLabel = plan.ptGoal.isEmpty ? "General" : plan.ptGoal
        let subtitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.darkGray
        ]
        let subtitle = "Goal: \(goalLabel) · Week \(plan.currentWeek) of \(plan.totalWeeks) · \(plan.heroPreference.rawValue)"
        let subtitleSize = (subtitle as NSString).size(withAttributes: subtitleAttrs)
        let subtitleX = (pageWidth - subtitleSize.width) / 2
        (subtitle as NSString).draw(at: CGPoint(x: subtitleX, y: currentY), withAttributes: subtitleAttrs)
        currentY += subtitleSize.height + 4

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        if let first = plan.days.first, let last = plan.days.last {
            let dateRange = "\(dateFormatter.string(from: first.date)) – \(dateFormatter.string(from: last.date))"
            let dateSize = (dateRange as NSString).size(withAttributes: subtitleAttrs)
            let dateX = (pageWidth - dateSize.width) / 2
            (dateRange as NSString).draw(at: CGPoint(x: dateX, y: currentY), withAttributes: subtitleAttrs)
            currentY += dateSize.height
        }

        currentY += 8
        ctx.setStrokeColor(UIColor.lightGray.cgColor)
        ctx.setLineWidth(0.5)
        ctx.move(to: CGPoint(x: margin, y: currentY))
        ctx.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
        ctx.strokePath()
        currentY += 12

        return currentY
    }

    private static func drawDaySection(in ctx: CGContext, at y: CGFloat, margin: CGFloat, contentWidth: CGFloat, day: WODPlanDay, dayNumber: Int) -> CGFloat {
        var currentY = y

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE, MMM d"
        let dayStr = dayFormatter.string(from: day.date)

        if day.isRestDay {
            let restAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .medium),
                .foregroundColor: UIColor.gray
            ]
            let restStr = "Day \(dayNumber) (\(dayStr)): Rest & Recovery"
            (restStr as NSString).draw(at: CGPoint(x: margin, y: currentY), withAttributes: restAttrs)
            currentY += 24
            return currentY
        }

        let isHero = HeroWODLibrary.isHeroWorkout(day.template)
        let heroTag = isHero ? " 🎖 HERO" : ""

        let dayTitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        let dayTitle = "Day \(dayNumber) (\(dayStr)): \(day.template.title)\(heroTag)"
        (dayTitle as NSString).draw(at: CGPoint(x: margin, y: currentY), withAttributes: dayTitleAttrs)
        currentY += 18

        let metaAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.darkGray
        ]
        let meta = "\(day.template.format.rawValue) · ~\(day.template.durationMinutes) min · \(day.template.category.rawValue)"
        (meta as NSString).draw(at: CGPoint(x: margin + 8, y: currentY), withAttributes: metaAttrs)
        currentY += 16

        if isHero, let tribute = HeroWODLibrary.tributeFor(day.template.title) {
            let tributeAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 9),
                .foregroundColor: UIColor.darkGray
            ]
            let tributeStr = "In honor of \(tribute.displayName), \(tribute.serviceBranch) — \(tribute.dateOfDeath), \(tribute.location)"
            let tributeRect = CGRect(x: margin + 8, y: currentY, width: contentWidth - 16, height: 40)
            (tributeStr as NSString).draw(with: tributeRect, options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], attributes: tributeAttrs, context: nil)
            currentY += 28
        }

        let exerciseAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]

        for movement in day.template.movements {
            let detail = movement.reps ?? movement.duration ?? ""
            let line = "• \(movement.name)\(detail.isEmpty ? "" : " — \(detail)")"
            (line as NSString).draw(at: CGPoint(x: margin + 12, y: currentY), withAttributes: exerciseAttrs)
            currentY += 15
        }

        currentY += 8
        return currentY
    }

    private static func drawFooter(in ctx: CGContext, margin: CGFloat, pageWidth: CGFloat, pageHeight: CGFloat) {
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8),
            .foregroundColor: UIColor.lightGray
        ]
        let footer = "Generated by MVM Army · Me vs Me"
        let footerSize = (footer as NSString).size(withAttributes: footerAttrs)
        let footerX = (pageWidth - footerSize.width) / 2
        (footer as NSString).draw(at: CGPoint(x: footerX, y: pageHeight - margin), withAttributes: footerAttrs)
    }
}
