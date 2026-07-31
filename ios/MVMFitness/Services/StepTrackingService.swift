import Foundation
import Observation

/// Owns step-count tracking: the pedometer wrapper, the persisted day-by-day
/// step history, and the date-bucketing logic used to fold today's live
/// pedometer reading into that history. Extracted from `AppViewModel` in
/// Phase 16 (slice 1) with zero behavior change — `AppViewModel` keeps its
/// existing `pedometer` / `stepHistory` public surface, now backed by this
/// service.
@Observable
final class StepTrackingService {
    private static let storageKey = "stepHistory"

    var pedometer = PedometerManager()
    var stepHistory: [StepDay] = []

    /// Loads persisted step history from `DataStore`.
    func load() {
        stepHistory = DataStore.load([StepDay].self, forKey: Self.storageKey, fallback: [])
    }

    /// Persists the current step history to `DataStore`.
    func persist() {
        DataStore.save(stepHistory, forKey: Self.storageKey)
    }

    /// Folds the pedometer's live today-reading into `stepHistory`: updates
    /// today's bucket if it already exists, otherwise appends a new one, then
    /// keeps the history sorted oldest-to-newest. Pure state update — callers
    /// are responsible for any follow-up persistence/logging.
    func updateTodayBucket(referenceDate: Date = .now) {
        let today = Calendar.current.startOfDay(for: referenceDate)
        if let index = stepHistory.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            stepHistory[index].steps = pedometer.todaySteps
        } else {
            stepHistory.append(StepDay(date: today, steps: pedometer.todaySteps))
        }
        stepHistory.sort { $0.date < $1.date }
    }

    func clear() {
        stepHistory = []
    }

    var averageSteps: Int {
        guard !stepHistory.isEmpty else { return 0 }
        return stepHistory.map(\.steps).reduce(0, +) / stepHistory.count
    }

    var weeklyStepAverage: Int {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: .now) ?? .now
        let recentSteps = stepHistory.filter { $0.date >= sevenDaysAgo }
        guard !recentSteps.isEmpty else { return 0 }
        return recentSteps.map(\.steps).reduce(0, +) / recentSteps.count
    }
}
