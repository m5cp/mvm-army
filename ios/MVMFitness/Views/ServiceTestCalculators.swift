import SwiftUI

// Sister-service test calculators embedded in the Calculator tab.
// Each content view mirrors the AFT calculator's spec-sheet layout
// (RaisedCard rows, InsetWell inputs, live scoring, Save + Share actions)
// and produces a unified `ServiceTestRecord` for history/progress/calendar.
//
// Scoring comes exclusively from the dedicated engines
// (MilitaryServiceScoring / MarineCorpsScoring / AdvancedReadinessScoring) —
// no thresholds are computed in these views.

// MARK: - Shared input components

private struct SvcLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(MVMTheme.mono(10))
            .kerning(1.2)
            .foregroundStyle(MVMTheme.textFaint)
    }
}

private struct SvcNumberWell: View {
    let placeholder: String
    @Binding var text: String
    let suffix: String
    var allowsDecimal: Bool = false

    var body: some View {
        InsetWell {
            HStack(spacing: 6) {
                TextField(placeholder, text: $text)
                    .keyboardType(allowsDecimal ? .decimalPad : .numberPad)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(MVMTheme.text)
                Spacer(minLength: 0)
                Text(suffix)
                    .font(MVMTheme.mono(11))
                    .foregroundStyle(MVMTheme.textMuted)
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
        }
    }
}

private struct SvcTimeWell: View {
    @Binding var minText: String
    @Binding var secText: String

    var body: some View {
        InsetWell {
            HStack(spacing: 4) {
                TextField("0", text: $minText)
                    .keyboardType(.numberPad)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(MVMTheme.text)
                    .multilineTextAlignment(.trailing)
                Text(":")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(MVMTheme.textMuted)
                TextField("00", text: $secText)
                    .keyboardType(.numberPad)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(MVMTheme.text)
                Spacer(minLength: 0)
                Text("MIN \(MVMTheme.dot) SEC")
                    .font(MVMTheme.mono(10))
                    .foregroundStyle(MVMTheme.textMuted)
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
        }
    }
}

/// Amber segmented chips, generic over any option list.
private struct SvcChoiceChips<T: Hashable>: View {
    let options: [T]
    @Binding var selection: T
    let label: (T) -> String
    var height: CGFloat = 44

    var body: some View {
        InsetWell {
            HStack(spacing: 3) {
                ForEach(options, id: \.self) { opt in
                    let selected = selection == opt
                    Text(label(opt))
                        .font(.system(size: 12.5, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(selected ? MVMTheme.onAmber : MVMTheme.textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: height - 6)
                        .background(selected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(.clear))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selection = opt
                            }
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(label(opt))
                        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : [.isButton])
                }
            }
            .padding(3)
        }
    }
}

/// Event row shell — photo-free variant used by service tests (title + points + input).
private struct SvcEventRow<Input: View>: View {
    let code: String
    let title: String
    let pointsDisplay: String
    let pointsColor: Color
    @ViewBuilder var input: Input

    var body: some View {
        RaisedCard {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Text(code)
                        .font(MVMTheme.mono(10.5, weight: .bold))
                        .foregroundStyle(MVMTheme.amber)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .frame(width: 44, height: 44)
                        .background(MVMTheme.well)
                        .clipShape(RoundedRectangle(cornerRadius: 13))

                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(MVMTheme.text)
                        .lineLimit(2)

                    Spacer(minLength: 8)

                    Text(pointsDisplay)
                        .font(MVMTheme.scoreDisplay(26))
                        .foregroundStyle(pointsColor)
                        .contentTransition(.numericText())
                        .lineLimit(1)
                        .fixedSize()
                }
                input
            }
            .padding(14)
        }
    }
}

/// Total card + Save/Share buttons shared by all service tests.
private struct SvcResultCard: View {
    let scoreDisplay: String
    let maxDisplay: String
    let resultLabel: String
    let passed: Bool
    let saveTitle: String
    let didSave: Bool
    let onSave: () -> Void
    let onShare: () -> Void
    /// Builds the record to export. Every assessment gets an unofficial score
    /// sheet, not just the AFT.
    var pdfRecord: (() -> ServiceTestRecord)?

    @AppStorage("profileDisplayName") private var profileDisplayName = ""
    @State private var pdfURL: URL?
    @State private var showPDFShare = false

