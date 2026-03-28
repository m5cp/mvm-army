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

        let templates = workoutTemplates(focus: focus, level: level, equipment: equipment, minutes: minutesPerWorkout)
        let selectedDays = distributeDays(count: daysPerWeek)

        var days: [WorkoutDay] = []
        var templateIndex = 0

        let modeTags = buildTags(ptMode: ptMode, dutyType: dutyType, focus: focus)

        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) ?? today
            let isWorkoutDay = selectedDays.contains(dayOffset)

            if isWorkoutDay && templateIndex < templates.count {
                let template = templates[templateIndex % templates.count]
                days.append(WorkoutDay(
                    dayIndex: dayOffset,
                    date: date,
                    title: template.title,
                    exercises: template.exercises,
                    isRestDay: false,
                    templateTag: template.tag,
                    tags: modeTags + template.tags
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
        let templates = workoutTemplates(focus: focus, level: level, equipment: equipment, minutes: minutes)
        let filtered = templates.filter { $0.tag != lastWorkoutTag }
        let chosen = filtered.randomElement() ?? templates.first!
        let modeTags = buildTags(ptMode: ptMode, dutyType: dutyType, focus: focus)

        return WorkoutDay(
            dayIndex: 0,
            date: Calendar.current.startOfDay(for: .now),
            title: chosen.title,
            exercises: chosen.exercises,
            templateTag: chosen.tag,
            tags: modeTags + chosen.tags
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
        let all = allRandomTemplates(level: level, equipment: equipment, minutes: minutes)
        let filtered = all.filter { $0.tag != lastWorkoutTag }
        let chosen = filtered.randomElement() ?? all.randomElement()!
        let modeTags = buildTags(ptMode: ptMode, dutyType: dutyType, focus: focus)

        return WorkoutDay(
            dayIndex: 0,
            date: Calendar.current.startOfDay(for: .now),
            title: chosen.title,
            exercises: chosen.exercises,
            templateTag: chosen.tag,
            tags: modeTags + chosen.tags
        )
    }

    static func generateUnitPT(focus: TrainingFocus, level: FitnessLevel) -> UnitPTPlan {
        let blocks: [UnitPTBlock]
        let objective: String
        let warmup: String
        let cooldown: String

        switch focus {
        case .aftPrep:
            objective = "Conduct AFT-focused PT targeting deadlift, push-up, sprint-drag-carry, plank, and 2-mile run readiness."
            warmup = "Prep Drill (PD), 10 reps each. Movement rehearsal for main effort events."
            blocks = [
                UnitPTBlock("Deadlift pattern drill: 3 rounds x 5 reps, focus on hip hinge form"),
                UnitPTBlock("Hand-release push-up sets: 3 x max effort with 60 sec rest"),
                UnitPTBlock("Sprint-drag-carry simulation: 4 x 50m shuttle efforts"),
                UnitPTBlock("Plank hold: 3 x 60-90 sec with controlled breathing"),
                UnitPTBlock("400m run intervals: 4 repeats with 90 sec recovery")
            ]
            cooldown = "Recovery Drill (RD), walking cool-down, controlled breathing reset."
        case .strength:
            objective = "Build functional strength through compound movements and carries."
            warmup = "Prep Drill (PD), 10 reps each. Joint mobility and activation drills."
            blocks = [
                UnitPTBlock("Squat pattern: 4 x 8 reps, progressive loading"),
                UnitPTBlock("Overhead press or push-up variation: 4 x 8-12"),
                UnitPTBlock("Row or pull variation: 4 x 8-10"),
                UnitPTBlock("Farmer carry: 4 x 40m"),
                UnitPTBlock("Core circuit: plank, dead bug, bird dog — 2 rounds")
            ]
            cooldown = "Recovery Drill (RD), full body stretch sequence, hydration."
        case .endurance:
            objective = "Develop aerobic base and run capacity for sustained operations."
            warmup = "Easy jog 400m, dynamic stretching, leg swings."
            blocks = [
                UnitPTBlock("Tempo run: 15-20 min at moderate-hard effort"),
                UnitPTBlock("OR interval option: 6 x 400m with 90 sec jog recovery"),
                UnitPTBlock("Finish with 5 min easy jog")
            ]
            cooldown = "Walking cool-down, static stretching, breathing reset."
        case .tacticalConditioning:
            objective = "Build work capacity through circuits, carries, and mixed-modal efforts."
            warmup = "Prep Drill (PD), bear crawl, inchworm, lateral shuffle."
            blocks = [
                UnitPTBlock("Circuit: 5 rounds — 10 burpees, 15 squats, 20 mountain climbers, 200m run"),
                UnitPTBlock("Sandbag/sled carry: 4 x 50m"),
                UnitPTBlock("Buddy drag simulation: 4 x 25m")
            ]
            cooldown = "Recovery Drill (RD), mobility flow, controlled breathing."
        case .recovery:
            objective = "Active recovery to promote readiness and reduce injury risk."
            warmup = "Light walk 400m, gentle joint circles."
            blocks = [
                UnitPTBlock("Mobility flow: 10 min full-body movement sequence"),
                UnitPTBlock("Light aerobic: 10-15 min easy walk or jog"),
                UnitPTBlock("Foam roll / self-massage: 5-8 min")
            ]
            cooldown = "Static stretching, deep breathing, hydration emphasis."
        case .generalArmyFitness:
            objective = "Balanced PT session covering strength, endurance, and core stability."
            warmup = "Prep Drill (PD), 10 reps each. Movement prep as needed."
            blocks = [
                UnitPTBlock("Push-up and pull-up/row superset: 3 rounds x 10-15 reps"),
                UnitPTBlock("Squat and lunge circuit: 3 rounds x 12 each"),
                UnitPTBlock("Core: plank variations 3 x 45 sec"),
                UnitPTBlock("Conditioning finisher: 4 x 200m effort with walk-back recovery")
            ]
            cooldown = "Recovery Drill (RD), stretch, after-action review."
        }

        return UnitPTPlan(
            title: "Unit PT — \(focus.rawValue)",
            objective: objective,
            formationNotes: "Form up by squad. Conduct accountability and safety brief prior to movement.",
            equipment: "Cones, timer, water source. Optional: sandbag, kettlebell, pull-up bar.",
            warmup: warmup,
            mainEffort: blocks,
            cooldown: cooldown,
            leaderNotes: "Maintain lane assignments, keep transitions tight. Capture notable performance or concerns."
        )
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

    private static func workoutTemplates(
        focus: TrainingFocus,
        level: FitnessLevel,
        equipment: EquipmentOption,
        minutes: Int
    ) -> [WorkoutTemplate] {
        switch focus {
        case .aftPrep: return aftPrepTemplates(level: level, equipment: equipment, minutes: minutes)
        case .strength: return strengthTemplates(level: level, equipment: equipment, minutes: minutes)
        case .endurance: return enduranceTemplates(level: level, minutes: minutes)
        case .tacticalConditioning: return tacticalTemplates(level: level, equipment: equipment, minutes: minutes)
        case .recovery: return recoveryTemplates(minutes: minutes)
        case .generalArmyFitness: return generalArmyTemplates(level: level, equipment: equipment, minutes: minutes)
        }
    }

    private static func setsFor(_ level: FitnessLevel) -> Int {
        switch level {
        case .beginner: return 3
        case .intermediate: return 4
        case .advanced: return 5
        }
    }

    // MARK: - AFT Prep

    private static func aftPrepTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)
        let useGym = equipment == .gym || equipment == .minimal

        return [
            WorkoutTemplate(title: "Lower Strength + Deadlift", exercises: [
                WorkoutExercise(name: useGym ? "Hex Bar Deadlift" : "Hip Hinge Pattern", sets: s, reps: useGym ? 5 : 10, weight: useGym ? "Working weight" : ""),
                WorkoutExercise(name: "Goblet Squats", sets: s, reps: 10),
                WorkoutExercise(name: "Romanian Deadlift", sets: s, reps: 8),
                WorkoutExercise(name: "Farmer Carry", sets: 3, durationSeconds: 45, category: .timed),
                WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: level == .beginner ? 45 : 75, category: .timed),
            ], tag: "aft_lower_strength", tags: ["Strength", "AFT Prep"]),

            WorkoutTemplate(title: "Upper Endurance + Push-Up", exercises: [
                WorkoutExercise(name: "Hand-Release Push-Ups", sets: s, reps: level == .beginner ? 10 : 20, category: .bodyweight),
                WorkoutExercise(name: "Push-Up Ladder (1-10)", sets: 1, reps: 55, notes: "Pyramid: 1,2,3...10", category: .bodyweight),
                WorkoutExercise(name: useGym ? "Dumbbell Rows" : "Inverted Rows", sets: s, reps: 10),
                WorkoutExercise(name: useGym ? "Overhead Press" : "Pike Push-Ups", sets: s, reps: 8),
                WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: 60, category: .timed),
            ], tag: "aft_upper_endurance", tags: ["Endurance", "AFT Prep"]),

            WorkoutTemplate(title: "Sprint-Drag-Carry Sim", exercises: [
                WorkoutExercise(name: "Sprint Intervals", sets: 6, durationSeconds: 20, notes: "Walk back recovery", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Sled/Sandbag Drag Sim", sets: 4, durationSeconds: 30, notes: "Heavy carry substitute", category: .timed),
                WorkoutExercise(name: "Lateral Shuffle", sets: 4, durationSeconds: 20, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Farmer Carry", sets: 4, durationSeconds: 40, category: .timed),
                WorkoutExercise(name: "Sprint Finish", sets: 4, durationSeconds: 15, notes: "Full effort", category: .cardio, cardioType: .run),
            ], tag: "aft_sdc", tags: ["Work Capacity", "AFT Prep"]),

            WorkoutTemplate(title: "Core + Plank Focus", exercises: [
                WorkoutExercise(name: "Plank Hold", sets: 4, durationSeconds: level == .beginner ? 45 : 90, category: .timed),
                WorkoutExercise(name: "Dead Bug", sets: s, reps: 10, notes: "Each side", category: .bodyweight),
                WorkoutExercise(name: "Bird Dog", sets: s, reps: 10, notes: "Each side", category: .bodyweight),
                WorkoutExercise(name: "Side Plank", sets: 3, durationSeconds: 30, notes: "Each side", category: .timed),
                WorkoutExercise(name: "Hollow Body Hold", sets: 3, durationSeconds: level == .beginner ? 20 : 40, category: .timed),
            ], tag: "aft_core", tags: ["Core", "AFT Prep"]),

            WorkoutTemplate(title: "2-Mile Run Prep", exercises: [
                WorkoutExercise(name: "Warm-Up Jog", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "400m Intervals", sets: level == .beginner ? 4 : 6, durationSeconds: 120, notes: "90 sec jog recovery", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Jog", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Stretch", sets: 1, durationSeconds: 180, category: .timed),
            ], tag: "aft_run", tags: ["Running", "AFT Prep"]),

            WorkoutTemplate(title: "Full AFT Simulation", exercises: [
                WorkoutExercise(name: "Deadlift Pattern", sets: 3, reps: 5, notes: "Focus on form"),
                WorkoutExercise(name: "Hand-Release Push-Ups", sets: 3, reps: level == .beginner ? 10 : 20, category: .bodyweight),
                WorkoutExercise(name: "Sprint-Drag-Carry Sim", sets: 3, durationSeconds: 60, notes: "Shuttle format", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: level == .beginner ? 45 : 90, category: .timed),
                WorkoutExercise(name: "800m Run", sets: 2, durationSeconds: 240, notes: "Target pace", category: .cardio, cardioType: .run),
            ], tag: "aft_full_sim", tags: ["Full Test", "AFT Prep"]),
        ]
    }

    // MARK: - Strength

    private static func strengthTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)
        let useGym = equipment == .gym || equipment == .minimal

        return [
            WorkoutTemplate(title: "Push Day", exercises: [
                WorkoutExercise(name: useGym ? "Bench Press" : "Push-Ups", sets: s, reps: useGym ? 8 : 15, weight: useGym ? "Working weight" : ""),
                WorkoutExercise(name: useGym ? "Overhead Press" : "Pike Push-Ups", sets: s, reps: useGym ? 8 : 12),
                WorkoutExercise(name: useGym ? "Incline Dumbbell Press" : "Diamond Push-Ups", sets: s, reps: 10),
                WorkoutExercise(name: useGym ? "Lateral Raises" : "Arm Circles", sets: s - 1, reps: 15),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: 45, category: .timed),
            ], tag: "str_push", tags: ["Strength", "Upper"]),

            WorkoutTemplate(title: "Pull Day", exercises: [
                WorkoutExercise(name: useGym ? "Barbell Rows" : "Inverted Rows", sets: s, reps: 8),
                WorkoutExercise(name: useGym ? "Pull-Ups" : "Doorway Rows", sets: s, reps: level == .beginner ? 5 : 10),
                WorkoutExercise(name: useGym ? "Face Pulls" : "Band Pull-Aparts", sets: s, reps: 15),
                WorkoutExercise(name: useGym ? "Dumbbell Curls" : "Towel Curls", sets: s - 1, reps: 12),
                WorkoutExercise(name: "Dead Bug", sets: 3, reps: 10, notes: "Each side", category: .bodyweight),
            ], tag: "str_pull", tags: ["Strength", "Upper"]),

            WorkoutTemplate(title: "Leg Day", exercises: [
                WorkoutExercise(name: useGym ? "Barbell Squats" : "Bodyweight Squats", sets: s, reps: useGym ? 8 : 20),
                WorkoutExercise(name: useGym ? "Romanian Deadlifts" : "Single-Leg Deadlifts", sets: s, reps: 10),
                WorkoutExercise(name: "Walking Lunges", sets: s, reps: 12, notes: "Each leg"),
                WorkoutExercise(name: "Calf Raises", sets: s, reps: 15),
                WorkoutExercise(name: "Farmer Carry", sets: 3, durationSeconds: 45, category: .timed),
            ], tag: "str_legs", tags: ["Strength", "Lower"]),

            WorkoutTemplate(title: "Full Body Strength", exercises: [
                WorkoutExercise(name: useGym ? "Deadlifts" : "Single-Leg Deadlifts", sets: s, reps: useGym ? 5 : 10),
                WorkoutExercise(name: useGym ? "Overhead Press" : "Pike Push-Ups", sets: s, reps: 8),
                WorkoutExercise(name: useGym ? "Pull-Ups" : "Inverted Rows", sets: s, reps: level == .beginner ? 5 : 8),
                WorkoutExercise(name: "Goblet Squats", sets: s, reps: 10),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: 60, category: .timed),
            ], tag: "str_full", tags: ["Strength", "Full Body"]),

            WorkoutTemplate(title: "Upper Hypertrophy", exercises: [
                WorkoutExercise(name: useGym ? "Dumbbell Bench Press" : "Decline Push-Ups", sets: s, reps: 10),
                WorkoutExercise(name: useGym ? "Seated Rows" : "Towel Rows", sets: s, reps: 10),
                WorkoutExercise(name: useGym ? "Arnold Press" : "Push-Up Variation", sets: s, reps: 10),
                WorkoutExercise(name: useGym ? "Tricep Pushdowns" : "Bench Dips", sets: s - 1, reps: 12),
                WorkoutExercise(name: "Core Rotation", sets: 3, reps: 10, notes: "Each side", category: .bodyweight),
            ], tag: "str_upper_hyp", tags: ["Strength", "Upper"]),

            WorkoutTemplate(title: "Lower Power", exercises: [
                WorkoutExercise(name: useGym ? "Front Squats" : "Jump Squats", sets: s, reps: useGym ? 6 : 12),
                WorkoutExercise(name: useGym ? "Deadlifts" : "Hip Thrusts", sets: s, reps: useGym ? 5 : 15),
                WorkoutExercise(name: "Step-Ups", sets: s, reps: 10, notes: "Each leg"),
                WorkoutExercise(name: "Sprint Starts", sets: 4, durationSeconds: 10, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: 60, category: .timed),
            ], tag: "str_lower_power", tags: ["Strength", "Lower"]),
        ]
    }

    // MARK: - Endurance

    private static func enduranceTemplates(level: FitnessLevel, minutes: Int) -> [WorkoutTemplate] {
        return [
            WorkoutTemplate(title: "Easy Run", exercises: [
                WorkoutExercise(name: "Warm-Up Walk", sets: 1, durationSeconds: 180, category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Easy Pace Run", sets: 1, durationSeconds: max(600, (minutes - 8) * 60), notes: "Conversational pace", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Walk", sets: 1, durationSeconds: 180, category: .cardio, cardioType: .walk),
            ], tag: "end_easy", tags: ["Running", "Easy"]),

            WorkoutTemplate(title: "Interval Training", exercises: [
                WorkoutExercise(name: "Warm-Up Jog", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Hard Intervals", sets: level == .beginner ? 4 : 8, durationSeconds: 60, notes: "90 sec jog between", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Jog", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
            ], tag: "end_intervals", tags: ["Running", "Intervals"]),

            WorkoutTemplate(title: "Long Steady Run", exercises: [
                WorkoutExercise(name: "Warm-Up Walk", sets: 1, durationSeconds: 180, category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Steady Run", sets: 1, durationSeconds: max(900, (minutes - 6) * 60), notes: "Maintain even effort", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Walk", sets: 1, durationSeconds: 180, category: .cardio, cardioType: .walk),
            ], tag: "end_long", tags: ["Running", "Long"]),

            WorkoutTemplate(title: "Tempo Run", exercises: [
                WorkoutExercise(name: "Easy Warm-Up", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Tempo Effort", sets: 1, durationSeconds: max(600, (minutes - 15) * 60), notes: "Comfortably hard", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Easy Cool-Down", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
            ], tag: "end_tempo", tags: ["Running", "Tempo"]),

            WorkoutTemplate(title: "Ruck March", exercises: [
                WorkoutExercise(name: "Ruck March", sets: 1, durationSeconds: max(1200, (minutes - 5) * 60), notes: "Steady pace with load", category: .cardio, cardioType: .ruck),
                WorkoutExercise(name: "Stretch", sets: 1, durationSeconds: 300, category: .timed),
            ], tag: "end_ruck", tags: ["Endurance", "Ruck"]),

            WorkoutTemplate(title: "Recovery Run", exercises: [
                WorkoutExercise(name: "Very Easy Jog", sets: 1, durationSeconds: max(600, (minutes - 5) * 60), notes: "Slow and relaxed", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Stretch", sets: 1, durationSeconds: 300, category: .timed),
            ], tag: "end_recovery", tags: ["Running", "Recovery"]),
        ]
    }

    // MARK: - Tactical Conditioning

    private static func tacticalTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)

        return [
            WorkoutTemplate(title: "Combat Circuit", exercises: [
                WorkoutExercise(name: "Burpees", sets: 4, reps: level == .beginner ? 5 : 10, category: .bodyweight),
                WorkoutExercise(name: "Squats", sets: 4, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Mountain Climbers", sets: 4, durationSeconds: 30, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Push-Ups", sets: 4, reps: 12, category: .bodyweight),
                WorkoutExercise(name: "200m Sprint", sets: 4, durationSeconds: 45, notes: "Walk back recovery", category: .cardio, cardioType: .run),
            ], tag: "tac_combat", tags: ["Tactical", "Circuit"]),

            WorkoutTemplate(title: "Carry & Drag", exercises: [
                WorkoutExercise(name: "Farmer Carry", sets: 4, durationSeconds: 45, category: .timed),
                WorkoutExercise(name: "Bear Crawl", sets: 4, durationSeconds: 30, category: .timed),
                WorkoutExercise(name: "Sandbag Carry", sets: 4, durationSeconds: 30, notes: "Or heavy backpack", category: .timed),
                WorkoutExercise(name: "Buddy Drag Sim", sets: 4, durationSeconds: 20, category: .timed),
                WorkoutExercise(name: "Sprawls", sets: 3, reps: 10, category: .bodyweight),
            ], tag: "tac_carry", tags: ["Tactical", "Carries"]),

            WorkoutTemplate(title: "EMOM Field Circuit", exercises: [
                WorkoutExercise(name: "Push-Ups", sets: 1, reps: 10, notes: "Every minute on the minute", category: .bodyweight),
                WorkoutExercise(name: "Squats", sets: 1, reps: 15, notes: "Alternate minutes", category: .bodyweight),
                WorkoutExercise(name: "Burpees", sets: 1, reps: 5, notes: "Alternate minutes", category: .bodyweight),
                WorkoutExercise(name: "Total Duration", sets: 1, durationSeconds: max(600, (minutes - 5) * 60), category: .timed),
            ], tag: "tac_emom", tags: ["Tactical", "EMOM"]),

            WorkoutTemplate(title: "Tabata Blitz", exercises: [
                WorkoutExercise(name: "Jump Squats", sets: 8, durationSeconds: 20, notes: "10 sec rest", category: .bodyweight),
                WorkoutExercise(name: "Push-Ups", sets: 8, durationSeconds: 20, notes: "10 sec rest", category: .bodyweight),
                WorkoutExercise(name: "Mountain Climbers", sets: 8, durationSeconds: 20, notes: "10 sec rest", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Burpees", sets: 8, durationSeconds: 20, notes: "10 sec rest", category: .bodyweight),
            ], tag: "tac_tabata", tags: ["Tactical", "Tabata"]),

            WorkoutTemplate(title: "Field Ready", exercises: [
                WorkoutExercise(name: "Ruck March / Fast Walk", sets: 1, durationSeconds: 600, notes: "With weight if available", category: .cardio, cardioType: .ruck),
                WorkoutExercise(name: "Bear Crawl", sets: 4, durationSeconds: 30, category: .timed),
                WorkoutExercise(name: "Sandbag Carry", sets: 4, durationSeconds: 30, category: .timed),
                WorkoutExercise(name: "Sprawls", sets: 3, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: 60, category: .timed),
            ], tag: "tac_field", tags: ["Tactical", "Field"]),

            WorkoutTemplate(title: "AMRAP Challenge", exercises: [
                WorkoutExercise(name: "5 Pull-Ups / Rows", sets: 1, reps: 5),
                WorkoutExercise(name: "10 Push-Ups", sets: 1, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "15 Squats", sets: 1, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Repeat for Time", sets: 1, durationSeconds: max(600, (minutes - 5) * 60), notes: "As many rounds as possible", category: .timed),
            ], tag: "tac_amrap", tags: ["Tactical", "AMRAP"]),
        ]
    }

    // MARK: - Recovery

    private static func recoveryTemplates(minutes: Int) -> [WorkoutTemplate] {
        return [
            WorkoutTemplate(title: "Mobility Flow", exercises: [
                WorkoutExercise(name: "World's Greatest Stretch", sets: 2, reps: 5, notes: "Each side", category: .bodyweight),
                WorkoutExercise(name: "Hip Circles", sets: 2, reps: 10, notes: "Each direction", category: .bodyweight),
                WorkoutExercise(name: "Cat-Cow", sets: 2, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "Light Walk", sets: 1, durationSeconds: max(300, (minutes - 15) * 60), category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Deep Breathing", sets: 1, durationSeconds: 180, category: .timed),
            ], tag: "rec_mobility", tags: ["Recovery"]),

            WorkoutTemplate(title: "Active Recovery Walk", exercises: [
                WorkoutExercise(name: "Easy Walk", sets: 1, durationSeconds: max(600, (minutes - 10) * 60), notes: "Low intensity", category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Full Body Stretch", sets: 1, durationSeconds: 480, category: .timed),
                WorkoutExercise(name: "Breathing Reset", sets: 1, durationSeconds: 120, category: .timed),
            ], tag: "rec_walk", tags: ["Recovery"]),

            WorkoutTemplate(title: "Stretch & Reset", exercises: [
                WorkoutExercise(name: "Foam Roll", sets: 1, durationSeconds: 300, notes: "Full body", category: .timed),
                WorkoutExercise(name: "Hip Flexor Stretch", sets: 2, durationSeconds: 45, notes: "Each side", category: .timed),
                WorkoutExercise(name: "Hamstring Stretch", sets: 2, durationSeconds: 45, notes: "Each side", category: .timed),
                WorkoutExercise(name: "Shoulder Stretch", sets: 2, durationSeconds: 30, notes: "Each side", category: .timed),
                WorkoutExercise(name: "Child's Pose", sets: 1, durationSeconds: 120, category: .timed),
            ], tag: "rec_stretch", tags: ["Recovery"]),
        ]
    }

    // MARK: - General Army Fitness

    private static func generalArmyTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)
        let useGym = equipment == .gym || equipment == .minimal

        return [
            WorkoutTemplate(title: "Total Body Circuit", exercises: [
                WorkoutExercise(name: "Squats", sets: s, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Push-Ups", sets: s, reps: level == .beginner ? 8 : 15, category: .bodyweight),
                WorkoutExercise(name: "Lunges", sets: s, reps: 12, notes: "Each leg", category: .bodyweight),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: level == .beginner ? 30 : 45, category: .timed),
                WorkoutExercise(name: "Jumping Jacks", sets: 3, durationSeconds: 60, category: .cardio, cardioType: .run),
            ], tag: "gen_total", tags: ["General", "Full Body"]),

            WorkoutTemplate(title: "Calisthenics Circuit", exercises: [
                WorkoutExercise(name: "Push-Up Ladder (1-10)", sets: 1, reps: 55, notes: "Pyramid: 1,2,3...10", category: .bodyweight),
                WorkoutExercise(name: "Squats", sets: 4, reps: 20, category: .bodyweight),
                WorkoutExercise(name: "Flutter Kicks", sets: 4, durationSeconds: 30, category: .timed),
                WorkoutExercise(name: "Burpees", sets: 3, reps: level == .beginner ? 5 : 10, category: .bodyweight),
                WorkoutExercise(name: "Mountain Climbers", sets: 4, durationSeconds: 30, category: .cardio, cardioType: .run),
            ], tag: "gen_calisthenics", tags: ["General", "Calisthenics"]),

            WorkoutTemplate(title: "Strength Foundations", exercises: [
                WorkoutExercise(name: "Goblet Squats", sets: s, reps: 12),
                WorkoutExercise(name: "Push-Up Variation", sets: s, reps: 10, category: .bodyweight),
                WorkoutExercise(name: useGym ? "Bent-Over Rows" : "Inverted Rows", sets: s, reps: 10),
                WorkoutExercise(name: "Glute Bridges", sets: s, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Farmer Carry", sets: 3, durationSeconds: 40, category: .timed),
            ], tag: "gen_strength", tags: ["General", "Strength"]),

            WorkoutTemplate(title: "Cardio + Core", exercises: [
                WorkoutExercise(name: "High Knees", sets: 4, durationSeconds: 30, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Mountain Climbers", sets: 4, durationSeconds: 30, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Bicycle Crunches", sets: s, reps: 20, category: .bodyweight),
                WorkoutExercise(name: "Burpees", sets: 3, reps: level == .beginner ? 5 : 10, category: .bodyweight),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: 45, category: .timed),
            ], tag: "gen_cardio_core", tags: ["General", "Cardio"]),

            WorkoutTemplate(title: "Endurance Run", exercises: [
                WorkoutExercise(name: "Warm-Up Jog", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Tempo Run", sets: 1, durationSeconds: minutes >= 45 ? 1200 : 900, notes: "Moderate hard pace", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Sprint Intervals", sets: 6, durationSeconds: 30, notes: "60 sec walk between", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Walk", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .walk),
            ], tag: "gen_endurance", tags: ["General", "Running"]),

            WorkoutTemplate(title: "Mobility + Endurance", exercises: [
                WorkoutExercise(name: "World's Greatest Stretch", sets: 2, reps: 5, notes: "Each side", category: .bodyweight),
                WorkoutExercise(name: "Easy Jog / Walk", sets: 1, durationSeconds: minutes >= 30 ? 600 : 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Bear Crawl", sets: 3, durationSeconds: 30, category: .timed),
                WorkoutExercise(name: "Side Lunges", sets: 3, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "Hip Circles", sets: 2, reps: 10, notes: "Each direction", category: .bodyweight),
            ], tag: "gen_mobility", tags: ["General", "Recovery"]),
        ]
    }

    // MARK: - Random Pool

    private static func allRandomTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        var all: [WorkoutTemplate] = []
        all.append(contentsOf: generalArmyTemplates(level: level, equipment: equipment, minutes: minutes))
        all.append(contentsOf: tacticalTemplates(level: level, equipment: equipment, minutes: minutes))
        all.append(contentsOf: aftPrepTemplates(level: level, equipment: equipment, minutes: minutes))
        return all
    }
}
