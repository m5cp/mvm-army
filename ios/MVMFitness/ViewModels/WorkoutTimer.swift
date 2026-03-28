import Foundation
import Combine

@Observable
final class WorkoutTimer {
    var timeRemaining: Int = 0
    var isRunning: Bool = false
    var timerMode: TimerMode = .none
    var showRestTimer: Bool = false
    var restTimeRemaining: Int = 0
    var isRestRunning: Bool = false
    var autoAdvance: Bool = true

    private var timer: Timer?
    private var restTimer: Timer?

    nonisolated enum TimerMode: Equatable, Sendable {
        case none
        case countdown(Int)
        case amrap(Int)
        case emom(Int, perRound: Int)
        case interval(work: Int, rest: Int)
    }

    var totalDuration: Int {
        switch timerMode {
        case .none: return 0
        case .countdown(let s): return s
        case .amrap(let s): return s
        case .emom(let s, _): return s
        case .interval(let w, _): return w
        }
    }

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (Double(timeRemaining) / Double(totalDuration))
    }

    var formattedTime: String {
        let mins = timeRemaining / 60
        let secs = timeRemaining % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    var formattedRestTime: String {
        let mins = restTimeRemaining / 60
        let secs = restTimeRemaining % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    var hasTimer: Bool {
        timerMode != .none
    }

    func configure(for exercise: WorkoutExercise) {
        stopAll()

        if exercise.isTimeBased && exercise.durationSeconds > 0 {
            timerMode = .countdown(exercise.durationSeconds)
            timeRemaining = exercise.durationSeconds
        } else {
            timerMode = .none
            timeRemaining = 0
        }
    }

    func configureAMRAP(minutes: Int) {
        stopAll()
        let seconds = minutes * 60
        timerMode = .amrap(seconds)
        timeRemaining = seconds
    }

    func configureEMOM(totalMinutes: Int, perRoundSeconds: Int = 60) {
        stopAll()
        let seconds = totalMinutes * 60
        timerMode = .emom(seconds, perRound: perRoundSeconds)
        timeRemaining = seconds
    }

    func configureInterval(workSeconds: Int, restSeconds: Int) {
        stopAll()
        timerMode = .interval(work: workSeconds, rest: restSeconds)
        timeRemaining = workSeconds
    }

    func startPause() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    func start() {
        guard timeRemaining > 0 else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        timeRemaining = totalDuration
    }

    func startRest(seconds: Int) {
        restTimeRemaining = seconds
        showRestTimer = true
        isRestRunning = true
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.restTick()
            }
        }
    }

    func skipRest() {
        stopRest()
    }

    func stopAll() {
        pause()
        stopRest()
        timerMode = .none
        timeRemaining = 0
    }

    private func tick() {
        guard timeRemaining > 0 else {
            pause()
            return
        }
        timeRemaining -= 1
        if timeRemaining <= 0 {
            pause()
        }
    }

    private func restTick() {
        guard restTimeRemaining > 0 else {
            stopRest()
            return
        }
        restTimeRemaining -= 1
        if restTimeRemaining <= 0 {
            stopRest()
        }
    }

    private func stopRest() {
        isRestRunning = false
        showRestTimer = false
        restTimeRemaining = 0
        restTimer?.invalidate()
        restTimer = nil
    }
}