    var body: some View {
        VStack(spacing: 14) {
            RaisedCard {
                VStack(spacing: 10) {
                    Text("TOTAL SCORE")
                        .font(MVMTheme.mono(11))
                        .kerning(1.4)
                        .foregroundStyle(MVMTheme.textFaint)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(scoreDisplay)
                            .font(MVMTheme.scoreDisplay(56))
                            .foregroundStyle(MVMTheme.text)
                            .contentTransition(.numericText())
                            .lineLimit(1)
                            .fixedSize()
                        Text(maxDisplay)
                            .font(MVMTheme.mono(14))
                            .foregroundStyle(MVMTheme.textFaint)
                            .lineLimit(1)
                            .fixedSize()
                    }

                    Text(resultLabel)
                        .font(.caption.weight(.heavy))
                        .tracking(1.2)
                        .foregroundStyle(passed ? MVMTheme.success : MVMTheme.danger)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background((passed ? MVMTheme.success : MVMTheme.danger).opacity(0.14))
                        .clipShape(Capsule())
                        .lineLimit(1)
                        .fixedSize()
                }
                .padding(18)
                .frame(maxWidth: .infinity)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Total score \(scoreDisplay) \(maxDisplay), \(resultLabel)")

            AmberButton(title: didSave ? "Saved" : saveTitle) { onSave() }

            Button {
                onShare()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Score Card")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.text)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(MVMTheme.well)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16).stroke(MVMTheme.hairline, lineWidth: 1)
                }
                .contentShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressScaleButtonStyle())

            if let pdfRecord {
                Button {
                    let record = pdfRecord()
                    guard let data = ServiceTestPDFService.generatePDF(from: record, soldierName: profileDisplayName),
                          let url = ServiceTestPDFService.savePDFToTemp(data: data, record: record) else { return }
                    pdfURL = url
                    showPDFShare = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                        Text("Save Score Sheet (PDF)")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.text)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.well)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16).stroke(MVMTheme.hairline, lineWidth: 1)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())

                Text("Score sheets and cards from this app are unofficial practice records.")
                    .font(.caption2)
                    .foregroundStyle(MVMTheme.textFaint)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
        }
        .sheet(isPresented: $showPDFShare) {
            if let pdfURL {
                ShareSheet(items: [pdfURL])
            }
        }
    }
}

private func svcTime(_ minText: String, _ secText: String) -> Int {
    (Int(minText) ?? 0) * 60 + (Int(secText) ?? 0)
}

private func svcTimeDisplay(_ seconds: Int) -> String {
    String(format: "%d:%02d", seconds / 60, seconds % 60)
}

// MARK: - Navy PRT

struct NavyPRTContent: View {
    @Environment(AppViewModel.self) private var vm

    @State private var ageText = "25"
    @State private var sex: ServiceSex = .male
    @State private var altitude: NavyAltitude = .below5000
    @State private var pushUpsText = "40"
    @State private var plankMin = "2"
    @State private var plankSec = "00"
    @State private var cardioEvent: NavyEvent = .run1_5Mile
    @State private var cardioMin = "12"
    @State private var cardioSec = "00"
    @State private var didSave = false
    @State private var shareRecord: ServiceTestRecord?

    private var age: Int { Int(ageText) ?? 25 }

    private var pushResult: NavyEventResult {
        NavyScoring.score(event: .pushUps, rawValue: Int(pushUpsText) ?? 0, age: age, sex: sex, altitude: altitude)
    }
    private var plankResult: NavyEventResult {
        NavyScoring.score(event: .forearmPlank, rawValue: svcTime(plankMin, plankSec), age: age, sex: sex, altitude: altitude)
    }
    private var cardioResult: NavyEventResult {
        NavyScoring.score(event: cardioEvent, rawValue: svcTime(cardioMin, cardioSec), age: age, sex: sex, altitude: altitude)
    }
    private var overall: NavyEventResult? {
        NavyScoring.overall(events: [pushResult, plankResult, cardioResult])
    }

    private var passed: Bool {
        guard let overall else { return false }
        return overall.category != .failure && overall.category != .probationary
    }

    private var resultLabel: String {
        guard let overall else { return "—" }
        let level = overall.level == .none ? "" : " \(MVMTheme.dot) \(overall.level.rawValue.uppercased())"
        return overall.category.rawValue.uppercased() + level
    }

    private func cardioCode(_ event: NavyEvent) -> String {
        switch event {
        case .run1_5Mile: return "1.5MI"
        case .row2Kilometer: return "2K ROW"
        case .swim500Yard: return "500YD"
        case .swim450Meter: return "450M"
        case .pushUps, .forearmPlank: return ""
        }
    }

    private func cardioTitle(_ event: NavyEvent) -> String {
        switch event {
        case .run1_5Mile: return "1.5-Mile Run"
        case .row2Kilometer: return "2000 m Row"
        case .swim500Yard: return "500 yd Swim"
        case .swim450Meter: return "450 m Swim"
        case .pushUps, .forearmPlank: return ""
        }
    }

    private func buildRecord() -> ServiceTestRecord {
        ServiceTestRecord(
            branch: .navy,
            scoreDisplay: "\(overall?.points ?? 0)",
            maxDisplay: "/ 100",
            scoreValue: Double(overall?.points ?? 0),
            resultLabel: resultLabel,
            passed: passed,
            events: [
                .init(code: "PU", raw: "\(Int(pushUpsText) ?? 0) REPS", points: "\(pushResult.points)"),
                .init(code: "PLK", raw: svcTimeDisplay(svcTime(plankMin, plankSec)), points: "\(plankResult.points)"),
                .init(code: cardioCode(cardioEvent), raw: svcTimeDisplay(svcTime(cardioMin, cardioSec)), points: "\(cardioResult.points)")
            ]
        )
    }

    var body: some View {
        VStack(spacing: 14) {
            RaisedCard {
                VStack(spacing: 14) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            SvcLabel(text: "AGE")
                            SvcNumberWell(placeholder: "25", text: $ageText, suffix: "YRS")
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            SvcLabel(text: "SEX")
                            SvcChoiceChips(options: ServiceSex.allCases, selection: $sex, height: 54) { $0.rawValue.capitalized }
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        SvcLabel(text: "ALTITUDE")
                        SvcChoiceChips(options: [NavyAltitude.below5000, .above5000], selection: $altitude, height: 44) {
                            $0 == .below5000 ? "Below 5,000 ft" : "5,000 ft +"
                        }
                    }
                }
                .padding(16)
            }

