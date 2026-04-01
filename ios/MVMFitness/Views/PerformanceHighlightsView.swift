import SwiftUI

struct PerformanceHighlightsView: View {
    let highlights: [PerformanceHighlight]

    var body: some View {
        if highlights.isEmpty { EmptyView() } else {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .foregroundStyle(MVMTheme.accent)
                        .font(.subheadline.weight(.semibold))
                    Text("Performance Highlights")
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                }

                VStack(spacing: 8) {
                    ForEach(highlights) { highlight in
                        highlightRow(highlight)
                    }
                }
            }
            .padding(18)
            .premiumCard()
        }
    }

    private func highlightRow(_ highlight: PerformanceHighlight) -> some View {
        HStack(spacing: 12) {
            Image(systemName: highlight.icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(highlight.isPositive ? MVMTheme.success : MVMTheme.warning)
                .frame(width: 30, height: 30)
                .background((highlight.isPositive ? MVMTheme.success : MVMTheme.warning).opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(highlight.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)

                if let detail = highlight.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }

            Spacer()
        }
        .padding(10)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
