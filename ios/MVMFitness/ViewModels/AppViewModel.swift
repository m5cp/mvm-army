import SwiftUI
import Observation

@Observable
final class AppViewModel {
    var currentPlan: WeeklyPlan?
    var completedRecords: [CompletedWorkoutRecord] = []
    var stepHistory: [StepDay] = []
    var pedometer = PedometerManager()
    var lastWorkoutTag: String = ""
    var unitPTPlans: [UnitPTPlan] = []
    var importedWorkouts: [WorkoutDay] = []
    var aftScores: [AFTScoreRecord] = []
    var aftCalculatorResults: [AFTCalculatorResult] = []

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
        unitPTPlans = LocalStore.load([UnitPTPlan].self, forKey: "unitPTPlans", fallback: [])
        importedWorkouts = LocalStore.load([WorkoutDay].self, forKey: "importedWorkouts", fallback: [])
        aftScores = LocalStore.load([AFTScoreRecord].self, forKey: "aftScores", fallback: [])
        aftCalculatorResults = LocalStore.load([AFTCalculatorResult].self, forKey: "aftCalculatorResults", fallback: [])
    }

    func persistAll() {
        LocalStore.save(currentPlan, forKey: "currentPlan")
        LocalStore.save(completedRecords, forKey: "completedRecords")
        LocalStore.save(stepHistory, forKey: "stepHistory")
        UserDefaults.standard.set(lastWorkoutTag, forKey: "lastWorkoutTag")
        LocalStore.save(unitPTPlans, forKey: "unitPTPlans")
        LocalStore.save(importedWorkouts, forKey: "importedWorkouts")
        LocalStore.save(aftScores, forKey: "aftScores")
        LocalStore.save(aftCalculatorResults, forKey: "aftCalculatorResults")
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

    // MARK: - Preferences

    var currentFocus: TrainingFocus {
        TrainingFocus(rawValue: UserDefaults.standard.string(forKey: "trainingFocus") ?? "") ?? .generalArmyFitness
    }

    var currentLevel: FitnessLevel {
        FitnessLevel(rawValue: UserDefaults.standard.string(forKey: "fitnessLevel") ?? "") ?? .intermediate
    }

    var currentEquipment: EquipmentOption {
        EquipmentOption(rawValue: UserDefaults.standard.string(forKey: "equipment") ?? "") ?? .bodyweight
    }

    var currentMinutes: Int {
        let m = UserDefaults.standard.integer(forKey: "minutesPerWorkout")
        return m > 0 ? m : 30
    }

    var currentPTMode: PTMode {
        PTMode(rawValue: UserDefaults.standard.string(forKey: "ptMode") ?? "") ?? .both
    }

    var currentDutyType: DutyType {
        DutyType(rawValue: UserDefaults.standard.string(forKey: "dutyType") ?? "") ?? .both
    }

    // MARK: - Plan Generation

    func generateWeeklyPlan() {
        let days = UserDefaults.standard.integer(forKey: "daysPerWeek")
        let daysPerWeek = days > 0 ? days : 3

        currentPlan = WorkoutGenerator.generateWeeklyPlan(
            focus: currentFocus,
            level: currentLevel,
            equipment: currentEquipment,
            daysPerWeek: daysPerWeek,
            minutesPerWorkout: currentMinutes,
            ptMode: currentPTMode,
            dutyType: currentDutyType
        )
        persistAll()
    }

    func generateWorkoutOfDay() -> WorkoutDay {
        WorkoutGenerator.generateWorkoutOfDay(
            focus: currentFocus, level: currentLevel, equipment: currentEquipment,
            minutes: currentMinutes, lastWorkoutTag: lastWorkoutTag,
            ptMode: currentPTMode, dutyType: currentDutyType
        )
    }

    func generateRandomWorkout() -> WorkoutDay {
        WorkoutGenerator.generateRandomWorkout(
            focus: currentFocus, level: currentLevel, equipment: currentEquipment,
            minutes: currentMinutes, lastWorkoutTag: lastWorkoutTag,
            ptMode: currentPTMode, dutyType: currentDutyType
        )
    }

    func generateUnitPT() -> UnitPTPlan {
        let plan = WorkoutGenerator.generateUnitPT(focus: currentFocus, level: currentLevel)
        unitPTPlans.insert(plan, at: 0)
        persistAll()
        return plan
    }

    // MARK: - AFT Scores

    func saveAFTScore(_ record: AFTScoreRecord) {
        aftScores.insert(record, at: 0)
        persistAll()
    }

    var latestAFTScore: AFTScoreRecord? {
        aftScores.first
    }

    var averageAFTScore: Int {
        guard !aftScores.isEmpty else { return 0 }
        return aftScores.map(\.totalScore).reduce(0, +) / aftScores.count
    }

    var aftWeakestEvents: [String] {
        latestAFTScore?.weakestEvents ?? []
    }

    // MARK: - AFT Calculator

    func saveAFTCalculatorResult(_ result: AFTCalculatorResult) {
        aftCalculatorResults.insert(result, at: 0)
        persistAll()
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

    func saveImportedWorkout(_ workout: WorkoutDay) {
        importedWorkouts.insert(workout, at: 0)
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
        unitPTPlans = []
        importedWorkouts = []
        aftScores = []
        aftCalculatorResults = []
        persistAll()
    }
}