            SvcEventRow(code: "PU", title: "Push-Ups (2 min)", pointsDisplay: "\(pushResult.points)", pointsColor: pointsColor(pushResult)) {
                SvcNumberWell(placeholder: "40", text: $pushUpsText, suffix: "REPS")
            }

            SvcEventRow(code: "PLK", title: "Forearm Plank", pointsDisplay: "\(plankResult.points)", pointsColor: pointsColor(plankResult)) {
                SvcTimeWell(minText: $plankMin, secText: $plankSec)
            }

            SvcEventRow(code: cardioCode(cardioEvent), title: cardioTitle(cardioEvent), pointsDisplay: "\(cardioResult.points)", pointsColor: pointsColor(cardioResult)) {
                VStack(spacing: 8) {
                    SvcChoiceChips(
                        options: [NavyEvent.run1_5Mile, .row2Kilometer, .swim500Yard, .swim450Meter],
                        selection: $cardioEvent,
                        height: 40
                    ) { cardioCode($0) }
                    SvcTimeWell(minText: $cardioMin, secText: $cardioSec)
                }
            }

            SvcResultCard(
                scoreDisplay: "\(overall?.points ?? 0)",
                maxDisplay: "/ 100 \(MVMTheme.dot) \(resultLabel)",
                resultLabel: passed ? "GO \(MVMTheme.dot) \(resultLabel)" : "NO GO \(MVMTheme.dot) \(resultLabel)",
                passed: passed,
                saveTitle: "Save Navy PRT Result",
                didSave: didSave,
                onSave: {
                    vm.saveServiceTestRecord(buildRecord())
                    didSave = true
                },
                onShare: { shareRecord = buildRecord() },
                pdfRecord: { buildRecord() }
            )
        }
        .sensoryFeedback(.success, trigger: didSave)
        .sheet(item: $shareRecord) { record in
            ServiceTestShareSheet(record: record, previousScore: previousScore(for: record))
        }
    }

    private func previousScore(for record: ServiceTestRecord) -> Double? {
        vm.serviceTestRecords.first { $0.branch == record.branch && $0.id != record.id }?.scoreValue
    }

    private func pointsColor(_ result: NavyEventResult) -> Color {
        switch result.category {
        case .outstanding, .excellent: return MVMTheme.success
        case .good, .satisfactory: return MVMTheme.warning
        case .probationary, .failure: return MVMTheme.danger
        }
    }
}

// MARK: - Air Force PT

struct AirForcePTContent: View {
    @Environment(AppViewModel.self) private var vm

    private enum CardioChoice: String, CaseIterable { case run = "2-Mi Run", hamr = "HAMR", walk = "2-Km Walk" }
    private enum StrengthChoice: String, CaseIterable { case pushUps = "Push-Ups", hrPushUps = "HR Push-Ups" }
    private enum CoreChoice: String, CaseIterable { case sitUps = "Sit-Ups", crunch = "Reverse Crunch", plank = "Plank" }

    @State private var ageText = "25"
    @State private var sex: ServiceSex = .male
    @State private var waistText = "34"
    @State private var heightText = "69"
    @State private var cardioChoice: CardioChoice = .run
    @State private var runMin = "13"
    @State private var runSec = "30"
    @State private var hamrText = "60"
    @State private var strengthChoice: StrengthChoice = .pushUps
    @State private var strengthText = "40"
    @State private var coreChoice: CoreChoice = .sitUps
    @State private var coreText = "40"
    @State private var corePlankMin = "2"
    @State private var corePlankSec = "00"
    @State private var didSave = false
    @State private var shareRecord: ServiceTestRecord?

    private var age: Int { Int(ageText) ?? 25 }

    private var whtrValue: Double? {
        AirForceScoring.waistToHeightRatio(waist: Double(waistText) ?? 0, height: Double(heightText) ?? 0)
    }
    private var whtrScore: Double {
        guard let ratio = whtrValue else { return 0 }
        return AirForceScoring.score(event: .waistToHeightRatio, rawValue: ratio, age: age, sex: sex) ?? 0
    }

    private var cardioSeconds: Int { svcTime(runMin, runSec) }

    private var walkPassed: Bool {
        AirForceScoring.twoKilometerWalkPassed(seconds: cardioSeconds, age: age, sex: sex)
    }

    private var cardioScore: Double {
        switch cardioChoice {
        case .run: return AirForceScoring.score(event: .twoMileRun, rawValue: Double(cardioSeconds), age: age, sex: sex) ?? 0
        case .hamr: return AirForceScoring.score(event: .hamr20m, rawValue: Double(Int(hamrText) ?? 0), age: age, sex: sex) ?? 0
        case .walk: return 0 // pass/fail — excluded from the composite denominator
        }
    }

    private var strengthScore: Double {
        let reps = Double(Int(strengthText) ?? 0)
        let event: AirForceEvent = strengthChoice == .pushUps ? .pushUps : .handReleasePushUps
        return AirForceScoring.score(event: event, rawValue: reps, age: age, sex: sex) ?? 0
    }

