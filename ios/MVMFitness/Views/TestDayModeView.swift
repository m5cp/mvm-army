import SwiftUI
import UIKit
import AVFoundation

/// Test Day Mode — a guided, full-screen proctor flow for running an actual
/// AFT: event-by-event with a big stopwatch, voice announcements, raw-score
/// entry as you go, live points from `AFTScoringEngine` (never computed here),
/// and an auto-saved result with the share card at the end.
struct TestDayModeView: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    // Locked in from the calculator before the test starts.
    let soldierName: String
    let age: Int
    let sex: SoldierSex
    let standard: AFTStandard

    private enum Phase: Equatable {
        case briefing
        case event(Int)
        case summary
    }

    private static let events: [AFTEventType] = [.mdl, .hrp, .sdc, .plk, .run2mi]

    @State private var phase: Phase = .briefing
    @State private var voiceOn: Bool = true
    @State private var speech = AVSpeechSynthesizer()

    // Stopwatch
    @State private var stopwatchRunning = false
    @State private var stopwatchStart: Date?
    @State private var stopwatchSeconds: Int = 0
    @State private var timer: Timer?

    // Raw results per event
    @State private var deadliftText = ""
    @State private var pushUpText = ""
    @State private var sdcSeconds: Int = 0
    @State private var plankSeconds: Int = 0
    @State private var runSeconds: Int = 0

    @State private var startTrigger = false
    @State private var stopTrigger = false
    @State private var didSave = false
    @State private var showShare = false

    private let engine = AFTScoringEngine.shared

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.screen.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        switch phase {
                        case .briefing: briefingContent
                        case .event(let index): eventContent(index)
                        case .summary: summaryContent
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                    .adaptiveContainer()
                }
            }
            .navigationTitle("Test Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MVMTheme.screen, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Exit") { endAndDismiss() }
                        .foregroundStyle(MVMTheme.textMuted)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        voiceOn.toggle()
                    } label: {
                        Image(systemName: voiceOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(voiceOn ? MVMTheme.amber : MVMTheme.textFaint)
                    }
                    .accessibilityLabel(voiceOn ? "Voice announcements on" : "Voice announcements off")
                }
            }
            .sensoryFeedback(.impact(weight: .heavy), trigger: startTrigger)
            .sensoryFeedback(.success, trigger: stopTrigger)
            .sheet(isPresented: $showShare) {
                AFTShareSheet(score: builtScoreRecord, previous: vm.previousAFTScore)
            }
            .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
                timer?.invalidate()
            }
        }
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled(phase != .briefing)
    }

    // MARK: - Briefing

    private var briefingContent: some View {
        VStack(spacing: 18) {
            RaisedCard(radius: 22) {
                ZStack(alignment: .bottomLeading) {
                    GradedPhoto(name: "hero-runner-dusk", grade: .heroDuotone)
                        .frame(height: 180)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("ARMY FITNESS TEST")
                            .font(MVMTheme.mono(11))
                            .kerning(2)
                            .foregroundStyle(MVMTheme.amber)
                        Text("Test Day.")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(MVMTheme.text)
                    }
                    .padding(16)
                }
            }

            RaisedCard {
                VStack(alignment: .leading, spacing: 12) {
                    infoLine(icon: "person.fill", text: soldierName.isEmpty ? "Soldier" : soldierName)
                    infoLine(icon: "number", text: "Age \(age) \(MVMTheme.dot) \(sex.rawValue) \(MVMTheme.dot) \(standard.rawValue) standard")
                    infoLine(icon: "list.number", text: "5 events in order: MDL \(MVMTheme.dot) HRP \(MVMTheme.dot) SDC \(MVMTheme.dot) PLK \(MVMTheme.dot) 2MR")
                    infoLine(icon: "timer", text: "Timed events use the built-in stopwatch — times drop straight into your score")
                    infoLine(icon: "speaker.wave.2", text: "Voice announcements guide each event (toggle top-right)")
                    infoLine(icon: "sun.max.fill", text: "Screen stays awake for the whole test")
                }
                .padding(18)
            }

            AmberButton(title: "Begin Test") {
                startTrigger.toggle()
                phase = .event(0)
                announce("Test day. First event: three repetition maximum deadlift. Load the bar, then enter your heaviest successful weight.")
            }
        }
    }

    private func infoLine(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(MVMTheme.amber)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.textMuted)
        }
    }

    // MARK: - Event flow

    private func eventContent(_ index: Int) -> some View {
        let event = Self.events[index]

        return VStack(spacing: 16) {
            // Progress dots
            HStack(spacing: 6) {
                ForEach(0..<Self.events.count, id: \.self) { i in
                    Capsule()
                        .fill(i < index ? MVMTheme.success : i == index ? MVMTheme.amber : MVMTheme.well)
                        .frame(height: 4)
                }
            }

            RaisedCard(radius: 20) {
                VStack(spacing: 10) {
                    EventPhotoChip(event: event)
                        .scaleEffect(1.6)
                        .padding(.top, 20)

                    Text("EVENT \(index + 1) OF \(Self.events.count)")
                        .font(MVMTheme.mono(10))
                        .kerning(1.6)
                        .foregroundStyle(MVMTheme.textFaint)
                        .padding(.top, 14)

                    Text(eventTitle(event))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(MVMTheme.text)
                        .multilineTextAlignment(.center)

                    Text(eventInstruction(event))
                        .font(.caption)
                        .foregroundStyle(MVMTheme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 18)
                }
                .frame(maxWidth: .infinity)
            }

            if isTimedEvent(event) {
                stopwatchCard(for: event)
            } else {
                repEntryCard(for: event)
            }

            // Live points from the engine only.
            RaisedCard {
                HStack {
                    Text("POINTS")
                        .font(MVMTheme.mono(10))
                        .kerning(1.4)
                        .foregroundStyle(MVMTheme.textFaint)
                    Spacer()
                    Text("\(points(for: event))")
                        .font(MVMTheme.scoreDisplay(34))
                        .foregroundStyle(points(for: event) >= standard.minimumPerEvent ? MVMTheme.success : MVMTheme.danger)
                        .contentTransition(.numericText())
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
            }

            AmberButton(title: index == Self.events.count - 1 ? "Finish Test" : "Next Event") {
                stopTrigger.toggle()
                stopStopwatch(save: false)
                if index == Self.events.count - 1 {
                    phase = .summary
                    announce("Test complete. Total score \(totalScore). \(overallPassed ? "Go." : "No go.")")
                } else {
                    let next = Self.events[index + 1]
                    phase = .event(index + 1)
                    resetStopwatch()
                    announce("Next event: \(spokenName(next)). \(isTimedEvent(next) ? "Start the clock when the event begins." : "Enter your result when complete.")")
                }
            }
        }
    }

    private func stopwatchCard(for event: AFTEventType) -> some View {
        RaisedCard {
            VStack(spacing: 14) {
                Text(String(format: "%d:%02d", stopwatchSeconds / 60, stopwatchSeconds % 60))
                    .font(.system(size: 64, weight: .heavy, design: .monospaced))
                    .foregroundStyle(MVMTheme.text)
                    .contentTransition(.numericText())

                HStack(spacing: 12) {
                    Button {
                        if stopwatchRunning {
                            stopTrigger.toggle()
                            stopStopwatch(save: true, event: event)
                            announce("Time recorded.")
                        } else {
                            startTrigger.toggle()
                            startStopwatch()
                            announce("Go.")
                        }
                    } label: {
                        Text(stopwatchRunning ? "Stop" : "Start")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(stopwatchRunning ? Color.white : MVMTheme.onAmber)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(stopwatchRunning ? AnyShapeStyle(MVMTheme.danger) : AnyShapeStyle(MVMTheme.amberButtonGradient))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .contentShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }

                // Manual adjust (proctor kept official time on a wristwatch, etc.)
                HStack(spacing: 8) {
                    Text("RECORDED")
                        .font(MVMTheme.mono(9))
                        .kerning(1.2)
                        .foregroundStyle(MVMTheme.textFaint)
                    Spacer()
                    Text(String(format: "%d:%02d", recordedSeconds(for: event) / 60, recordedSeconds(for: event) % 60))
                        .font(MVMTheme.mono(14, weight: .bold))
                        .foregroundStyle(MVMTheme.amber)
                    Stepper("", onIncrement: { adjustSeconds(for: event, by: 1) },
                            onDecrement: { adjustSeconds(for: event, by: -1) })
                        .labelsHidden()
                        .tint(MVMTheme.amber)
                }
            }
            .padding(18)
        }
    }

    private func repEntryCard(for event: AFTEventType) -> some View {
        RaisedCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(event == .mdl ? "WEIGHT LIFTED" : "REPS COMPLETED")
                    .font(MVMTheme.mono(10))
                    .kerning(1.4)
                    .foregroundStyle(MVMTheme.textFaint)

                InsetWell {
                    HStack(spacing: 6) {
                        TextField(event == .mdl ? "180" : "25", text: event == .mdl ? $deadliftText : $pushUpText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(MVMTheme.text)
                        Spacer(minLength: 0)
                        Text(event == .mdl ? "LB" : "REPS")
                            .font(MVMTheme.mono(12))
                            .foregroundStyle(MVMTheme.textMuted)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 64)
                }
            }
            .padding(16)
        }
    }

    // MARK: - Summary

    private var summaryContent: some View {
        VStack(spacing: 16) {
            RaisedCard(radius: 22) {
                VStack(spacing: 12) {
                    Text("FINAL SCORE")
                        .font(MVMTheme.mono(11))
                        .kerning(1.6)
                        .foregroundStyle(MVMTheme.textFaint)
                        .padding(.top, 20)

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(totalScore)")
                            .font(MVMTheme.scoreDisplay(72))
                            .foregroundStyle(MVMTheme.text)
                        Text("/ 500")
                            .font(MVMTheme.mono(16))
                            .foregroundStyle(MVMTheme.textFaint)
                    }

                    Text(overallPassed ? "GO" : "NO GO")
                        .font(.headline.weight(.heavy))
                        .tracking(2)
                        .foregroundStyle(overallPassed ? MVMTheme.success : MVMTheme.danger)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 8)
                        .background((overallPassed ? MVMTheme.success : MVMTheme.danger).opacity(0.15))
                        .clipShape(Capsule())

                    HStack(spacing: 8) {
                        summaryPill(.mdl)
                        summaryPill(.hrp)
                        summaryPill(.sdc)
                        summaryPill(.plk)
                        summaryPill(.run2mi)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
            }

            AmberButton(title: didSave ? "Saved" : "Save AFT Result") {
                guard !didSave else { return }
                vm.saveAFTCalculatorResult(builtCalculatorResult)
                didSave = true
            }
            .sensoryFeedback(.success, trigger: didSave)

            Button {
                showShare = true
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
                .overlay { RoundedRectangle(cornerRadius: 16).stroke(MVMTheme.hairline, lineWidth: 1) }
                .contentShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                endAndDismiss()
            } label: {
                Text("Done")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.textMuted)
            }
            .padding(.top, 4)
        }
    }

    private func summaryPill(_ event: AFTEventType) -> some View {
        VStack(spacing: 3) {
            Text(event.displayCode)
                .font(MVMTheme.mono(9, weight: .bold))
                .foregroundStyle(MVMTheme.textMuted)
            Text("\(points(for: event))")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(points(for: event) >= standard.minimumPerEvent ? MVMTheme.success : MVMTheme.danger)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(MVMTheme.well)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Stopwatch mechanics

    private func startStopwatch() {
        stopwatchStart = .now
        stopwatchSeconds = 0
        stopwatchRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if let start = stopwatchStart {
                    stopwatchSeconds = Int(Date.now.timeIntervalSince(start))
                }
            }
        }
    }

    private func stopStopwatch(save: Bool, event: AFTEventType? = nil) {
        timer?.invalidate()
        timer = nil
        stopwatchRunning = false
        if save, let event {
            setRecordedSeconds(for: event, to: stopwatchSeconds)
        }
    }

    private func resetStopwatch() {
        stopwatchSeconds = 0
        stopwatchStart = nil
        stopwatchRunning = false
    }

    private func isTimedEvent(_ event: AFTEventType) -> Bool {
        switch event {
        case .sdc, .plk, .run2mi: return true
        case .mdl, .hrp: return false
        }
    }

    private func recordedSeconds(for event: AFTEventType) -> Int {
        switch event {
        case .sdc: return sdcSeconds
        case .plk: return plankSeconds
        case .run2mi: return runSeconds
        case .mdl, .hrp: return 0
        }
    }

    private func setRecordedSeconds(for event: AFTEventType, to value: Int) {
        let clamped = max(0, value)
        switch event {
        case .sdc: sdcSeconds = clamped
        case .plk: plankSeconds = clamped
        case .run2mi: runSeconds = clamped
        case .mdl, .hrp: break
        }
    }

    private func adjustSeconds(for event: AFTEventType, by delta: Int) {
        setRecordedSeconds(for: event, to: recordedSeconds(for: event) + delta)
    }

    // MARK: - Scoring (engine only)

    private func rawValue(for event: AFTEventType) -> Int {
        switch event {
        case .mdl: return Int(deadliftText) ?? 0
        case .hrp: return Int(pushUpText) ?? 0
        case .sdc: return sdcSeconds
        case .plk: return plankSeconds
        case .run2mi: return runSeconds
        }
    }

    private func points(for event: AFTEventType) -> Int {
        engine.score(event: event, age: age, sex: sex, standard: standard, rawValue: rawValue(for: event))
    }

    private var totalScore: Int {
        Self.events.reduce(0) { $0 + points(for: $1) }
    }

    private var overallPassed: Bool {
        Self.events.allSatisfy { points(for: $0) >= standard.minimumPerEvent }
            && totalScore >= standard.minimumTotal
    }

    private var builtCalculatorResult: AFTCalculatorResult {
        let eventScores: [(String, Int)] = Self.events.map { ($0.displayCode, points(for: $0)) }
        let weakest = eventScores.sorted { $0.1 < $1.1 }.prefix(2).map(\.0)
        return AFTCalculatorResult(
            soldierName: soldierName,
            age: age,
            sex: sex,
            standard: standard,
            deadliftLbs: rawValue(for: .mdl),
            pushUpReps: rawValue(for: .hrp),
            sdcSeconds: sdcSeconds,
            plankSeconds: plankSeconds,
            runSeconds: runSeconds,
            deadliftPoints: points(for: .mdl),
            pushUpPoints: points(for: .hrp),
            sdcPoints: points(for: .sdc),
            plankPoints: points(for: .plk),
            runPoints: points(for: .run2mi),
            totalScore: totalScore,
            passed: overallPassed,
            weakestEvents: weakest
        )
    }

    private var builtScoreRecord: AFTScoreRecord {
        AFTScoreRecord(
            deadliftLbs: rawValue(for: .mdl),
            pushUpReps: rawValue(for: .hrp),
            sdcSeconds: sdcSeconds,
            plankSeconds: plankSeconds,
            runSeconds: runSeconds,
            deadliftPoints: points(for: .mdl),
            pushUpPoints: points(for: .hrp),
            sdcPoints: points(for: .sdc),
            plankPoints: points(for: .plk),
            runPoints: points(for: .run2mi),
            totalScore: totalScore,
            weakestEvents: []
        )
    }

    // MARK: - Voice + titles

    private func announce(_ text: String) {
        guard voiceOn else { return }
        speech.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        speech.speak(utterance)
    }

    private func eventTitle(_ event: AFTEventType) -> String {
        switch event {
        case .mdl: return "3-Rep Max Deadlift"
        case .hrp: return "Hand-Release Push-Up"
        case .sdc: return "Sprint-Drag-Carry"
        case .plk: return "Plank"
        case .run2mi: return "2-Mile Run"
        }
    }

    private func spokenName(_ event: AFTEventType) -> String {
        switch event {
        case .mdl: return "deadlift"
        case .hrp: return "hand release push up"
        case .sdc: return "sprint drag carry"
        case .plk: return "plank"
        case .run2mi: return "two mile run"
        }
    }

    private func eventInstruction(_ event: AFTEventType) -> String {
        switch event {
        case .mdl: return "3 reps at max weight on the hex bar. Enter the heaviest successful weight."
        case .hrp: return "2 minutes, hands fully released at the bottom of each rep. Enter total reps."
        case .sdc: return "50 m sprint, drag, lateral, carry, sprint. Start the clock on 'go', stop at the finish."
        case .plk: return "Hold the forearm plank as long as possible. Start the clock when the hold begins."
        case .run2mi: return "2 miles on a measured course. Start the clock at the start line."
        }
    }

    private func endAndDismiss() {
        timer?.invalidate()
        speech.stopSpeaking(at: .immediate)
        dismiss()
    }
}
