import SwiftUI
import HealthKit
import Observation

@Observable
final class WatchViewModel {
    var data: WatchData = WatchData()
    var todaySteps: Int = 0
    var todayCalories: Double = 0
    var todayDistance: Double = 0
    var heartRate: Double = 0
    var isLoadingHealth: Bool = false

    private let healthStore = HKHealthStore()

    func refresh() {
        data = WatchSharedData.readWidgetData()
        Task {
            await fetchHealthData()
        }
    }

    func requestHealthAccess() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.heartRate)
        ]

        let writeTypes: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning)
        ]

        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
        } catch {}
    }

    func fetchHealthData() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        isLoadingHealth = true

        let start = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now, options: .strictStartDate)

        async let steps = fetchSum(type: HKQuantityType(.stepCount), unit: .count(), predicate: predicate)
        async let cals = fetchSum(type: HKQuantityType(.activeEnergyBurned), unit: .kilocalorie(), predicate: predicate)
        async let dist = fetchSum(type: HKQuantityType(.distanceWalkingRunning), unit: .mile(), predicate: predicate)
        async let hr = fetchLatestHeartRate()

        let (s, c, d, h) = await (steps, cals, dist, hr)
        todaySteps = Int(s)
        todayCalories = c
        todayDistance = d
        heartRate = h
        isLoadingHealth = false
    }

    private func fetchSum(type: HKQuantityType, unit: HKUnit, predicate: NSPredicate) async -> Double {
        await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }

    private func fetchLatestHeartRate() async -> Double {
        let hrType = HKQuantityType(.heartRate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: hrType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: 0)
                    return
                }
                let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                continuation.resume(returning: bpm)
            }
            healthStore.execute(query)
        }
    }

    func saveWorkoutToHealth(title: String, duration: TimeInterval) async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }

        let config = HKWorkoutConfiguration()
        config.activityType = .functionalStrengthTraining
        config.locationType = .indoor

        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: config, device: .local())

        do {
            let endDate = Date()
            let startDate = endDate.addingTimeInterval(-duration)
            try await builder.beginCollection(at: startDate)
            try await builder.endCollection(at: endDate)
            try await builder.finishWorkout()
            return true
        } catch {
            return false
        }
    }
}
