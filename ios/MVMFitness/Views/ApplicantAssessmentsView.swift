import SwiftUI

/// ROTC & Service Academy applicant assessments, embedded in the Calculator
/// tab. Scoring comes exclusively from `ApplicantAssessmentScoring` (practice
/// comparison scale — never labeled as an official selection score) and, for
/// the Marine option, the official `MarineCorpsScoring` event tables.
struct ApplicantAssessmentContent: View {
    @Environment(AppViewModel.self) private var vm

    @State private var program: ApplicantAssessmentProgram = .armyROTC
    @State private var sex: ApplicantSex = .male
    @State private var ageText = "17"

    // Shared raw inputs (reused across programs where the event matches)
    @State private var pushUpsText = "40"
    @State private var coreText = "40"          // curl-ups / sit-ups
    @State private var plankMin = "2"
    @State private var plankSec = "00"
    @State private var runMin = "7"
    @State private var runSec = "00"

    // Marine option
    @State private var marineUpper: MarineOptionUpperBodyChoice = .pullUps
    @State private var marineRepsText = "12"

    // CFA extras
    @State private var throwText = "60"
    @State private var cfaUpper: CFAUpperBodyEvent = .pullUps
    @State private var cfaUpperReps = "8"
    @State private var hangMin = "0"
    @State private var hangSec = "30"
    @State private var shuttleSecText = "9.5"
    @State private var cfaSitUpsText = "60"

    @State private var didSave = false
    @State private var shareRecord: ServiceTestRecord?
    @State private var showAcademies = false

    private func time(_ m: String, _ s: String) -> ApplicantTime {
        ApplicantTime(minutes: Int(m) ?? 0, seconds: Int(s) ?? 0)
    }

    // MARK: - Scoring

    private var result: ApplicantAssessmentResult? {
        switch program {
        case .armyROTC:
            return ApplicantAssessmentScoring.scoreArmyROTC(ArmyROTCApplicantInput(
                sex: sex,
                pushUpsOneMinute: Int(pushUpsText) ?? 0,
                curlUpsOneMinute: Int(coreText) ?? 0,
                oneMileRun: time(runMin, runSec)
            ))
        case .airForceROTC:
            return ApplicantAssessmentScoring.scoreAirForceROTC(AirForceROTCApplicantInput(
                sex: sex,
                pushUpsOneMinute: Int(pushUpsText) ?? 0,
                sitUpsOneMinute: Int(coreText) ?? 0,
                twoMileRun: time(runMin, runSec)
            ))
        case .navyROTC:
            return ApplicantAssessmentScoring.scoreNavyROTC(NavyROTCApplicantInput(
                sex: sex,
                pushUpsTwoMinutes: Int(pushUpsText) ?? 0,
                forearmPlank: time(plankMin, plankSec),
                oneMileRun: time(runMin, runSec)
            ))
        case .serviceAcademyCFA:
            return ApplicantAssessmentScoring.scoreServiceAcademyCFA(ServiceAcademyCFAInput(
                sex: sex,
                basketballThrowFeet: Double(throwText) ?? 0,
                upperBodyEvent: cfaUpper,
                pullUpRepetitions: cfaUpper == .pullUps ? (Int(cfaUpperReps) ?? 0) : nil,
                flexedArmHang: cfaUpper == .flexedArmHang ? time(hangMin, hangSec) : nil,
                shuttleRun: ApplicantTime(seconds: Int((Double(shuttleSecText) ?? 0).rounded())),
                modifiedSitUpsTwoMinutes: Int(cfaSitUpsText) ?? 0,
                pushUpsTwoMinutes: Int(pushUpsText) ?? 0,
                oneMileRun: time(runMin, runSec)
            ))
        case .marineOptionROTC:
            return nil // scored via the official Marine tables below
        }
    }

    /// Marine option uses the official Marine PFT tables (no duplication).
    private var marineResult: MarineTestResult? {
        guard program == .marineOptionROTC else { return nil }
        return MarineCorpsScoring.scorePFT(MarinePFTInput(
            age: max(17, Int(ageText) ?? 17),
            sex: sex == .male ? .male : .female,
            altitude: .standard,
            upperBodyEvent: marineUpper == .pullUps ? .pullUps : .pushUps,
            upperBodyRepetitions: Int(marineRepsText) ?? 0,
            plankTime: MarineTime(minutes: Int(plankMin) ?? 0, seconds: Int(plankSec) ?? 0),
            cardioEvent: .threeMileRun,
            cardioTime: MarineTime(minutes: Int(runMin) ?? 0, seconds: Int(runSec) ?? 0)
        ))
    }

