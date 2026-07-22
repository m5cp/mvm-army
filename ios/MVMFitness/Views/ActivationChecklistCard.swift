import SwiftUI

/// "Get Mission Ready" first-session checklist. Shows until all three steps are
/// complete or the user dismisses it. Steps 1–2 are derived from real app state;
/// step 3 is flagged by ShareCardRenderer.
struct ActivationChecklistCard: View {
    @Environment(AppViewModel.self) private var vm

    @AppStorage("activationCardDismissed") private var dismissed = false
    @AppStorage("hasSharedOnce") private var hasSharedOnce = false

    let onScoreAFT: () -> Void
    let onStartWorkout: () -> Void
    let onShare: () -> Void

    private var aftDone: Bool {
        !vm.aftScores.isEmpty || !vm.aftCalculatorResults.isEmpty
    }
    private var workoutDone: Bool {
        !vm.completedRecords.isEmpty || !vm.quickStartRecords.isEmpty
    }
    private var allDone: Bool { aftDone && workoutDone && hasSharedOnce }

    var body: some View {
        if !dismissed && !allDone {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("GET MISSION READY")
                        .font(.caption.weight(.heavy))
                        .tracking(1.2)
                        .foregroundStyle(MVMTheme.accent)
                    Spacer()
                    Button {
                        withAnimation { dismissed = true }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                    .accessibilityLabel("Dismiss checklist")
                }

                checklistRow(done: aftDone, title: "Score your first AFT", subtitle: "60 seconds, works offline", action: onScoreAFT)
                checklistRow(done: workoutDone, title: "Complete your first workout", subtitle: "Try a Quick Start activity", action: onStartWorkout)
                checklistRow(done: hasSharedOnce, title: "Share a result", subtitle: "Send a score card to your squad", action: onShare)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.card))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(MVMTheme.accent.opacity(0.25)))
        }
    }

    private func checklistRow(done: Bool, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: { if !done { action() } }) {
            HStack(spacing: 12) {
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(done ? MVMTheme.success : MVMTheme.tertiaryText)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(done ? MVMTheme.secondaryText : MVMTheme.primaryText)
                        .strikethrough(done)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                Spacer()
                if !done {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(done ? "Complete" : "Not complete")")
    }
}
