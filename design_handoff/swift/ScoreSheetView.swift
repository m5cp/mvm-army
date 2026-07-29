import SwiftUI

/// 10b — spec-sheet calculator. Every row: event code chip · raw input well ·
/// points. Inputs are ALWAYS linked to sex, age band, and standard, and the
/// min/max references are ALWAYS visible per event (standing constraint).
struct ScoreSheetView: View {
    // Swap IllustrativeScoring for OfficialTableScoring before ship.
    private let scoring: AFTScoring = IllustrativeScoring()

    @State private var sex: Sex = .male
    @State private var age = 27
    @State private var standard: Standard = .general
    @State private var raws: [AFTEvent: Double] = [:]

    var body: some View {
        ZStack {
            MVMTheme.screen.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 10) {
                    profileRow
                    ForEach(AFTEvent.allCases, id: \.self) { event in
                        eventRow(event)
                    }
                    disclaimer
                }
                .padding(.horizontal, 22).padding(.top, 12)
            }
        }
        .navigationTitle("Score")
    }

    private var profileRow: some View {
        HStack(spacing: 8) {
            picker("SEX", selection: $sex, options: [.male, .female]) { $0 == .male ? "M" : "F" }
            // Age band + standard follow the same pattern; refs recompute on any change.
            picker("STD", selection: $standard, options: [.general, .combat]) { $0 == .general ? "GEN" : "CBT" }
        }
    }

    private func eventRow(_ event: AFTEvent) -> some View {
        let refs = scoring.references(event: event, sex: sex, age: age, standard: standard)
        let raw = raws[event]
        let pts = raw.map { scoring.points(event: event, raw: $0, sex: sex, age: age, standard: standard) }
        return RaisedCard {
            VStack(spacing: 11) {
                HStack(spacing: 12) {
                    EventTagChip(event: event)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(eventName(event))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(MVMTheme.text)
                        // Min/max refs — must stay visible, update with profile.
                        Text("60 PT \(format(event, refs.min60))  \(MVMTheme.dot)  100 PT \(format(event, refs.max100))")
                            .font(MVMTheme.mono(10.5)).kerning(0.5)
                            .foregroundStyle(MVMTheme.textMuted)
                            .lineLimit(1).fixedSize()
                    }
                    Spacer()
                    // Points readout — display numerals, never wraps.
                    Text(pts.map(String.init) ?? "—")
                        .font(MVMTheme.scoreDisplay(28))
                        .foregroundStyle(pts != nil ? MVMTheme.amber : MVMTheme.textFaint)
                        .lineLimit(1).fixedSize()
                }
                InsetWell {
                    TextField("Enter raw", value: binding(event), format: .number)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(MVMTheme.text)
                        .padding(.horizontal, 16).frame(height: 54)
                }
            }
            .padding(12)
        }
    }

    private var disclaimer: some View {
        // Stated ON SCREEN by design: prototype thresholds are illustrative.
        Text("Reference marks are illustrative until the official 2025-06 tables are wired in.")
            .font(.system(size: 11))
            .foregroundStyle(MVMTheme.textMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(MVMTheme.well)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: helpers
    private func binding(_ e: AFTEvent) -> Binding<Double?> {
        .init(get: { raws[e] }, set: { raws[e] = $0 })
    }
    private func eventName(_ e: AFTEvent) -> String {
        switch e {
        case .MDL: "3-Rep Max Deadlift"
        case .HRP: "Hand-Release Push-up"
        case .SDC: "Sprint-Drag-Carry"
        case .PLK: "Plank"
        case .TMR: "Two-Mile Run"
        }
    }
    private func format(_ e: AFTEvent, _ v: Double) -> String {
        switch e {
        case .MDL: "\(Int(v)) LB"
        case .HRP: "\(Int(v)) REPS"
        case .SDC, .TMR, .PLK:
            "\(Int(v) / 60):" + String(format: "%02d", Int(v) % 60)
        }
    }
    private func picker<T: Hashable>(_ label: String, selection: Binding<T>, options: [T], title: (T) -> String) -> some View {
        InsetWell {
            HStack(spacing: 3) {
                ForEach(options, id: \.self) { opt in
                    Text(title(opt))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(selection.wrappedValue == opt ? MVMTheme.onAmber : MVMTheme.textMuted)
                        .frame(maxWidth: .infinity).frame(height: 38)
                        .background(selection.wrappedValue == opt ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(.clear))
                        .clipShape(RoundedRectangle(cornerRadius: 11))
                        .onTapGesture { selection.wrappedValue = opt }
                }
            }
            .padding(3)
        }
    }
}
