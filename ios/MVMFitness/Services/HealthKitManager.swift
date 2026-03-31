import Foundation
import HealthKit
import Observation

nonisolated struct ActivitySummary: Identifiable, Sendable {
    let id: String
    let activityType: HKWorkoutActivityType
    let name: String
    let icon: String
    let todayDuration: TimeInterval
    let todayCalories: Double
    let todayDistance: Double
    let weeklyAvgDuration: TimeInterval
    let weeklyAvgCalories: Double
    let weeklyAvgDistance: Double
    let todayCount: Int
    let hasData: Bool
}

@Observable
final class HealthKitManager {
    private let store = HKHealthStore()

    var isAvailable: Bool = HKHealthStore.isHealthDataAvailable()
    var authorizationStatus: HKAuthorizationStatus = .notDetermined
    var todaySteps: Int = 0
    var todayActiveCalories: Double = 0
    var weeklyAvgSteps: Int = 0
    var hasRequestedAuthorization: Bool = false
    var permissionDenied: Bool = false
    var activities: [ActivitySummary] = []
    var isLoadingActivities: Bool = false

    private let stepType = HKQuantityType(.stepCount)
    private let activeEnergyType = HKQuantityType(.activeEnergyBurned)
    private let distanceWalkRunType = HKQuantityType(.distanceWalkingRunning)
    private let distanceCyclingType = HKQuantityType(.distanceCycling)
    private let workoutType = HKObjectType.workoutType()

    var readTypes: Set<HKObjectType> {
        [stepType, activeEnergyType, distanceWalkRunType, distanceCyclingType, workoutType]
    }



    private let trackedActivityTypes: [(HKWorkoutActivityType, String, String)] = [
        (.running, "Running", "figure.run"),
        (.walking, "Walking", "figure.walk"),
        (.cycling, "Cycling", "figure.outdoor.cycle"),
        (.elliptical, "Elliptical", "figure.elliptical"),
        (.functionalStrengthTraining, "Strength Training", "figure.strengthtraining.traditional"),
        (.traditionalStrengthTraining, "Weight Training", "dumbbell.fill"),
        (.highIntensityIntervalTraining, "HIIT", "bolt.heart.fill"),
        (.coreTraining, "Core Training", "figure.core.training"),
        (.flexibility, "Flexibility", "figure.flexibility"),
        (.swimming, "Swimming", "figure.pool.swim"),
        (.rowing, "Rowing", "figure.rowing"),
        (.stairClimbing, "Stair Climbing", "figure.stair.stepper"),
        (.hiking, "Hiking", "figure.hiking"),
        (.yoga, "Yoga", "figure.yoga"),
        (.cooldown, "Cooldown", "figure.cooldown"),
    ]

    func requestAuthorization() async -> Bool {
        guard isAvailable else {
            permissionDenied = true
            return false
        }

        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            hasRequestedAuthorization = true
            authorizationStatus = store.authorizationStatus(for: stepType)
            if authorizationStatus == .sharingDenied {
                permissionDenied = true
            }
            return true
        } catch {
            permissionDenied = true
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
            ) { _, result, error in
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                let denied = (error as? NSError)?.code == 5
                Task { @MainActor in
                    self.todaySteps = Int(steps)
                    if denied { self.permissionDenied = true }
                    continuation.resume()
                }
            }
            store.execute(query)
        }
    }

    func fetchWeeklyAvgSteps() async {
        guard isAvailable else { return }

        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: .now)
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else { return }

        var dailySteps: [Int] = []

        for dayOffset in 0..<7 {
            guard let dayStart = calendar.date(byAdding: .day, value: dayOffset, to: startDate),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { continue }

            let predicate = HKQuery.predicateForSamples(withStart: dayStart, end: dayEnd, options: .strictStartDate)

            let steps: Int = await withCheckedContinuation { continuation in
                let query = HKStatisticsQuery(
                    quantityType: stepType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, result, _ in
                    let value = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                    continuation.resume(returning: Int(value))
                }
                store.execute(query)
            }
            dailySteps.append(steps)
        }

        let nonZeroDays = dailySteps.filter { $0 > 0 }
        let avg = nonZeroDays.isEmpty ? 0 : nonZeroDays.reduce(0, +) / nonZeroDays.count
        weeklyAvgSteps = avg
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

    func fetchAllActivities() async {
        guard isAvailable else { return }
        isLoadingActivities = true

        var results: [ActivitySummary] = []
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: .now)
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: todayStart) ?? todayStart

        for (activityType, name, icon) in trackedActivityTypes {
            let todayData = await fetchWorkoutData(for: activityType, from: todayStart, to: .now)
            let weekData = await fetchWorkoutData(for: activityType, from: sevenDaysAgo, to: .now)

            let daysWithData = countDaysWithWorkouts(weekData.workouts, from: sevenDaysAgo)
            let divisor = max(daysWithData, 1)

            let summary = ActivitySummary(
                id: "\(activityType.rawValue)",
                activityType: activityType,
                name: name,
                icon: icon,
                todayDuration: todayData.totalDuration,
                todayCalories: todayData.totalCalories,
                todayDistance: todayData.totalDistance,
                weeklyAvgDuration: weekData.totalDuration / Double(divisor),
                weeklyAvgCalories: weekData.totalCalories / Double(divisor),
                weeklyAvgDistance: weekData.totalDistance / Double(divisor),
                todayCount: todayData.workouts.count,
                hasData: !weekData.workouts.isEmpty
            )

            if summary.hasData {
                results.append(summary)
            }
        }

        activities = results
        isLoadingActivities = false
    }

    private nonisolated struct WorkoutData: Sendable {
        let workouts: [SendableWorkoutInfo]
        let totalDuration: TimeInterval
        let totalCalories: Double
        let totalDistance: Double
    }

    private nonisolated struct SendableWorkoutInfo: Sendable {
        let startDate: Date
        let duration: TimeInterval
        let calories: Double
        let distance: Double
    }

    private func fetchWorkoutData(for activityType: HKWorkoutActivityType, from startDate: Date, to endDate: Date) async -> WorkoutData {
        let typePredicate = HKQuery.predicateForWorkouts(with: activityType)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [typePredicate, datePredicate])

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: compound,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, _ in
                let workouts = (samples as? [HKWorkout]) ?? []

                var totalDuration: TimeInterval = 0
                var totalCalories: Double = 0
                var totalDistance: Double = 0
                var infos: [SendableWorkoutInfo] = []

                for workout in workouts {
                    totalDuration += workout.duration
                    let cal = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
                    totalCalories += cal
                    let dist = workout.totalDistance?.doubleValue(for: .mile()) ?? 0
                    totalDistance += dist
                    infos.append(SendableWorkoutInfo(
                        startDate: workout.startDate,
                        duration: workout.duration,
                        calories: cal,
                        distance: dist
                    ))
                }

                continuation.resume(returning: WorkoutData(
                    workouts: infos,
                    totalDuration: totalDuration,
                    totalCalories: totalCalories,
                    totalDistance: totalDistance
                ))
            }
            store.execute(query)
        }
    }

    private func countDaysWithWorkouts(_ workouts: [SendableWorkoutInfo], from startDate: Date) -> Int {
        let calendar = Calendar.current
        let uniqueDays = Set(workouts.map { calendar.startOfDay(for: $0.startDate) })
        return max(uniqueDays.count, 1)
    }



    func refreshAll() async {
        _ = await requestAuthorization()
        await fetchTodaySteps()
        await fetchWeeklyAvgSteps()
        await fetchTodayActiveCalories()
        await fetchAllActivities()
    }
}
