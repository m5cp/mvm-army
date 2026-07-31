import Testing
import Foundation
@testable import MVMFitness

/// Phase 16 (slice 1) — tests for the step-history date-bucketing logic
/// extracted into `StepTrackingService`. No CoreMotion/device hardware
/// involved: `pedometer.todaySteps` is set directly to drive the bucket
/// update, exactly like the pedometer's completion handler would.
@Suite("StepTrackingService — date bucketing")
struct StepTrackingServiceTests {

    @MainActor
    @Test func updateTodayBucketAppendsWhenNoEntryExistsForToday() {
        let service = StepTrackingService()
        service.pedometer.todaySteps = 4200

        service.updateTodayBucket()

        #expect(service.stepHistory.count == 1)
        #expect(service.stepHistory[0].steps == 4200)
        #expect(Calendar.current.isDateInToday(service.stepHistory[0].date))
    }

    @MainActor
    @Test func updateTodayBucketUpdatesExistingEntryForToday() {
        let service = StepTrackingService()
        let today = Calendar.current.startOfDay(for: .now)
        service.stepHistory = [StepDay(date: today, steps: 100)]
        service.pedometer.todaySteps = 9999

        service.updateTodayBucket()

        #expect(service.stepHistory.count == 1)
        #expect(service.stepHistory[0].steps == 9999)
    }

    @MainActor
    @Test func updateTodayBucketDoesNotTouchOtherDays() {
        let service = StepTrackingService()
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: .now)!
        service.stepHistory = [StepDay(date: yesterday, steps: 5000)]
        service.pedometer.todaySteps = 1234

        service.updateTodayBucket()

        #expect(service.stepHistory.count == 2)
        let yesterdayEntry = service.stepHistory.first { calendar.isDate($0.date, inSameDayAs: yesterday) }
        #expect(yesterdayEntry?.steps == 5000)
    }

    @MainActor
    @Test func updateTodayBucketKeepsHistorySortedOldestFirst() {
        let service = StepTrackingService()
        let calendar = Calendar.current
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: .now)!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: .now)!
        service.stepHistory = [
            StepDay(date: yesterday, steps: 3000),
            StepDay(date: twoDaysAgo, steps: 2000)
        ]
        service.pedometer.todaySteps = 4000

        service.updateTodayBucket()

        let dates = service.stepHistory.map(\.date)
        #expect(dates == dates.sorted())
    }

    @MainActor
    @Test func averageStepsIsZeroWhenEmpty() {
        let service = StepTrackingService()
        #expect(service.averageSteps == 0)
    }

    @MainActor
    @Test func averageStepsComputesMeanAcrossHistory() {
        let service = StepTrackingService()
        service.stepHistory = [
            StepDay(date: .now, steps: 1000),
            StepDay(date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!, steps: 3000)
        ]
        #expect(service.averageSteps == 2000)
    }

    @MainActor
    @Test func weeklyStepAverageOnlyCountsLastSevenDays() {
        let service = StepTrackingService()
        let calendar = Calendar.current
        let recent = calendar.date(byAdding: .day, value: -2, to: .now)!
        let stale = calendar.date(byAdding: .day, value: -30, to: .now)!
        service.stepHistory = [
            StepDay(date: recent, steps: 6000),
            StepDay(date: stale, steps: 100)
        ]
        #expect(service.weeklyStepAverage == 6000)
    }

    @MainActor
    @Test func clearEmptiesHistory() {
        let service = StepTrackingService()
        service.stepHistory = [StepDay(date: .now, steps: 500)]
        service.clear()
        #expect(service.stepHistory.isEmpty)
    }

    @MainActor
    @Test func loadAndPersistRoundTripThroughDataStore() {
        let service = StepTrackingService()
        service.stepHistory = [StepDay(date: .now, steps: 7777)]
        service.persist()

        let reloaded = StepTrackingService()
        reloaded.load()

        #expect(reloaded.stepHistory == service.stepHistory)
    }
}
