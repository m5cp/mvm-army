import SwiftUI

struct AFTCalculatorView: View {
    @Environment(AppViewModel.self) private var vm

    @State private var soldierName: String = ""
    @State private var ageText: String = "25"
    @State private var sex: SoldierSex = .male
    @State private var standard: AFTStandard = .combat

    @State private var deadliftLbs: String = "180"
    @State private var pushUpReps: String = "25"
    @State private var sdcMinutes: String = "2"
    @State private var sdcSeconds: String = "00"
    @State private var plankMinutes: String = "2"
    @State private var plankSeconds: String = "00"
    @State private var runMinutes: String = "16"
    @State private var runSeconds: String = "00"

    @State private var didSave = false
    @State private var showSavedResults = false

    private var sdcTotalSeconds: Int {
        (Int(sdcMinutes) ?? 0) * 60 + (Int(sdcSeconds) ?? 0)
    }

    private var plankTotalSeconds: Int {
        (Int(plankMinutes) ?? 0) * 60 + (Int(plankSeconds) ?? 0)
    }

    private var runTotalSeconds: Int {
        (Int(runMinutes) ?? 0) * 60 + (Int(runSeconds) ?? 0)
    }

    private var preview: AFTCalculatorResult {
        AFTCalculatorService.calculate(
            soldierName: soldierName,
            age: Int(ageText) ?? 25,
            sex: sex,
            standard: standard,
            deadliftLbs: Int(deadliftLbs) ?? 0,
            pushUpReps: Int(pushUpReps) ?? 0,
            sdcSeconds: sdcTotalSeconds,
            plankSeconds: plankTotalSeconds,
            runSeconds: runTotalSeconds
        )
    }

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    infoCard
                    soldierInfoCard
                    eventInputs
                    scorePreview
                    passFailCard
                    weakestCard

                    Button {
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
                }
                .padding(20)
                .padding(.bottom, 36)
            }
        }
        .navigationTitle("AFT Calculator")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSavedResults = true
                } label: {
                    Image(systemName: "list.clipboard")
                        .foregroundStyle(MVMTheme.accent)
                }
            }
        }
        .navigationDestination(isPresented: $showSavedResults) {
            AFTSavedResultsView()
        }
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "shield.checkered")
                    .foregroundStyle(MVMTheme.accent)
                Text("AFT Calculator")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }

            Text("Enter soldier info and event results. Scores are calculated using age- and sex-normed AFT scoring tables.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
        }
        .padding(18)
        .premiumCard()
    }

    private var soldierInfoCard: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)

                TextField("Soldier Name", text: $soldierName)
                    .font(.body)
                    .foregroundStyle(MVMTheme.primaryText)
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
                icon: "figure.run.circle",
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

            Text("/ 500")
                .font(.title3.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.top, -12)

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

    private var passFailCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(preview.passed ? MVMTheme.success.opacity(0.18) : MVMTheme.danger.opacity(0.18))
                    .frame(width: 50, height: 50)

                Image(systemName: preview.passed ? "checkmark.shield.fill" : "xmark.shield.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(preview.passed ? MVMTheme.success : MVMTheme.danger)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(preview.passed ? "PASS" : "NO GO")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(preview.passed ? MVMTheme.success : MVMTheme.danger)

                Text("\(standard.rawValue) Standard — Min \(standard.minimumPerEvent) per event, \(standard.minimumTotal) total")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            Spacer()
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
