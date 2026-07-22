import SwiftUI

/// Grader mode: enter all 5 raw AFT values per member; scores compute on the
/// member's OWN age band / sex / standard via the verified AFTScoringEngine.
struct SquadAFTTestDayView: View {
    @Environment(\.dismiss) private var dismiss
    let store: SquadStore

    @State private var memberIndex = 0
    @State private var mdlText = ""
    @State private var hrpText = ""
    @State private var sdcMin = ""; @State private var sdcSec = ""
    @State private var plkMin = ""; @State private var plkSec = ""
    @State private var runMin = ""; @State private var runSec = ""

    private let engine = AFTScoringEngine.shared

    private var member: SquadMember? {
        store.activeMembers.indices.contains(memberIndex) ? store.activeMembers[memberIndex] : nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                if let member {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            memberHeader(member)
                            entryFields
                            livePreview(member)
                            saveButton(member)
                        }
                        .padding(20)
                    }
                    .scrollDismissesKeyboard(.interactively)
                } else {
                    Text("All members graded")
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }
            .navigationTitle("AFT Test Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("End") { dismiss() } } }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private func memberHeader(_ member: SquadMember) -> some View {
        VStack(spacing: 4) {
            Text("\(memberIndex + 1) of \(store.activeMembers.count)")
                .font(.caption2.weight(.semibold)).foregroundStyle(MVMTheme.tertiaryText)
            Text(member.name)
                .font(.title3.weight(.heavy)).foregroundStyle(MVMTheme.primaryText)
            Text("\(member.standard.rawValue) standard · Age \(member.age())")
                .font(.caption).foregroundStyle(MVMTheme.secondaryText)
        }
    }

    private var entryFields: some View {
        VStack(spacing: 12) {
            numberField("MDL (lbs)", text: $mdlText)
            numberField("HRP (reps)", text: $hrpText)
            timeField("SDC", min: $sdcMin, sec: $sdcSec)
            timeField("Plank", min: $plkMin, sec: $plkSec)
            timeField("2-Mile Run", min: $runMin, sec: $runSec)
        }
    }

    private func numberField(_ title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(MVMTheme.primaryText)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.numberPad).multilineTextAlignment(.trailing)
                .frame(width: 90).padding(10)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(MVMTheme.cardSoft))
                .foregroundStyle(MVMTheme.primaryText)
        }
        .padding(.horizontal, 14).padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(MVMTheme.card))
    }

    private func timeField(_ title: String, min: Binding<String>, sec: Binding<String>) -> some View {
        HStack {
            Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(MVMTheme.primaryText)
            Spacer()
            TextField("m", text: min).keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 44)
            Text(":").foregroundStyle(MVMTheme.tertiaryText)
            TextField("ss", text: sec).keyboardType(.numberPad).frame(width: 44)
        }
        .padding(10)
        .foregroundStyle(MVMTheme.primaryText)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(MVMTheme.card))
    }

    private func rawValues() -> (mdl: Int, hrp: Int, sdc: Int, plk: Int, run: Int) {
        (Int(mdlText) ?? 0,
         Int(hrpText) ?? 0,
         (Int(sdcMin) ?? 0) * 60 + (Int(sdcSec) ?? 0),
         (Int(plkMin) ?? 0) * 60 + (Int(plkSec) ?? 0),
         (Int(runMin) ?? 0) * 60 + (Int(runSec) ?? 0))
    }

    private func result(for member: SquadMember) -> AFTResult {
        let raw = rawValues()
        return engine.evaluate(
            age: member.age(), sex: member.sex, standard: member.standard,
            mdl: raw.mdl, hrp: raw.hrp, sdcSeconds: raw.sdc,
            plkSeconds: raw.plk, run2miSeconds: raw.run
        )
    }

    private func livePreview(_ member: SquadMember) -> some View {
        let r = result(for: member)
        return VStack(spacing: 6) {
            Text("\(r.total)")
                .font(.system(size: 48, weight: .heavy, design: .rounded)).monospacedDigit()
                .foregroundStyle(r.passedOverall ? MVMTheme.success : MVMTheme.primaryText)
                .contentTransition(.numericText())
            Text(r.passedOverall ? "PASS" : "Min \(r.minimumTotalRequired) total · 60/event")
                .font(.caption.weight(.semibold))
                .foregroundStyle(r.passedOverall ? MVMTheme.success : MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity).padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.card))
    }

    private func saveButton(_ member: SquadMember) -> some View {
        Button {
            let raw = rawValues()
            let r = result(for: member)
            let points = [AFTEventType.mdl, .hrp, .sdc, .plk, .run2mi].map { r.eventScores[$0] ?? 0 }
            store.addAFT(SquadAFTResult(
                memberID: member.id, mdlLbs: raw.mdl, hrpReps: raw.hrp,
                sdcSeconds: raw.sdc, plkSeconds: raw.plk, runSeconds: raw.run,
                eventPoints: points, total: r.total, passed: r.passedOverall
            ))
            AnalyticsService.track(.squadTestDayRun)
            clearFields()
            if memberIndex < store.activeMembers.count - 1 { memberIndex += 1 } else { dismiss() }
        } label: {
            Text(memberIndex < store.activeMembers.count - 1 ? "Save & Next Member" : "Save & Finish")
                .font(.headline.weight(.bold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity).frame(height: 54)
                .background(MVMTheme.heroGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .sensoryFeedback(.success, trigger: memberIndex)
    }

    private func clearFields() {
        mdlText = ""; hrpText = ""; sdcMin = ""; sdcSec = ""
        plkMin = ""; plkSec = ""; runMin = ""; runSec = ""
    }
}
