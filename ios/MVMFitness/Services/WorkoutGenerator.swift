import Foundation

enum WorkoutGenerator {

    struct WorkoutTemplate {
        let title: String
        let exercises: [WorkoutExercise]
        let tag: String
        let tags: [String]
    }

    static func generateWeeklyPlan(
        focus: TrainingFocus,
        level: FitnessLevel,
        equipment: EquipmentOption,
        daysPerWeek: Int,
        minutesPerWorkout: Int,
        ptMode: PTMode,
        dutyType: DutyType
    ) -> WeeklyPlan {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today) ?? today

        let armyMode = ArmyGenerator.mapArmyMode(ptMode: ptMode, dutyType: dutyType)
        let armyEquipment = ArmyGenerator.mapArmyEquipment(equipment)
        let armyFocuses = ArmyGenerator.mapArmyFocuses(focus)

        let armyTemplates = ArmyGenerator.weeklyPlan(
            mode: armyMode,
            focuses: armyFocuses,
            equipment: armyEquipment,
            days: daysPerWeek
        )

        let selectedDays = distributeDays(count: daysPerWeek)
        let modeTags = buildTags(ptMode: ptMode, dutyType: dutyType, focus: focus)

        var days: [WorkoutDay] = []
        var templateIndex = 0

        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) ?? today
            let isWorkoutDay = selectedDays.contains(dayOffset)

            if isWorkoutDay && templateIndex < armyTemplates.count {
                let armyTemplate = armyTemplates[templateIndex]
                let exercises = ArmyGenerator.convertToWorkoutExercises(armyTemplate)
                let templateTags = [armyTemplate.focus.rawValue, armyTemplate.mode.rawValue]

                days.append(WorkoutDay(
                    dayIndex: dayOffset,
                    date: date,
                    title: armyTemplate.title,
                    exercises: exercises,
                    isRestDay: false,
                    templateTag: armyTemplate.title,
                    tags: modeTags + templateTags
                ))
                templateIndex += 1
            } else {
                days.append(WorkoutDay(
                    dayIndex: dayOffset,
                    date: date,
                    title: "Rest Day",
                    exercises: [],
                    isRestDay: true,
                    templateTag: "rest"
                ))
            }
        }

        return WeeklyPlan(
            weekStartDate: startOfWeek,
            goal: focus.rawValue,
            level: level.rawValue,
            equipment: equipment.rawValue,
            minutesPerWorkout: minutesPerWorkout,
            days: days
        )
    }

    static func generateWorkoutOfDay(
        focus: TrainingFocus,
        level: FitnessLevel,
        equipment: EquipmentOption,
        minutes: Int,
        lastWorkoutTag: String,
        ptMode: PTMode,
        dutyType: DutyType
    ) -> WorkoutDay {
        let armyEquipment = ArmyGenerator.mapArmyEquipment(equipment)
        let armyFocuses = ArmyGenerator.mapArmyFocuses(focus)
        let randomFocus = armyFocuses.randomElement() ?? .aftPrep

        let template = ArmyGenerator.nextTemplate(
            mode: .workoutOfDay,
            focus: randomFocus,
            equipment: armyEquipment,
            excluding: lastWorkoutTag
        ) ?? ArmyGenerator.nextTemplate(
            mode: .onDutyIndividual,
            focus: randomFocus,
            equipment: armyEquipment,
            excluding: lastWorkoutTag
        )

        guard let chosen = template else {
            return fallbackWorkoutDay(focus: focus, ptMode: ptMode, dutyType: dutyType)
        }

        let exercises = ArmyGenerator.convertToWorkoutExercises(chosen)
        let modeTags = buildTags(ptMode: ptMode, dutyType: dutyType, focus: focus)

        return WorkoutDay(
            dayIndex: 0,
            date: Calendar.current.startOfDay(for: .now),
            title: chosen.title,
            exercises: exercises,
            templateTag: chosen.title,
            tags: modeTags + [chosen.focus.rawValue, "WOD"]
        )
    }

    static func generateRandomWorkout(
        focus: TrainingFocus,
        level: FitnessLevel,
        equipment: EquipmentOption,
        minutes: Int,
        lastWorkoutTag: String,
        ptMode: PTMode,
        dutyType: DutyType
    ) -> WorkoutDay {
        let armyEquipment = ArmyGenerator.mapArmyEquipment(equipment)
        let armyFocuses = ArmyGenerator.mapArmyFocuses(focus)
        let randomFocus = armyFocuses.randomElement() ?? .tactical

        let template = ArmyGenerator.nextTemplate(
            mode: .randomSession,
            focus: randomFocus,
            equipment: armyEquipment,
            excluding: lastWorkoutTag
        ) ?? ArmyGenerator.nextTemplate(
            mode: .offDutyIndividual,
            focus: randomFocus,
            equipment: armyEquipment,
            excluding: lastWorkoutTag
        )

        guard let chosen = template else {
            return fallbackWorkoutDay(focus: focus, ptMode: ptMode, dutyType: dutyType)
        }

        let exercises = ArmyGenerator.convertToWorkoutExercises(chosen)
        let modeTags = buildTags(ptMode: ptMode, dutyType: dutyType, focus: focus)

        return WorkoutDay(
            dayIndex: 0,
            date: Calendar.current.startOfDay(for: .now),
            title: chosen.title,
            exercises: exercises,
            templateTag: chosen.title,
            tags: modeTags + [chosen.focus.rawValue, "Random"]
        )
    }

    static func generateUnitPT(focus: TrainingFocus, level: FitnessLevel) -> UnitPTPlan {
        let armyFocuses = ArmyGenerator.mapArmyFocuses(focus)
        let randomFocus = armyFocuses.randomElement() ?? .aftPrep

        let unitTemplates = ArmyTemplateLibrary.templates.filter { $0.mode == .unitPT && $0.focus == randomFocus }
        let allUnit = ArmyTemplateLibrary.templates.filter { $0.mode == .unitPT }
        let chosen = unitTemplates.randomElement() ?? allUnit.randomElement()

        if let template = chosen {
            return ArmyGenerator.convertToUnitPTPlan(template)
        }

        return fallbackUnitPTPlan(focus: focus)
    }

    // MARK: - Private

    private static func buildTags(ptMode: PTMode, dutyType: DutyType, focus: TrainingFocus) -> [String] {
        var tags: [String] = []
        switch ptMode {
        case .individual: tags.append("Individual")
        case .unit: tags.append("Unit")
        case .both: tags.append("Individual")
        }
        switch dutyType {
        case .onDuty: tags.append("On-Duty")
        case .offDuty: tags.append("Off-Duty")
        case .both: tags.append("On-Duty")
        }
        if focus == .aftPrep { tags.append("AFT Prep") }
        return tags
    }

    private static func distributeDays(count: Int) -> Set<Int> {
        switch count {
        case 2: return [1, 4]
        case 3: return [1, 3, 5]
        case 4: return [1, 2, 4, 5]
        case 5: return [1, 2, 3, 4, 5]
        case 6: return [0, 1, 2, 3, 4, 5]
        default: return [1, 3, 5]
        }
    }

    private static func fallbackWorkoutDay(focus: TrainingFocus, ptMode: PTMode, dutyType: DutyType) -> WorkoutDay {
        let modeTags = buildTags(ptMode: ptMode, dutyType: dutyType, focus: focus)
        return WorkoutDay(
            dayIndex: 0,
            date: Calendar.current.startOfDay(for: .now),
            title: "General Army PT",
            exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 300, notes: "PD: 10 exercises, 5 reps each", category: .timed),
                WorkoutExercise(name: "Push-Up", sets: 4, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Air Squat", sets: 4, reps: 20, category: .bodyweight),
                WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: 60, category: .timed),
                WorkoutExercise(name: "400 m Run", sets: 3, durationSeconds: 120, notes: "Moderate pace", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 240, notes: "RD: Full sequence", category: .timed)
            ],
            templateTag: "fallback_general",
            tags: modeTags + ["General"]
        )
    }

    private static func fallbackUnitPTPlan(focus: TrainingFocus) -> UnitPTPlan {
        UnitPTPlan(
            title: "Unit PRT — \(focus.rawValue)",
            objective: "Conduct a structured PRT session aligned to \(focus.rawValue.lowercased()).",
            formationNotes: "Form up by squad in extended rectangular formation. Conduct accountability, safety brief, and session overview.",
            equipment: "Cones, timer, water source. Optional: hex bar, sandbag, kettlebell, pull-up bar.",
            warmup: "Preparation Drill (PD): Bend and Reach, Rear Lunge, High Jumper, Rower, Squat Bender, Windmill, Forward Lunge, Prone Row, Bent-Leg Body Twist, Push-Up — 5-10 reps each.",
            mainEffort: [
                UnitPTBlock("Push-Pull Superset: Push-up variation and row — 3 rounds x 10-15 reps. 60 sec rest."),
                UnitPTBlock("Lower Body: Squat and lunge circuit — 3 rounds x 12 each."),
                UnitPTBlock("Core: Plank variations 3 x 45 sec, flutter kicks 3 x 20."),
                UnitPTBlock("Conditioning Finisher: 4 x 200m effort with walk-back recovery.")
            ],
            cooldown: "Recovery Drill (RD): Overhead Arm Pull, Rear Lunge, Extend and Flex, Thigh Stretch, Single-Leg Over — 20-30 sec each.",
            leaderNotes: "Maintain lane assignments and keep transitions tight. Monitor form. Adjust intensity for ability groups."
        )
    }
}
