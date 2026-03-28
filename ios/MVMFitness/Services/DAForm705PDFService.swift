import UIKit
import PDFKit

enum DAForm705PDFService {

    static func generatePDF(from data: DAForm705ExportData) -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 36
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        return renderer.pdfData { context in
            context.beginPage()

            var y: CGFloat = margin

            y = drawHeader(in: context.cgContext, at: y, width: contentWidth, margin: margin)
            y += 8
            y = drawSoldierInfo(in: context.cgContext, at: y, width: contentWidth, margin: margin, data: data)
            y += 8
            y = drawEventScores(in: context.cgContext, at: y, width: contentWidth, margin: margin, data: data)
            y += 8
            y = drawTotalScore(in: context.cgContext, at: y, width: contentWidth, margin: margin, data: data)
            y += 8
            y = drawBodyComposition(in: context.cgContext, at: y, width: contentWidth, margin: margin, data: data)
            y += 8
            y = drawSignatures(in: context.cgContext, at: y, width: contentWidth, margin: margin, data: data)
            y += 16
            drawFooter(in: context.cgContext, at: y, width: contentWidth, margin: margin)
        }
    }

    static func savePDFToTemp(data: Data, soldierName: String) -> URL? {
        let sanitized = soldierName.isEmpty ? "Soldier" : soldierName.replacingOccurrences(of: " ", with: "_")
        let dateStr = DateFormatter.shortFileDate.string(from: .now)
        let fileName = "DA_Form_705_\(sanitized)_\(dateStr).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Header

    private static func drawHeader(in ctx: CGContext, at y: CGFloat, width: CGFloat, margin: CGFloat) -> CGFloat {
        var currentY = y

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]
        let subtitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.darkGray
        ]

        let title = "ARMY FITNESS TEST SCORECARD"
        let subtitle = "DA Form 705-TEST (Unofficial Reproduction — MVM Army)"

        let titleSize = title.size(withAttributes: titleAttrs)
        title.draw(at: CGPoint(x: margin + (width - titleSize.width) / 2, y: currentY), withAttributes: titleAttrs)
        currentY += titleSize.height + 4

        let subSize = subtitle.size(withAttributes: subtitleAttrs)
        subtitle.draw(at: CGPoint(x: margin + (width - subSize.width) / 2, y: currentY), withAttributes: subtitleAttrs)
        currentY += subSize.height + 4

        drawLine(in: ctx, from: CGPoint(x: margin, y: currentY), to: CGPoint(x: margin + width, y: currentY), lineWidth: 1.5)
        currentY += 6

        return currentY
    }

    // MARK: - Soldier Info

    private static func drawSoldierInfo(in ctx: CGContext, at y: CGFloat, width: CGFloat, margin: CGFloat, data: DAForm705ExportData) -> CGFloat {
        var currentY = y

        currentY = drawSectionTitle("SOLDIER INFORMATION", in: ctx, at: currentY, margin: margin)

        let colWidth = width / 2
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        let leftFields: [(String, String)] = [
            ("Name", data.soldierName.isEmpty ? "—" : data.soldierName),
            ("Age", "\(data.age)"),
            ("Sex", data.sex.rawValue),
            ("MOS", data.mos.isEmpty ? "—" : data.mos)
        ]

        let rightFields: [(String, String)] = [
            ("Pay Grade", data.payGrade.isEmpty ? "—" : data.payGrade),
            ("Unit/Location", data.unit.isEmpty ? "—" : data.unit),
            ("Test Date", dateFormatter.string(from: data.testDate)),
            ("Test Type", data.testType.rawValue)
        ]

        let startY = currentY
        for (label, value) in leftFields {
            currentY = drawFieldRow(label: label, value: value, at: currentY, x: margin, width: colWidth - 8)
        }

        var rightY = startY
        for (label, value) in rightFields {
            rightY = drawFieldRow(label: label, value: value, at: rightY, x: margin + colWidth + 8, width: colWidth - 8)
        }

        currentY = max(currentY, rightY)

        currentY = drawFieldRow(label: "Standard", value: "\(data.standard.rawValue) (Min \(data.standard.minimumPerEvent)/event, \(data.standard.minimumTotal) total)", at: currentY, x: margin, width: width)

        return currentY
    }

    // MARK: - Event Scores

    private static func drawEventScores(in ctx: CGContext, at y: CGFloat, width: CGFloat, margin: CGFloat, data: DAForm705ExportData) -> CGFloat {
        var currentY = y

        currentY = drawSectionTitle("EVENT SCORES", in: ctx, at: currentY, margin: margin)

        let headers = ["Event", "Raw Score", "Points"]
        let colWidths: [CGFloat] = [width * 0.45, width * 0.3, width * 0.25]

        currentY = drawTableHeader(headers: headers, colWidths: colWidths, at: currentY, margin: margin, ctx: ctx)

        let events: [(String, String, Int)] = [
            ("3-Rep Max Deadlift (MDL)", "\(data.deadliftLbs) lbs", data.deadliftPoints),
            ("Hand-Release Push-Up (HRP)", "\(data.pushUpReps) reps", data.pushUpPoints),
            ("Sprint-Drag-Carry (SDC)", formatTime(data.sdcSeconds), data.sdcPoints),
            ("Plank (PLK)", formatTime(data.plankSeconds), data.plankPoints),
            ("2-Mile Run (2MR)", formatTime(data.runSeconds), data.runPoints)
        ]

        for (index, event) in events.enumerated() {
            let isAlt = index % 2 == 1
            currentY = drawTableRow(
                values: [event.0, event.1, "\(event.2)"],
                colWidths: colWidths,
                at: currentY,
                margin: margin,
                ctx: ctx,
                alternate: isAlt
            )
        }

        drawLine(in: ctx, from: CGPoint(x: margin, y: currentY), to: CGPoint(x: margin + width, y: currentY), lineWidth: 0.5)

        return currentY
    }

    // MARK: - Total Score

    private static func drawTotalScore(in ctx: CGContext, at y: CGFloat, width: CGFloat, margin: CGFloat, data: DAForm705ExportData) -> CGFloat {
        var currentY = y

        let boxHeight: CGFloat = 52
        let boxRect = CGRect(x: margin, y: currentY, width: width, height: boxHeight)

        ctx.setFillColor(UIColor(white: 0.95, alpha: 1).cgColor)
        ctx.fill(boxRect)
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(1)
        ctx.stroke(boxRect)

        let totalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor.black
        ]
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 11),
            .foregroundColor: UIColor.darkGray
        ]
        let statusAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: data.passed ? UIColor.systemGreen : UIColor.systemRed
        ]

        let label = "TOTAL SCORE"
        let labelSize = label.size(withAttributes: labelAttrs)
        label.draw(at: CGPoint(x: margin + 14, y: currentY + 8), withAttributes: labelAttrs)

        let score = "\(data.totalScore) / 500"
        let scoreSize = score.size(withAttributes: totalAttrs)
        score.draw(at: CGPoint(x: margin + 14, y: currentY + 8 + labelSize.height + 2), withAttributes: totalAttrs)

        let status = data.passed ? "PASS" : "NO GO"
        let statusSize = status.size(withAttributes: statusAttrs)
        status.draw(at: CGPoint(x: margin + width - statusSize.width - 14, y: currentY + (boxHeight - statusSize.height) / 2), withAttributes: statusAttrs)

        currentY += boxHeight

        return currentY
    }

    // MARK: - Body Composition

    private static func drawBodyComposition(in ctx: CGContext, at y: CGFloat, width: CGFloat, margin: CGFloat, data: DAForm705ExportData) -> CGFloat {
        var currentY = y

        let hasData = !data.height.isEmpty || !data.weight.isEmpty || !data.bodyFatPercent.isEmpty

        currentY = drawSectionTitle("BODY COMPOSITION (Optional)", in: ctx, at: currentY, margin: margin)

        let colWidth = width / 4
        let fields: [(String, String)] = [
            ("Height", data.height.isEmpty ? "—" : data.height),
            ("Weight", data.weight.isEmpty ? "—" : data.weight),
            ("Body Fat %", data.bodyFatPercent.isEmpty ? "—" : data.bodyFatPercent),
            ("BC Date", data.bodyCompDate.isEmpty ? "—" : data.bodyCompDate)
        ]

        let startY = currentY
        for (index, field) in fields.enumerated() {
            let x = margin + CGFloat(index) * colWidth
            _ = drawFieldRow(label: field.0, value: field.1, at: startY, x: x, width: colWidth - 8)
        }
        currentY = startY + 32

        return currentY
    }

    // MARK: - Signatures

    private static func drawSignatures(in ctx: CGContext, at y: CGFloat, width: CGFloat, margin: CGFloat, data: DAForm705ExportData) -> CGFloat {
        var currentY = y

        currentY = drawSectionTitle("AUTHENTICATION", in: ctx, at: currentY, margin: margin)

        let halfWidth = width / 2 - 8

        currentY = drawSignatureBlock(
            title: "OIC / Test Administrator",
            name: data.oicName,
            date: data.oicDate,
            at: currentY, x: margin, width: halfWidth, ctx: ctx
        )

        _ = drawSignatureBlock(
            title: "NCOIC / Scorer",
            name: data.ncoicName,
            date: data.ncoicDate,
            at: currentY - 62, x: margin + halfWidth + 16, width: halfWidth, ctx: ctx
        )

        currentY += 8

        currentY = drawSignatureBlock(
            title: "Soldier Signature",
            name: "",
            date: "",
            at: currentY, x: margin, width: halfWidth, ctx: ctx
        )

        _ = drawSignatureBlock(
            title: "Supervisor Signature",
            name: "",
            date: "",
            at: currentY - 62, x: margin + halfWidth + 16, width: halfWidth, ctx: ctx
        )

        return currentY
    }

    // MARK: - Footer

    private static func drawFooter(in ctx: CGContext, at y: CGFloat, width: CGFloat, margin: CGFloat) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 7),
            .foregroundColor: UIColor.gray
        ]

        let text = "Generated by MVM Army — Unofficial reproduction of DA Form 705-TEST. Not for official Army record unless validated by unit leadership."
        let textSize = text.size(withAttributes: attrs)
        text.draw(at: CGPoint(x: margin + (width - textSize.width) / 2, y: y), withAttributes: attrs)
    }

    // MARK: - Drawing Helpers

    private static func drawSectionTitle(_ title: String, in ctx: CGContext, at y: CGFloat, margin: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]
        let size = title.size(withAttributes: attrs)
        title.draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)

        let lineY = y + size.height + 2
        drawLine(in: ctx, from: CGPoint(x: margin, y: lineY), to: CGPoint(x: margin + 540, y: lineY), lineWidth: 0.5)

        return lineY + 6
    }

    private static func drawFieldRow(label: String, value: String, at y: CGFloat, x: CGFloat, width: CGFloat) -> CGFloat {
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8),
            .foregroundColor: UIColor.gray
        ]
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]

        label.draw(at: CGPoint(x: x, y: y), withAttributes: labelAttrs)
        let labelHeight = label.size(withAttributes: labelAttrs).height
        value.draw(at: CGPoint(x: x, y: y + labelHeight + 1), withAttributes: valueAttrs)
        let valueHeight = value.size(withAttributes: valueAttrs).height

        return y + labelHeight + valueHeight + 6
    }

    private static func drawTableHeader(headers: [String], colWidths: [CGFloat], at y: CGFloat, margin: CGFloat, ctx: CGContext) -> CGFloat {
        let rowHeight: CGFloat = 20
        let rect = CGRect(x: margin, y: y, width: colWidths.reduce(0, +), height: rowHeight)

        ctx.setFillColor(UIColor(white: 0.88, alpha: 1).cgColor)
        ctx.fill(rect)
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(0.5)
        ctx.stroke(rect)

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 9),
            .foregroundColor: UIColor.black
        ]

        var x = margin
        for (index, header) in headers.enumerated() {
            header.draw(at: CGPoint(x: x + 6, y: y + 4), withAttributes: attrs)
            x += colWidths[index]
        }

        return y + rowHeight
    }

    private static func drawTableRow(values: [String], colWidths: [CGFloat], at y: CGFloat, margin: CGFloat, ctx: CGContext, alternate: Bool) -> CGFloat {
        let rowHeight: CGFloat = 22
        let totalWidth = colWidths.reduce(0, +)
        let rect = CGRect(x: margin, y: y, width: totalWidth, height: rowHeight)

        if alternate {
            ctx.setFillColor(UIColor(white: 0.96, alpha: 1).cgColor)
            ctx.fill(rect)
        }

        ctx.setStrokeColor(UIColor(white: 0.8, alpha: 1).cgColor)
        ctx.setLineWidth(0.25)
        ctx.stroke(rect)

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.black
        ]

        var x = margin
        for (index, value) in values.enumerated() {
            value.draw(at: CGPoint(x: x + 6, y: y + 5), withAttributes: attrs)
            x += colWidths[index]
        }

        return y + rowHeight
    }

    private static func drawSignatureBlock(title: String, name: String, date: String, at y: CGFloat, x: CGFloat, width: CGFloat, ctx: CGContext) -> CGFloat {
        var currentY = y

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 8),
            .foregroundColor: UIColor.darkGray
        ]
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.black
        ]

        title.draw(at: CGPoint(x: x, y: currentY), withAttributes: titleAttrs)
        currentY += 14

        drawLine(in: ctx, from: CGPoint(x: x, y: currentY + 16), to: CGPoint(x: x + width, y: currentY + 16), lineWidth: 0.5)

        if !name.isEmpty {
            name.draw(at: CGPoint(x: x, y: currentY), withAttributes: valueAttrs)
        }
        currentY += 20

        let dateLabel = "Date: \(date.isEmpty ? "____________" : date)"
        dateLabel.draw(at: CGPoint(x: x, y: currentY), withAttributes: [
            .font: UIFont.systemFont(ofSize: 8),
            .foregroundColor: UIColor.gray
        ])
        currentY += 18

        return currentY
    }

    private static func drawLine(in ctx: CGContext, from: CGPoint, to: CGPoint, lineWidth: CGFloat) {
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(lineWidth)
        ctx.move(to: from)
        ctx.addLine(to: to)
        ctx.strokePath()
    }

    private static func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private extension DateFormatter {
    static let shortFileDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f
    }()
}
