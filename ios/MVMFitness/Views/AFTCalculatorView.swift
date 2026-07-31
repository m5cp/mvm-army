import SwiftUI

/// Which test the Calculator tab is working with. AFT is the scored
/// five-event test; CFT is the pass/fail seven-event Combat Field Test.
/// (Always "AFT" — never the retired "ACFT" name.)
nonisolated enum FitnessTestKind: String, CaseIterable, Identifiable, Sendable {
    case aft = "AFT"
    case cft = "CFT"
    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .aft: return "5 EVENTS \(MVMTheme.dot) SCORED"
        case .cft: return "7 EVENTS \(MVMTheme.dot) GO/NO-GO"
        }
    }
}

struct AFTCalculatorView: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(StoreViewModel.self) private var store

    @State private var selectedTest: FitnessTestKind = .aft
    @State private var showUpgradeFromGate = false
    @State private var soldierName: String = ""
    @State private var ageText: String = "25"
    @State private var sex: SoldierSex = .male
    @State private var standard: AFTStandard = .combat

    @State private var deadliftText: String = "180"
    @State private var pushUpText: String = "25"
    @State private var sdcMinText: String = "2"
    @State private var sdcSecText: String = "00"
    @State private var plankMinText: String = "2"
    @State private var plankSecText: String = "00"
    @State private var runMinText: String = "16"
    @State private var runSecText: String = "00"

    @State private var didSave = false
    @State private var showExportSheet = false
    @State private var showAFTShareSheet: Bool = false
    @State private var showScoreHistory: Bool = false
    @State private var showResultPDFSheet: Bool = false
    @State private var resultPDFURL: URL?
    @State private var isGeneratingResultPDF: Bool = false
    @FocusState private var focusedField: CalculatorField?

    private enum CalculatorField: Hashable {
        case name, age
        case deadlift, pushUp
        case sdcMin, sdcSec, plankMin, plankSec, runMin, runSec
    }

    private var scoringAge: Int {
        Int(ageText) ?? 25
    }

    private var deadliftLbs: Int {
        Int(deadliftText) ?? 0
    }

    private var pushUpReps: Int {
        Int(pushUpText) ?? 0
    }

    private var sdcTotalSeconds: Int {
        (Int(sdcMinText) ?? 0) * 60 + (Int(sdcSecText) ?? 0)
    }

    private var plankTotalSeconds: Int {
        (Int(plankMinText) ?? 0) * 60 + (Int(plankSecText) ?? 0)
    }

    private var runTotalSeconds: Int {
        (Int(runMinText) ?? 0) * 60 + (Int(runSecText) ?? 0)
    }

    private let engine = AFTScoringEngine.shared

    private var deadliftPoints: Int {
        engine.score(event: .mdl, age: scoringAge, sex: sex, standard: standard, rawValue: deadliftLbs)
    }
    private var pushUpPoints: Int {
        engine.score(event: .hrp, age: scoringAge, sex: sex, standard: standard, rawValue: pushUpReps)
    }
    private var sdcPoints: Int {
        engine.score(event: .sdc, age: scoringAge, sex: sex, standard: standard, rawValue: sdcTotalSeconds)
    }
    private var plankPoints: Int {
        engine.score(event: .plk, age: scoringAge, sex: sex, standard: standard, rawValue: plankTotalSeconds)
    }
    private var runPoints: Int {
        engine.score(event: .run2mi, age: scoringAge, sex: sex, standard: standard, rawValue: runTotalSeconds)
    }

    private var totalScore: Int {
        deadliftPoints + pushUpPoints + sdcPoints + plankPoints + runPoints
    }

    private func eventPassed(_ points: Int) -> Bool {
        points >= standard.minimumPerEvent
    }

    private var allEventsPassed: Bool {
        [deadliftPoints, pushUpPoints, sdcPoints, plankPoints, runPoints].allSatisfy { $0 >= standard.minimumPerEvent }
    }

    private var overallPassed: Bool {
        allEventsPassed && totalScore >= standard.minimumTotal
    }

    /// Delta vs the last SAVED test — nil means no saved history yet (baseline treatment).
    /// Reads only vm.latestAFTScore; no scoring math, plain arithmetic on two engine totals.
    private var deltaVsPrevious: Int? {
        guard let previous = vm.latestAFTScore else { return nil }
        return totalScore - previous.totalScore
    }

    /// Points over the 60-pt minimum per event — arithmetic on engine-produced
    /// points and the standard's own minimumPerEvent constant. No interpolation.
    private var marginsOverMinimum: [(AFTEventType, Int)] {
        [
            (.mdl, deadliftPoints - standard.minimumPerEvent),
            (.hrp, pushUpPoints - standard.minimumPerEvent),
            (.sdc, sdcPoints - standard.minimumPerEvent),
            (.plk, plankPoints - standard.minimumPerEvent),
            (.run2mi, runPoints - standard.minimumPerEvent)
        ]
    }

    private var preview: AFTCalculatorResult {
        let eventScores: [(String, Int)] = [
            ("MDL", deadliftPoints), ("HRP", pushUpPoints), ("SDC", sdcPoints),
            ("PLK", plankPoints), ("2MR", runPoints)
        ]
        let weakest = eventScores.sorted { $0.1 < $1.1 }.prefix(2).map(\.0)

        return AFTCalculatorResult(
            soldierName: soldierName,
            age: scoringAge,
            sex: sex,
            standard: standard,
            deadliftLbs: deadliftLbs,
            pushUpReps: pushUpReps,
            sdcSeconds: sdcTotalSeconds,
            plankSeconds: plankTotalSeconds,
            runSeconds: runTotalSeconds,
            deadliftPoints: deadliftPoints,
            pushUpPoints: pushUpPoints,
            sdcPoints: sdcPoints,
            plankPoints: plankPoints,
            runPoints: runPoints,
            totalScore: totalScore,
            passed: overallPassed,
            weakestEvents: weakest
        )
    }

    var body: some View {
        ZStack {
            MVMTheme.screen.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    testPicker

                    if selectedTest == .aft {
                        if let error = engine.loadError {
                            scoringUnavailableBanner(error)
                        }
                        soldierInfoCard
                        deadliftEventRow
                        pushUpEventRow
                        sdcEventRow
                        plankEventRow
                        runEventRow
                        totalScoreCard
                        marginOverMinimumCard
                        overallPassFailCard
                        actionButtons
                    } else {
                        CFTContent()
                    }
                }
                .padding(20)
                .padding(.bottom, 36)
                .adaptiveContainer()
            }
            .scrollDismissesKeyboard(.interactively)
            .hidesTabBarOnScroll()
        }
        .sensoryFeedback(.success, trigger: didSave)
        .onAppear { prefillFromLastScore() }
        .navigationTitle(selectedTest == .aft ? "AFT Calculator" : "Combat Field Test")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.screen, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            if selectedTest == .aft {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showScoreHistory = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                    .accessibilityLabel("Saved AFT Scores")
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    normalizeSecondsFields()
                    focusedField = nil
                }
                .fontWeight(.semibold)
            }
        }
        .sheet(isPresented: $showScoreHistory) {
            AFTScoreSheet()
        }
        .sheet(isPresented: $showAFTShareSheet) {
            AFTShareSheet(score: AFTScoreRecord(
                deadliftLbs: preview.deadliftLbs,
                pushUpReps: preview.pushUpReps,
                sdcSeconds: preview.sdcSeconds,
                plankSeconds: preview.plankSeconds,
                runSeconds: preview.runSeconds,
                deadliftPoints: preview.deadliftPoints,
                pushUpPoints: preview.pushUpPoints,
                sdcPoints: preview.sdcPoints,
                plankPoints: preview.plankPoints,
                runPoints: preview.runPoints,
                totalScore: preview.totalScore,
                weakestEvents: preview.weakestEvents
            ), previous: vm.previousAFTScore)
        }
        .sheet(isPresented: $showExportSheet) {
            DAForm705ExportView(result: preview)
        }
        .sheet(isPresented: $showResultPDFSheet) {
            if let url = resultPDFURL {
                ShareSheet(items: [url])
            }
        }
        .sheet(isPresented: $showUpgradeFromGate) {
            UpgradeView()
        }
    }

    // MARK: - Test Picker (AFT / CFT)

    /// Lets the user choose which test they're taking. Mirrors the styling of
    /// the STANDARD toggle so it reads as part of the same spec sheet.
    private var testPicker: some View {
        InsetWell {
            HStack(spacing: 3) {
                ForEach(FitnessTestKind.allCases) { kind in
                    let selected = selectedTest == kind
                    VStack(spacing: 2) {
                        Text(kind.rawValue)
                            .font(.system(size: 15, weight: .bold))
                        Text(kind.subtitle)
                            .font(.system(size: 9, weight: .semibold))
                            .opacity(0.75)
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .foregroundStyle(selected ? MVMTheme.onAmber : MVMTheme.textMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(selected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(.clear))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTest = kind
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(kind == .aft ? "Army Fitness Test, five scored events" : "Combat Field Test, seven events, go or no go")
                    .accessibilityAddTraits(selected ? [.isButton, .isSelected] : [.isButton])
                }
            }
            .padding(3)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Choose test")
    }

    // MARK: - Scoring Unavailable Banner

    private func scoringUnavailableBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.body.weight(.bold))
                .foregroundStyle(MVMTheme.warning)

            VStack(alignment: .leading, spacing: 4) {
                Text("Scoring Unavailable")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.text)
                Text("\(message) Scores will show as 0 until this is fixed. Your inputs are still saved.")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.textMuted)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(MVMTheme.warning.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(MVMTheme.warning.opacity(0.3))
        }
    }

    // MARK: - Soldier Info (sex / age / standard — always visible)

    private var soldierInfoCard: some View {
        RaisedCard {
            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("NAME")
                        .font(MVMTheme.mono(10))
                        .kerning(1.2)
                        .foregroundStyle(MVMTheme.textFaint)

                    InsetWell {
                        TextField("Soldier Name", text: $soldierName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(MVMTheme.text)
                            .focused($focusedField, equals: .name)
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                    }
                }

                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Text("AGE")
                                .font(MVMTheme.mono(10))
                                .kerning(1.2)
                                .foregroundStyle(MVMTheme.textFaint)
                            Text("· BAND \(AFTScoringEngine.ageBand(from: scoringAge))")
                                .font(MVMTheme.mono(9))
                                .foregroundStyle(MVMTheme.textFaint)
                                .lineLimit(1)
                                .fixedSize()
                        }

                        InsetWell {
                            TextField("25", text: $ageText)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .age)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(MVMTheme.text)
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("SEX")
                            .font(MVMTheme.mono(10))
                            .kerning(1.2)
                            .foregroundStyle(MVMTheme.textFaint)

                        segmentedToggle(SoldierSex.allCases, selection: $sex, height: 48, accessibilityLabel: "Sex") { $0.rawValue }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("STANDARD")
                        .font(MVMTheme.mono(10))
                        .kerning(1.2)
                        .foregroundStyle(MVMTheme.textFaint)

                    InsetWell {
                        HStack(spacing: 3) {
                            ForEach(AFTStandard.allCases) { option in
                                let selected = standard == option
                                VStack(spacing: 2) {
                                    Text(option.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(option == .combat ? "350 TOTAL \(MVMTheme.dot) 60 EACH" : "300 TOTAL \(MVMTheme.dot) 60 EACH")
                                        .font(.system(size: 9, weight: .semibold))
                                        .opacity(0.75)
                                        .lineLimit(1)
                                        .fixedSize()
                                }
                                .foregroundStyle(selected ? MVMTheme.onAmber : MVMTheme.textMuted)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(selected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(.clear))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        standard = option
                                    }
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("\(option.rawValue) standard, \(option == .combat ? "350 total, 60 minimum each event" : "300 total, 60 minimum each event")")
                                .accessibilityAddTraits(selected ? [.isButton, .isSelected] : [.isButton])
                            }
                        }
                        .padding(3)
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Standard")
                }
            }
            .padding(16)
        }
    }

    private func segmentedToggle<T: Hashable>(_ options: [T], selection: Binding<T>, height: CGFloat, accessibilityLabel: String, label: @escaping (T) -> String) -> some View {
        InsetWell {
            HStack(spacing: 3) {
                ForEach(options, id: \.self) { opt in
                    let selected = selection.wrappedValue == opt
                    Text(label(opt))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(selected ? MVMTheme.onAmber : MVMTheme.textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: height - 6)
                        .background(selected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(.clear))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selection.wrappedValue = opt
                            }
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(label(opt))
                        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : [.isButton])
                }
            }
            .padding(3)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Event Rows (spec-sheet: chip · title + min/max refs · points, then input well)

    private var deadliftEventRow: some View {
        eventRow(event: .mdl, title: "3-Rep Max Deadlift", points: deadliftPoints) {
            valueWell(text: $deadliftText, placeholder: "180", field: .deadlift, suffix: "LB")
        }
    }

    private var pushUpEventRow: some View {
        eventRow(event: .hrp, title: "Hand-Release Push-Up", points: pushUpPoints) {
            valueWell(text: $pushUpText, placeholder: "25", field: .pushUp, suffix: "REPS")
        }
    }

    private var sdcEventRow: some View {
        eventRow(event: .sdc, title: "Sprint-Drag-Carry", points: sdcPoints) {
            timeWell(minText: $sdcMinText, secText: $sdcSecText, minField: .sdcMin, secField: .sdcSec)
        }
    }

    private var plankEventRow: some View {
        eventRow(event: .plk, title: "Plank", points: plankPoints) {
            timeWell(minText: $plankMinText, secText: $plankSecText, minField: .plankMin, secField: .plankSec)
        }
    }

    private var runEventRow: some View {
        eventRow(event: .run2mi, title: "2-Mile Run", points: runPoints) {
            timeWell(minText: $runMinText, secText: $runSecText, minField: .runMin, secField: .runSec)
        }
    }

    // MARK: - Generic Event Row

    @ViewBuilder
    private func eventRow<Content: View>(
        event: AFTEventType,
        title: String,
        points: Int,
        @ViewBuilder input: () -> Content
    ) -> some View {
        RaisedCard {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    EventPhotoChip(event: event)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(MVMTheme.text)
                            .lineLimit(1)

                        Text(referenceLabel(for: event))
                            .font(MVMTheme.mono(10))
                            .kerning(0.4)
                            .foregroundStyle(MVMTheme.textMuted)
                            .lineLimit(1)
                            .fixedSize()
                    }

                    Spacer(minLength: 8)

                    Text("\(points)")
                        .font(MVMTheme.scoreDisplay(28))
                        .foregroundStyle(pointsColor(points))
                        .contentTransition(.numericText())
                        .lineLimit(1)
                        .fixedSize()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(eventRowAccessibilityLabel(event: event, title: title, points: points))

                input()
            }
            .padding(14)
        }
    }

    /// Builds the combined VoiceOver announcement for one event row, e.g.
    /// "Deadlift, 300 pounds, 87 points, minimum 140, maximum 340."
    private func eventRowAccessibilityLabel(event: AFTEventType, title: String, points: Int) -> String {
        let min60 = engine.rawNeeded(event: event, age: scoringAge, sex: sex, standard: standard, targetPoints: 60)
        let max100 = engine.rawNeeded(event: event, age: scoringAge, sex: sex, standard: standard, targetPoints: 100)
        let minStr = min60.map { spokenRaw(event, $0) } ?? "unavailable"
        let maxStr = max100.map { spokenRaw(event, $0) } ?? "unavailable"
        let currentStr = spokenRaw(event, currentRawValue(for: event))
        return "\(title), \(currentStr), \(points) points, minimum \(minStr), maximum \(maxStr)"
    }

    private func currentRawValue(for event: AFTEventType) -> Int {
        switch event {
        case .mdl: return deadliftLbs
        case .hrp: return pushUpReps
        case .sdc: return sdcTotalSeconds
        case .plk: return plankTotalSeconds
        case .run2mi: return runTotalSeconds
        }
    }

    private func spokenRaw(_ event: AFTEventType, _ v: Int) -> String {
        switch event {
        case .mdl: return "\(v) pounds"
        case .hrp: return "\(v) reps"
        case .sdc, .plk, .run2mi:
            return "\(v / 60) minutes \(v % 60) seconds"
        }
    }

    // MARK: - Input wells

    private func valueWell(text: Binding<String>, placeholder: String, field: CalculatorField, suffix: String) -> some View {
        InsetWell {
            HStack(spacing: 6) {
                TextField(placeholder, text: text)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: field)
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

    private func timeWell(minText: Binding<String>, secText: Binding<String>, minField: CalculatorField, secField: CalculatorField) -> some View {
        InsetWell {
            HStack(spacing: 4) {
                TextField("0", text: minText)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: minField)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(MVMTheme.text)
                    .multilineTextAlignment(.trailing)
                Text(":")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(MVMTheme.textMuted)
                TextField("00", text: secText)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: secField)
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

    // MARK: - Min/Max references (from AFTScoringEngine.rawNeeded — never computed here)

    private func referenceLabel(for event: AFTEventType) -> String {
        let min60 = engine.rawNeeded(event: event, age: scoringAge, sex: sex, standard: standard, targetPoints: 60)
        let max100 = engine.rawNeeded(event: event, age: scoringAge, sex: sex, standard: standard, targetPoints: 100)
        let minStr = min60.map { formatRaw(event, $0) } ?? "—"
        let maxStr = max100.map { formatRaw(event, $0) } ?? "—"
        return "60 PT \(minStr) \(MVMTheme.dot) 100 PT \(maxStr)"
    }

    private func formatRaw(_ event: AFTEventType, _ v: Int) -> String {
        switch event {
        case .mdl: return "\(v) LB"
        case .hrp: return "\(v) REPS"
        case .sdc, .plk, .run2mi:
            return "\(v / 60):" + String(format: "%02d", v % 60)
        }
    }

    // MARK: - Normalize seconds on dismiss

    private func normalizeSecondsFields() {
        if let s = Int(sdcSecText) { sdcSecText = String(format: "%02d", min(59, max(0, s))) }
        if let s = Int(plankSecText) { plankSecText = String(format: "%02d", min(59, max(0, s))) }
        if let s = Int(runSecText) { runSecText = String(format: "%02d", min(59, max(0, s))) }
    }

    // MARK: - Total Score

    private var totalScoreCard: some View {
        RaisedCard {
            VStack(spacing: 14) {
                Text("TOTAL SCORE")
                    .font(MVMTheme.mono(11))
                    .kerning(1.4)
                    .foregroundStyle(MVMTheme.textFaint)

                TotalScoreGauge(
                    total: totalScore,
                    minimumToPass: standard.minimumTotal,
                    passed: overallPassed
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(totalScoreAccessibilityLabel)

                if let delta = deltaVsPrevious {
                    Text((delta >= 0 ? "+" : "\u{2212}") + "\(abs(delta)) VS LAST")
                        .font(MVMTheme.mono(11))
                        .kerning(1)
                        .foregroundStyle(delta >= 0 ? MVMTheme.amber : MVMTheme.textMuted)
                        .lineLimit(1)
                        .fixedSize()
                } else {
                    Text("BASELINE \(MVMTheme.dot) EVERYTHING COMPARES BACK TO TODAY")
                        .font(MVMTheme.mono(10))
                        .kerning(1)
                        .foregroundStyle(MVMTheme.textMuted)
                        .lineLimit(1)
                        .fixedSize()
                }

                HStack(spacing: 8) {
                    scorePill(.mdl, deadliftPoints)
                    scorePill(.hrp, pushUpPoints)
                    scorePill(.sdc, sdcPoints)
                    scorePill(.plk, plankPoints)
                    scorePill(.run2mi, runPoints)
                }
            }
            .padding(18)
        }
    }

    /// "Total score 340, pass, 10 points above the 330 minimum" style announcement.
    private var totalScoreAccessibilityLabel: String {
        let statusWord = overallPassed ? "pass" : "fail"
        let margin = totalScore - standard.minimumTotal
        let marginPhrase = margin >= 0
            ? "\(margin) points above the \(standard.minimumTotal) minimum"
            : "\(abs(margin)) points below the \(standard.minimumTotal) minimum"
        return "Total score \(totalScore), \(statusWord), \(marginPhrase)"
    }

    // MARK: - Margin Over Minimum (plaque table — 10c/10d)

    private var marginOverMinimumCard: some View {
        RaisedCard {
            VStack(spacing: 0) {
                ForEach(Array(marginsOverMinimum.enumerated()), id: \.offset) { index, pair in
                    let (event, margin) = pair
                    HStack(spacing: 12) {
                        EventTagChip(event: event)
                        Text("OVER MINIMUM")
                            .font(MVMTheme.mono(10))
                            .kerning(1.2)
                            .foregroundStyle(MVMTheme.textFaint)
                        Spacer()
                        Text((margin >= 0 ? "+" : "\u{2212}") + "\(abs(margin))")
                            .font(MVMTheme.scoreDisplay(22))
                            .foregroundStyle(margin >= 0 ? MVMTheme.amber : MVMTheme.danger)
                            .contentTransition(.numericText())
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 58)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(event.fullName), \(margin >= 0 ? "\(margin) points over the minimum" : "\(abs(margin)) points under the minimum")")
                    if index < marginsOverMinimum.count - 1 {
                        Divider().overlay(MVMTheme.hairline)
                    }
                }
            }
        }
    }

    private var overallPassFailCard: some View {
        RaisedCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(overallPassed ? MVMTheme.success.opacity(0.18) : MVMTheme.danger.opacity(0.18))
                        .frame(width: 50, height: 50)

                    Image(systemName: overallPassed ? "checkmark.shield.fill" : "xmark.shield.fill")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(overallPassed ? MVMTheme.success : MVMTheme.danger)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(overallPassed ? "GO" : "NO GO")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(overallPassed ? MVMTheme.success : MVMTheme.danger)

                    Text(standard == .combat
                         ? "Combat — 350 total / 60 each"
                         : "General — 300 total / 60 each")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.textMuted)
                }

                Spacer()
            }
            .padding(18)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(overallPassed ? "Go" : "No go"), \(standard == .combat ? "Combat standard, 350 total, 60 minimum each event" : "General standard, 300 total, 60 minimum each event")")
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            AmberButton(title: didSave ? "Saved" : "Save AFT Result") {
                normalizeSecondsFields()
                vm.saveAFTCalculatorResult(preview)
                didSave = true
            }
            .sensoryFeedback(.success, trigger: didSave)

            Button {
                normalizeSecondsFields()
                showAFTShareSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share AFT Score")
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
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                normalizeSecondsFields()
                if ProGate.isUnlocked(.da705Export, isPremium: store.isPremium) {
                    showExportSheet = true
                } else {
                    showUpgradeFromGate = true
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                    Text("Export Score Report")
                    if !store.isPremium {
                        Text("PRO")
                            .font(.caption2.weight(.heavy))
                            .tracking(0.5)
                            .foregroundStyle(MVMTheme.onAmber)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(MVMTheme.amberButtonGradient)
                            .clipShape(Capsule())
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.amber)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(MVMTheme.amber.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16).stroke(MVMTheme.amber.opacity(0.3))
                }
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                normalizeSecondsFields()
                generateAndShareResultPDF()
            } label: {
                HStack(spacing: 8) {
                    if isGeneratingResultPDF {
                        ProgressView().tint(MVMTheme.text)
                    } else {
                        Image(systemName: "doc.plaintext")
                    }
                    Text(isGeneratingResultPDF ? "Preparing PDF…" : "Share Result PDF")
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
            }
            .buttonStyle(PressScaleButtonStyle())
            .disabled(isGeneratingResultPDF)
        }
    }

    /// Renders the compact result-plaque PDF (total + margin table) from the
    /// on-screen preview and presents the system share sheet. All figures come
    /// from `preview`, itself built entirely from `AFTScoringEngine` output.
    private func generateAndShareResultPDF() {
        isGeneratingResultPDF = true
        let previousTotal = vm.latestAFTScore?.totalScore
        Task {
            guard let data = AFTResultPDFService.generatePDF(from: preview, previousTotal: previousTotal),
                  let url = AFTResultPDFService.savePDFToTemp(data: data, soldierName: soldierName) else {
                isGeneratingResultPDF = false
                return
            }
            resultPDFURL = url
            showResultPDFSheet = true
            isGeneratingResultPDF = false
        }
    }

    // MARK: - Helpers

    private func scorePill(_ event: AFTEventType, _ value: Int) -> some View {
        VStack(spacing: 4) {
            Text(event.displayCode)
                .font(MVMTheme.mono(9.5, weight: .bold))
                .foregroundStyle(MVMTheme.textMuted)
            Text("\(value)")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(pointsColor(value))
                .contentTransition(.numericText())
                .lineLimit(1)
                .fixedSize()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(MVMTheme.well)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func pointsColor(_ value: Int) -> Color {
        if value >= standard.minimumPerEvent { return MVMTheme.success }
        if value >= 40 { return MVMTheme.warning }
        if value > 0 { return MVMTheme.danger }
        return MVMTheme.textFaint
    }

    /// Pre-fill inputs from the user's last saved score so re-testing takes seconds
    /// (pattern from the best-rated logging apps: never make the user re-enter knowns).
    private func prefillFromLastScore() {
        guard let last = vm.aftScores.first else { return }
        // Only prefill if the user hasn't already typed custom values this session
        guard deadliftText == "180", pushUpText == "25" else { return }
        deadliftText = String(last.deadliftLbs)
        pushUpText = String(last.pushUpReps)
        sdcMinText = String(last.sdcSeconds / 60); sdcSecText = String(format: "%02d", last.sdcSeconds % 60)
        plankMinText = String(last.plankSeconds / 60); plankSecText = String(format: "%02d", last.plankSeconds % 60)
        runMinText = String(last.runSeconds / 60); runSecText = String(format: "%02d", last.runSeconds % 60)
    }
}