    private var coreScore: Double {
        switch coreChoice {
        case .sitUps: return AirForceScoring.score(event: .sitUps, rawValue: Double(Int(coreText) ?? 0), age: age, sex: sex) ?? 0
        case .crunch: return AirForceScoring.score(event: .crossLegReverseCrunch, rawValue: Double(Int(coreText) ?? 0), age: age, sex: sex) ?? 0
        case .plank: return AirForceScoring.score(event: .forearmPlank, rawValue: Double(svcTime(corePlankMin, corePlankSec)), age: age, sex: sex) ?? 0
        }
    }

    /// Composite: points earned / points possible × 100. With the walk
    /// (pass/fail) the denominator drops to 50 (WHtR 20 + strength 15 + core 15).
    private var composite: Double {
        let earned = whtrScore + strengthScore + coreScore + cardioScore
        let possible: Double = cardioChoice == .walk ? 50 : 100
        return (earned / possible) * 100
    }

    private var passed: Bool {
        let meets = composite >= 75
        return cardioChoice == .walk ? (walkPassed && meets) : meets
    }

    private var resultLabel: String {
        if !passed { return "UNSATISFACTORY" }
        return composite >= 90 ? "EXCELLENT" : "SATISFACTORY"
    }

    private var compositeDisplay: String { String(format: "%.1f", composite) }

    private func buildRecord() -> ServiceTestRecord {
        var events: [ServiceTestEventDetail] = [
            .init(code: "WHtR", raw: whtrValue.map { String(format: "%.2f", $0) } ?? "—", points: String(format: "%.0f", whtrScore))
        ]
        switch cardioChoice {
        case .run:
            events.append(.init(code: "2MI", raw: svcTimeDisplay(cardioSeconds), points: String(format: "%.1f", cardioScore)))
        case .hamr:
            events.append(.init(code: "HAMR", raw: "\(Int(hamrText) ?? 0) SHTL", points: String(format: "%.1f", cardioScore)))
        case .walk:
            events.append(.init(code: "WALK", raw: svcTimeDisplay(cardioSeconds), points: walkPassed ? "PASS" : "FAIL"))
        }
        events.append(.init(code: strengthChoice == .pushUps ? "PU" : "HRP", raw: "\(Int(strengthText) ?? 0) REPS", points: String(format: "%.0f", strengthScore)))
        switch coreChoice {
        case .plank:
            events.append(.init(code: "PLK", raw: svcTimeDisplay(svcTime(corePlankMin, corePlankSec)), points: String(format: "%.0f", coreScore)))
        case .sitUps:
            events.append(.init(code: "SU", raw: "\(Int(coreText) ?? 0) REPS", points: String(format: "%.0f", coreScore)))
        case .crunch:
            events.append(.init(code: "CRUNCH", raw: "\(Int(coreText) ?? 0) REPS", points: String(format: "%.0f", coreScore)))
        }
        return ServiceTestRecord(
            branch: .airForce,
            scoreDisplay: compositeDisplay,
            maxDisplay: "/ 100",
            scoreValue: composite,
            resultLabel: resultLabel,
            passed: passed,
            events: events
        )
    }

    var body: some View {
        VStack(spacing: 14) {
            RaisedCard {
                VStack(spacing: 14) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            SvcLabel(text: "AGE")
                            SvcNumberWell(placeholder: "25", text: $ageText, suffix: "YRS")
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            SvcLabel(text: "SEX")
                            SvcChoiceChips(options: ServiceSex.allCases, selection: $sex, height: 54) { $0.rawValue.capitalized }
                        }
                    }
                }
                .padding(16)
            }

            SvcEventRow(code: "WHtR", title: "Waist-to-Height Ratio", pointsDisplay: String(format: "%.0f", whtrScore), pointsColor: whtrScore > 0 ? MVMTheme.success : MVMTheme.danger) {
                HStack(spacing: 10) {
                    SvcNumberWell(placeholder: "34", text: $waistText, suffix: "WAIST IN", allowsDecimal: true)
                    SvcNumberWell(placeholder: "69", text: $heightText, suffix: "HT IN", allowsDecimal: true)
                }
            }

            SvcEventRow(
                code: cardioChoice == .run ? "2MI" : cardioChoice == .hamr ? "HAMR" : "WALK",
                title: cardioChoice == .hamr ? "20 m HAMR Shuttles" : cardioChoice == .run ? "2-Mile Run" : "2-Km Walk (pass/fail)",
                pointsDisplay: cardioChoice == .walk ? (walkPassed ? "PASS" : "FAIL") : String(format: "%.1f", cardioScore),
                pointsColor: cardioChoice == .walk ? (walkPassed ? MVMTheme.success : MVMTheme.danger) : (cardioScore > 0 ? MVMTheme.success : MVMTheme.danger)
            ) {
                VStack(spacing: 8) {
                    SvcChoiceChips(options: CardioChoice.allCases, selection: $cardioChoice, height: 40) { $0.rawValue }
                    if cardioChoice == .hamr {
                        SvcNumberWell(placeholder: "60", text: $hamrText, suffix: "SHUTTLES")
                    } else {
                        SvcTimeWell(minText: $runMin, secText: $runSec)
                    }
                }
            }

            SvcEventRow(
                code: strengthChoice == .pushUps ? "PU" : "HRP",
                title: strengthChoice == .pushUps ? "Push-Ups (1 min)" : "Hand-Release Push-Ups (2 min)",
                pointsDisplay: String(format: "%.0f", strengthScore),
                pointsColor: strengthScore > 0 ? MVMTheme.success : MVMTheme.danger
            ) {
                VStack(spacing: 8) {
                    SvcChoiceChips(options: StrengthChoice.allCases, selection: $strengthChoice, height: 40) { $0.rawValue }
                    SvcNumberWell(placeholder: "40", text: $strengthText, suffix: "REPS")
                }
            }

            SvcEventRow(
                code: coreChoice == .plank ? "PLK" : coreChoice == .sitUps ? "SU" : "CLRC",
                title: coreChoice == .plank ? "Forearm Plank" : coreChoice == .sitUps ? "Sit-Ups (1 min)" : "Cross-Leg Reverse Crunch (2 min)",
                pointsDisplay: String(format: "%.0f", coreScore),
                pointsColor: coreScore > 0 ? MVMTheme.success : MVMTheme.danger
            ) {
                VStack(spacing: 8) {
                    SvcChoiceChips(options: CoreChoice.allCases, selection: $coreChoice, height: 40) { $0.rawValue }
                    if coreChoice == .plank {
                        SvcTimeWell(minText: $corePlankMin, secText: $corePlankSec)
                    } else {
                        SvcNumberWell(placeholder: "40", text: $coreText, suffix: "REPS")
                    }
                }
            }

            SvcResultCard(
                scoreDisplay: compositeDisplay,
                maxDisplay: "/ 100",
                resultLabel: resultLabel,
                passed: passed,
                saveTitle: "Save Air Force PT Result",
                didSave: didSave,
                onSave: {
                    vm.saveServiceTestRecord(buildRecord())
                    didSave = true
                },
                onShare: { shareRecord = buildRecord() },
                pdfRecord: { buildRecord() }
            )
        }
        .sensoryFeedback(.success, trigger: didSave)
        .sheet(item: $shareRecord) { record in
            ServiceTestShareSheet(record: record, previousScore: vm.serviceTestRecords.first { $0.branch == .airForce && $0.id != record.id }?.scoreValue)
        }
    }
}

