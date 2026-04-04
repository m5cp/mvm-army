import SwiftUI
import MapKit

struct ActiveQuickStartView: View {
    @Environment(AppViewModel.self) private var vm
    @Bindable var quickStart: QuickStartViewModel

    @State private var endTrigger: Bool = false
    @State private var pauseTrigger: Bool = false
    @State private var showEndConfirm: Bool = false
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var animateTimer: Bool = false

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
                let record = quickStart.completedRecord
                if let record {
                    vm.saveQuickStartRecord(record)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your session data will be saved.")
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: endTrigger)
        .sensoryFeedback(.selection, trigger: pauseTrigger)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                animateTimer = true
            }
        }
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
        .background(MVMTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(MVMTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
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
