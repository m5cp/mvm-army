import UIKit

/// Unofficial score sheet for every non-AFT assessment: Navy PRT, Air Force PT,
/// Marine PFT/CFT, Advanced Readiness and the ROTC / Service Academy programs.
///
/// Every page is explicitly and repeatedly marked UNOFFICIAL. None of these is a
/// service record: the Navy's record is in PRIMS, the Air Force's in myFSS, the
/// Marine Corps' in MCTFS, and no ROTC or academy board accepts a printout from
/// a phone. This is a training aid, and the document says so on the banner, in
/// the title, in the body and in the footer of every page.
enum ServiceTestPDFService {

    private static let pageSize = CGSize(width: 612, height: 792) // US Letter
    private static let margin: CGFloat = 44

    static func generatePDF(from record: ServiceTestRecord, soldierName: String) -> Data? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        return renderer.pdfData { context in
            context.beginPage()
            let ctx = context.cgContext
            let contentWidth = pageSize.width - margin * 2
            var y = margin

            y = drawUnofficialBanner(in: ctx, at: y, width: contentWidth)
            y = drawTitle(in: ctx, at: y, record: record, width: contentWidth)
            y = drawIdentity(in: ctx, at: y, record: record, soldierName: soldierName, width: contentWidth)
            y = drawScore(in: ctx, at: y, record: record, width: contentWidth)
            y = drawEvents(in: ctx, at: y, record: record, width: contentWidth)
            drawDisclaimer(in: ctx, at: y, record: record, width: contentWidth)
            drawFooter(in: ctx, record: record)
        }
    }

    static func savePDFToTemp(data: Data, record: ServiceTestRecord) -> URL? {
        let stamp = DateFormatter()
        stamp.dateFormat = "yyyy-MM-dd"
        let safeBranch = record.branch.displayName
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "/", with: "-")
        let name = "UNOFFICIAL-\(safeBranch)-\(stamp.string(from: record.date)).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Sections

    private static func drawUnofficialBanner(in ctx: CGContext, at y: CGFloat, width: CGFloat) -> CGFloat {
        let height: CGFloat = 30
        let rect = CGRect(x: margin, y: y, width: width, height: height)
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.fill(rect)

        let text = "UNOFFICIAL — PERSONAL TRAINING REFERENCE ONLY — NOT A SERVICE RECORD"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9.5, weight: .heavy),
            .foregroundColor: UIColor.white,
            .kern: 0.8
        ]
        let size = (text as NSString).size(withAttributes: attrs)
        (text as NSString).draw(
            at: CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2),
            withAttributes: attrs
        )
        return y + height + 18
    }

    private static func drawTitle(in ctx: CGContext, at y: CGFloat, record: ServiceTestRecord, width: CGFloat) -> CGFloat {
        var cursor = y
        let title = "\(record.branch.displayName.uppercased()) SCORE SHEET — UNOFFICIAL"
        (title as NSString).draw(at: CGPoint(x: margin, y: cursor), withAttributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .heavy),
            .foregroundColor: UIColor.black
        ])
        cursor += 22

        if let subtitle = record.subtitle, !subtitle.isEmpty {
            (subtitle as NSString).draw(at: CGPoint(x: margin, y: cursor), withAttributes: [
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                .foregroundColor: UIColor.darkGray
            ])
            cursor += 16
        }

        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(1)
        ctx.move(to: CGPoint(x: margin, y: cursor + 4))
        ctx.addLine(to: CGPoint(x: margin + width, y: cursor + 4))
        ctx.strokePath()
        return cursor + 18
    }

    private static func drawIdentity(in ctx: CGContext, at y: CGFloat, record: ServiceTestRecord, soldierName: String, width: CGFloat) -> CGFloat {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let rows: [(String, String)] = [
            ("NAME", OPSECService.shared.stripIdentity || soldierName.isEmpty ? "—" : soldierName),
            ("ASSESSMENT", record.branch.displayName),
            ("DATE", formatter.string(from: record.date)),
            ("TYPE", "Example / practice score — not an official test event")
        ]
        var cursor = y
        for (label, value) in rows {
            (label as NSString).draw(at: CGPoint(x: margin, y: cursor), withAttributes: [
                .font: UIFont.systemFont(ofSize: 8, weight: .bold),
                .foregroundColor: UIColor.darkGray,
                .kern: 0.7
            ])
            (value as NSString).draw(at: CGPoint(x: margin + 110, y: cursor - 2), withAttributes: [
                .font: UIFont.systemFont(ofSize: 11, weight: .regular),
                .foregroundColor: UIColor.black
            ])
            cursor += 20
        }
        return cursor + 8
    }

    private static func drawScore(in ctx: CGContext, at y: CGFloat, record: ServiceTestRecord, width: CGFloat) -> CGFloat {
        let boxHeight: CGFloat = 74
        let rect = CGRect(x: margin, y: y, width: width, height: boxHeight)
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(1.2)
        ctx.stroke(rect)

        ("TOTAL" as NSString).draw(at: CGPoint(x: margin + 14, y: y + 12), withAttributes: [
            .font: UIFont.systemFont(ofSize: 8, weight: .bold),
            .foregroundColor: UIColor.darkGray,
            .kern: 0.7
        ])
        ("\(record.scoreDisplay) \(record.maxDisplay)" as NSString).draw(at: CGPoint(x: margin + 14, y: y + 26), withAttributes: [
            .font: UIFont.systemFont(ofSize: 28, weight: .heavy),
            .foregroundColor: UIColor.black
        ])

        let verdict = record.passed ? "GO" : "NO GO"
        let verdictText = "\(verdict) — \(record.resultLabel)"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .heavy),
            .foregroundColor: UIColor.black
        ]
        let size = (verdictText as NSString).size(withAttributes: attrs)
        (verdictText as NSString).draw(
            at: CGPoint(x: margin + width - 14 - size.width, y: y + boxHeight / 2 - size.height / 2),
            withAttributes: attrs
        )
        return y + boxHeight + 20
    }

    private static func drawEvents(in ctx: CGContext, at y: CGFloat, record: ServiceTestRecord, width: CGFloat) -> CGFloat {
        guard !record.events.isEmpty else { return y }
        var cursor = y

        ("EVENTS" as NSString).draw(at: CGPoint(x: margin, y: cursor), withAttributes: [
            .font: UIFont.systemFont(ofSize: 8, weight: .bold),
            .foregroundColor: UIColor.darkGray,
            .kern: 0.7
        ])
        cursor += 16

        let colRaw = margin + 120
        let colPoints = margin + width - 70

        for event in record.events {
            ctx.setStrokeColor(UIColor.lightGray.cgColor)
            ctx.setLineWidth(0.5)
            ctx.move(to: CGPoint(x: margin, y: cursor - 4))
            ctx.addLine(to: CGPoint(x: margin + width, y: cursor - 4))
            ctx.strokePath()

            let body: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10.5, weight: .regular),
                .foregroundColor: UIColor.black
            ]
            (event.code as NSString).draw(at: CGPoint(x: margin, y: cursor), withAttributes: [
                .font: UIFont.systemFont(ofSize: 10.5, weight: .bold),
                .foregroundColor: UIColor.black
            ])
            (event.raw as NSString).draw(at: CGPoint(x: colRaw, y: cursor), withAttributes: body)
            (event.points as NSString).draw(at: CGPoint(x: colPoints, y: cursor), withAttributes: [
                .font: UIFont.systemFont(ofSize: 10.5, weight: .bold),
                .foregroundColor: UIColor.black
            ])
            cursor += 19
        }
        return cursor + 16
    }

    private static func drawDisclaimer(in ctx: CGContext, at y: CGFloat, record: ServiceTestRecord, width: CGFloat) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 2.5

        let text = """
        THIS IS NOT AN OFFICIAL DOCUMENT. It is a practice score sheet produced by \
        the MVM Fitness app for personal training use. It has no official standing, \
        is not a substitute for a graded test event, and cannot be submitted to any \
        command, board, selection panel or personnel system.

        \(record.branch.authorityNote)
        """
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8.5, weight: .regular),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraph
        ]

        // Measure before stroking. A fixed 96pt box clipped the last line of the
        // exact disclaimer this sheet exists to display, and would clip more the
        // moment an authorityNote is edited.
        let measured = (text as NSString).boundingRect(
            with: CGSize(width: width - 24, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attrs,
            context: nil
        )
        let rect = CGRect(x: margin, y: y, width: width, height: ceil(measured.height) + 22)
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(1)
        ctx.stroke(rect)

        (text as NSString).draw(in: rect.insetBy(dx: 12, dy: 10), withAttributes: attrs)
    }

    private static func drawFooter(in ctx: CGContext, record: ServiceTestRecord) {
        let y = pageSize.height - 32
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 7.5, weight: .semibold),
            .foregroundColor: UIColor.darkGray,
            .kern: 0.5
        ]
        let left = "\(record.branch.displayName.uppercased()) — UNOFFICIAL PRACTICE SCORE SHEET"
        (left as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)

        let right = "MVM Fitness — Me vs Me"
        let size = (right as NSString).size(withAttributes: attrs)
        (right as NSString).draw(at: CGPoint(x: pageSize.width - margin - size.width, y: y), withAttributes: attrs)
    }
}