    private var compositeDisplay: String {
        if let marineResult { return "\(marineResult.totalPoints)" }
        guard let result else { return "0" }
        return String(format: "%.0f", result.practiceComposite)
    }

    private var maxDisplay: String {
        marineResult != nil ? "/ 300" : "/ 100 PRACTICE"
    }

    private var ratingLabel: String {
        if let marineResult { return marineResult.classification.rawValue.uppercased() }
        guard let result else { return "—" }
        return result.rating.rawValue.uppercased()
    }

    private var passed: Bool {
        if let marineResult { return marineResult.passed }
        guard let result else { return false }
        return result.practiceComposite >= 60
    }

    private func buildRecord() -> ServiceTestRecord {
        var events: [ServiceTestEventDetail] = []
        if let marineResult {
            let codes = [marineUpper == .pullUps ? "PULL" : "PU", "PLK", "3MI"]
            let raws = ["\(Int(marineRepsText) ?? 0) REPS",
                        time(plankMin, plankSec).formatted,
                        time(runMin, runSec).formatted]
            for (i, score) in marineResult.eventScores.enumerated() where i < 3 {
                events.append(.init(code: codes[i], raw: raws[i], points: "\(score.points)"))
            }
        } else if let result {
            events = result.eventResults.prefix(6).map { event in
                .init(
                    code: shortCode(event.eventID),
                    raw: rawLabel(event),
                    points: String(format: "%.0f", event.practiceScore)
                )
            }
        }
        return ServiceTestRecord(
            branch: .applicant,
            subtitle: programShortName,
            scoreDisplay: compositeDisplay,
            maxDisplay: maxDisplay,
            scoreValue: marineResult.map { Double($0.totalPoints) } ?? (result?.practiceComposite ?? 0),
            resultLabel: ratingLabel,
            passed: passed,
            events: events
        )
    }

    private var programShortName: String {
        switch program {
        case .armyROTC: return "Army ROTC"
        case .airForceROTC: return "Air Force ROTC"
        case .navyROTC: return "Navy ROTC"
        case .marineOptionROTC: return "Marine Option"
        case .serviceAcademyCFA: return "Academy CFA"
        }
    }

    private func shortCode(_ eventID: String) -> String {
        if eventID.contains("pushups") || eventID.contains("pushUps") { return "PU" }
        if eventID.contains("curl") { return "CU" }
        if eventID.contains("sit") { return "SU" }
        if eventID.contains("plank") { return "PLK" }
        if eventID.contains("basketball") { return "THROW" }
        if eventID.contains("pull") { return "PULL" }
        if eventID.contains("hang") { return "HANG" }
        if eventID.contains("shuttle") { return "SHTL" }
        if eventID.contains("oneMile") || eventID.contains("1mi") || eventID.contains("mile") { return "RUN" }
        if eventID.contains("twoMile") { return "2MI" }
        return "EVT"
    }

    private func rawLabel(_ event: ApplicantEventResult) -> String {
        switch event.unit {
        case "seconds": return ApplicantTime(seconds: Int(event.rawValue)).formatted
        case "feet": return String(format: "%.0f FT", event.rawValue)
        default: return "\(Int(event.rawValue)) \(event.unit.uppercased())"
        }
    }

    // MARK: - Grader eligibility (application-prep reference)

