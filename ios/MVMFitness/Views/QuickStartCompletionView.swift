import SwiftUI
import MapKit

struct QuickStartCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm
    let record: QuickStartRecord
    let onDismiss: () -> Void

    @State private var checkScale: CGFloat = 0
    @State private var cardScale: CGFloat = 0.9
    @State private var cardOpacity: Double = 0
    @State private var calendarService = CalendarExportService()
    @State private var calendarExported: Bool = false
    @State private var calendarExportMessage: String = ""
    @State private var showShareCardEditor: Bool = false
    @State private var shareCardImage: UIImage?
    @State private var logged: Bool = false

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

                    shareCardRow

                    calendarSyncRow

                    logToProgressRow

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
            .fullScreenCover(isPresented: $showShareCardEditor) {
                if let image = shareCardImage {
                    ShareCardEditorView(baseImage: image)
                }
            }
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

    private var shareCardRow: some View {
        Button {
            if let rendered = ShareCardRenderer.renderImage(cardType: .quickStart(record: record), date: record.startDate) {
                shareCardImage = rendered
                showShareCardEditor = true
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 36, height: 36)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Share Activity")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Create a share card with photo, filters & text")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .padding(14)
            .background(MVMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(MVMTheme.border)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
    }

    private var calendarSyncRow: some View {
        Button {
            Task {
                let result = await vm.exportQuickStartToCalendar(record, calendarService: calendarService)
                switch result {
                case .success:
                    calendarExported = true
                    calendarExportMessage = "Added to Calendar"
                case .denied:
                    calendarExportMessage = "Calendar access denied"
                case .error(let msg):
                    calendarExportMessage = msg
                case .partial:
                    calendarExportMessage = "Partially exported"
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: calendarExported ? "checkmark.circle.fill" : "calendar.badge.plus")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(calendarExported ? MVMTheme.success : MVMTheme.accent)
                    .frame(width: 36, height: 36)
                    .background((calendarExported ? MVMTheme.success : MVMTheme.accent).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(calendarExported ? "Added to Calendar" : "Add to Calendar")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text(calendarExported ? calendarExportMessage : "Save this session to your iOS Calendar")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                if !calendarExported {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            }
            .padding(14)
            .background(MVMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(MVMTheme.border)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(calendarExported)
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
    }

    private var logToProgressRow: some View {
        Button {
            guard !logged else { return }
            vm.saveQuickStartRecord(record)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                logged = true
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: logged ? "checkmark.circle.fill" : "chart.line.uptrend.xyaxis")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(logged ? MVMTheme.success : Color(hex: "#FF6B35"))
                    .frame(width: 36, height: 36)
                    .background((logged ? MVMTheme.success : Color(hex: "#FF6B35")).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(logged ? "Logged to Progress" : "Log to Progress")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text(logged ? "Session saved to your training history" : "Save this session to your progress tracker")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                if !logged {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            }
            .padding(14)
            .background(MVMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(logged ? MVMTheme.success.opacity(0.3) : MVMTheme.border)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(logged)
        .sensoryFeedback(.success, trigger: logged)
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
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
