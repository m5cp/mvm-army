import SwiftUI

struct CFTView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = CFTStore()
    @State private var showInfo = false

    // Stopwatch state
    @State private var isRunning = false
    @State private var startDate: Date?
    @State private var elapsed: Int = 0
    @State private var completedEvents: Int = 0
    @State private var splits: [Int] = []
    @State private var timer: Timer?
    @State private var showResultEntry = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        stopwatchCard
                        eventChecklist
                        if !store.records.isEmpty { historyCard }
                        Text(LegalText.full)
                            .font(.caption2)
                            .foregroundStyle(MVMTheme.tertiaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Combat Field Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }.foregroundStyle(MVMTheme.accent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showInfo = true } label: { Image(systemName: "info.circle").foregroundStyle(MVMTheme.accent) }
                }
            }
            .sheet(isPresented: $showInfo) { CFTInfoSheet() }
            .sheet(isPresented: $showResultEntry) {
                CFTResultSheet(totalSeconds: elapsed, splits: splits) { record in
                    store.add(record)
                    resetStopwatch()
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var formattedElapsed: String {
        String(format: "%d:%02d", elapsed / 60, elapsed % 60)
    }

    private var stopwatchCard: some View {
        VStack(spacing: 14) {
            Text(formattedElapsed)
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(MVMTheme.primaryText)
                .contentTransition(.numericText())

            Text("Cumulative time — no individual event is timed")
                .font(.caption)
                .foregroundStyle(MVMTheme.tertiaryText)

            HStack(spacing: 12) {
                if !isRunning && completedEvents == 0 {
                    controlButton("Start Test", color: MVMTheme.accent) { start() }
                } else if isRunning {
                    controlButton(completedEvents < CFTEvent.allCases.count - 1 ? "Event Complete" : "Finish Test", color: MVMTheme.success) { markEvent() }
                    controlButton("Stop", color: MVMTheme.danger) { stopAndRecord() }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(MVMTheme.card))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(MVMTheme.border))
    }

    private func controlButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var eventChecklist: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("7 Events — In Sequence")
                .font(.headline)
                .foregroundStyle(MVMTheme.primaryText)

            ForEach(Array(CFTEvent.allCases.enumerated()), id: \.offset) { index, event in
                HStack(spacing: 10) {
                    Image(systemName: index < completedEvents ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(index < completedEvents ? MVMTheme.success : MVMTheme.tertiaryText)
                    Text("\(index + 1). \(event.rawValue)")
                        .font(.subheadline)
                        .foregroundStyle(index < completedEvents ? MVMTheme.secondaryText : MVMTheme.primaryText)
                        .strikethrough(index < completedEvents)
                    Spacer()
                    if index < splits.count {
                        Text(String(format: "%d:%02d", splits[index] / 60, splits[index] % 60))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.card))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(MVMTheme.border))
    }

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("History").font(.headline).foregroundStyle(MVMTheme.primaryText)
            ForEach(store.records) { record in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(record.formattedTime)
                            .font(.subheadline.weight(.bold)).monospacedDigit()
                            .foregroundStyle(MVMTheme.primaryText)
                        Text(record.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2).foregroundStyle(MVMTheme.tertiaryText)
                    }
                    Spacer()
                    Text(record.isGo ? "GO" : "NO-GO")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(record.isGo ? MVMTheme.success : MVMTheme.danger)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Capsule().fill((record.isGo ? MVMTheme.success : MVMTheme.danger).opacity(0.12)))
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.card))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(MVMTheme.border))
    }

    // MARK: - Stopwatch logic

    private func start() {
        startDate = .now
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if let start = startDate { elapsed = Int(Date.now.timeIntervalSince(start)) }
            }
        }
    }

    private func markEvent() {
        splits.append(elapsed)
        completedEvents += 1
        if completedEvents >= CFTEvent.allCases.count { stopAndRecord() }
    }

    private func stopAndRecord() {
        timer?.invalidate(); timer = nil
        isRunning = false
        showResultEntry = true
    }

    private func resetStopwatch() {
        elapsed = 0; completedEvents = 0; splits = []; startDate = nil
    }
}

struct CFTResultSheet: View {
    @Environment(\.dismiss) private var dismiss
    let totalSeconds: Int
    let splits: [Int]
    let onSave: (CFTRecord) -> Void

    @State private var isGo = true
    @State private var graderName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Text(String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60))
                        .font(.system(size: 56, weight: .heavy, design: .rounded)).monospacedDigit()
                        .foregroundStyle(MVMTheme.primaryText)

                    Text("The official time standard is pending publication. Enter the grader's GO/NO-GO determination.")
                        .font(.footnote)
                        .foregroundStyle(MVMTheme.secondaryText)
                        .multilineTextAlignment(.center)

                    Picker("Result", selection: $isGo) {
                        Text("GO").tag(true)
                        Text("NO-GO").tag(false)
                    }
                    .pickerStyle(.segmented)

                    TextField("Grader name (optional)", text: $graderName)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(MVMTheme.cardSoft))
                        .foregroundStyle(MVMTheme.primaryText)

                    Button {
                        onSave(CFTRecord(totalSeconds: totalSeconds, isGo: isGo, graderName: graderName, eventSplits: splits))
                        dismiss()
                    } label: {
                        Text("Save Result")
                            .font(.headline.weight(.bold)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(MVMTheme.heroGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("CFT Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}

struct CFTInfoSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        block("What is the CFT?", "Per Army Directive 2026-07, the Combat Field Test is a pass/fail requirement for Soldiers in combat specialties. Seven events are performed in sequence; the cumulative time determines pass/fail. No individual event is timed.")
                        block("Events", CFTEvent.allCases.enumerated().map { "\($0.offset + 1). \($0.element.rawValue)" }.joined(separator: "\n"))
                        block("Uniform", "ACU top and bottom, boots, no headgear. Failure to complete any event terminates the test as a failure.")
                        block("Cadence", "1 CFT + 1 AFT annually for RA/AGR and RC on 365+ day orders; other RC Soldiers alternate AFT/CFT by calendar year. Minimum 4 months between record tests (8 for other RC).")
                        block("Time Standard", "The official time standard has not yet been published. This app records your raw time and grader GO/NO-GO; scoring will be updated when the standard is released.")
                        Text(LegalText.full).font(.caption2).foregroundStyle(MVMTheme.tertiaryText)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("About the CFT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private func block(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline).foregroundStyle(MVMTheme.primaryText)
            Text(body).font(.subheadline).foregroundStyle(MVMTheme.secondaryText)
        }
    }
}
