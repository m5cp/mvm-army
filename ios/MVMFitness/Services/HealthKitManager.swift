import Foundation
import HealthKit
import Observation

@Observable
final class HealthKitManager {
    private let store = HKHealthStore()

    var isAvailable: Bool = HKHealthStore.isHealthDataAvailable()
    var authorizationStatus: HKAuthorizationStatus = .notDetermined
    var todaySteps: Int = 0
    var todayActiveCalories: Double = 0
    var hasRequestedAuthorization: Bool = false

    private let stepType = HKQuantityType(.stepCount)
    private let activeEnergyType = HKQuantityType(.activeEnergyBurned)
    private let workoutType = HKObjectType.workoutType()

    var readTypes: Set<HKObjectType> {
        [stepType, activeEnergyType, workoutType]
    }

    var writeTypes: Set<HKSampleType> {
        [workoutType, activeEnergyType]
    }

    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }

        do {
            try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
            hasRequestedAuthorization = true
            authorizationStatus = store.authorizationStatus(for: stepType)
            return true
        } catch {
            return false
        }
    }

    func fetchTodaySteps() async {
        guard isAvailable else { return }

        let start = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now, options: .strictStartDate)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                Task { @MainActor in
                    self.todaySteps = Int(steps)
                    continuation.resume()
                }
            }
            store.execute(query)
        }
    }

    func fetchTodayActiveCalories() async {
        guard isAvailable else { return }

        let start = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now, options: .strictStartDate)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let query = HKStatisticsQuery(
                quantityType: activeEnergyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let cals = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                Task { @MainActor in
                    self.todayActiveCalories = cals
                    continuation.resume()
                }
            }
            store.execute(query)
        }
    }

    func saveWorkout(title: String, duration: TimeInterval, calories: Double?) async {
        guard isAvailable else { return }

        let config = HKWorkoutConfiguration()
        config.activityType = .functionalStrengthTraining
        config.locationType = .unknown

        let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: .local())

        do {
            try await builder.beginCollection(at: Date().addingTimeInterval(-duration))

            if let cal = calories, cal > 0 {
                let energySample = HKQuantitySample(
                    type: activeEnergyType,
                    quantity: HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: cal),
                    start: Date().addingTimeInterval(-duration),
                    end: .now
                )
                try await builder.addSamples([energySample])
            }

            try await builder.endCollection(at: .now)
            try await builder.finishWorkout()
        } catch {
            // Silently fail - workout save is best-effort
        }
    }
}
