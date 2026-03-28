import SwiftUI

struct AFTScoreSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var deadliftLbs: String = "180"
    @State private var pushUpReps: String = "25"
    @State private var sdcMinutes: String = "2"
    @State private var sdcSeconds: String = "00"
    @State private var plankMinutes: String = "2"
    @State private var plankSeconds: String = "00"
    @State private var runMinutes: String = "16"
    @State private var runSeconds: String = "00"
    @State private var didSave = false

    private var sdcTotalSeconds: Int {
        (Int(sdcMinutes) ?? 0) * 60 + (Int(sdcSeconds) ?? 0)
    }

    private var plankTotalSeconds: Int {
        (Int(plankMinutes) ?? 0) * 60 + (Int(plankSeconds) ?? 0)
    }

    private var runTotalSeconds: Int {
        (Int(runMinutes) ?? 0) * 60 + (Int(runSeconds) ?? 0)
    }

    private var preview: AFTScoreRecord {
        AFTScoreCalculator.calculate(
            deadliftLbs: Int(deadliftLbs) ?? 0,
            pushUpReps: Int(pushUpReps) ?? 0,
            sdcSeconds: sdcTotalSeconds,
            plankSeconds: plankTotalSeconds,
            runSeconds: runTotalSeconds
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        infoCard
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

            Text("Log your AFT event results to track progress and identify weak events. Scores are estimated — use official scoring tables for record tests.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
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
            Text("Estimated Total")
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