    private var graderInfo: String {
        switch program {
        case .armyROTC:
            return "Graded by a non-related adult proctor — JROTC instructor, PE teacher, or coach. Parents cannot administer. Army allows retakes and counts your best attempt."
        case .airForceROTC:
            return "The only program that allows a parent or guardian to administer, in addition to school officials and coaches. Passing is 75+, with per-event minimums."
        case .navyROTC:
            return "Administered by a school official, JROTC instructor, or coach. Parents cannot proctor."
        case .marineOptionROTC:
            return "Administered by a school official, JROTC instructor, or coach. Parents cannot administer. Escalating minimums: 200 to qualify, 235 after year one, 265 before OCS."
        case .serviceAcademyCFA:
            return "Administered by a PE teacher, coach, JROTC instructor, or Admissions liaison per each academy's instructions. The CFA is its own test — ROTC assessments are not interchangeable with it."
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 14) {
            programPicker

            RaisedCard {
                VStack(spacing: 14) {
                    HStack(alignment: .top, spacing: 12) {
                        if program == .marineOptionROTC {
                            VStack(alignment: .leading, spacing: 6) {
                                label("AGE")
                                SvcInput(text: $ageText, suffix: "YRS")
                            }
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            label("SEX")
                            chips([ApplicantSex.male, .female], selection: $sex) { $0.rawValue.capitalized }
                        }
                    }
                }
                .padding(16)
            }

            programInputs

            resultCard

            graderCard

            Button {
                showAcademies = true
            } label: {
                HStack(spacing: 12) {
                    CardPhotoThumb(name: "photo-founders-trail-run", size: 40, radius: 10)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Compare Service Academies")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(MVMTheme.text)
                        Text("USMA \(MVMTheme.dot) USNA \(MVMTheme.dot) USAFA \(MVMTheme.dot) USCGA \(MVMTheme.dot) USMMA")
                            .font(.caption2)
                            .foregroundStyle(MVMTheme.textMuted)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.textFaint)
                }
                .padding(14)
                .background(MVMTheme.cardGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay { RoundedRectangle(cornerRadius: 16).stroke(MVMTheme.hairline, lineWidth: 1) }
                .contentShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressScaleButtonStyle())

            Text("Practice comparison only — not affiliated with or endorsed by any ROTC program, service academy, or the Department of Defense. This is not an official scholarship, admissions, or selection score.")
                .font(.caption2)
                .foregroundStyle(MVMTheme.textFaint)
                .multilineTextAlignment(.center)
        }
        .sensoryFeedback(.success, trigger: didSave)
        .sheet(item: $shareRecord) { record in
            ServiceTestShareSheet(record: record, previousScore: vm.serviceTestRecords.first { $0.branch == .applicant && $0.subtitle == record.subtitle && $0.id != record.id }?.scoreValue)
        }
        .sheet(isPresented: $showAcademies) {
            AcademyComparisonView()
                .preferredColorScheme(.dark)
        }
        .onChange(of: program) { _, _ in didSave = false }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(MVMTheme.mono(10))
            .kerning(1.2)
            .foregroundStyle(MVMTheme.textFaint)
    }

