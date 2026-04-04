import SwiftUI
import MapKit

struct QuickStartCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    let record: QuickStartRecord
    let onDismiss: () -> Void

    @State private var checkScale: CGFloat = 0
    @State private var cardScale: CGFloat = 0.9
    @State private var cardOpacity: Double = 0

    private var hex: (String, String) {
        record.activity.gradientHex
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    completionHeader

                    if !record.routeCoordinates.isEmpty {
                        routeMap
                    }

                    statsCard

                    doneButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
            .background(MVMTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ACTIVITY COMPLETE")
                        .font(.caption.weight(.heavy))
                        .tracking(2.0)
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                checkScale = 1
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15)) {
                cardScale = 1
                cardOpacity = 1
            }
        }
    }

    private var completionHeader: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(MVMTheme.success.opacity(0.1))
                    .frame(width: 110, height: 110)

                Circle()
                    .fill(MVMTheme.success.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(MVMTheme.success)
                    .scaleEffect(checkScale)
            }

            VStack(spacing: 6) {
                Text(record.activity.rawValue)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text(record.formattedDuration)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: hex.0))
            }
        }
    }

    @ViewBuilder
    private var routeMap: some View {
        let coords = record.routeCoordinates.map(\.clCoordinate)
        if coords.count > 1 {
            Map {
                MapPolyline(coordinates: coords)
                    .stroke(Color(hex: hex.0), lineWidth: 4)

                if let first = coords.first {
                    Annotation("Start", coordinate: first) {
                        Circle()
                            .fill(MVMTheme.success)
                            .frame(width: 12, height: 12)
                            .overlay { Circle().stroke(.white, lineWidth: 2) }
                    }
                }

                if let last = coords.last {
                    Annotation("End", coordinate: last) {
                        Circle()
                            .fill(MVMTheme.danger)
                            .frame(width: 12, height: 12)
                            .overlay { Circle().stroke(.white, lineWidth: 2) }
                    }
                }
            }
            .mapStyle(.standard)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(MVMTheme.border)
            }
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
        }
    }

    private var statsCard: some View {
        VStack(spacing: 0) {
            if record.activity.usesGPS {
                HStack(spacing: 0) {
                    statItem(value: record.formattedDistance, label: "Distance")
                    Rectangle().fill(MVMTheme.border).frame(width: 1, height: 40)
                    statItem(value: record.formattedPace, label: "Avg Pace")
                }
                .padding(.vertical, 18)

                Rectangle().fill(MVMTheme.border).frame(height: 1)
            }

            HStack(spacing: 0) {
                statItem(value: record.formattedDuration, label: "Duration")
                Rectangle().fill(MVMTheme.border).frame(width: 1, height: 40)
                statItem(value: dateString, label: "Date")
            }
            .padding(.vertical, 18)
        }
        .background(MVMTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(MVMTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, h:mm a"
        return f.string(from: record.startDate)
    }

    private var doneButton: some View {
        Button {
            onDismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.subheadline.weight(.bold))
                Text("Done")
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(MVMTheme.heroGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: MVMTheme.accent.opacity(0.28), radius: 14, y: 8)
        }
        .buttonStyle(PressScaleButtonStyle())
    }
}
