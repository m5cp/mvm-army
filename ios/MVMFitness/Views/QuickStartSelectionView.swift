import SwiftUI

struct QuickStartSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm
    @Bindable var quickStart: QuickStartViewModel

    /// Most recent GPS session of the selected activity worth racing against.
    private var ghostCandidate: QuickStartRecord? {
        guard let activity = quickStart.selectedActivity, activity.usesGPS else { return nil }
        return vm.quickStartRecords.first {
            $0.activity == activity && $0.distanceMeters > 200 && $0.elapsedSeconds > 60
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    headerSection

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(QuickStartActivity.allCases) { activity in
                            activityCard(activity)
                        }
                    }

                    if let selected = quickStart.selectedActivity {
                        gpsInfoBanner(selected)
                    }

                    if let ghost = ghostCandidate {
                        ghostRaceToggle(ghost)
                    }

                    startButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
            .background(MVMTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("QUICK START")
                        .font(.caption.weight(.heavy))
                        .tracking(2.0)
                        .foregroundStyle(MVMTheme.secondaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(MVMTheme.accent.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(MVMTheme.accent)
            }

            Text("Choose Your Activity")
                .font(.title2.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text("Select an activity to start tracking")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .padding(.top, 8)
    }

    private func activityCard(_ activity: QuickStartActivity) -> some View {
        let isSelected = quickStart.selectedActivity == activity
        let hex = activity.gradientHex

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                quickStart.selectActivity(activity)
            }
        } label: {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                                ? LinearGradient(colors: [Color(hex: hex.0), Color(hex: hex.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [MVMTheme.cardSoft, MVMTheme.cardSoft], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 52, height: 52)

                    Image(systemName: activity.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : MVMTheme.secondaryText)
                }

                VStack(spacing: 4) {
                    Text(activity.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? MVMTheme.primaryText : MVMTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    if activity.usesGPS {
                        HStack(spacing: 3) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 8))
                            Text("GPS")
                                .font(.caption2.weight(.bold))
                        }
                        .foregroundStyle(isSelected ? Color(hex: hex.0) : MVMTheme.tertiaryText)
                    } else {
                        Text("Timer Only")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 8)
            .background(isSelected ? MVMTheme.card : MVMTheme.card.opacity(0.6))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color(hex: hex.0).opacity(0.5) : MVMTheme.border, lineWidth: isSelected ? 1.5 : 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(PressScaleButtonStyle())
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    @ViewBuilder
    private func gpsInfoBanner(_ activity: QuickStartActivity) -> some View {
        if activity.usesGPS {
            HStack(spacing: 12) {
                Image(systemName: "map.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 36, height: 36)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("GPS Tracking Enabled")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Your route will be tracked on a map. Location access required.")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer(minLength: 0)
            }
            .padding(14)
            .background(MVMTheme.card)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(MVMTheme.accent.opacity(0.2))
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        } else {
            HStack(spacing: 12) {
                Image(systemName: "timer")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(MVMTheme.slateAccent)
                    .frame(width: 36, height: 36)
                    .background(MVMTheme.slateAccent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Timer Mode")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Session time will be tracked. No GPS needed.")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer(minLength: 0)
            }
            .padding(14)
            .mvmCard(cornerRadius: 14)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }

    /// "Me vs Me" made literal — race the pace of your last session.
    private func ghostRaceToggle(_ ghost: QuickStartRecord) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                quickStart.ghostEnabled.toggle()
                quickStart.ghostRecord = quickStart.ghostEnabled ? ghost : nil
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "figure.run.motion")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(quickStart.ghostEnabled ? MVMTheme.onAmber : MVMTheme.amber)
                    .frame(width: 40, height: 40)
                    .background(quickStart.ghostEnabled ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(MVMTheme.cardSoft))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ghost Race")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Race your last \(ghost.activity.rawValue.lowercased()): \(ghost.formattedDistance) in \(ghost.formattedDuration)")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Image(systemName: quickStart.ghostEnabled ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(quickStart.ghostEnabled ? MVMTheme.amber : MVMTheme.tertiaryText)
            }
            .padding(14)
            .background(MVMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(quickStart.ghostEnabled ? MVMTheme.amber.opacity(0.5) : MVMTheme.border, lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PressScaleButtonStyle())
        .sensoryFeedback(.selection, trigger: quickStart.ghostEnabled)
        .accessibilityLabel("Ghost race, \(quickStart.ghostEnabled ? "on" : "off"). Race your previous \(ghost.activity.rawValue)")
    }

    private var startButton: some View {
        Button {
            quickStart.startSession()
            dismiss()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                    .font(.subheadline.weight(.bold))
                Text("Start \(quickStart.selectedActivity?.rawValue ?? "Activity")")
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(
                quickStart.selectedActivity != nil
                    ? MVMTheme.heroGradient
                    : LinearGradient(colors: [MVMTheme.cardSoft, MVMTheme.cardSoft], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: quickStart.selectedActivity != nil ? MVMTheme.accent.opacity(0.3) : .clear, radius: 16, y: 8)
        }
        .disabled(quickStart.selectedActivity == nil)
        .opacity(quickStart.selectedActivity == nil ? 0.5 : 1)
        .buttonStyle(PressScaleButtonStyle())
    }
}
