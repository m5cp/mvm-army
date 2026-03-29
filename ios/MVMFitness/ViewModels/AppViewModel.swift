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
    var scheduledUnitPT: [WorkoutDay] = []
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
        scheduledUnitPT = LocalStore.load([WorkoutDay].self, forKey: "scheduledUnitPT", fallback: [])
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
        LocalStore.save(scheduledUnitPT, forKey: "scheduledUnitPT")
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
        let daysPerWeek = days > 0 ? min(days, 7) : 3

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

    func ensureTodayHasWorkout() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        if let plan = currentPlan {
            let hasTodayInPlan = plan.days.contains { calendar.isDate($0.date, inSameDayAs: today) }
            if !hasTodayInPlan {
                let completedDays = plan.days.filter(\.isCompleted)
                generateWeeklyPlan()
                if var newPlan = currentPlan {
                    for completed in completedDays {
                        if let idx = newPlan.days.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: completed.date) }) {
                            newPlan.days[idx].isCompleted = true
                        }
                    }
                    currentPlan = newPlan
                    persistAll()
                }
            }
        } else {
            generateWeeklyPlan()
        }
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

    func generateRecoverySession() -> WorkoutDay {
        let recoveryTemplates = ArmyTemplateLibrary.templates.filter { $0.focus == .recovery }
        let template = recoveryTemplates.randomElement()

        if let template {
            let exercises = ArmyGenerator.convertToWorkoutExercises(template)
            return WorkoutDay(
                dayIndex: -1,
                date: Calendar.current.startOfDay(for: .now),
                title: template.title,
                exercises: exercises,
                templateTag: template.title,
                tags: ["Recovery", "Active Rest"]
            )
        }

        return WorkoutDay(
            dayIndex: -1,
            date: Calendar.current.startOfDay(for: .now),
            title: "Recovery & Mobility",
            exercises: [
                WorkoutExercise(name: "PMCS Drill", sets: 1, durationSeconds: 360, notes: "Full mobility sequence", category: .timed),
                WorkoutExercise(name: "Hip Stability Drill", sets: 1, durationSeconds: 300, notes: "Through sequence", category: .timed),
                WorkoutExercise(name: "Shoulder Stability Drill", sets: 1, durationSeconds: 300, notes: "Through sequence", category: .timed),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 300, notes: "Full sequence", category: .timed)
            ],
            templateTag: "recovery_fallback",
            tags: ["Recovery", "Active Rest"]
        )
    }

    func generateUnitPT() -> UnitPTPlan {
        let plan = WorkoutGenerator.generateUnitPT(focus: currentFocus, level: currentLevel)
        unitPTPlans.insert(plan, at: 0)
        persistAll()
        return plan
    }

    func addUnitPTToCalendar(_ unitPlan: UnitPTPlan, on date: Date, startTime: Date? = nil, endTime: Date? = nil) {
        var exercises: [WorkoutExercise] = []

        if !unitPlan.objective.isEmpty {
            exercises.append(WorkoutExercise(
                name: "Objective",
                sets: 1,
                notes: unitPlan.objective,
                category: .timed
            ))
        }

        if !unitPlan.formationNotes.isEmpty {
            exercises.append(WorkoutExercise(
                name: "Formation",
                sets: 1,
                notes: unitPlan.formationNotes,
                category: .timed
            ))
        }

        exercises.append(WorkoutExercise(
            name: "Warm-Up",
            sets: 1,
            durationSeconds: 600,
            notes: unitPlan.warmup,
            category: .timed
        ))

        for (index, block) in unitPlan.mainEffort.enumerated() {
            exercises.append(WorkoutExercise(
                name: "Main Effort \(index + 1)",
                sets: 1,
                notes: block.description,
                category: .timed
            ))
        }

        exercises.append(WorkoutExercise(
            name: "Cool-Down",
            sets: 1,
            durationSeconds: 300,
            notes: unitPlan.cooldown,
            category: .timed
        ))

        if !unitPlan.leaderNotes.isEmpty {
            exercises.append(WorkoutExercise(
                name: "Leader Notes",
                sets: 1,
                notes: unitPlan.leaderNotes,
                category: .timed
            ))
        }

        var tags = ["Unit PT"]
        if !unitPlan.objective.isEmpty { tags.append(unitPlan.objective) }

        let unitDay = WorkoutDay(
            dayIndex: 100 + scheduledUnitPT.count,
            date: Calendar.current.startOfDay(for: date),
            title: unitPlan.title,
            exercises: exercises,
            templateTag: "unit_pt",
            tags: tags,
            source: .unit,
            startTime: startTime,
            endTime: endTime
        )

        scheduledUnitPT.append(unitDay)
        persistAll()
    }

    func removeUnitPTFromCalendar(id: UUID) {
        scheduledUnitPT.removeAll { $0.id == id }
        persistAll()
    }

    func allWorkoutsForDate(_ date: Date) -> [WorkoutDay] {
        let calendar = Calendar.current
        var results: [WorkoutDay] = []

        if let plan = currentPlan {
            results += plan.days.filter { calendar.isDate($0.date, inSameDayAs: date) }
        }

        results += scheduledUnitPT.filter { calendar.isDate($0.date, inSameDayAs: date) }

        return results
    }

    func markUnitPTCompleted(id: UUID) {
        guard let idx = scheduledUnitPT.firstIndex(where: { $0.id == id }) else { return }
        scheduledUnitPT[idx].isCompleted = true
        completedRecords.insert(
            CompletedWorkoutRecord(
                title: scheduledUnitPT[idx].title,
                exerciseCount: scheduledUnitPT[idx].exercises.count
            ), at: 0
        )
        persistAll()
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

        let scoreRecord = AFTScoreRecord(
            date: result.date,
            deadliftLbs: result.deadliftLbs,
            pushUpReps: result.pushUpReps,
            sdcSeconds: result.sdcSeconds,
            plankSeconds: result.plankSeconds,
            runSeconds: result.runSeconds,
            deadliftPoints: result.deadliftPoints,
            pushUpPoints: result.pushUpPoints,
            sdcPoints: result.sdcPoints,
            plankPoints: result.plankPoints,
            runPoints: result.runPoints,
            totalScore: result.totalScore,
            weakestEvents: result.weakestEvents
        )
        aftScores.insert(scoreRecord, at: 0)
        persistAll()
    }

    func generateFocusWorkout(weakEvents: [String]) -> WorkoutDay? {
        let armyEquipment = ArmyGenerator.mapArmyEquipment(currentEquipment)
        let armyMode = ArmyGenerator.mapArmyMode(ptMode: currentPTMode, dutyType: currentDutyType)

        guard let template = ArmyGenerator.generateFocusSession(
            weakEvents: weakEvents,
            equipment: armyEquipment,
            mode: armyMode,
            lastTitle: lastWorkoutTag
        ) else { return nil }

        let exercises = ArmyGenerator.convertToWorkoutExercises(template)
        let focusLabels = weakEvents.map { ArmyGenerator.mapWeakEventToFocus($0) }.map { ArmyGenerator.focusLabel(for: $0) }

        return WorkoutDay(
            dayIndex: 0,
            date: Calendar.current.startOfDay(for: .now),
            title: template.title,
            exercises: exercises,
            templateTag: template.title,
            tags: ["Focus PT"] + focusLabels
        )
    }

    func addFocusSessionToPlan(weakEvents: [String]) -> Bool {
        guard var plan = currentPlan,
              let workout = generateFocusWorkout(weakEvents: weakEvents) else { return false }

        if let restIdx = plan.days.firstIndex(where: { $0.isRestDay && !$0.isCompleted }) {
            plan.days[restIdx] = WorkoutDay(
                dayIndex: plan.days[restIdx].dayIndex,
                date: plan.days[restIdx].date,
                title: workout.title,
                exercises: workout.exercises,
                templateTag: workout.templateTag,
                tags: workout.tags
            )
        } else {
            if let lastIdx = plan.days.lastIndex(where: { !$0.isCompleted }) {
                plan.days[lastIdx] = WorkoutDay(
                    dayIndex: plan.days[lastIdx].dayIndex,
                    date: plan.days[lastIdx].date,
                    title: workout.title,
                    exercises: workout.exercises,
                    templateTag: workout.templateTag,
                    tags: workout.tags
                )
            } else {
                return false
            }
        }

        currentPlan = plan
        persistAll()
        return true
    }

    // MARK: - Completion

    func markDayCompleted(dayIndex: Int) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex }) else { return }
        let alreadyCompleted = plan.days[idx].isCompleted
        plan.days[idx].isCompleted = true
        lastWorkoutTag = plan.days[idx].templateTag
        currentPlan = plan

        if !alreadyCompleted {
            completedRecords.insert(
                CompletedWorkoutRecord(
                    title: plan.days[idx].title,
                    exerciseCount: plan.days[idx].exercises.count
                ), at: 0
            )
        }
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

    func replaceRestDayWithWorkout(dayIndex: Int) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex && $0.isRestDay }) else { return }

        let armyMode = ArmyGenerator.mapArmyMode(ptMode: currentPTMode, dutyType: currentDutyType)
        let armyEquipment = ArmyGenerator.mapArmyEquipment(currentEquipment)
        let armyFocuses = ArmyGenerator.mapArmyFocuses(currentFocus)
        let randomFocus = armyFocuses.randomElement() ?? .aftPrep

        let template = ArmyGenerator.nextTemplate(
            mode: armyMode,
            focus: randomFocus,
            equipment: armyEquipment,
            excluding: lastWorkoutTag
        )

        let modeTags = WorkoutGenerator.buildModeTags(ptMode: currentPTMode, dutyType: currentDutyType, focus: currentFocus)

        if let template {
            let exercises = ArmyGenerator.convertToWorkoutExercises(template)
            plan.days[idx] = WorkoutDay(
                dayIndex: dayIndex,
                date: plan.days[idx].date,
                title: template.title,
                exercises: exercises,
                isRestDay: false,
                templateTag: template.title,
                tags: modeTags + [template.focus.rawValue]
            )
        } else {
            plan.days[idx] = WorkoutDay(
                dayIndex: dayIndex,
                date: plan.days[idx].date,
                title: "General Army PT",
                exercises: [
                    WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 300, notes: "PD: 10 exercises, 5 reps each", category: .timed),
                    WorkoutExercise(name: "Push-Up", sets: 4, reps: 15, category: .bodyweight),
                    WorkoutExercise(name: "Air Squat", sets: 4, reps: 20, category: .bodyweight),
                    WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: 60, category: .timed),
                    WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 240, notes: "RD: Full sequence", category: .timed)
                ],
                isRestDay: false,
                templateTag: "fallback_general",
                tags: modeTags + ["General"]
            )
        }
        currentPlan = plan
        persistAll()
    }

    func regenerateSingleDay(dayIndex: Int) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex }) else { return }

        let armyMode = ArmyGenerator.mapArmyMode(ptMode: currentPTMode, dutyType: currentDutyType)
        let armyEquipment = ArmyGenerator.mapArmyEquipment(currentEquipment)
        let armyFocuses = ArmyGenerator.mapArmyFocuses(currentFocus)
        let randomFocus = armyFocuses.randomElement() ?? .aftPrep
        let currentTag = plan.days[idx].templateTag

        let template = ArmyGenerator.nextTemplate(
            mode: armyMode,
            focus: randomFocus,
            equipment: armyEquipment,
            excluding: currentTag
        )

        let modeTags = WorkoutGenerator.buildModeTags(ptMode: currentPTMode, dutyType: currentDutyType, focus: currentFocus)

        if let template {
            let exercises = ArmyGenerator.convertToWorkoutExercises(template)
            plan.days[idx] = WorkoutDay(
                dayIndex: dayIndex,
                date: plan.days[idx].date,
                title: template.title,
                exercises: exercises,
                isRestDay: false,
                templateTag: template.title,
                tags: modeTags + [template.focus.rawValue]
            )
        }
        currentPlan = plan
        persistAll()
    }

    func convertDayToRecovery(dayIndex: Int) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex }) else { return }
        let titles = ["Recovery & Mobility", "Active Recovery", "Easy Movement", "Maintenance Session", "Light Mobility"]
        plan.days[idx] = WorkoutDay(
            dayIndex: dayIndex,
            date: plan.days[idx].date,
            title: titles[dayIndex % titles.count],
            exercises: [],
            isRestDay: true,
            templateTag: "recovery"
        )
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

    var unitPTSessionsCompleted: Int {
        unitPTPlans.count
    }

    var previousAFTScore: AFTScoreRecord? {
        guard aftScores.count > 1 else { return nil }
        return aftScores[1]
    }

    var aftScoreDifference: Int? {
        guard let latest = latestAFTScore, let previous = previousAFTScore else { return nil }
        return latest.totalScore - previous.totalScore
    }

    var weeklyStepAverage: Int {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: .now) ?? .now
        let recentSteps = stepHistory.filter { $0.date >= sevenDaysAgo }
        guard !recentSteps.isEmpty else { return 0 }
        return recentSteps.map(\.steps).reduce(0, +) / recentSteps.count
    }

    func resetAllData() {
        currentPlan = nil
        completedRecords = []
        stepHistory = []
        lastWorkoutTag = ""
        unitPTPlans = []
        scheduledUnitPT = []
        importedWorkouts = []
        aftScores = []
        aftCalculatorResults = []
        persistAll()
    }
}
