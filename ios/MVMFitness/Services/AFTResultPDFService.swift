import UIKit

/// Shareable one-page PDF summary of the result plaque (10c/10d): total score,
/// pass/fail, and the margin-over-minimum table per event. Distinct from the
/// full DA-705 export — this is the compact "just the score" summary.
///
/// All numbers come straight from `AFTCalculatorResult`, which is itself
/// produced entirely by `AFTScoringEngine` in the calculator view. Zero
/// scoring or threshold math happens in this file — it only draws.
enum AFTResultPDFService {

    static func generatePDF(from result: AFTCalculatorResult, previousTotal: Int?) -> Data? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 48
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { context in
            context.beginPage()
            var y = margin

            y = drawHeader(at: y, margin: margin, pageWidth: pageWidth, date: result.date)
            y = drawTotalPlaque(at: y, margin: margin, contentWidth: contentWidth, result: result, previousTotal: previousTotal)
            y = drawPassFail(at: y, margin: margin, contentWidth: contentWidth, result: result)
            y = drawMarginTable(at: y, margin: margin, contentWidth: contentWidth, result: result)
            drawFooter(margin: margin, pageWidth: pageWidth, pageHeight: pageHeight)
        }
    }

    static func savePDFToTemp(data: Data, soldierName: String) -> URL? {
        let sanitized = soldierName.isEmpty ? "Soldier" : soldierName.replacingOccurrences(of: " ", with: "_")
        let dateStr = DateFormatter.aftResultFileDate.string(from: .now)
        let fileName = "AFT_Result_Summary_\(sanitized)_\(dateStr).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Sections

    private static func drawHeader(at y: CGFloat, margin: CGFloat, pageWidth: CGFloat, date: Date) -> CGFloat {
        var currentY = y

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        let title = "AFT RESULT SUMMARY — UNOFFICIAL"
        (title as NSString).draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttrs)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.darkGray
        ]
        let dateStr = dateFormatter.string(from: date)
        let dateSize = (dateStr as NSString).size(withAttributes: dateAttrs)
        (dateStr as NSString).draw(at: CGPoint(x: pageWidth - margin - dateSize.width, y: currentY + 3), withAttributes: dateAttrs)

        currentY += 26

        let subtitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.gray
        ]
        ("Me vs Me — Army Fitness Test" as NSString).draw(at: CGPoint(x: margin, y: currentY), withAttributes: subtitleAttrs)
        currentY += 14

        // This is a practice summary, not a graded test event. Say so on the
        // page rather than leaving it to be inferred.
        let disclaimerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 8.5),
            .foregroundColor: UIColor.black
        ]
        ("EXAMPLE / PRACTICE SCORE — NOT AN OFFICIAL ARMY RECORD. Official AFT results are recorded on DA Form 705 and in ATIS."
            as NSString).draw(
                in: CGRect(x: margin, y: currentY, width: pageWidth - margin * 2, height: 22),
                withAttributes: disclaimerAttrs
            )
        currentY += 24

        UIColor(white: 0.85, alpha: 1).setStroke()
        let line = UIBezierPath()
        line.lineWidth = 0.5
        line.move(to: CGPoint(x: margin, y: currentY))
        line.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
        line.stroke()
        currentY += 18

        return currentY
    }

    private static func drawTotalPlaque(at y: CGFloat, margin: CGFloat, contentWidth: CGFloat, result: AFTCalculatorResult, previousTotal: Int?) -> CGFloat {
        var currentY = y
        let plaqueHeight: CGFloat = 110
        let plaqueRect = CGRect(x: margin, y: currentY, width: contentWidth, height: plaqueHeight)

        UIColor(white: 0.96, alpha: 1).setFill()
        UIBezierPath(roundedRect: plaqueRect, cornerRadius: 12).fill()
        UIColor(white: 0.82, alpha: 1).setStroke()
        let border = UIBezierPath(roundedRect: plaqueRect, cornerRadius: 12)
        border.lineWidth = 0.75
        border.stroke()

        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 9),
            .foregroundColor: UIColor.gray
        ]
        ("TOTAL SCORE" as NSString).draw(at: CGPoint(x: margin + 20, y: currentY + 16), withAttributes: labelAttrs)

        let scoreAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 46),
            .foregroundColor: UIColor.black
        ]
        ("\(result.totalScore)" as NSString).draw(at: CGPoint(x: margin + 18, y: currentY + 30), withAttributes: scoreAttrs)

        let maxAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.gray
        ]
        let scoreDigits = "\(result.totalScore)"
        let scoreWidth = (scoreDigits as NSString).size(withAttributes: scoreAttrs).width
        ("/ 500" as NSString).draw(at: CGPoint(x: margin + 18 + scoreWidth + 6, y: currentY + 58), withAttributes: maxAttrs)

        if let previous = previousTotal {
            let delta = result.totalScore - previous
            let deltaColor: UIColor = delta >= 0 ? UIColor(red: 0, green: 0.55, blue: 0.2, alpha: 1) : .red
            let deltaAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 11),
                .foregroundColor: deltaColor
            ]
            let deltaText = (delta >= 0 ? "+\(delta)" : "\(delta)") + " VS LAST RECORDED TEST"
            let deltaSize = (deltaText as NSString).size(withAttributes: deltaAttrs)
            (deltaText as NSString).draw(at: CGPoint(x: margin + contentWidth - 20 - deltaSize.width, y: currentY + 22), withAttributes: deltaAttrs)
        } else {
            let baselineAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 11),
                .foregroundColor: UIColor.gray
            ]
            let text = "BASELINE — FIRST RECORDED TEST"
            let size = (text as NSString).size(withAttributes: baselineAttrs)
            (text as NSString).draw(at: CGPoint(x: margin + contentWidth - 20 - size.width, y: currentY + 22), withAttributes: baselineAttrs)
        }

        currentY += plaqueHeight + 18
        return currentY
    }

    private static func drawPassFail(at y: CGFloat, margin: CGFloat, contentWidth: CGFloat, result: AFTCalculatorResult) -> CGFloat {
        var currentY = y
        let boxHeight: CGFloat = 34
        let boxRect = CGRect(x: margin, y: currentY, width: contentWidth, height: boxHeight)
        let color: UIColor = result.passed ? UIColor(red: 0, green: 0.55, blue: 0.2, alpha: 1) : .red

        color.withAlphaComponent(0.08).setFill()
        UIBezierPath(roundedRect: boxRect, cornerRadius: 8).fill()

        let text = result.passed ? "GO — \(result.standard.rawValue) Standard" : "NO GO — \(result.standard.rawValue) Standard"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 13),
            .foregroundColor: color
        ]
        let size = (text as NSString).size(withAttributes: attrs)
        (text as NSString).draw(at: CGPoint(x: margin + (contentWidth - size.width) / 2, y: currentY + (boxHeight - size.height) / 2), withAttributes: attrs)

        currentY += boxHeight + 22
        return currentY
    }

    private static func drawMarginTable(at y: CGFloat, margin: CGFloat, contentWidth: CGFloat, result: AFTCalculatorResult) -> CGFloat {
        var currentY = y

        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 11),
            .foregroundColor: UIColor.black
        ]
        ("EVENT MARGINS — POINTS OVER THE 60-PT MINIMUM" as NSString).draw(at: CGPoint(x: margin, y: currentY), withAttributes: headerAttrs)
        currentY += 22

        let minPerEvent = result.standard.minimumPerEvent
        let rows: [(String, String, String, Int, Int)] = [
            ("MDL", "3-Rep Max Deadlift", "\(result.deadliftLbs) lbs", result.deadliftPoints, result.deadliftPoints - minPerEvent),
            ("HRP", "Hand-Release Push-Up", "\(result.pushUpReps) reps", result.pushUpPoints, result.pushUpPoints - minPerEvent),
            ("SDC", "Sprint-Drag-Carry", formatTime(result.sdcSeconds), result.sdcPoints, result.sdcPoints - minPerEvent),
            ("PLK", "Plank", formatTime(result.plankSeconds), result.plankPoints, result.plankPoints - minPerEvent),
            ("2MR", "2-Mile Run", formatTime(result.runSeconds), result.runPoints, result.runPoints - minPerEvent)
        ]

        let rowHeight: CGFloat = 34
        for (index, row) in rows.enumerated() {
            let (abbr, name, raw, points, margin90) = row
            let rowRect = CGRect(x: margin, y: currentY, width: contentWidth, height: rowHeight)
            if index % 2 == 0 {
                UIColor(white: 0.97, alpha: 1).setFill()
                UIRectFill(rowRect)
            }

            let abbrAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 10),
                .foregroundColor: UIColor.darkGray
            ]
            (abbr as NSString).draw(at: CGPoint(x: margin + 8, y: currentY + 11), withAttributes: abbrAttrs)

            let nameAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.black
            ]
            (name as NSString).draw(at: CGPoint(x: margin + 48, y: currentY + 4), withAttributes: nameAttrs)

            let rawAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9),
                .foregroundColor: UIColor.gray
            ]
            let rawText = "\(raw) \u{2022} \(points) PTS"
            (rawText as NSString).draw(at: CGPoint(x: margin + 48, y: currentY + 18), withAttributes: rawAttrs)

            let marginColor: UIColor = margin90 >= 0 ? UIColor(red: 0, green: 0.55, blue: 0.2, alpha: 1) : .red
            let marginText = (margin90 >= 0 ? "+\(margin90)" : "\(margin90)")
            let marginAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 15),
                .foregroundColor: marginColor
            ]
            let marginSize = (marginText as NSString).size(withAttributes: marginAttrs)
            (marginText as NSString).draw(at: CGPoint(x: margin + contentWidth - 12 - marginSize.width, y: currentY + 8), withAttributes: marginAttrs)

            currentY += rowHeight
        }

        UIColor(white: 0.85, alpha: 1).setStroke()
        let border = UIBezierPath(rect: CGRect(x: margin, y: y + 22, width: contentWidth, height: rowHeight * CGFloat(rows.count)))
        border.lineWidth = 0.5
        border.stroke()

        return currentY + 12
    }

    private static func drawFooter(margin: CGFloat, pageWidth: CGFloat, pageHeight: CGFloat) {
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8),
            .foregroundColor: UIColor.gray
        ]
        let footerY = pageHeight - margin + 6
        ("Generated by MVM Fitness — for personal reference only, not an official military document" as NSString)
            .draw(at: CGPoint(x: margin, y: footerY), withAttributes: footerAttrs)
    }

    private static func formatTime(_ totalSeconds: Int) -> String {
        String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}

private extension DateFormatter {
    static let aftResultFileDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd_HHmm"
        return f
    }()
}