// MARK: - Marine PFT / CFT

struct MarineTestContent: View {
    @Environment(AppViewModel.self) private var vm

    @State private var testType: MarineTestType = .pft
    @State private var ageText = "25"
    @State private var sex: MarineSex = .male
    @State private var altitude: MarineAltitude = .standard

    // PFT inputs
    @State private var upperEvent: MarinePFTUpperBodyEvent = .pullUps
    @State private var upperText = "12"
    @State private var plankMin = "2"
    @State private var plankSec = "00"
    @State private var cardioEvent: MarinePFTCardioEvent = .threeMileRun
    @State private var cardioMin = "24"
    @State private var cardioSec = "00"

    // CFT inputs
    @State private var mtcMin = "3"
    @State private var mtcSec = "00"
    @State private var ammoText = "60"
    @State private var mufMin = "3"
    @State private var mufSec = "00"

    @State private var didSave = false
    @State private var shareRecord: ServiceTestRecord?

    private var age: Int { Int(ageText) ?? 25 }

    private var result: MarineTestResult? {
        switch testType {
        case .pft:
            return MarineCorpsScoring.scorePFT(MarinePFTInput(
                age: age, sex: sex, altitude: altitude,
                upperBodyEvent: upperEvent,
                upperBodyRepetitions: Int(upperText) ?? 0,
                plankTime: MarineTime(seconds: svcTime(plankMin, plankSec)),
                cardioEvent: cardioEvent,
                cardioTime: MarineTime(seconds: svcTime(cardioMin, cardioSec))
            ))
        case .cft:
            return MarineCorpsScoring.scoreCFT(MarineCFTInput(
                age: age, sex: sex, altitude: altitude,
                movementToContactTime: MarineTime(seconds: svcTime(mtcMin, mtcSec)),
                ammunitionLiftRepetitions: Int(ammoText) ?? 0,
                maneuverUnderFireTime: MarineTime(seconds: svcTime(mufMin, mufSec))
            ))
        }
    }

    private var resultLabel: String {
        result?.classification.rawValue.uppercased() ?? "ENTER AGE 17+"
    }

    private func eventScore(_ index: Int) -> MarineEventScore? {
        guard let result, result.eventScores.indices.contains(index) else { return nil }
        return result.eventScores[index]
    }

    private func pointsDisplay(_ index: Int) -> String {
        eventScore(index).map { "\($0.points)" } ?? "—"
    }

    private func pointsColor(_ index: Int) -> Color {
        guard let score = eventScore(index) else { return MVMTheme.textFaint }
        return score.passed ? MVMTheme.success : MVMTheme.danger
    }

