import SwiftUI
import MapKit
import UIKit

struct ActiveQuickStartView: View {
    @Environment(AppViewModel.self) private var vm
    @Bindable var quickStart: QuickStartViewModel

    @State private var endTrigger: Bool = false
    @State private var pauseTrigger: Bool = false
    @State private var showEndConfirm: Bool = false
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var animateTimer: Bool = false
    /// true = ahead of the ghost, false = behind; nil until the race settles.
    @State private var ghostAheadState: Bool?
    /// Fires the "ghost is closing" warning pulse once per close-approach.
    @State private var ghostClosingWarned: Bool = false
    @State private var ghostClosingPulse: Int = 0

    private var activity: QuickStartActivity {
        quickStart.selectedActivity ?? .outdoorRun
    }

    private var hex: (String, String) {
        activity.gradientHex
    }

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                if quickStart.usesGPS {
                    mapSection
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if !quickStart.usesGPS {
                            Spacer().frame(height: 8)
                        }

                        activityBadge

                        if quickStart.ghostActive {
                            ghostPacerSection
                        }

                        timerDisplay

                        if quickStart.usesGPS {
                            statsGrid
                        }

                        controlButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 48)
                    .adaptiveContainer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(quickStart.isPaused ? MVMTheme.warning : MVMTheme.success)
                        .frame(width: 8, height: 8)
                    Text(quickStart.isPaused ? "PAUSED" : "ACTIVE")
                        .font(.caption.weight(.heavy))
                        .tracking(1.5)
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }
        }
        .confirmationDialog("End Activity?", isPresented: $showEndConfirm, titleVisibility: .visible) {
            Button("End \(activity.rawValue)", role: .destructive) {
                endTrigger.toggle()
                quickStart.endSession()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your session data will be saved.")
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: endTrigger)
        .sensoryFeedback(.selection, trigger: pauseTrigger)
        // Overtake = success tap; overtaken = warning buzz.
        .sensoryFeedback(trigger: ghostAheadState) { old, new in
            guard old != nil, let new else { return nil }
            return new ? .success : .warning
        }
        // "Ghost is closing" pulse when your lead shrinks under 5 seconds.
        .sensoryFeedback(.impact(weight: .medium, intensity: 0.9), trigger: ghostClosingPulse)
        .onChange(of: quickStart.elapsedSeconds) { _, _ in
            updateGhostState()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                animateTimer = true
            }
            // Keep the screen awake for the whole session — pacing and maps
            // are useless behind a locked screen.
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // MARK: - Ghost race

    private func updateGhostState() {
        guard quickStart.ghostActive, quickStart.elapsedSeconds > 10,
              quickStart.locationService.totalDistanceMeters > 30 else { return }
        let delta = quickStart.ghostDeltaSeconds
        let ahead = delta >= 0
        if ghostAheadState != ahead {
            ghostAheadState = ahead
            ghostClosingWarned = false
        }
        // Warn once each time a comfortable lead (>10 s) shrinks below 5 s.
        if ahead {
            if delta > 10 { ghostClosingWarned = false }
            if delta < 5, !ghostClosingWarned {
                ghostClosingWarned = true
                ghostClosingPulse += 1
            }
        }
    }

    private var ghostPacerSection: some View {
        let delta = quickStart.ghostDeltaSeconds
        let ahead = delta >= 0
        let progress = quickStart.ghostProgress

        return VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "figure.run.motion")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.amber)
                Text("GHOST RACE")
                    .font(MVMTheme.mono(10))
                    .kerning(1.6)
                    .foregroundStyle(MVMTheme.textFaint)

                Spacer()

                // The big ahead/behind readout.
                HStack(spacing: 5) {
                    Image(systemName: ahead ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .font(.caption.weight(.heavy))
                    Text(ghostDeltaLabel(delta))
                        .font(.system(size: 17, weight: .heavy, design: .monospaced))
                        .contentTransition(.numericText())
                }
                .foregroundStyle(ahead ? MVMTheme.success : MVMTheme.danger)
                .lineLimit(1)
                .fixedSize()
            }

            // Pacer track: you (amber) vs ghost (gray) along the ghost's distance.
            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(MVMTheme.well)
                        .frame(height: 6)

                    // Ghost marker
                    Circle()
                        .fill(Color.white.opacity(0.45))
                        .frame(width: 14, height: 14)
                        .overlay { Circle().stroke(.white.opacity(0.7), lineWidth: 1.5) }
                        .offset(x: max(0, width * progress.ghost - 7))
                        .animation(.linear(duration: 1), value: progress.ghost)

                    // You
                    Circle()
                        .fill(MVMTheme.amberButtonGradient)
                        .frame(width: 18, height: 18)
                        .overlay { Circle().stroke(.white, lineWidth: 2) }
                        .shadow(color: MVMTheme.amber.opacity(0.6), radius: 6)
                        .offset(x: max(0, width * progress.you - 9))
                        .animation(.linear(duration: 1), value: progress.you)
                }
                .frame(height: 18)
            }
            .frame(height: 18)

            HStack {
                Text("YOU")
                    .font(MVMTheme.mono(9, weight: .bold))
                    .foregroundStyle(MVMTheme.amber)
                Text("\(quickStart.formattedDistance)")
                    .font(MVMTheme.mono(9))
                    .foregroundStyle(MVMTheme.textMuted)
                Spacer()
                Text("GHOST")
                    .font(MVMTheme.mono(9, weight: .bold))
                    .foregroundStyle(MVMTheme.textFaint)
                Text(String(format: "%.2f mi", quickStart.ghostDistanceMeters / 1609.34))
                    .font(MVMTheme.mono(9))
                    .foregroundStyle(MVMTheme.textFaint)
            }
        }
        .padding(16)
        .background(MVMTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(ahead ? MVMTheme.success.opacity(0.35) : MVMTheme.danger.opacity(0.35), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Ghost race: \(ahead ? "ahead" : "behind") by \(ghostDeltaLabel(delta))")
    }

    private func ghostDeltaLabel(_ delta: Double) -> String {
        let seconds = Int(abs(delta).rounded())
        let label = String(format: "%d:%02d", seconds / 60, seconds % 60)
        return delta >= 0 ? "\(label) AHEAD" : "\(label) BEHIND"
    }

    private var mapSection: some View {
        Map(position: $mapPosition) {
            UserAnnotation()

            if quickStart.locationService.routeCoordinates.count > 1 {
                MapPolyline(coordinates: quickStart.locationService.routeCoordinates)
                    .stroke(Color(hex: hex.0), lineWidth: 4)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(MVMTheme.border)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var activityBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: activity.icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(hex: hex.0))
            Text(activity.rawValue.uppercased())
                .font(.caption.weight(.heavy))
                .tracking(1.0)
                .foregroundStyle(Color(hex: hex.0))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(Color(hex: hex.0).opacity(0.12))
        .clipShape(Capsule())
    }

    private var timerDisplay: some View {
        VStack(spacing: 8) {
            Text(quickStart.formattedTime)
                .font(.system(size: 72, weight: .bold, design: .monospaced))
                .foregroundStyle(MVMTheme.primaryText)
                .contentTransition(.numericText())
                .animation(.default, value: quickStart.elapsedSeconds)
                .scaleEffect(animateTimer ? 1 : 0.8)
                .opacity(animateTimer ? 1 : 0)

            if quickStart.isPaused {
                Text("PAUSED")
                    .font(.caption.weight(.heavy))
                    .tracking(2.0)
                    .foregroundStyle(MVMTheme.warning)
                    .transition(.opacity)
            }
        }
    }

    private var statsGrid: some View {
        HStack(spacing: 0) {
            statCell(
                value: quickStart.formattedDistance,
                label: "Distance",
                icon: "point.topleft.down.to.point.bottomright.curvepath.fill"
            )

            Rectangle()
                .fill(MVMTheme.border)
                .frame(width: 1, height: 40)

            statCell(
                value: quickStart.formattedPace,
                label: "Avg Pace",
                icon: "speedometer"
            )

            Rectangle()
                .fill(MVMTheme.border)
                .frame(width: 1, height: 40)

            statCell(
                value: quickStart.formattedSpeed,
                label: "Speed",
                icon: "gauge.with.dots.needle.33percent"
            )
        }
        .padding(.vertical, 18)
        .mvmCard(cornerRadius: 18)
    }

    private func statCell(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color(hex: hex.0))

            Text(value)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
                .contentTransition(.numericText())
                .animation(.default, value: value)

            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var controlButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    pauseTrigger.toggle()
                    quickStart.togglePause()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: quickStart.isPaused ? "play.fill" : "pause.fill")
                            .font(.subheadline.weight(.bold))
                        Text(quickStart.isPaused ? "Resume" : "Pause")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(
                        quickStart.isPaused
                            ? LinearGradient(colors: [Color(hex: hex.0), Color(hex: hex.1)], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [MVMTheme.warning, MVMTheme.warning.opacity(0.9)], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    showEndConfirm = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                            .font(.subheadline.weight(.bold))
                        Text("End")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(height: 56)
                    .frame(width: 100)
                    .background(MVMTheme.danger)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())
            }

            if quickStart.usesGPS && !quickStart.locationService.isAuthorized {
                Button {
                    quickStart.locationService.requestPermission()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.caption.weight(.bold))
                        Text("Enable Location for GPS Tracking")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.accent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(MVMTheme.accent.opacity(0.2))
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
    }
}
