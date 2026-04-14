import SwiftUI

struct AFTCalculatorView: View {
    @Environment(AppViewModel.self) private var vm

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
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    soldierInfoCard
                    deadliftEventCard
                    pushUpEventCard
                    sdcEventCard
                    plankEventCard
                    runEventCard
                    totalScoreCard
                    overallPassFailCard
                    actionButtons
                }
                .padding(20)
                .padding(.bottom, 36)
                .adaptiveContainer()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("AFT Calculator")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    normalizeSecondsFields()
                    focusedField = nil
                }
                .fontWeight(.semibold)
            }
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
    }

    // MARK: - Soldier Info

    private var soldierInfoCard: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)

                TextField("Soldier Name", text: $soldierName)
                    .font(.body)
                    .foregroundStyle(MVMTheme.primaryText)
                    .focused($focusedField, equals: .name)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border)
                    }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Age")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)

                    TextField("25", text: $ageText)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .age)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(MVMTheme.cardSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border)
                        }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Sex")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)

                    HStack(spacing: 0) {
                        ForEach(SoldierSex.allCases) { option in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    sex = option
                                }
                            } label: {
                                Text(option.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(sex == option ? .white : MVMTheme.secondaryText)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(sex == option ? MVMTheme.accent : MVMTheme.cardSoft)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Standard")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)

                HStack(spacing: 0) {
                    ForEach(AFTStandard.allCases) { option in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                standard = option
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Text(option.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                Text(option == .combat ? "350 total / 60 each" : "300 total / 60 each")
                                    .font(.caption2)
                                    .opacity(0.7)
                            }
                            .foregroundStyle(standard == option ? .white : MVMTheme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(standard == option ? MVMTheme.accent : MVMTheme.cardSoft)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border)
                }
            }
        }
        .padding(18)
        .premiumCard()
    }

    // MARK: - Event Cards

    private var deadliftEventCard: some View {
        eventCard(
            icon: "figure.strengthtraining.traditional",
            title: "3RM Deadlift",
            abbreviation: "MDL",
            points: deadliftPoints
        ) {
            HStack(spacing: 8) {
                numericField(text: $deadliftText, placeholder: "180", field: .deadlift, width: 100)
                Text("lbs")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)
            }
        }
    }

    private var pushUpEventCard: some View {
        eventCard(
            icon: "figure.core.training",
            title: "Hand-Release Push-Up",
            abbreviation: "HRP",
            points: pushUpPoints
        ) {
            HStack(spacing: 8) {
                numericField(text: $pushUpText, placeholder: "25", field: .pushUp, width: 100)
                Text("reps")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)
            }
        }
    }

    private var sdcEventCard: some View {
        eventCard(
            icon: "figure.run",
            title: "Sprint-Drag-Carry",
            abbreviation: "SDC",
            points: sdcPoints
        ) {
            timeFields(minText: $sdcMinText, secText: $sdcSecText, minField: .sdcMin, secField: .sdcSec)
        }
    }

    private var plankEventCard: some View {
        eventCard(
            icon: "figure.pilates",
            title: "Plank",
            abbreviation: "PLK",
            points: plankPoints
        ) {
            timeFields(minText: $plankMinText, secText: $plankSecText, minField: .plankMin, secField: .plankSec)
        }
    }

    private var runEventCard: some View {
        eventCard(
            icon: "figure.run.circle",
            title: "2-Mile Run",
            abbreviation: "2MR",
            points: runPoints
        ) {
            timeFields(minText: $runMinText, secText: $runSecText, minField: .runMin, secField: .runSec)
        }
    }

    // MARK: - Generic Event Card

    @ViewBuilder
    private func eventCard<Content: View>(
        icon: String,
        title: String,
        abbreviation: String,
        points: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let passed = eventPassed(points)

        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(MVMTheme.accent)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)

                Spacer()

                goNoGoBadge(passed: passed)
            }

            HStack(spacing: 12) {
                content()

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(points)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(pointsColor(points))
                        .contentTransition(.numericText())

                    Text("pts")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            }

            HStack {
                Text(abbreviation)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(Capsule())

                Spacer()

                Text("Min \(standard.minimumPerEvent) pts to pass")
                    .font(.caption2)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
        }
        .padding(16)
        .background(MVMTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(passed ? MVMTheme.success.opacity(0.2) : (points > 0 ? MVMTheme.danger.opacity(0.2) : MVMTheme.border), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.25), radius: 18, y: 10)
    }

    // MARK: - Input Fields

    private func numericField(text: Binding<String>, placeholder: String, field: CalculatorField, width: CGFloat) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(.numberPad)
            .focused($focusedField, equals: field)
            .font(.title3.weight(.bold))
            .foregroundStyle(MVMTheme.primaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .frame(height: 48)
            .frame(maxWidth: width)
            .background(MVMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border)
            }
    }

    private func timeFields(minText: Binding<String>, secText: Binding<String>, minField: CalculatorField, secField: CalculatorField) -> some View {
        HStack(spacing: 6) {
            numericField(text: minText, placeholder: "0", field: minField, width: 70)

            Text(":")
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.secondaryText)

            numericField(text: secText, placeholder: "00", field: secField, width: 70)
        }
    }

    // MARK: - Normalize seconds on dismiss

    private func normalizeSecondsFields() {
        if let s = Int(sdcSecText) { sdcSecText = String(format: "%02d", min(59, max(0, s))) }
        if let s = Int(plankSecText) { plankSecText = String(format: "%02d", min(59, max(0, s))) }
        if let s = Int(runSecText) { runSecText = String(format: "%02d", min(59, max(0, s))) }
    }

    // MARK: - GO / NO-GO Badge

    private func goNoGoBadge(passed: Bool) -> some View {
        Text(passed ? "GO" : "NO GO")
            .font(.caption.weight(.heavy))
            .foregroundStyle(passed ? MVMTheme.success : MVMTheme.danger)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                (passed ? MVMTheme.success : MVMTheme.danger).opacity(0.12)
            )
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke((passed ? MVMTheme.success : MVMTheme.danger).opacity(0.3))
            }
    }

    // MARK: - Total Score

    private var totalScoreCard: some View {
        VStack(spacing: 12) {
            Text("Total Score")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)

            Text("\(totalScore)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(MVMTheme.primaryText)
                .contentTransition(.numericText())

            Text("/ 500")
                .font(.title3.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.top, -12)

            HStack(spacing: 8) {
                scorePill("MDL", deadliftPoints)
                scorePill("HRP", pushUpPoints)
                scorePill("SDC", sdcPoints)
                scorePill("PLK", plankPoints)
                scorePill("2MR", runPoints)
            }
        }
        .padding(18)
        .premiumCard()
    }

    private var overallPassFailCard: some View {
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
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            Spacer()
        }
        .padding(18)
        .premiumCard()
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                normalizeSecondsFields()
                vm.saveAFTCalculatorResult(preview)
                didSave = true
            } label: {
                Text(didSave ? "Saved" : "Save AFT Result")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: MVMTheme.accent.opacity(0.28), radius: 18, y: 10)
            }
            .buttonStyle(PressScaleButtonStyle())
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
                .foregroundStyle(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#4F8CFF"), Color(hex: "#7C5CFF")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ).opacity(0.85)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                normalizeSecondsFields()
                showExportSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                    Text("Export Score Report")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.accent)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(MVMTheme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16).stroke(MVMTheme.accent.opacity(0.3))
                }
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    // MARK: - Helpers

    private func scorePill(_ label: String, _ value: Int) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.secondaryText)
            Text("\(value)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(pointsColor(value))
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border)
        }
    }

    private func pointsColor(_ value: Int) -> Color {
        if value >= standard.minimumPerEvent { return MVMTheme.success }
        if value >= 40 { return MVMTheme.warning }
        return MVMTheme.danger
    }
}
