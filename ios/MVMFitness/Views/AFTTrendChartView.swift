import SwiftUI
import Charts

/// You tab — trend line chart of total AFT scores over time, complementing
/// the badge grid. Reads only `vm.aftScores` (the existing saved-results
/// store) through `AppViewModel.aftScores(in:)`, the new date-range filter —
/// no new storage, no scoring math, just plotting numbers the engine already
/// produced and saved.
struct AFTTrendChartView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var range: AppViewModel.AFTDateRange = .all

    private var points: [AFTScoreRecord] {
        vm.aftScores(in: range)
    }

    var body: some View {
        RaisedCard {
            VStack(alignment: .leading, spacing: 14) {
                header
                rangePicker
                if points.count >= 2 {
                    chart
                } else if points.count == 1 {
                    singlePointState
                } else {
                    emptyState
                }
            }
            .padding(16)
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Score Trend")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(MVMTheme.text)
            Spacer()
            if let latest = points.last {
                Text("\(latest.totalScore)")
                    .font(MVMTheme.scoreDisplay(20))
                    .foregroundStyle(MVMTheme.amber)
                    .lineLimit(1)
                    .fixedSize()
            }
        }
    }

    // MARK: - Range picker

    private var rangePicker: some View {
        InsetWell(radius: 12) {
            HStack(spacing: 3) {
                ForEach(AppViewModel.AFTDateRange.allCases) { option in
                    let selected = range == option
                    Text(option.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(selected ? MVMTheme.onAmber : MVMTheme.textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(selected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(.clear))
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                range = option
                            }
                        }
                }
            }
            .padding(3)
        }
    }

    // MARK: - Chart

    private var chart: some View {
        Chart {
            ForEach(points) { record in
                LineMark(
                    x: .value("Date", record.date),
                    y: .value("Score", record.totalScore)
                )
                .foregroundStyle(MVMTheme.amber)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                AreaMark(
                    x: .value("Date", record.date),
                    y: .value("Score", record.totalScore)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [MVMTheme.amber.opacity(0.22), MVMTheme.amber.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                PointMark(
                    x: .value("Date", record.date),
                    y: .value("Score", record.totalScore)
                )
                .foregroundStyle(MVMTheme.amber)
                .symbolSize(28)
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(MVMTheme.hairline)
                AxisValueLabel()
                    .foregroundStyle(MVMTheme.textFaint)
                    .font(MVMTheme.mono(9))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .foregroundStyle(MVMTheme.textFaint)
                    .font(MVMTheme.mono(9))
            }
        }
        .frame(height: 160)
    }

    // MARK: - Empty / single-point states

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 26))
                .foregroundStyle(MVMTheme.textFaint)
            Text(vm.aftScores.isEmpty ? "No AFT scores logged yet" : "No scores in this range")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(MVMTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }

    private var singlePointState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 26))
                .foregroundStyle(MVMTheme.amber.opacity(0.6))
            Text("BASELINE \(MVMTheme.dot) LOG ANOTHER TEST TO SEE A TREND")
                .font(MVMTheme.mono(10))
                .kerning(0.6)
                .foregroundStyle(MVMTheme.textMuted)
                .lineLimit(1)
                .fixedSize()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
