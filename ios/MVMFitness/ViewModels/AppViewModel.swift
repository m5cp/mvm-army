import SwiftUI
import Observation

@Observable
final class AppViewModel {
    var currentPlan: WeeklyPlan?
    var completedRecords: [CompletedWorkoutRecord] = []
    var stepHistory: [StepDay] = []
    var pedometer = PedometerManager()
    var lastWorkoutTag: String = ""

    init() {
        loadLocalData()
        pedometer.refreshTodaySteps()
        syncTodaySteps()
    }

    func loadLocalData() {
        currentPlan = LocalStore.load(WeeklyPlan?.self, forKey: "currentPlan", fallback: nil)
        completedRecords = LocalStore.load([CompletedWorkoutRecord].self, forKey: "completedRecords", fallback: [])
        stepHistory = LocalStore.load([StepDay].self, forKey: "stepHistory", fallback: [])
        lastWorkoutTag = UserDefaults.standard.string(forKey: "lastWorkoutTag") ?? ""
    }

    func persistAll() {
        LocalStore.save(currentPlan, forKey: "currentPlan")
        LocalStore.save(completedRecords, forKey: "completedRecords")
        LocalStore.save(stepHistory, forKey: "stepHistory")
        UserDefaults.standard.set(lastWorkoutTag, forKey: "lastWorkoutTag")
    }

    func syncTodaySteps() {
        let today = Calendar.current.startOfDay(for: .now)
        if let index = stepHistory.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            stepHistory[index].steps = pedometer.todaySteps
        } else {
            stepHistory.append(StepDay(date: today, steps: pedometer.todaySteps))
        }
        stepHistory.sort { $0.date < $1.date }
        persistAll()
    }

    // MARK: - Plan Generation

    func generateWeeklyPlan() {
        let goal = TrainingGoal(rawValue: UserDefaults.standard.string(forKey: "trainingGoal") ?? TrainingGoal.generalFitness.rawValue) ?? .generalFitness
        let level = FitnessLevel(rawValue: UserDefaults.standard.string(forKey: "fitnessLevel") ?? FitnessLevel.intermediate.rawValue) ?? .intermediate
        let equipment = EquipmentOption(rawValue: UserDefaults.standard.string(forKey: "equipment") ?? EquipmentOption.bodyweight.rawValue) ?? .bodyweight
        let days = UserDefaults.standard.integer(forKey: "daysPerWeek")
        let daysPerWeek = days > 0 ? days : 3
        let mins = UserDefaults.standard.integer(forKey: "minutesPerWorkout")
        let minutesPerWorkout = mins > 0 ? mins : 30

        currentPlan = WorkoutGenerator.generateWeeklyPlan(
            goal: goal,
            level: level,
            equipment: equipment,
            daysPerWeek: daysPerWeek,
            minutesPerWorkout: minutesPerWorkout
        )
        persistAll()
    }

    func generateWorkoutOfDay() -> WorkoutDay {
        let goal = currentTrainingGoal
        let level = currentFitnessLevel
        let equipment = currentEquipment
        let mins = currentMinutes

        let wod = WorkoutGenerator.generateWorkoutOfDay(
            goal: goal, level: level, equipment: equipment,
            minutes: mins, lastWorkoutTag: lastWorkoutTag
        )
        return wod
    }

    func generateRandomWorkout() -> WorkoutDay {
        let level = currentFitnessLevel
        let equipment = currentEquipment
        let mins = currentMinutes
        let goal = currentTrainingGoal

        let random = WorkoutGenerator.generateRandomWorkout(
            goal: goal, level: level, equipment: equipment,
            minutes: mins, lastWorkoutTag: lastWorkoutTag
        )
        return random
    }

    // MARK: - Completion

    func markDayCompleted(dayIndex: Int) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex }) else { return }
        plan.days[idx].isCompleted = true
        lastWorkoutTag = plan.days[idx].templateTag
        currentPlan = plan

        completedRecords.insert(
            CompletedWorkoutRecord(
                title: plan.days[idx].title,
                exerciseCount: plan.days[idx].exercises.count
            ), at: 0
        )
        persistAll()
    }

    func markDayIncomplete(dayIndex: Int) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex }) else { return }
        plan.days[idx].isCompleted = false
        currentPlan = plan
        persistAll()
    }

    func completeStandaloneWorkout(_ workout: WorkoutDay) {
        lastWorkoutTag = workout.templateTag
        completedRecords.insert(
            CompletedWorkoutRecord(
                title: workout.title,
                exerciseCount: workout.exercises.count
            ), at: 0
        )
        persistAll()
    }

    func updateDayExercises(dayIndex: Int, exercises: [WorkoutExercise]) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex }) else { return }
        plan.days[idx].exercises = exercises
        currentPlan = plan
        persistAll()
    }

    // MARK: - Computed

    var todayWorkout: WorkoutDay? {
        guard let plan = currentPlan else { return nil }
        let today = Calendar.current.startOfDay(for: .now)
        return plan.days.first { Calendar.current.isDate($0.date, inSameDayAs: today) && !$0.isRestDay }
    }

    var weeklyCompletedCount: Int {
        currentPlan?.completedCount ?? 0
    }

    var weeklyTotalDays: Int {
        currentPlan?.totalWorkoutDays ?? 0
    }

    var streak: Int {
        let calendar = Calendar.current
        let completedDays = Set(completedRecords.map { calendar.startOfDay(for: $0.date) })

        var streakCount = 0
        var currentDay = calendar.startOfDay(for: .now)

        while completedDays.contains(currentDay) {
            streakCount += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: currentDay) else { break }
            currentDay = previous
        }

        return streakCount
    }

    var totalWorkoutsCompleted: Int {
        completedRecords.count
    }

    var workoutsThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now
        return completedRecords.filter { $0.date >= startOfWeek }.count
    }

    var averageSteps: Int {
        guard !stepHistory.isEmpty else { return 0 }
        return stepHistory.map(\.steps).reduce(0, +) / stepHistory.count
    }

    func resetAllData() {
        currentPlan = nil
        completedRecords = []
        stepHistory = []
        lastWorkoutTag = ""
        persistAll()
    }

    // MARK: - Preferences Helpers

    private var currentTrainingGoal: TrainingGoal {
        TrainingGoal(rawValue: UserDefaults.standard.string(forKey: "trainingGoal") ?? "") ?? .generalFitness
    }

    private var currentFitnessLevel: FitnessLevel {
        FitnessLevel(rawValue: UserDefaults.standard.string(forKey: "fitnessLevel") ?? "") ?? .intermediate
    }

    private var currentEquipment: EquipmentOption {
        EquipmentOption(rawValue: UserDefaults.standard.string(forKey: "equipment") ?? "") ?? .bodyweight
    }

    private var currentMinutes: Int {
        let m = UserDefaults.standard.integer(forKey: "minutesPerWorkout")
        return m > 0 ? m : 30
    }
}
