import SwiftUI

struct AFTScoringTableView: View {
    @State private var selectedEvent: AFTEventType = .mdl
    @State private var selectedAgeBand: String = "17-21"

    private let ageBands: [String] = [
        "17-21", "22-26", "27-31", "32-36", "37-41",
        "42-46", "47-51", "52-56", "57-61", "Over 62"
    ]

    private let eventLabels: [(AFTEventType, String)] = [
        (.mdl, "MDL"), (.hrp, "HRP"), (.sdc, "SDC"), (.plk, "PLK"), (.run2mi, "2MR")
    ]

    private let engine = AFTScoringEngine.shared

    private var tableRows: [ScoringTableRow] {
        let mEntries = engine.entries(for: selectedEvent, ageBand: selectedAgeBand, column: .male)
        let cEntries = engine.entries(for: selectedEvent, ageBand: selectedAgeBand, column: .combat)
        let fEntries = engine.entries(for: selectedEvent, ageBand: selectedAgeBand, column: .female)

        let mByPts = Dictionary(uniqueKeysWithValues: mEntries.map { ($0.points, $0.rawValue) })
        let cByPts = Dictionary(uniqueKeysWithValues: cEntries.map { ($0.points, $0.rawValue) })
        let fByPts = Dictionary(uniqueKeysWithValues: fEntries.map { ($0.points, $0.rawValue) })

        let allPoints = Set(mEntries.map(\.points))
            .union(cEntries.map(\.points))
            .union(fEntries.map(\.points))
            .sorted(by: >)

        return allPoints.map { pts in
            ScoringTableRow(points: pts, maleRaw: mByPts[pts], combatRaw: cByPts[pts], femaleRaw: fByPts[pts])
        }
    }

    private var isTimeEvent: Bool {
        selectedEvent == .sdc || selectedEvent == .plk || selectedEvent == .run2mi
    }

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                eventPicker
                ageBandPicker
                tableHeader
                tableContent
            }
        }
        .navigationTitle("Scoring Tables")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var eventPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(eventLabels, id: \.0) { event, label in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedEvent = event
                        }
                    } label: {
                        Text(label)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(selectedEvent == event ? .white : MVMTheme.secondaryText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedEvent == event ? MVMTheme.accent : MVMTheme.cardSoft)
                            .clipShape(Capsule())
                            .overlay {
                                Capsule().stroke(selectedEvent == event ? MVMTheme.accent : MVMTheme.border)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var ageBandPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(ageBands, id: \.self) { band in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedAgeBand = band
                        }
                    } label: {
                        Text(band)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(selectedAgeBand == band ? .white : MVMTheme.tertiaryText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(selectedAgeBand == band ? MVMTheme.accent.opacity(0.7) : MVMTheme.card)
                            .clipShape(Capsule())
                            .overlay {
                                Capsule().stroke(selectedAgeBand == band ? MVMTheme.accent.opacity(0.5) : MVMTheme.border)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            Text("PTS")
                .frame(width: 50, alignment: .center)
            Text("M")
                .frame(maxWidth: .infinity, alignment: .center)
            Text("C")
                .frame(maxWidth: .infinity, alignment: .center)
            Text("F")
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .font(.caption.weight(.heavy))
        .foregroundStyle(MVMTheme.accent)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(MVMTheme.card)
        .overlay(alignment: .bottom) {
            Rectangle().fill(MVMTheme.border).frame(height: 1)
        }
    }

    private var tableContent: some View {
        ScrollView(showsIndicators: true) {
            LazyVStack(spacing: 0) {
                ForEach(tableRows) { row in
                    tableRowView(row)
                }
            }
            .padding(.bottom, 40)
        }
    }

    private func tableRowView(_ row: ScoringTableRow) -> some View {
        let isPassLine = row.points == 60

        return HStack(spacing: 0) {
            Text("\(row.points)")
                .font(.caption.weight(.bold).monospacedDigit())
                .foregroundStyle(pointColor(row.points))
                .frame(width: 50, alignment: .center)

            Text(formatRaw(row.maleRaw))
                .frame(maxWidth: .infinity, alignment: .center)

            Text(formatRaw(row.combatRaw))
                .frame(maxWidth: .infinity, alignment: .center)

            Text(formatRaw(row.femaleRaw))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .font(.caption.monospacedDigit())
        .foregroundStyle(MVMTheme.primaryText.opacity(row.points >= 60 ? 1.0 : 0.5))
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            row.points % 20 < 10
                ? MVMTheme.card.opacity(0.5)
                : Color.clear
        )
        .overlay(alignment: .bottom) {
            if isPassLine {
                Rectangle().fill(MVMTheme.warning.opacity(0.5)).frame(height: 1)
            }
        }
        .overlay(alignment: .trailing) {
            if isPassLine {
                Text("MIN")
                    .font(.system(size: 8, weight: .heavy))
                    .foregroundStyle(MVMTheme.warning)
                    .padding(.trailing, 4)
            }
        }
    }

    private func formatRaw(_ value: Int?) -> String {
        guard let value else { return "—" }
        if isTimeEvent {
            let minutes = value / 60
            let seconds = value % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
        return "\(value)"
    }

    private func pointColor(_ pts: Int) -> Color {
        if pts >= 90 { return MVMTheme.success }
        if pts >= 60 { return MVMTheme.primaryText }
        if pts >= 40 { return MVMTheme.warning }
        return MVMTheme.danger
    }
}

private struct ScoringTableRow: Identifiable {
    let points: Int
    let maleRaw: Int?
    let combatRaw: Int?
    let femaleRaw: Int?

    var id: Int { points }
}
