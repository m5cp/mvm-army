import Foundation
import HealthKit

@Observable
@MainActor
final class WatchWorkoutManager: NSObject {
    static let shared = WatchWorkoutManager()

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    var isActive = false
    var elapsedSeconds: Int = 0
    var heartRate: Double = 0
    var activeCalories: Double = 0
    private var timer: Timer?

    func requestAuthorization() async -> Bool {
        let share: Set<HKSampleType> = [HKObjectType.workoutType()]
        var read: Set<HKObjectType> = [HKObjectType.workoutType()]
        if let hr = HKObjectType.quantityType(forIdentifier: .heartRate) { read.insert(hr) }
        if let cal = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) { read.insert(cal) }
        do {
            try await healthStore.requestAuthorization(toShare: share, read: read)
            return true
        } catch { return false }
    }

    func start(activityType: HKWorkoutActivityType, isOutdoor: Bool) async {
        guard !isActive else { return }
        let config = HKWorkoutConfiguration()
        config.activityType = activityType
        config.locationType = isOutdoor ? .outdoor : .indoor
        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            let builder = session.associatedWorkoutBuilder()
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)
            builder.delegate = self
            self.session = session
            self.builder = builder
            session.startActivity(with: .now)
            try await builder.beginCollection(at: .now)
            isActive = true
            elapsedSeconds = 0
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                Task { @MainActor in self.elapsedSeconds += 1 }
            }
        } catch {
            print("Watch workout start failed: \(error.localizedDescription)")
        }
    }

    func end() async {
        timer?.invalidate(); timer = nil
        session?.end()
        do {
            try await builder?.endCollection(at: .now)
            try await builder?.finishWorkout()
        } catch {
            print("Watch workout end failed: \(error.localizedDescription)")
        }
        isActive = false
        session = nil
        builder = nil
    }
}

extension WatchWorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType,
                  let stats = workoutBuilder.statistics(for: quantityType) else { continue }
            Task { @MainActor in
                switch quantityType.identifier {
                case HKQuantityTypeIdentifier.heartRate.rawValue:
                    self.heartRate = stats.mostRecentQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? self.heartRate
                case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
                    self.activeCalories = stats.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? self.activeCalories
                default: break
                }
            }
        }
    }

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