    private func buildRecord() -> ServiceTestRecord {
        let events: [ServiceTestEventDetail]
        switch testType {
        case .pft:
            events = [
                .init(code: upperEvent == .pullUps ? "PULL" : "PU", raw: "\(Int(upperText) ?? 0) REPS", points: pointsDisplay(0)),
                .init(code: "PLK", raw: svcTimeDisplay(svcTime(plankMin, plankSec)), points: pointsDisplay(1)),
                .init(code: cardioEvent == .threeMileRun ? "3MI" : "5K ROW", raw: svcTimeDisplay(svcTime(cardioMin, cardioSec)), points: pointsDisplay(2))
            ]
        case .cft:
            events = [
                .init(code: "MTC", raw: svcTimeDisplay(svcTime(mtcMin, mtcSec)), points: pointsDisplay(0)),
                .init(code: "AL", raw: "\(Int(ammoText) ?? 0) REPS", points: pointsDisplay(1)),
                .init(code: "MUF", raw: svcTimeDisplay(svcTime(mufMin, mufSec)), points: pointsDisplay(2))
            ]
        }
        return ServiceTestRecord(
            branch: testType == .pft ? .marinePFT : .marineCFT,
            scoreDisplay: "\(result?.totalPoints ?? 0)",
            maxDisplay: "/ 300",
            scoreValue: Double(result?.totalPoints ?? 0),
            resultLabel: resultLabel,
            passed: result?.passed ?? false,
            events: events
        )
    }

    var body: some View {
        VStack(spacing: 14) {
            RaisedCard {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        SvcLabel(text: "TEST")
                        SvcChoiceChips(options: [MarineTestType.pft, .cft], selection: $testType, height: 44) {
                            $0 == .pft ? "PFT" : "CFT"
                        }
                    }
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            SvcLabel(text: "AGE")
                            SvcNumberWell(placeholder: "25", text: $ageText, suffix: "YRS")
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            SvcLabel(text: "SEX")
                            SvcChoiceChips(options: MarineSex.allCases, selection: $sex, height: 54) { $0.rawValue.capitalized }
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        SvcLabel(text: "ALTITUDE")
                        SvcChoiceChips(options: MarineAltitude.allCases, selection: $altitude, height: 44) {
                            $0 == .standard ? "Standard" : "4,500 ft +"
                        }
                    }
                }
                .padding(16)
            }

            if testType == .pft {
                SvcEventRow(
                    code: upperEvent == .pullUps ? "PULL" : "PU",
                    title: upperEvent == .pullUps ? "Pull-Ups" : "Push-Ups (2 min)",
                    pointsDisplay: pointsDisplay(0),
                    pointsColor: pointsColor(0)
                ) {
                    VStack(spacing: 8) {
                        SvcChoiceChips(options: MarinePFTUpperBodyEvent.allCases, selection: $upperEvent, height: 40) {
                            $0 == .pullUps ? "Pull-Ups" : "Push-Ups"
                        }
                        SvcNumberWell(placeholder: "12", text: $upperText, suffix: "REPS")
                    }
                }

                SvcEventRow(code: "PLK", title: "Plank", pointsDisplay: pointsDisplay(1), pointsColor: pointsColor(1)) {
                    SvcTimeWell(minText: $plankMin, secText: $plankSec)
                }

                SvcEventRow(
                    code: cardioEvent == .threeMileRun ? "3MI" : "5K",
                    title: cardioEvent == .threeMileRun ? "3-Mile Run" : "5000 m Row",
                    pointsDisplay: pointsDisplay(2),
                    pointsColor: pointsColor(2)
                ) {
                    VStack(spacing: 8) {
                        SvcChoiceChips(options: MarinePFTCardioEvent.allCases, selection: $cardioEvent, height: 40) {
                            $0 == .threeMileRun ? "3-Mi Run" : "5K Row"
                        }
                        SvcTimeWell(minText: $cardioMin, secText: $cardioSec)
                    }
                }
            } else {
                SvcEventRow(code: "MTC", title: "Movement to Contact (880 yd)", pointsDisplay: pointsDisplay(0), pointsColor: pointsColor(0)) {
                    SvcTimeWell(minText: $mtcMin, secText: $mtcSec)
                }
                SvcEventRow(code: "AL", title: "Ammunition Lift (2 min)", pointsDisplay: pointsDisplay(1), pointsColor: pointsColor(1)) {
                    SvcNumberWell(placeholder: "60", text: $ammoText, suffix: "REPS")
                }
                SvcEventRow(code: "MUF", title: "Maneuver Under Fire (300 yd)", pointsDisplay: pointsDisplay(2), pointsColor: pointsColor(2)) {
                    SvcTimeWell(minText: $mufMin, secText: $mufSec)
                }
            }

            SvcResultCard(
                scoreDisplay: "\(result?.totalPoints ?? 0)",
                maxDisplay: "/ 300",
                resultLabel: resultLabel,
                passed: result?.passed ?? false,
                saveTitle: testType == .pft ? "Save Marine PFT Result" : "Save Marine CFT Result",
                didSave: didSave,
                onSave: {
                    vm.saveServiceTestRecord(buildRecord())
                    didSave = true
                },
                onShare: { shareRecord = buildRecord() },
                pdfRecord: { buildRecord() }
            )
        }
        .sensoryFeedback(.success, trigger: didSave)
        .sheet(item: $shareRecord) { record in
            ServiceTestShareSheet(record: record, previousScore: vm.serviceTestRecords.first { $0.branch == record.branch && $0.id != record.id }?.scoreValue)
        }
        .onChange(of: testType) { _, _ in didSave = false }
    }
}

// MARK: - Advanced Readiness (proprietary benchmarks)

struct AdvancedReadinessContent: View {
    @Environment(AppViewModel.self) private var vm

    @State private var benchmarkID: String = ReadinessScoringData.benchmarks.first?.id ?? "waterOperations"
    @State private var repInputs: [String: String] = [:]
    @State private var minInputs: [String: String] = [:]
    @State private var secInputs: [String: String] = [:]
    @State private var binaryInputs: [String: Bool] = [:]
    @State private var didSave = false
    @State private var shareRecord: ServiceTestRecord?