    private var programPicker: some View {
        RaisedCard {
            VStack(alignment: .leading, spacing: 10) {
                label("PROGRAM")
                ForEach(ApplicantAssessmentProgram.allCases, id: \.self) { option in
                    let selected = option == program
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { program = option }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selected ? MVMTheme.amber : MVMTheme.textFaint)
                            Text(option.rawValue)
                                .font(.subheadline.weight(selected ? .bold : .medium))
                                .foregroundStyle(selected ? MVMTheme.text : MVMTheme.textMuted)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(selected ? MVMTheme.amber.opacity(0.09) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private var programInputs: some View {
        switch program {
        case .armyROTC:
            inputRow("PU", "Push-Ups (1 min)") { SvcInput(text: $pushUpsText, suffix: "REPS") }
            inputRow("CU", "Curl-Ups (1 min)") { SvcInput(text: $coreText, suffix: "REPS") }
            inputRow("RUN", "1-Mile Run") { timeInput }
        case .airForceROTC:
            inputRow("PU", "Push-Ups (1 min)") { SvcInput(text: $pushUpsText, suffix: "REPS") }
            inputRow("SU", "Sit-Ups (1 min)") { SvcInput(text: $coreText, suffix: "REPS") }
            inputRow("2MI", "2-Mile Run") { timeInput }
        case .navyROTC:
            inputRow("PU", "Push-Ups (2 min)") { SvcInput(text: $pushUpsText, suffix: "REPS") }
            inputRow("PLK", "Forearm Plank") { plankInput }
            inputRow("RUN", "1-Mile Run") { timeInput }
        case .marineOptionROTC:
            inputRow(marineUpper == .pullUps ? "PULL" : "PU", marineUpper == .pullUps ? "Pull-Ups" : "Push-Ups") {
                VStack(spacing: 8) {
                    chips([MarineOptionUpperBodyChoice.pullUps, .pushUps], selection: $marineUpper) {
                        $0 == .pullUps ? "Pull-Ups" : "Push-Ups"
                    }
                    SvcInput(text: $marineRepsText, suffix: "REPS")
                }
            }
            inputRow("PLK", "Plank") { plankInput }
            inputRow("3MI", "3-Mile Run") { timeInput }
        case .serviceAcademyCFA:
            inputRow("THROW", "Basketball Throw (kneeling)") { SvcInput(text: $throwText, suffix: "FEET", decimal: true) }
            inputRow(cfaUpper == .pullUps ? "PULL" : "HANG", cfaUpper == .pullUps ? "Pull-Ups" : "Flexed-Arm Hang") {
                VStack(spacing: 8) {
                    chips([CFAUpperBodyEvent.pullUps, .flexedArmHang], selection: $cfaUpper) {
                        $0 == .pullUps ? "Pull-Ups" : "Arm Hang"
                    }
                    if cfaUpper == .pullUps {
                        SvcInput(text: $cfaUpperReps, suffix: "REPS")
                    } else {
                        HStack(spacing: 8) {
                            SvcInput(text: $hangMin, suffix: "MIN")
                            SvcInput(text: $hangSec, suffix: "SEC")
                        }
                    }
                }
            }
            inputRow("SHTL", "Shuttle Run (40 yd)") { SvcInput(text: $shuttleSecText, suffix: "SECONDS", decimal: true) }
            inputRow("SU", "Modified Sit-Ups (2 min)") { SvcInput(text: $cfaSitUpsText, suffix: "REPS") }
            inputRow("PU", "Push-Ups (2 min)") { SvcInput(text: $pushUpsText, suffix: "REPS") }
            inputRow("RUN", "1-Mile Run") { timeInput }
        }
    }

    private var timeInput: some View {
        HStack(spacing: 8) {
            SvcInput(text: $runMin, suffix: "MIN")
            SvcInput(text: $runSec, suffix: "SEC")
        }
    }

    private var plankInput: some View {
        HStack(spacing: 8) {
            SvcInput(text: $plankMin, suffix: "MIN")
            SvcInput(text: $plankSec, suffix: "SEC")
        }
    }

    private func inputRow<Content: View>(_ code: String, _ title: String, @ViewBuilder content: () -> Content) -> some View {
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
                    Spacer(minLength: 0)
                }
                content()
            }
            .padding(14)
        }
    }

    private var resultCard: some View {
        VStack(spacing: 14) {
            RaisedCard {
                VStack(spacing: 10) {
                    Text(marineResult != nil ? "PFT SCORE" : "PRACTICE COMPOSITE")
                        .font(MVMTheme.mono(11))
                        .kerning(1.4)
                        .foregroundStyle(MVMTheme.textFaint)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(compositeDisplay)
                            .font(MVMTheme.scoreDisplay(56))
                            .foregroundStyle(MVMTheme.text)
                            .contentTransition(.numericText())
                            .lineLimit(1)
                            .fixedSize()
                        Text(maxDisplay)
                            .font(MVMTheme.mono(13))
                            .foregroundStyle(MVMTheme.textFaint)
                            .lineLimit(1)
                            .fixedSize()
                    }

                    Text(ratingLabel)
                        .font(.caption.weight(.heavy))
                        .tracking(1.2)
                        .foregroundStyle(passed ? MVMTheme.success : MVMTheme.warning)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background((passed ? MVMTheme.success : MVMTheme.warning).opacity(0.14))
                        .clipShape(Capsule())
                        .lineLimit(1)
                        .fixedSize()
                }
                .padding(18)
                .frame(maxWidth: .infinity)
            }

            AmberButton(title: didSave ? "Saved" : "Save \(programShortName) Result") {
                vm.saveServiceTestRecord(buildRecord())
                didSave = true
            }

            Button {
                shareRecord = buildRecord()
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
                .overlay { RoundedRectangle(cornerRadius: 16).stroke(MVMTheme.hairline, lineWidth: 1) }
                .contentShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    private var graderCard: some View {
        RaisedCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.shield.checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.amber)
                    Text("WHO CAN GRADE THIS")
                        .font(MVMTheme.mono(10))
                        .kerning(1.4)
                        .foregroundStyle(MVMTheme.textFaint)
                }
                Text(graderInfo)
                    .font(.caption)
                    .foregroundStyle(MVMTheme.textMuted)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Local input helpers

private struct SvcInput: View {
    @Binding var text: String
    let suffix: String
    var decimal: Bool = false

    var body: some View {
        InsetWell {
            HStack(spacing: 6) {
                TextField("0", text: $text)
                    .keyboardType(decimal ? .decimalPad : .numberPad)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(MVMTheme.text)
                Spacer(minLength: 0)
                Text(suffix)
                    .font(MVMTheme.mono(10))
                    .foregroundStyle(MVMTheme.textMuted)
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
        }
    }
}

private func chips<T: Hashable>(_ options: [T], selection: Binding<T>, label: @escaping (T) -> String) -> some View {
    InsetWell {
        HStack(spacing: 3) {
            ForEach(options, id: \.self) { opt in
                let selected = selection.wrappedValue == opt
                Text(label(opt))
                    .font(.system(size: 12.5, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(selected ? MVMTheme.onAmber : MVMTheme.textMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(selected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(.clear))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selection.wrappedValue = opt
                        }
                    }
            }
        }
        .padding(3)
    }
}
