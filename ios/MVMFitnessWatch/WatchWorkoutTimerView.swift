import SwiftUI

struct WatchWorkoutTimerView: View {
    @Environment(WatchViewModel.self) private var viewModel
    @State private var elapsedSeconds: Int = 0
    @State private var isRunning: Bool = false
    @State private var timer: Timer?
    @State private var startDate: Date?
    @State private var showComplete: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Text("WORKOUT")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundStyle(WatchTheme.accent)

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: timerProgress)
                    .stroke(
                        isRunning ? WatchTheme.accent : WatchTheme.warning,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: timerProgress)

                VStack(spacing: 2) {
                    Text(formattedTime)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)

                    Text(isRunning ? "In Progress" : (elapsedSeconds > 0 ? "Paused" : "Ready"))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(WatchTheme.subtleText)
                }
            }
            .frame(width: 120, height: 120)

            HStack(spacing: 12) {
                if elapsedSeconds > 0 {
                    Button {
                        resetTimer()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(WatchTheme.danger.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    toggleTimer()
                } label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(isRunning ? WatchTheme.warning : WatchTheme.accent)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                if elapsedSeconds > 0 && !isRunning {
                    Button {
                        completeWorkout()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(WatchTheme.success.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(isPresented: $showComplete) {
            workoutCompleteSheet
        }
    }

    private var workoutCompleteSheet: some View {
        VStack(spacing: 10) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 32))
                .foregroundStyle(.yellow)

            Text("Workout Saved!")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(formattedDuration(elapsedSeconds))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(WatchTheme.subtleText)

            Button("Done") {
                showComplete = false
                resetTimer()
            }
            .tint(WatchTheme.accent)
        }
    }

    private var timerProgress: Double {
        let maxTime: Double = 3600
        return min(Double(elapsedSeconds) / maxTime, 1.0)
    }

    private var formattedTime: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    private func formattedDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return "\(m)m \(s)s"
    }

    private func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        isRunning = true
        if startDate == nil {
            startDate = Date()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                elapsedSeconds += 1
            }
        }
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        pauseTimer()
        elapsedSeconds = 0
        startDate = nil
    }

    private func completeWorkout() {
        pauseTimer()
        let duration = TimeInterval(elapsedSeconds)
        Task {
            _ = await viewModel.saveWorkoutToHealth(
                title: viewModel.data.todayWorkoutTitle ?? "MVM Workout",
                duration: duration
            )
            showComplete = true
        }
    }
}