    private var benchmark: ReadinessBenchmark {
        ReadinessScoringData.benchmarks.first { $0.id == benchmarkID } ?? ReadinessScoringData.benchmarks[0]
    }

    private func curve(_ eventID: String) -> EventCurve? {
        ReadinessScoringData.curves[eventID]
    }

    /// Returns nil when the user has not entered this event yet, so the
    /// benchmark's completeness guard can distinguish "blank" from "zero".
    private func rawValue(_ eventID: String) -> Double? {
        guard let curve = curve(eventID) else { return nil }
        switch curve.unit {
        case "seconds":
            let minText = minInputs[eventID] ?? ""
            let secText = secInputs[eventID] ?? ""
            guard !(minText.isEmpty && secText.isEmpty) else { return nil }
            let seconds = svcTime(minText, secText)
            return seconds > 0 ? Double(seconds) : nil
        case "pass/fail":
            guard let value = binaryInputs[eventID] else { return nil }
            return value ? 1 : 0
        default: // reps, points
            let text = repInputs[eventID] ?? ""
            guard !text.isEmpty, let reps = Int(text), reps >= 0 else { return nil }
            return Double(reps)
        }
    }

    private var results: [String: Double] {
        var out: [String: Double] = [:]
        for event in benchmark.events {
            if let value = rawValue(event.eventID) { out[event.eventID] = value }
        }
        return out
    }

    /// nil until every event in the benchmark has been entered.
    private var totalOrNil: Double? {
        benchmark.totalScore(results: results, curves: ReadinessScoringData.curves)
    }

    private var isComplete: Bool { totalOrNil != nil }
    private var total: Double { totalOrNil ?? 0 }

    private var rating: ReadinessRating { ReadinessRating.from(score: total) }
    /// Every GO/NO-GO event (the rucks, water confidence) met its standard.
    private var gatesPassed: Bool {
        benchmark.gatesPassed(results: results, curves: ReadinessScoringData.curves)
    }

    /// Points alone are not a pass — a missed ruck cap fails the benchmark
    /// outright, exactly like the Air Force 2 km walk gates its composite.
    private var passed: Bool { isComplete && gatesPassed && total >= 60 }

    /// Faint when the event has not been entered yet.
    private static func pointsColor(for score: Double?) -> Color {
        guard let score else { return MVMTheme.textFaint }
        return score >= 60 ? MVMTheme.success : score > 0 ? MVMTheme.warning : MVMTheme.danger
    }

    /// Every row now states the standard it is measured against — the maximum
    /// allowable time for a gate, or the 60/100 point references otherwise.
    /// Previously the row showed only the event's weight.
    private static func rowTitle(curve: EventCurve, event: BenchmarkEvent) -> String {
        if let standard = curve.standardLabel {
            return "\(curve.displayName) \(MVMTheme.dot) \(standard)"
        }
        return "\(curve.displayName) \(MVMTheme.dot) \(Int(event.weight * 100))%"
    }

    private static func rowValue(curve: EventCurve, entered: Double?, score: Double?) -> String {
        if curve.isGate {
            guard entered != nil else { return "—" }
            return curve.passesGate(entered) ? "GO" : "NO GO"
        }
        return score.map { String(format: "%.0f", $0) } ?? "—"
    }

    private static func rowColor(curve: EventCurve, entered: Double?, score: Double?) -> Color {
        if curve.isGate {
            guard entered != nil else { return MVMTheme.textFaint }
            return curve.passesGate(entered) ? MVMTheme.success : MVMTheme.danger
        }
        return pointsColor(for: score)
    }

    private func shortCode(_ eventID: String) -> String {
        switch eventID {
        case "swim500yd": return "500YD"
        case "swim1000m": return "1000M"
        case "run1_5mi": return "1.5MI"
        case "run3mi": return "3MI"
        case "run5mi": return "5MI"
        case "ruck12mi45": return "12MI"
        case "ruck10mi45": return "10MI"
        case "shuttle300yd": return "300YD"
        case "farmer400m106": return "FARMER"
        case "pullUps": return "PULL"
        case "pushUps2m": return "PU"
        case "hrPushUps2m": return "HRP"
        case "sitUps2m": return "SU"
        case "plank": return "PLK"
        case "armyFitnessTotal": return "AFT"
        case "waterConfidence": return "WATER"
        default: return eventID.uppercased()
        }
    }

    private func rawDisplay(_ eventID: String) -> String {
        guard let curve = curve(eventID) else { return "—" }
        guard let value = rawValue(eventID) else { return "—" }
        switch curve.unit {
        case "seconds": return svcTimeDisplay(Int(value))
        case "pass/fail": return value >= 1 ? "PASS" : "NOT DONE"
        case "points": return "\(Int(value)) PTS"
        default: return "\(Int(value)) REPS"
        }
    }

    private func buildRecord() -> ServiceTestRecord {
        ServiceTestRecord(
            branch: .advancedReadiness,
            subtitle: benchmark.displayName,
            scoreDisplay: String(format: "%.0f", total),
            maxDisplay: "/ 100",
            scoreValue: total,
            resultLabel: gatesPassed ? rating.rawValue.uppercased() : "NO GO \(MVMTheme.dot) STANDARD NOT MET",
            passed: passed,
            events: benchmark.events.map { event in
                let score = rawValue(event.eventID).flatMap { raw in curve(event.eventID)?.score(for: raw) } ?? 0
                return .init(code: shortCode(event.eventID), raw: rawDisplay(event.eventID), points: String(format: "%.0f", score))
            }
        )
    }

