import SwiftUI
import Observation

@Observable
final class AppViewModel {
    var currentPlan: WeeklyPlan?
    var completedRecords: [CompletedWorkoutRecord] = []
    var stepHistory: [StepDay] = []
    var pedometer = PedometerManager()
    var healthKit = HealthKitManager()
    var lastWorkoutTag: String = ""
    var unitPTPlans: [UnitPTPlan] = []
    var unitPTFullPlan: UnitPTFullPlan?
    var scheduledUnitPT: [WorkoutDay] = []
    var importedWorkouts: [WorkoutDay] = []
    var aftScores: [AFTScoreRecord] = []
    var aftCalculatorResults: [AFTCalculatorResult] = []
    var wodPlan: WODPlan?
    var todayFunctionalWOD: WODTemplate?
    var activeRecap: InstantRecap?

    var performanceHighlights: [PerformanceHighlight] {
        PerformanceHighlightsService.generateHighlights(
            aftScores: aftScores,
            completedRecords: completedRecords,
            currentPlan: currentPlan,
            wodPlan: wodPlan,
            streak: streak
        )
    }

    func showRecap(_ recap: InstantRecap) {
        activeRecap = recap
    }

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
        unitPTFullPlan = LocalStore.load(UnitPTFullPlan?.self, forKey: "unitPTFullPlan", fallback: nil)
        scheduledUnitPT = LocalStore.load([WorkoutDay].self, forKey: "scheduledUnitPT", fallback: [])
        importedWorkouts = LocalStore.load([WorkoutDay].self, forKey: "importedWorkouts", fallback: [])
        aftScores = LocalStore.load([AFTScoreRecord].self, forKey: "aftScores", fallback: [])
        aftCalculatorResults = LocalStore.load([AFTCalculatorResult].self, forKey: "aftCalculatorResults", fallback: [])
        wodPlan = LocalStore.load(WODPlan?.self, forKey: "wodPlan", fallback: nil)
        loadTodayFunctionalWOD()
    }

    func persistAll() {
        LocalStore.save(currentPlan, forKey: "currentPlan")
        LocalStore.save(completedRecords, forKey: "completedRecords")
        LocalStore.save(stepHistory, forKey: "stepHistory")
        UserDefaults.standard.set(lastWorkoutTag, forKey: "lastWorkoutTag")
        LocalStore.save(unitPTPlans, forKey: "unitPTPlans")
        LocalStore.save(unitPTFullPlan, forKey: "unitPTFullPlan")
        LocalStore.save(scheduledUnitPT, forKey: "scheduledUnitPT")
        LocalStore.save(importedWorkouts, forKey: "importedWorkouts")
        LocalStore.save(aftScores, forKey: "aftScores")
        LocalStore.save(aftCalculatorResults, forKey: "aftCalculatorResults")
        LocalStore.save(wodPlan, forKey: "wodPlan")
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

    var currentPTGoal: PTGoal? {
        guard let raw = UserDefaults.standard.string(forKey: "ptGoal"), !raw.isEmpty else { return nil }
        return PTGoal(rawValue: raw)
    }

    var currentPlanWeeks: Int {
        let w = UserDefaults.standard.integer(forKey: "planWeeks")
        return w > 0 ? w : 4
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
            dutyType: currentDutyType,
            ptGoal: currentPTGoal,
            totalWeeks: currentPlanWeeks,
            currentWeek: currentPlan?.currentWeek ?? 1
        )
        persistAll()
    }

    func generateGoalPlan(goal: PTGoal, weeks: Int) {
        UserDefaults.standard.set(goal.rawValue, forKey: "ptGoal")
        UserDefaults.standard.set(weeks, forKey: "planWeeks")

        let days = UserDefaults.standard.integer(forKey: "daysPerWeek")
        let daysPerWeek = days > 0 ? min(days, 7) : 3

        currentPlan = WorkoutGenerator.generateWeeklyPlan(
            focus: currentFocus,
            level: currentLevel,
            equipment: currentEquipment,
            daysPerWeek: daysPerWeek,
            minutesPerWorkout: currentMinutes,
            ptMode: currentPTMode,
            dutyType: currentDutyType,
            ptGoal: goal,
            totalWeeks: weeks,
            currentWeek: 1
        )
        persistAll()
    }

    func advanceToNextWeek() {
        guard let plan = currentPlan else { return }
        let nextWeek = plan.currentWeek + 1
        guard nextWeek <= plan.totalWeeks else { return }

        let days = UserDefaults.standard.integer(forKey: "daysPerWeek")
        let daysPerWeek = days > 0 ? min(days, 7) : 3

        currentPlan = WorkoutGenerator.generateWeeklyPlan(
            focus: currentFocus,
            level: currentLevel,
            equipment: currentEquipment,
            daysPerWeek: daysPerWeek,
            minutesPerWorkout: currentMinutes,
            ptMode: currentPTMode,
            dutyType: currentDutyType,
            ptGoal: currentPTGoal,
            totalWeeks: plan.totalWeeks,
            currentWeek: nextWeek
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

    func generateUnitPT(goal: PTGoal? = nil, weeks: Int = 4) -> UnitPTPlan {
        let plan = WorkoutGenerator.generateUnitPT(focus: currentFocus, level: currentLevel, goal: goal, weeks: weeks)
        unitPTPlans.insert(plan, at: 0)
        persistAll()
        return plan
    }

    func generateUnitPTFullPlan(goal: PTGoal, weeks: Int, daysPerWeek: Int = 5) -> UnitPTFullPlan {
        let plan = WorkoutGenerator.generateUnitPTFullPlan(
            focus: currentFocus,
            level: currentLevel,
            goal: goal,
            weeks: weeks,
            daysPerWeek: daysPerWeek
        )
        unitPTFullPlan = plan
        persistAll()
        return plan
    }

    func regenerateUnitPTDay(weekIndex: Int, dayIndex: Int) {
        guard var plan = unitPTFullPlan else { return }
        guard weekIndex < plan.weeks.count, dayIndex < plan.weeks[weekIndex].days.count else { return }
        let existingDay = plan.weeks[weekIndex].days[dayIndex]
        let goal = PTGoal(rawValue: plan.goal) ?? .aftScoreImprovement

        let armyFocuses = goal.armyFocuses
        let focusForDay = armyFocuses[dayIndex % armyFocuses.count]
        let currentTitle = existingDay.title

        let unitTemplates = ArmyTemplateLibrary.templates.filter {
            $0.mode == .unitPT && $0.focus == focusForDay && $0.title != currentTitle
        }
        let allUnit = ArmyTemplateLibrary.templates.filter {
            $0.mode == .unitPT && $0.title != currentTitle
        }
        let fallbackUnit = ArmyTemplateLibrary.templates.filter { $0.mode == .unitPT }
        guard let template = unitTemplates.randomElement() ?? allUnit.randomElement() ?? fallbackUnit.randomElement() else { return }

        let warmupText = template.warmup.map { ex in
            "\(ex.name)\(ex.reps.map { " \u{2014} \($0)" } ?? "")\(ex.duration.map { " \u{2014} \($0)" } ?? "")"
        }.joined(separator: "\n")

        let cooldownText = template.cooldown.map { ex in
            "\(ex.name)\(ex.duration.map { " \u{2014} \($0)" } ?? "")"
        }.joined(separator: "\n")

        let blocks = template.mainEffort.map { ex in
            var desc = ex.name
            if let sets = ex.sets { desc += " \u{2014} \(sets) sets" }
            if let reps = ex.reps { desc += " x \(reps)" }
            if let dur = ex.duration { desc += " (\(dur))" }
            if let notes = ex.notes, !notes.isEmpty { desc += ". \(notes)" }
            return UnitPTBlock(desc)
        }

        let equipmentText = template.equipment.map(\.rawValue).joined(separator: ", ")

        let phaseLabel: String
        let progress = Double(weekIndex) / Double(max(plan.totalWeeks - 1, 1))
        if progress < 0.33 { phaseLabel = "Foundation Phase" }
        else if progress < 0.66 { phaseLabel = "Build Phase" }
        else { phaseLabel = "Peak Phase" }

        plan.weeks[weekIndex].days[dayIndex] = UnitPTDayPlan(
            date: existingDay.date,
            dayIndex: dayIndex,
            weekIndex: weekIndex,
            title: template.title,
            objective: template.objective,
            formationNotes: "Form up by squad in extended rectangular formation. Conduct accountability, safety brief, and session overview. Designate lane NCOs for station-based work.",
            equipment: equipmentText.isEmpty ? "Cones, timer, water source" : "Cones, timer, water source. \(equipmentText) as available.",
            warmup: warmupText.isEmpty ? "Preparation Drill (PD): 10 exercises, 5 reps each" : warmupText,
            mainEffort: blocks,
            cooldown: cooldownText.isEmpty ? "Recovery Drill (RD): Full sequence" : cooldownText,
            leaderNotes: template.leaderNotes ?? "Maintain lane assignments and keep transitions tight. Monitor form on all lifts. Adjust intensity for ability groups as needed.",
            task: "Conduct Unit PRT session focused on \(template.focus.rawValue.lowercased()) to support \(goal.rawValue.lowercased()) (Week \(weekIndex + 1) \u{2014} \(phaseLabel)).",
            condition: "Given standard PRT equipment, a designated training area, and supervision by a qualified PRT leader, Soldiers will execute the prescribed session IAW FM 7-22.",
            standard: "All Soldiers complete warm-up, main effort, and cool-down with proper form. Leaders correct unsafe movement patterns. Session completed within the allocated time window."
        )
        unitPTFullPlan = plan
        persistAll()
    }

    func updateUnitPTDay(weekIndex: Int, dayIndex: Int, updatedDay: UnitPTDayPlan) {
        guard var plan = unitPTFullPlan else { return }
        guard weekIndex < plan.weeks.count, dayIndex < plan.weeks[weekIndex].days.count else { return }
        plan.weeks[weekIndex].days[dayIndex] = updatedDay
        unitPTFullPlan = plan
        persistAll()
    }

    func addFullUnitPTToCalendar(startTime: Date, endTime: Date) {
        guard let plan = unitPTFullPlan else { return }
        scheduledUnitPT.removeAll { $0.templateTag == "unit_pt_full" }

        for week in plan.weeks {
            for day in week.days {
                var exercises: [WorkoutExercise] = []

                exercises.append(WorkoutExercise(
                    name: "Warm-Up", sets: 1, durationSeconds: 600,
                    notes: day.warmup, category: .timed
                ))

                for (index, block) in day.mainEffort.enumerated() {
                    exercises.append(WorkoutExercise(
                        name: "Main Effort \(index + 1)", sets: 1,
                        notes: block.description, category: .timed
                    ))
                }

                exercises.append(WorkoutExercise(
                    name: "Cool-Down", sets: 1, durationSeconds: 300,
                    notes: day.cooldown, category: .timed
                ))

                let cal = Calendar.current
                let dayStart = cal.date(bySettingHour: cal.component(.hour, from: startTime),
                                        minute: cal.component(.minute, from: startTime),
                                        second: 0, of: day.date) ?? day.date
                let dayEnd = cal.date(bySettingHour: cal.component(.hour, from: endTime),
                                      minute: cal.component(.minute, from: endTime),
                                      second: 0, of: day.date) ?? day.date

                let unitDay = WorkoutDay(
                    dayIndex: 100 + scheduledUnitPT.count,
                    date: cal.startOfDay(for: day.date),
                    title: day.title,
                    exercises: exercises,
                    templateTag: "unit_pt_full",
                    tags: ["Unit PT", day.objective],
                    source: .unit,
                    startTime: dayStart,
                    endTime: dayEnd
                )
                scheduledUnitPT.append(unitDay)
            }
        }
        persistAll()
    }

    func clearUnitPTFullPlan() {
        unitPTFullPlan = nil
        persistAll()
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
                exerciseCount: scheduledUnitPT[idx].exercises.count,
                exercises: scheduledUnitPT[idx].exercises,
                source: .unit
            ), at: 0
        )
        showRecap(PerformanceHighlightsService.workoutRecap(title: scheduledUnitPT[idx].title, exerciseCount: scheduledUnitPT[idx].exercises.count))
        persistAll()
    }

    // MARK: - AFT Scores

    func saveAFTScore(_ record: AFTScoreRecord) {
        let previousScores = aftScores
        aftScores.insert(record, at: 0)
        showRecap(PerformanceHighlightsService.aftScoreRecap(newScore: record, previousScores: previousScores))
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
        let previousScores = aftScores
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
        showRecap(PerformanceHighlightsService.aftScoreRecap(newScore: scoreRecord, previousScores: previousScores))
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
            SmartWorkoutBrain.recordWorkoutPatterns(plan.days[idx].exercises)
            completedRecords.insert(
                CompletedWorkoutRecord(
                    title: plan.days[idx].title,
                    exerciseCount: plan.days[idx].exercises.count,
                    exercises: plan.days[idx].exercises,
                    source: plan.days[idx].source
                ), at: 0
            )

            let completed = plan.days.filter(\.isCompleted).count
            let total = plan.totalWorkoutDays
            showRecap(PerformanceHighlightsService.planDayRecap(dayNumber: completed, totalDays: total))
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
        SmartWorkoutBrain.recordWorkoutPatterns(workout.exercises)
        completedRecords.insert(
            CompletedWorkoutRecord(
                title: workout.title,
                exerciseCount: workout.exercises.count,
                exercises: workout.exercises,
                source: workout.source
            ), at: 0
        )
        showRecap(PerformanceHighlightsService.workoutRecap(title: workout.title, exerciseCount: workout.exercises.count))
        persistAll()
    }

    func updateDayExercises(dayIndex: Int, exercises: [WorkoutExercise]) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex }) else { return }
        plan.days[idx].exercises = exercises
        currentPlan = plan
        persistAll()
    }

    func updateCompletedRecord(id: UUID, exercises: [WorkoutExercise]) {
        guard let idx = completedRecords.firstIndex(where: { $0.id == id }) else { return }
        completedRecords[idx].exercises = exercises
        completedRecords[idx].exerciseCount = exercises.count
        persistAll()
    }

    func completedRecordsForDate(_ date: Date) -> [CompletedWorkoutRecord] {
        let calendar = Calendar.current
        return completedRecords.filter { calendar.isDate($0.date, inSameDayAs: date) }
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

    func savePlanSnapshot() {
        persistAll()
    }

    func importPlan(_ plan: WeeklyPlan) {
        currentPlan = plan
        persistAll()
    }

    var planShareText: String {
        guard let plan = currentPlan else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let goalLabel = plan.ptGoal.isEmpty ? "General" : plan.ptGoal

        var text = "MVM Fitness — Individual PT Plan\n"
        text += "Goal: \(goalLabel) · Week \(plan.currentWeek) of \(plan.totalWeeks)\n"
        if let first = plan.days.first, let last = plan.days.last {
            text += "\(dateFormatter.string(from: first.date)) – \(dateFormatter.string(from: last.date))\n"
        }
        text += "\n"

        for (index, day) in plan.days.enumerated() {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            let dayName = dayFormatter.string(from: day.date)

            if day.isRestDay {
                text += "Day \(index + 1) (\(dayName)): Rest & Recovery\n"
            } else {
                text += "Day \(index + 1) (\(dayName)): \(day.title)\n"
                for exercise in day.exercises {
                    text += "  • \(exercise.name) — \(exercise.displayDetail)\n"
                }
            }
            text += "\n"
        }

        text += "#MVMFitness"
        return text
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

    // MARK: - WOD Plan

    func loadTodayFunctionalWOD() {
        let today = Calendar.current.startOfDay(for: .now)

        if let plannedDay = wodPlan?.days.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) && !$0.isRestDay }) {
            todayFunctionalWOD = plannedDay.template
            return
        }

        let lastDate = UserDefaults.standard.double(forKey: "lastFunctionalWODDate")
        if lastDate > 0, Calendar.current.isDate(Date(timeIntervalSince1970: lastDate), inSameDayAs: today) {
            if let data = UserDefaults.standard.data(forKey: "todayFunctionalWOD"),
               let template = try? JSONDecoder().decode(WODTemplate.self, from: data) {
                todayFunctionalWOD = template
                return
            }
        }
        regenerateFunctionalWOD()
    }

    func regenerateFunctionalWOD() {
        let template = WODService.generateWOD(
            equipment: currentEquipment,
            dutyType: currentDutyType
        )
        todayFunctionalWOD = template
        if let data = try? JSONEncoder().encode(template) {
            UserDefaults.standard.set(data, forKey: "todayFunctionalWOD")
        }
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastFunctionalWODDate")
    }

    var todayPTWorkout: WorkoutDay? {
        guard let plan = currentPlan else { return nil }
        let today = Calendar.current.startOfDay(for: .now)
        return plan.days.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    var todayWODPlanDay: WODPlanDay? {
        guard let plan = wodPlan else { return nil }
        let today = Calendar.current.startOfDay(for: .now)
        return plan.days.first { Calendar.current.isDate($0.date, inSameDayAs: today) && !$0.isRestDay }
    }

    func generateWODPlan(goal: PTGoal, weeks: Int, heroPreference: WODHeroPreference = .regular, trainingFrequency: Int = 5, trainingGoal: TrainingGoal = .generalFitness) {
        UserDefaults.standard.set(goal.rawValue, forKey: "ptGoal")
        UserDefaults.standard.set(weeks, forKey: "planWeeks")

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today

        var days: [WODPlanDay] = []
        let daysCount = 7

        let clampedFrequency = min(max(trainingFrequency, 2), 6)
        let restDayIndices = computeRestDays(trainingDays: clampedFrequency)

        let pool = WODTemplateLibrary.poolForPreference(heroPreference)
        let workoutDayCount = daysCount - restDayIndices.count

        let wodEquipment: WODEquipment
        switch currentEquipment {
        case .gym: wodEquipment = .gym
        case .minimal, .field: wodEquipment = .minimal
        default: wodEquipment = .none
        }

        let brainSelection = SmartBrainSelection(
            goal: trainingGoal,
            duration: currentMinutes,
            equipment: wodEquipment,
            difficulty: SmartWorkoutBrain.shouldReduceIntensity() ? .moderate : .high,
            trainingFrequency: workoutDayCount,
            focusArea: .fullBody,
            workoutStyle: heroPreference == .mixed ? .freeWeight : heroPreference == .heroOnly ? .hybrid : .functional,
            level: currentLevel
        )

        let smartSelections = SmartWorkoutBrain.selectWeekPlanWithBrain(
            pool: pool,
            selection: brainSelection,
            weekNumber: 1,
            totalWeeks: weeks
        )

        var workoutIndex = 0

        for i in 0..<daysCount {
            guard let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) else { continue }

            if restDayIndices.contains(i) {
                let restTemplate = WODTemplate(
                    title: "Rest & Recovery",
                    category: .crossfit,
                    format: .circuit,
                    durationMinutes: 0,
                    equipment: .none,
                    movements: [],
                    workoutDescription: "Active rest day"
                )
                days.append(WODPlanDay(date: date, template: restTemplate, isRestDay: true))
            } else {
                let selected: WODTemplate
                if workoutIndex < smartSelections.count {
                    selected = smartSelections[workoutIndex]
                } else {
                    selected = pool.randomElement() ?? WODTemplateLibrary.functionalWODs[0]
                }
                SmartWorkoutBrain.recordWODSplit(selected.trainingSplit)
                days.append(WODPlanDay(date: date, template: selected))
                workoutIndex += 1
            }
        }

        wodPlan = WODPlan(
            days: days,
            ptGoal: goal.rawValue,
            totalWeeks: weeks,
            currentWeek: 1,
            weekStartDate: startOfWeek,
            heroPreference: heroPreference,
            trainingFrequency: clampedFrequency,
            trainingGoal: trainingGoal.rawValue,
            workoutStyle: heroPreference.rawValue
        )
        loadTodayFunctionalWOD()
        persistAll()
    }

    private func computeRestDays(trainingDays: Int) -> Set<Int> {
        switch trainingDays {
        case 2: return [1, 2, 4, 5, 6]
        case 3: return [1, 3, 5, 6]
        case 4: return [2, 4, 6]
        case 5: return [3, 6]
        case 6: return [6]
        default: return [3, 6]
        }
    }

    var wodPlanShareText: String {
        guard let plan = wodPlan else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let goalLabel = plan.ptGoal.isEmpty ? "FunctionFitness Plan" : plan.ptGoal

        var text = "MVM Fitness — FunctionFitness Plan\n"
        text += "Goal: \(goalLabel) · Week \(plan.currentWeek) of \(plan.totalWeeks)\n"
        if let first = plan.days.first, let last = plan.days.last {
            text += "\(dateFormatter.string(from: first.date)) – \(dateFormatter.string(from: last.date))\n"
        }
        text += "\n"

        for (index, day) in plan.days.enumerated() {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            let dayName = dayFormatter.string(from: day.date)

            if day.isRestDay {
                text += "Day \(index + 1) (\(dayName)): Rest & Recovery\n"
            } else {
                let heroTag = ""
                text += "Day \(index + 1) (\(dayName)): \(day.template.title)\(heroTag)\n"
                text += "  \(day.template.format.rawValue) · ~\(day.template.durationMinutes) min\n"
                for movement in day.template.movements {
                    let detail = movement.reps ?? movement.duration ?? ""
                    text += "  • \(movement.name)\(detail.isEmpty ? "" : " — \(detail)")\n"
                }
            }
            text += "\n"
        }

        text += "#MVMFitness"
        return text
    }

    func saveWODPlanSnapshot() {
        persistAll()
    }

    func refreshWODPlan() {
        guard let plan = wodPlan else { return }
        let goal = PTGoal(rawValue: plan.ptGoal) ?? .aftScoreImprovement
        let tGoal = TrainingGoal(rawValue: plan.trainingGoal) ?? .generalFitness
        generateWODPlan(goal: goal, weeks: plan.totalWeeks, heroPreference: plan.heroPreference, trainingFrequency: plan.trainingFrequency, trainingGoal: tGoal)
    }

    func convertWODDayToRest(dayId: UUID) {
        guard var plan = wodPlan,
              let idx = plan.days.firstIndex(where: { $0.id == dayId }) else { return }
        let restTemplate = WODTemplate(
            title: "Rest & Recovery",
            category: .bodyweight,
            format: .circuit,
            durationMinutes: 0,
            equipment: .none,
            movements: [],
            workoutDescription: "Active rest"
        )
        plan.days[idx] = WODPlanDay(date: plan.days[idx].date, template: restTemplate, isRestDay: true)
        wodPlan = plan
        persistAll()
    }

    func convertWODRestToWorkout(dayId: UUID) {
        guard var plan = wodPlan,
              let idx = plan.days.firstIndex(where: { $0.id == dayId && $0.isRestDay }) else { return }
        let pool = WODTemplateLibrary.poolForPreference(plan.heroPreference)
        let recentSplits = SmartWorkoutBrain.recentTrainingSplits()
        let usedTitles = Set(plan.days.filter { !$0.isRestDay }.map { $0.template.title })
        if let newTemplate = SmartWorkoutBrain.selectBestTemplate(
            from: pool,
            equipment: .gym,
            recentSplits: recentSplits,
            excluding: usedTitles
        ) {
            plan.days[idx] = WODPlanDay(date: plan.days[idx].date, template: newTemplate)
            wodPlan = plan
            persistAll()
        }
    }

    func updateWODDayMovements(dayId: UUID, movements: [WODMovement]) {
        guard var plan = wodPlan,
              let idx = plan.days.firstIndex(where: { $0.id == dayId }) else { return }
        plan.days[idx].template.movements = movements
        wodPlan = plan
        persistAll()
    }

    func regenerateWODDay(dayId: UUID, heroOnly: Bool = false) {
        guard var plan = wodPlan,
              let idx = plan.days.firstIndex(where: { $0.id == dayId }) else { return }
        let currentTitle = plan.days[idx].template.title
        let pool = WODTemplateLibrary.poolForPreference(plan.heroPreference)
        let usedTitles = Set(plan.days.filter { !$0.isRestDay }.map { $0.template.title })
        let recentSplits = SmartWorkoutBrain.recentTrainingSplits()
        if let newTemplate = SmartWorkoutBrain.selectBestTemplate(
            from: pool,
            equipment: .gym,
            recentSplits: recentSplits,
            excluding: usedTitles.union([currentTitle])
        ) {
            plan.days[idx] = WODPlanDay(date: plan.days[idx].date, template: newTemplate)
            wodPlan = plan
            persistAll()
        }
    }

    // MARK: - Unified Calendar Data

    nonisolated enum CalendarWorkoutStatus: Sendable {
        case planned
        case completed
        case missed
    }

    struct CalendarWorkoutEntry: Identifiable {
        let id: UUID
        let title: String
        let date: Date
        let type: String
        let duration: Int
        let status: CalendarWorkoutStatus
        let source: WorkoutSource
        let exerciseCount: Int
    }

    func allCalendarEntriesForDate(_ date: Date) -> [CalendarWorkoutEntry] {
        let cal = Calendar.current
        var entries: [CalendarWorkoutEntry] = []
        let isPast = cal.startOfDay(for: date) < cal.startOfDay(for: .now)
        let isToday = cal.isDateInToday(date)

        if let plan = currentPlan {
            for day in plan.days where cal.isDate(day.date, inSameDayAs: date) && !day.isRestDay {
                let status: CalendarWorkoutStatus
                if day.isCompleted { status = .completed }
                else if isPast && !isToday { status = .missed }
                else { status = .planned }
                entries.append(CalendarWorkoutEntry(
                    id: day.id, title: day.title, date: day.date,
                    type: "PT", duration: max(day.exercises.count * 4, 15),
                    status: status, source: day.source, exerciseCount: day.exercises.count
                ))
            }
        }

        for unitDay in scheduledUnitPT where cal.isDate(unitDay.date, inSameDayAs: date) {
            let status: CalendarWorkoutStatus
            if unitDay.isCompleted { status = .completed }
            else if isPast && !isToday { status = .missed }
            else { status = .planned }
            entries.append(CalendarWorkoutEntry(
                id: unitDay.id, title: unitDay.title, date: unitDay.date,
                type: "Unit PT", duration: max(unitDay.exercises.count * 4, 15),
                status: status, source: .unit, exerciseCount: unitDay.exercises.count
            ))
        }

        if let wPlan = wodPlan {
            for wDay in wPlan.days where cal.isDate(wDay.date, inSameDayAs: date) && !wDay.isRestDay {
                let status: CalendarWorkoutStatus
                if wDay.isCompleted { status = .completed }
                else if isPast && !isToday { status = .missed }
                else { status = .planned }
                let typeLabel = "Functional"
                entries.append(CalendarWorkoutEntry(
                    id: wDay.id, title: wDay.template.title, date: wDay.date,
                    type: typeLabel, duration: wDay.template.durationMinutes,
                    status: status, source: .wod, exerciseCount: wDay.template.movements.count
                ))
            }
        }

        for record in completedRecords where cal.isDate(record.date, inSameDayAs: date) {
            let alreadyTracked = entries.contains { $0.title == record.title && $0.status == .completed }
            if !alreadyTracked {
                entries.append(CalendarWorkoutEntry(
                    id: record.id, title: record.title, date: record.date,
                    type: record.source.rawValue, duration: max(record.exerciseCount * 4, 15),
                    status: .completed, source: record.source, exerciseCount: record.exerciseCount
                ))
            }
        }

        return entries
    }

    func calendarDateStatus(_ date: Date) -> CalendarWorkoutStatus? {
        let entries = allCalendarEntriesForDate(date)
        if entries.isEmpty { return nil }
        if entries.allSatisfy({ $0.status == .completed }) { return .completed }
        if entries.contains(where: { $0.status == .planned }) { return .planned }
        if entries.contains(where: { $0.status == .completed }) { return .completed }
        return .missed
    }

    var todayCalendarEntryCount: Int {
        allCalendarEntriesForDate(Calendar.current.startOfDay(for: .now)).count
    }

    // MARK: - Calendar Sync Preference

    var isCalendarSyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "calendarSyncEnabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "calendarSyncEnabled")
        }
    }

    func resetAllData() {
        currentPlan = nil
        completedRecords = []
        stepHistory = []
        lastWorkoutTag = ""
        unitPTPlans = []
        unitPTFullPlan = nil
        scheduledUnitPT = []
        importedWorkouts = []
        aftScores = []
        aftCalculatorResults = []
        wodPlan = nil
        todayFunctionalWOD = nil
        persistAll()
    }
}
