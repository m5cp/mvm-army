import SwiftUI

struct AFTScoreSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var ageText: String = "25"
    @State private var sex: SoldierSex = .male
    @State private var standard: AFTStandard = .general
    @State private var deadliftLbs: String = "180"
    @State private var pushUpReps: String = "25"
    @State private var sdcMinutes: String = "2"
    @State private var sdcSeconds: String = "00"
    @State private var plankMinutes: String = "2"
    @State private var plankSeconds: String = "00"
    @State private var runMinutes: String = "16"
    @State private var runSeconds: String = "00"
    @State private var didSave = false

    private var scoringAge: Int {
        Int(ageText) ?? 25
    }

    private var sdcTotalSeconds: Int {
        (Int(sdcMinutes) ?? 0) * 60 + (Int(sdcSeconds) ?? 0)
    }

    private var plankTotalSeconds: Int {
        (Int(plankMinutes) ?? 0) * 60 + (Int(plankSeconds) ?? 0)
    }

    private var runTotalSeconds: Int {
        (Int(runMinutes) ?? 0) * 60 + (Int(runSeconds) ?? 0)
    }

    private var dlPts: Int { AFTScoringTables.scoreDeadlift(lbs: Int(deadliftLbs) ?? 0, age: scoringAge, sex: sex, standard: standard) }
    private var puPts: Int { AFTScoringTables.scorePushUp(reps: Int(pushUpReps) ?? 0, age: scoringAge, sex: sex, standard: standard) }
    private var sdcPts: Int { AFTScoringTables.scoreSDC(seconds: sdcTotalSeconds, age: scoringAge, sex: sex, standard: standard) }
    private var plkPts: Int { AFTScoringTables.scorePlank(seconds: plankTotalSeconds, age: scoringAge, sex: sex, standard: standard) }
    private var runPts: Int { AFTScoringTables.scoreRun(seconds: runTotalSeconds, age: scoringAge, sex: sex, standard: standard) }
    private var totalScore: Int { dlPts + puPts + sdcPts + plkPts + runPts }

    private var preview: AFTScoreRecord {
        let pairs: [(String, Int)] = [("MDL", dlPts), ("HRP", puPts), ("SDC", sdcPts), ("PLK", plkPts), ("2MR", runPts)]
        let weakest = pairs.sorted { $0.1 < $1.1 }.prefix(2).map(\.0)
        return AFTScoreRecord(
            deadliftLbs: Int(deadliftLbs) ?? 0,
            pushUpReps: Int(pushUpReps) ?? 0,
            sdcSeconds: sdcTotalSeconds,
            plankSeconds: plankTotalSeconds,
            runSeconds: runTotalSeconds,
            deadliftPoints: dlPts,
            pushUpPoints: puPts,
            sdcPoints: sdcPts,
            plankPoints: plkPts,
            runPoints: runPts,
            totalScore: totalScore,
            weakestEvents: weakest
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        infoCard
                        soldierInfoCard
                        eventInputs
                        scorePreview
                        weakestCard

                        Button {
                            vm.saveAFTScore(preview)
                            didSave = true
                        } label: {
                            Text(didSave ? "Saved" : "Save AFT Score")
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
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("AFT Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "shield.fill")
                    .foregroundStyle(MVMTheme.accent)
                Text("Army Fitness Test")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }

            Text("Log your AFT event results to track progress and identify weak events. Scores use age- and sex-normed AFT tables.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
        }
        .padding(18)
        .premiumCard()
    }

    private var soldierInfoCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Age")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)

                    TextField("25", text: $ageText)
                        .keyboardType(.numberPad)
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
                                Text("Min \(option.minimumPerEvent)/evt")
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

    private var eventInputs: some View {
        VStack(spacing: 14) {
            eventField(
                icon: "figure.strengthtraining.traditional",
                title: "3RM Deadlift",
                abbreviation: "MDL"
            ) {
                HStack(spacing: 8) {
                    numericInput(text: $deadliftLbs, placeholder: "180")
                    Text("lbs")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }

            eventField(
                icon: "figure.core.training",
                title: "Hand-Release Push-Up",
                abbreviation: "HRP"
            ) {
                HStack(spacing: 8) {
                    numericInput(text: $pushUpReps, placeholder: "25")
                    Text("reps")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }

            eventField(
                icon: "figure.run",
                title: "Sprint-Drag-Carry",
                abbreviation: "SDC"
            ) {
                timeInput(minutes: $sdcMinutes, seconds: $sdcSeconds)
            }

            eventField(
                icon: "figure.pilates",
                title: "Plank",
                abbreviation: "PLK"
            ) {
                timeInput(minutes: $plankMinutes, seconds: $plankSeconds)
            }

            eventField(
                icon: "figure.outdoor.cycle",
                title: "2-Mile Run",
                abbreviation: "2MR"
            ) {
                timeInput(minutes: $runMinutes, seconds: $runSeconds)
            }
        }
        .padding(18)
        .premiumCard()
    }

    private var scorePreview: some View {
        VStack(spacing: 16) {
            Text("Total Score")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)

            Text("\(preview.totalScore)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(MVMTheme.primaryText)
                .contentTransition(.numericText())

            HStack(spacing: 8) {
                scorePill("MDL", preview.deadliftPoints)
                scorePill("HRP", preview.pushUpPoints)
                scorePill("SDC", preview.sdcPoints)
                scorePill("PLK", preview.plankPoints)
                scorePill("2MR", preview.runPoints)
            }
        }
        .padding(18)
        .premiumCard()
    }

    private var weakestCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(MVMTheme.warning)
                Text("Weakest Events")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }

            Text(preview.weakestEvents.joined(separator: " and "))
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)

            Text("Focus training on these events to improve your total score.")
                .font(.caption)
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .padding(18)
        .premiumCard()
    }

    @ViewBuilder
    private func eventField<Content: View>(
        icon: String,
        title: String,
        abbreviation: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(MVMTheme.accent)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)

                Spacer()

                Text(abbreviation)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(Capsule())
            }

            content()
        }
        .padding(14)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(MVMTheme.border)
        }
    }

    private func numericInput(text: Binding<String>, placeholder: String) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(.numberPad)
            .font(.title3.weight(.bold))
            .foregroundStyle(MVMTheme.primaryText)
            .padding(.horizontal, 12)
            .frame(height: 48)
            .frame(maxWidth: 100)
            .background(MVMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border)
            }
    }

    private func timeInput(minutes: Binding<String>, seconds: Binding<String>) -> some View {
        HStack(spacing: 6) {
            numericInput(text: minutes, placeholder: "0")
            Text(":")
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.secondaryText)
            numericInput(text: seconds, placeholder: "00")
        }
    }

    private func scorePill(_ label: String, _ value: Int) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.secondaryText)
            Text("\(value)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(pillColor(value))
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

    private func pillColor(_ value: Int) -> Color {
        if value >= 80 { return MVMTheme.success }
        if value >= 60 { return MVMTheme.accent }
        if value >= 40 { return MVMTheme.warning }
        return MVMTheme.danger
    }
}