    var body: some View {
        VStack(spacing: 14) {
            RaisedCard {
                VStack(alignment: .leading, spacing: 10) {
                    SvcLabel(text: "BENCHMARK")
                    ForEach(ReadinessScoringData.benchmarks, id: \.id) { option in
                        let selected = option.id == benchmarkID
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                benchmarkID = option.id
                                didSave = false
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selected ? MVMTheme.amber : MVMTheme.textFaint)
                                Text(option.displayName)
                                    .font(.subheadline.weight(selected ? .bold : .medium))
                                    .foregroundStyle(selected ? MVMTheme.text : MVMTheme.textMuted)
                                Spacer(minLength: 0)
                                Text("\(option.events.count) EVENTS")
                                    .font(MVMTheme.mono(9))
                                    .foregroundStyle(MVMTheme.textFaint)
                                    .lineLimit(1)
                                    .fixedSize()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(selected ? MVMTheme.amber.opacity(0.09) : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .contentShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(PressScaleButtonStyle())
                    }

                    Text("Proprietary MVM benchmarks — not official military selection standards.")
                        .font(.caption2)
                        .foregroundStyle(MVMTheme.textFaint)
                }
                .padding(16)
            }

            ForEach(benchmark.events, id: \.eventID) { event in
                if let curve = curve(event.eventID) {
                    let entered = rawValue(event.eventID)
                    let score = entered.map { curve.score(for: $0) }
                    SvcEventRow(
                        code: shortCode(event.eventID),
                        title: Self.rowTitle(curve: curve, event: event),
                        pointsDisplay: Self.rowValue(curve: curve, entered: entered, score: score),
                        pointsColor: Self.rowColor(curve: curve, entered: entered, score: score)
                    ) {
                        eventInput(for: event.eventID, curve: curve)
                    }
                }
            }

            SvcResultCard(
                scoreDisplay: isComplete ? String(format: "%.0f", total) : "—",
                maxDisplay: "/ 100",
                resultLabel: isComplete
                    ? (gatesPassed ? rating.rawValue.uppercased() : "NO GO \(MVMTheme.dot) STANDARD NOT MET")
                    : "ENTER ALL EVENTS",
                passed: passed,
                saveTitle: "Save Advanced Readiness Result",
                didSave: didSave,
                onSave: {
                    guard isComplete else { return }
                    vm.saveServiceTestRecord(buildRecord())
                    didSave = true
                },
                onShare: { if isComplete { shareRecord = buildRecord() } },
                pdfRecord: { buildRecord() }
            )
            .disabled(!isComplete)
        }
        .sensoryFeedback(.success, trigger: didSave)
        .sheet(item: $shareRecord) { record in
            ServiceTestShareSheet(record: record, previousScore: vm.serviceTestRecords.first { $0.branch == .advancedReadiness && $0.subtitle == record.subtitle && $0.id != record.id }?.scoreValue)
        }
        .onAppear { prefillAFTTotal() }
        .onChange(of: benchmarkID) { _, _ in prefillAFTTotal() }
    }

    /// If a benchmark includes the AFT total event, pre-fill it from the
    /// user's latest saved AFT score so re-entry is never required.
    private func prefillAFTTotal() {
        seedBinaryDefaults()
        guard benchmark.events.contains(where: { $0.eventID == "armyFitnessTotal" }),
              repInputs["armyFitnessTotal"] == nil,
              let latest = vm.latestAFTScore else { return }
        repInputs["armyFitnessTotal"] = "\(latest.totalScore)"
    }

    /// A pass/fail chip renders "Not Completed" as selected, so leaving the
    /// value nil would show an answered control while the model treats the
    /// event as blank — an invisible reason the Save button stays disabled.
    /// Seeding false makes the displayed state and the model agree.
    private func seedBinaryDefaults() {
        for event in benchmark.events where curve(event.eventID)?.unit == "pass/fail" {
            if binaryInputs[event.eventID] == nil { binaryInputs[event.eventID] = false }
        }
    }

    @ViewBuilder
    private func eventInput(for eventID: String, curve: EventCurve) -> some View {
        switch curve.unit {
        case "seconds":
            SvcTimeWell(
                minText: Binding(
                    get: { minInputs[eventID] ?? "" },
                    set: { minInputs[eventID] = $0 }
                ),
                secText: Binding(
                    get: { secInputs[eventID] ?? "" },
                    set: { secInputs[eventID] = $0 }
                )
            )
        case "pass/fail":
            SvcChoiceChips(
                options: [true, false],
                selection: Binding(
                    get: { binaryInputs[eventID] ?? false },
                    set: { binaryInputs[eventID] = $0 }
                ),
                height: 44
            ) { $0 ? "Completed" : "Not Completed" }
        default:
            SvcNumberWell(
                placeholder: "0",
                text: Binding(
                    get: { repInputs[eventID] ?? "" },
                    set: { repInputs[eventID] = $0 }
                ),
                suffix: curve.unit == "points" ? "PTS" : "REPS"
            )
        }
    }
}
