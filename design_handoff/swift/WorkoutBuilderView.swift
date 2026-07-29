import SwiftUI

/// 14b — name well, TARGETS / EST TIME / BLOCKS chips, movement blocks with
/// SETS / HOLD·REPS / LOAD·TEMPO wells. Tempo renders as 3·1·1 (middle dots).
struct WorkoutBuilderView: View {
    struct Block: Identifiable {
        let id = UUID()
        var movement: String
        var event: AFTEvent
        var cells: [(label: String, value: String)]   // label ABOVE value; wraps never
    }
    @State private var name = "Thursday core"
    @State private var blocks: [Block] = [
        .init(movement: "Weighted plank", event: .PLK,
              cells: [("SETS", "3"), ("HOLD", "0:45"), ("LOAD", "25 LB")]),
        .init(movement: "Ab rollout", event: .PLK,
              cells: [("SETS", "4"), ("REPS", "8"), ("TEMPO", "3\(MVMTheme.dot)1\(MVMTheme.dot)1")]),
        .init(movement: "Hand-release push-up", event: .HRP,
              cells: [("SETS", "3"), ("REPS", "15"), ("REST", "1:00")]),
    ]

    var body: some View {
        ZStack {
            MVMTheme.screen.ignoresSafeArea()
            VStack(spacing: 10) {
                InsetWell(radius: 15) {
                    TextField("Workout name", text: $name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(MVMTheme.text)
                        .padding(.horizontal, 16).frame(height: 54)
                }
                summaryChips
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(blocks) { block in blockCard(block) }
                        addMovement
                        hint
                    }
                }
                AmberButton(title: "Save & start")
            }
            .padding(.horizontal, 22).padding(.top, 10).padding(.bottom, 14)
        }
        .navigationTitle("New workout")
    }

    private var summaryChips: some View {
        HStack(spacing: 8) {
            chip("TARGETS", targets, MVMTheme.amber)
            chip("EST. TIME", "31 MIN", MVMTheme.text)
            chip("BLOCKS", "\(blocks.count)", MVMTheme.text)
        }
    }
    private var targets: String {
        // Unique tags joined with middle dots — e.g. "PLK · HRP"
        var seen = [AFTEvent]()
        for b in blocks where !seen.contains(b.event) { seen.append(b.event) }
        return seen.map(\.rawValue).joined(separator: " \(MVMTheme.dot) ")
    }
    private func chip(_ label: String, _ value: String, _ color: Color) -> some View {
        RaisedCard(radius: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(label).font(MVMTheme.mono(10)).kerning(1.2)
                    .foregroundStyle(MVMTheme.textFaint).lineLimit(1).fixedSize()
                Text(value).font(MVMTheme.mono(14, weight: .bold))
                    .foregroundStyle(color).lineLimit(1).fixedSize()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14).padding(.vertical, 11)
        }
    }

    private func blockCard(_ block: Block) -> some View {
        RaisedCard {
            VStack(spacing: 11) {
                HStack(spacing: 12) {
                    EventTagChip(event: block.event)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(block.movement).font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(MVMTheme.text)
                        Text("BLOCK \((blocks.firstIndex { $0.id == block.id } ?? 0) + 1)")
                            .font(MVMTheme.mono(10.5)).foregroundStyle(MVMTheme.textFaint)
                            .lineLimit(1).fixedSize()
                    }
                    Spacer()
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(MVMTheme.text.opacity(0.34))
                }
                HStack(spacing: 8) {
                    ForEach(block.cells, id: \.label) { cell in
                        InsetWell(radius: 13) {
                            MetricCell(label: cell.label, value: cell.value)
                        }
                    }
                }
            }
            .padding(.init(top: 11, leading: 14, bottom: 11, trailing: 14))
        }
    }

    private var addMovement: some View {
        HStack(spacing: 12) {
            Image(systemName: "plus")
                .font(.system(size: 15, weight: .bold)).foregroundStyle(MVMTheme.amber)
                .frame(width: 36, height: 36)
                .background(MVMTheme.amber.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: 11))
            Text("Add a movement").font(.system(size: 14, weight: .semibold))
                .foregroundStyle(MVMTheme.amber)
            Spacer()
        }
        .padding(.horizontal, 16).frame(minHeight: 56)
        .overlay(RoundedRectangle(cornerRadius: 20)
            .strokeBorder(MVMTheme.amber.opacity(0.42), style: .init(lineWidth: 1.5, dash: [6, 5])))
    }

    private var hint: some View {
        Text("Event tags are what let Home say targets your weakest score. Untagged movements still log.")
            .font(.system(size: 11)).foregroundStyle(MVMTheme.textMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 15).padding(.vertical, 12)
            .background(MVMTheme.well)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
