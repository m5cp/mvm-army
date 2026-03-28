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
            objective = "Conduct AFT-focused PRT targeting deadlift strength, push-up endurance, sprint-drag-carry work capacity, core stability, and 2-mile run pacing."
            warmup = "Preparation Drill (PD): Bend and Reach, Rear Lunge, High Jumper, Rower, Squat Bender, Windmill, Forward Lunge, Prone Row, Bent-Leg Body Twist, Push-Up — 5-10 reps each. Hip Stability Drill as needed."
            blocks = [
                UnitPTBlock("MDL Prep: Hex bar or trap bar deadlift pattern drill — 4 rounds x 3-5 reps at controlled tempo. Focus on hip hinge, flat back, and leg drive."),
                UnitPTBlock("HRP Station: Hand-release push-up sets — 3 x max effort with 60 sec rest. Emphasize full chest-to-ground, hands release, full arm extension."),
                UnitPTBlock("SDC Lane: Sprint-drag-carry simulation — 5 x 25m shuttle efforts alternating sprint, lateral shuffle, drag, and carry movements with 90 sec recovery."),
                UnitPTBlock("PLK Hold: Forearm plank — 3 x 60-90 sec with strict form. Neutral spine, engaged glutes, controlled breathing throughout."),
                UnitPTBlock("2MR Intervals: 400m repeats — 4-6 x 400m at target 2MR pace with equal jog recovery. Focus on consistent splits.")
            ]
            cooldown = "Recovery Drill (RD): Overhead Arm Pull, Rear Lunge, Extend and Flex, Thigh Stretch, Single-Leg Over — 20-30 sec each. Walking cool-down 400m."

        case .strength:
            objective = "Build functional strength through compound movement patterns aligned with operational demands. Emphasis on lower body power and upper body pressing/pulling balance."
            warmup = "Preparation Drill (PD): 10 reps each exercise. Movement Drill 1 (MD1): Power Skip, Crossover, Crouch Run — 25m each."
            blocks = [
                UnitPTBlock("Primary Lift: Squat or deadlift pattern — 4 x 5-8 reps with progressive loading. 2 min rest between sets."),
                UnitPTBlock("Superset: Overhead press or push variation paired with row or pull variation — 4 x 8-10 reps each. 90 sec rest."),
                UnitPTBlock("Accessory Circuit: Goblet squat, farmer carry 40m, glute bridge — 3 rounds with minimal transition time."),
                UnitPTBlock("Core Stability: Dead bug, bird dog, side plank — 3 x 30 sec each. Controlled movement and breathing.")
            ]
            cooldown = "Recovery Drill (RD): Full sequence. Emphasis on hip flexor and hamstring mobility. Hydration and after-action review."

        case .endurance:
            objective = "Develop aerobic base and run capacity for sustained operations and 2MR improvement. Build pacing discipline and recovery between efforts."
            warmup = "Easy jog 400m. Preparation Drill (PD): 5 reps each. Dynamic leg swings, ankle circles, A-skips 2 x 25m."
            blocks = [
                UnitPTBlock("Option A — Tempo Run: 15-20 min at moderate-hard effort (target 2MR pace + 30 sec per 400m). Maintain consistent rhythm."),
                UnitPTBlock("Option B — Interval Training: 6-8 x 400m at target 2MR pace with 90 sec jog recovery. Focus on even splits."),
                UnitPTBlock("Finish with 5-8 min easy jog to bring heart rate down gradually.")
            ]
            cooldown = "Walking cool-down 400m. Recovery Drill (RD): Focus on quads, hamstrings, hip flexors, calves. Deep breathing reset."

        case .tacticalConditioning:
            objective = "Build work capacity and anaerobic power through circuit-based training. Simulate SDC demands with carries, drags, and high-intensity transitions."
            warmup = "Preparation Drill (PD): 10 reps each. Conditioning Drill 1 (CD1): Power Jump, V-Up, Mountain Climber, Leg Tuck and Twist, Single-Leg Push-Up — 5-10 reps each."
            blocks = [
                UnitPTBlock("Combat Circuit: 5 rounds — 10 burpees, 15 squats, 20 mountain climbers, 200m sprint. 90 sec rest between rounds."),
                UnitPTBlock("Carry and Drag Lane: Farmer carry 50m, bear crawl 25m, sled/sandbag drag 25m, buddy drag sim 25m — 4 rounds."),
                UnitPTBlock("Finisher: Tabata-style 4 min — 20 sec work / 10 sec rest alternating sprawls and jump squats.")
            ]
            cooldown = "Recovery Drill (RD): Full sequence. Walking cool-down. Controlled breathing emphasis. Hydration."

        case .recovery:
            objective = "Active recovery session to promote readiness, reduce injury risk, and maintain mobility. Low intensity throughout."
            warmup = "Light walk 400m. Gentle joint circles — ankles, knees, hips, shoulders, neck."
            blocks = [
                UnitPTBlock("Mobility Flow: World's greatest stretch, 90/90 hip switch, cat-cow, thoracic rotation — 10 min continuous movement."),
                UnitPTBlock("Light Aerobic: 10-15 min easy walk or very light jog. Heart rate below 120 BPM."),
                UnitPTBlock("Self-Maintenance: Foam roll or lacrosse ball work — IT band, quads, glutes, thoracic spine, calves — 5-8 min.")
            ]
            cooldown = "Static stretching: hip flexor, hamstring, pigeon, shoulder cross-body, chest doorway stretch — 30 sec each. Deep breathing reset 2 min."

        case .generalArmyFitness:
            objective = "Balanced PRT session covering strength, endurance, and core stability. Build general physical readiness across all AFT domains."
            warmup = "Preparation Drill (PD): 10 reps each exercise. 4 for the Core (4C): Bent-Leg Raise, Side Bridge, Back Bridge, Quadraplex — 5-10 reps each."
            blocks = [
                UnitPTBlock("Push-Pull Superset: Push-up variation and row/pull-up — 3 rounds x 10-15 reps. 60 sec rest between rounds."),
                UnitPTBlock("Lower Body: Squat and lunge circuit — 3 rounds x 12 each. Walking lunges with overhead arm extension."),
                UnitPTBlock("Core: Plank variations 3 x 45 sec, flutter kicks 3 x 20, leg tuck 3 x 10."),
                UnitPTBlock("Conditioning Finisher: 4 x 200m effort with walk-back recovery. Focus on controlled acceleration.")
            ]
            cooldown = "Recovery Drill (RD): Full sequence. After-action review with formation. Hydration emphasis."
        }

        return UnitPTPlan(
            title: "Unit PRT — \(focus.rawValue)",
            objective: objective,
            formationNotes: "Form up by squad in extended rectangular formation. Conduct accountability, safety brief, and session overview. Designate lane NCOs for station-based work.",
            equipment: "Cones, timer, water source. Optional: hex bar, sandbag, kettlebell, pull-up bar, sled. Adjust based on availability.",
            warmup: warmup,
            mainEffort: blocks,
            cooldown: cooldown,
            leaderNotes: "Maintain lane assignments and keep transitions tight. Monitor form on all lifts. Adjust intensity for ability groups as needed. Capture standout performance and areas for individual improvement."
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

    // MARK: - AFT Prep (FM 7-22 Aligned)

    private static func aftPrepTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)
        let useGym = equipment == .gym || equipment == .minimal

        return [
            WorkoutTemplate(title: "MDL Strength — Lower Body", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 300, notes: "PD: 10 exercises, 5 reps each", category: .timed),
                WorkoutExercise(name: useGym ? "3RM Deadlift Pattern" : "Hip Hinge to Deadlift", sets: s, reps: useGym ? 5 : 10, weight: useGym ? "Build to working weight" : "", notes: "Focus on hip hinge, flat back, leg drive"),
                WorkoutExercise(name: "Goblet Squat", sets: s, reps: 10, notes: "Sit between hips, chest tall"),
                WorkoutExercise(name: "Romanian Deadlift", sets: s, reps: 8, notes: "Slow eccentric, stretch hamstrings"),
                WorkoutExercise(name: "Farmer Carry", sets: 3, durationSeconds: 45, notes: "Heavy grip, tall posture", category: .timed),
                WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: level == .beginner ? 45 : 75, notes: "Neutral spine, engaged glutes", category: .timed),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 240, notes: "RD: Overhead Arm Pull, Rear Lunge, Extend and Flex", category: .timed),
            ], tag: "aft_mdl_strength", tags: ["MDL", "Strength", "AFT Prep"]),

            WorkoutTemplate(title: "HRP Endurance — Upper Body", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 300, notes: "PD: 10 exercises, 5 reps each", category: .timed),
                WorkoutExercise(name: "Hand-Release Push-Up", sets: s, reps: level == .beginner ? 10 : 20, notes: "Chest to ground, full hand release, lock out", category: .bodyweight),
                WorkoutExercise(name: "Push-Up Pyramid (1-10)", sets: 1, reps: 55, notes: "1, 2, 3...10 reps with brief rest between", category: .bodyweight),
                WorkoutExercise(name: useGym ? "Dumbbell Row" : "Inverted Row", sets: s, reps: 10, notes: "Lead with elbows, squeeze back"),
                WorkoutExercise(name: useGym ? "Overhead Press" : "Pike Push-Up", sets: s, reps: 8, notes: "Full lockout overhead"),
                WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: 60, notes: "Maintain form throughout", category: .timed),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 240, notes: "RD: Focus on shoulders and chest", category: .timed),
            ], tag: "aft_hrp_endurance", tags: ["HRP", "Endurance", "AFT Prep"]),

            WorkoutTemplate(title: "SDC Work Capacity", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 300, notes: "PD followed by Movement Drill 1", category: .timed),
                WorkoutExercise(name: "Sprint Intervals", sets: 6, durationSeconds: 20, notes: "25m sprint, walk back recovery", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Sled/Sandbag Drag Simulation", sets: 4, durationSeconds: 30, notes: "Heavy backward drag or carry substitute", category: .timed),
                WorkoutExercise(name: "Lateral Shuffle", sets: 4, durationSeconds: 20, notes: "Low hips, quick feet, 25m each direction", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Farmer Carry", sets: 4, durationSeconds: 40, notes: "Max load, controlled posture", category: .timed),
                WorkoutExercise(name: "Sprint Finish", sets: 4, durationSeconds: 15, notes: "Full effort through the line", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 240, notes: "RD: Full sequence", category: .timed),
            ], tag: "aft_sdc_capacity", tags: ["SDC", "Work Capacity", "AFT Prep"]),

            WorkoutTemplate(title: "PLK Core Endurance", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 300, notes: "PD: 10 exercises, 5 reps each", category: .timed),
                WorkoutExercise(name: "Forearm Plank Hold", sets: 4, durationSeconds: level == .beginner ? 45 : 90, notes: "Neutral spine, steady breathing, engage glutes", category: .timed),
                WorkoutExercise(name: "Dead Bug", sets: s, reps: 10, notes: "Each side — slow and controlled, lower back flat", category: .bodyweight),
                WorkoutExercise(name: "Bird Dog", sets: s, reps: 10, notes: "Each side — extend fully, hold 2 sec", category: .bodyweight),
                WorkoutExercise(name: "Side Plank", sets: 3, durationSeconds: 30, notes: "Each side — stack hips, don't sag", category: .timed),
                WorkoutExercise(name: "Hollow Body Hold", sets: 3, durationSeconds: level == .beginner ? 20 : 40, notes: "Lower back pressed to ground", category: .timed),
                WorkoutExercise(name: "Leg Tuck and Twist", sets: 3, reps: 10, notes: "Slow rotation, engage obliques", category: .bodyweight),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Core-focused stretches", category: .timed),
            ], tag: "aft_plk_core", tags: ["PLK", "Core", "AFT Prep"]),

            WorkoutTemplate(title: "2MR Run Prep", exercises: [
                WorkoutExercise(name: "Warm-Up Jog", sets: 1, durationSeconds: 300, notes: "Easy pace, loosen up", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Dynamic Drills", sets: 1, durationSeconds: 180, notes: "A-skip, B-skip, butt kicks, high knees — 2 x 25m each", category: .timed),
                WorkoutExercise(name: "400m Repeats", sets: level == .beginner ? 4 : 6, durationSeconds: 120, notes: "Target 2MR pace — equal jog recovery between", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Jog", sets: 1, durationSeconds: 300, notes: "Easy pace, bring HR down", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 300, notes: "RD: Quads, hamstrings, hip flexors, calves", category: .timed),
            ], tag: "aft_2mr_run", tags: ["2MR", "Running", "AFT Prep"]),

            WorkoutTemplate(title: "Full AFT Simulation", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 300, notes: "PD: Full sequence, 5 reps each", category: .timed),
                WorkoutExercise(name: "Deadlift Pattern", sets: 3, reps: 5, notes: "Build to moderate-heavy load — practice 3RM setup"),
                WorkoutExercise(name: "Hand-Release Push-Up", sets: 3, reps: level == .beginner ? 10 : 20, notes: "Strict form — full release, full lockout", category: .bodyweight),
                WorkoutExercise(name: "SDC Simulation", sets: 3, durationSeconds: 60, notes: "Sprint-shuffle-drag-carry shuttle format", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: level == .beginner ? 45 : 90, notes: "Maintain strict form throughout", category: .timed),
                WorkoutExercise(name: "800m Run", sets: 2, durationSeconds: 240, notes: "At target 2MR pace — practice race effort", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 300, notes: "RD: Full sequence", category: .timed),
            ], tag: "aft_full_sim", tags: ["Full Test Sim", "AFT Prep"]),
        ]
    }

    // MARK: - Strength (Compound Movement Focus)

    private static func strengthTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)
        let useGym = equipment == .gym || equipment == .minimal

        return [
            WorkoutTemplate(title: "Push Day — Horizontal + Vertical", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD: Upper body focus", category: .timed),
                WorkoutExercise(name: useGym ? "Bench Press" : "Push-Ups", sets: s, reps: useGym ? 8 : 15, weight: useGym ? "Working weight" : ""),
                WorkoutExercise(name: useGym ? "Overhead Press" : "Pike Push-Up", sets: s, reps: useGym ? 8 : 12),
                WorkoutExercise(name: useGym ? "Incline Dumbbell Press" : "Decline Push-Up", sets: s, reps: 10),
                WorkoutExercise(name: useGym ? "Lateral Raise" : "Arm Circles", sets: s - 1, reps: 15),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: 45, category: .timed),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Shoulders, chest, triceps", category: .timed),
            ], tag: "str_push", tags: ["Strength", "Upper Push"]),

            WorkoutTemplate(title: "Pull Day — Back + Biceps", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD: Upper body focus", category: .timed),
                WorkoutExercise(name: useGym ? "Barbell Row" : "Inverted Row", sets: s, reps: 8),
                WorkoutExercise(name: useGym ? "Pull-Up" : "Doorway Row", sets: s, reps: level == .beginner ? 5 : 10),
                WorkoutExercise(name: useGym ? "Face Pull" : "Band Pull-Apart", sets: s, reps: 15),
                WorkoutExercise(name: useGym ? "Dumbbell Curl" : "Towel Curl", sets: s - 1, reps: 12),
                WorkoutExercise(name: "Dead Bug", sets: 3, reps: 10, notes: "Each side", category: .bodyweight),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Back, biceps, forearms", category: .timed),
            ], tag: "str_pull", tags: ["Strength", "Upper Pull"]),

            WorkoutTemplate(title: "Leg Day — Squat Focus", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD: Lower body emphasis", category: .timed),
                WorkoutExercise(name: useGym ? "Barbell Back Squat" : "Bodyweight Squat", sets: s, reps: useGym ? 8 : 20),
                WorkoutExercise(name: useGym ? "Romanian Deadlift" : "Single-Leg Deadlift", sets: s, reps: 10),
                WorkoutExercise(name: "Walking Lunge", sets: s, reps: 12, notes: "Each leg"),
                WorkoutExercise(name: "Calf Raise", sets: s, reps: 15),
                WorkoutExercise(name: "Farmer Carry", sets: 3, durationSeconds: 45, category: .timed),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Quads, hamstrings, hip flexors", category: .timed),
            ], tag: "str_legs", tags: ["Strength", "Lower Body"]),

            WorkoutTemplate(title: "Full Body Strength", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD: Full sequence", category: .timed),
                WorkoutExercise(name: useGym ? "Deadlift" : "Single-Leg Deadlift", sets: s, reps: useGym ? 5 : 10),
                WorkoutExercise(name: useGym ? "Overhead Press" : "Pike Push-Up", sets: s, reps: 8),
                WorkoutExercise(name: useGym ? "Pull-Up" : "Inverted Row", sets: s, reps: level == .beginner ? 5 : 8),
                WorkoutExercise(name: "Goblet Squat", sets: s, reps: 10),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: 60, category: .timed),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Full body", category: .timed),
            ], tag: "str_full", tags: ["Strength", "Full Body"]),

            WorkoutTemplate(title: "Upper Hypertrophy", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD: Upper body emphasis", category: .timed),
                WorkoutExercise(name: useGym ? "Dumbbell Bench Press" : "Decline Push-Up", sets: s, reps: 10),
                WorkoutExercise(name: useGym ? "Seated Row" : "Towel Row", sets: s, reps: 10),
                WorkoutExercise(name: useGym ? "Arnold Press" : "Push-Up Variation", sets: s, reps: 10),
                WorkoutExercise(name: useGym ? "Tricep Pushdown" : "Bench Dip", sets: s - 1, reps: 12),
                WorkoutExercise(name: "Core Rotation", sets: 3, reps: 10, notes: "Each side", category: .bodyweight),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Upper body", category: .timed),
            ], tag: "str_upper_hyp", tags: ["Strength", "Hypertrophy"]),

            WorkoutTemplate(title: "Lower Power + Sprint", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD + Movement Drill 1", category: .timed),
                WorkoutExercise(name: useGym ? "Front Squat" : "Jump Squat", sets: s, reps: useGym ? 6 : 12),
                WorkoutExercise(name: useGym ? "Deadlift" : "Hip Thrust", sets: s, reps: useGym ? 5 : 15),
                WorkoutExercise(name: "Step-Up", sets: s, reps: 10, notes: "Each leg"),
                WorkoutExercise(name: "Sprint Starts", sets: 4, durationSeconds: 10, notes: "Explosive first 10m", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: 60, category: .timed),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Lower body + hip flexors", category: .timed),
            ], tag: "str_lower_power", tags: ["Strength", "Power"]),
        ]
    }

    // MARK: - Endurance (Run-Focused)

    private static func enduranceTemplates(level: FitnessLevel, minutes: Int) -> [WorkoutTemplate] {
        return [
            WorkoutTemplate(title: "Easy Run — Aerobic Base", exercises: [
                WorkoutExercise(name: "Warm-Up Walk", sets: 1, durationSeconds: 180, notes: "Build to easy jog", category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Easy Pace Run", sets: 1, durationSeconds: max(600, (minutes - 8) * 60), notes: "Conversational pace — nose breathing", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Walk", sets: 1, durationSeconds: 180, notes: "Gradual deceleration", category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Lower body stretches", category: .timed),
            ], tag: "end_easy", tags: ["Running", "Easy Pace"]),

            WorkoutTemplate(title: "Interval Training — Speed Work", exercises: [
                WorkoutExercise(name: "Warm-Up Jog", sets: 1, durationSeconds: 300, notes: "Easy pace + dynamic drills", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Hard Intervals", sets: level == .beginner ? 4 : 8, durationSeconds: 60, notes: "90 sec jog recovery between — push effort", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Jog", sets: 1, durationSeconds: 300, notes: "Bring HR down gradually", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Calves, hamstrings, quads", category: .timed),
            ], tag: "end_intervals", tags: ["Running", "Intervals"]),

            WorkoutTemplate(title: "Long Steady Run", exercises: [
                WorkoutExercise(name: "Warm-Up Walk", sets: 1, durationSeconds: 180, notes: "Easy transition", category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Steady State Run", sets: 1, durationSeconds: max(900, (minutes - 6) * 60), notes: "Even effort — build endurance base", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Walk", sets: 1, durationSeconds: 180, notes: "Walk it out", category: .cardio, cardioType: .walk),
            ], tag: "end_long", tags: ["Running", "Long Run"]),

            WorkoutTemplate(title: "Tempo Run — Race Pace", exercises: [
                WorkoutExercise(name: "Easy Warm-Up", sets: 1, durationSeconds: 300, notes: "Build to tempo pace", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Tempo Effort", sets: 1, durationSeconds: max(600, (minutes - 15) * 60), notes: "Comfortably hard — target 2MR pace + 15 sec/400m", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Easy Cool-Down", sets: 1, durationSeconds: 300, notes: "Gradual return to easy pace", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Focus on hip flexors and calves", category: .timed),
            ], tag: "end_tempo", tags: ["Running", "Tempo"]),

            WorkoutTemplate(title: "Ruck March — Load Bearing", exercises: [
                WorkoutExercise(name: "Ruck March", sets: 1, durationSeconds: max(1200, (minutes - 5) * 60), notes: "Steady pace with load — maintain posture", category: .cardio, cardioType: .ruck),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 300, notes: "RD: Shoulders, back, hips, feet", category: .timed),
            ], tag: "end_ruck", tags: ["Endurance", "Ruck March"]),

            WorkoutTemplate(title: "Recovery Run — Active Recovery", exercises: [
                WorkoutExercise(name: "Very Easy Jog", sets: 1, durationSeconds: max(600, (minutes - 5) * 60), notes: "Conversation pace — slow and relaxed", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 300, notes: "RD: Full body mobility", category: .timed),
            ], tag: "end_recovery", tags: ["Running", "Recovery"]),
        ]
    }

    // MARK: - Tactical Conditioning (SDC-Aligned)

    private static func tacticalTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)

        return [
            WorkoutTemplate(title: "Combat Circuit", exercises: [
                WorkoutExercise(name: "Conditioning Drill 1", sets: 1, durationSeconds: 300, notes: "CD1: Power Jump, V-Up, Mountain Climber, Leg Tuck Twist, SL Push-Up — 5 reps each", category: .timed),
                WorkoutExercise(name: "Burpees", sets: 4, reps: level == .beginner ? 5 : 10, category: .bodyweight),
                WorkoutExercise(name: "Squat", sets: 4, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Mountain Climber", sets: 4, durationSeconds: 30, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Push-Up", sets: 4, reps: 12, category: .bodyweight),
                WorkoutExercise(name: "200m Sprint", sets: 4, durationSeconds: 45, notes: "Walk back recovery", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Full sequence", category: .timed),
            ], tag: "tac_combat", tags: ["Tactical", "Circuit"]),

            WorkoutTemplate(title: "Carry and Drag Lane", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD + bear crawl, inchworm warm-up", category: .timed),
                WorkoutExercise(name: "Farmer Carry", sets: 4, durationSeconds: 45, notes: "Max load, maintain posture", category: .timed),
                WorkoutExercise(name: "Bear Crawl", sets: 4, durationSeconds: 30, notes: "Low hips, opposite hand/foot", category: .timed),
                WorkoutExercise(name: "Sandbag Carry", sets: 4, durationSeconds: 30, notes: "Or heavy backpack — simulate casualty drag", category: .timed),
                WorkoutExercise(name: "Buddy Drag Simulation", sets: 4, durationSeconds: 20, notes: "Backward drag with load", category: .timed),
                WorkoutExercise(name: "Sprawl", sets: 3, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Full sequence", category: .timed),
            ], tag: "tac_carry", tags: ["Tactical", "Carries"]),

            WorkoutTemplate(title: "EMOM Field Circuit", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD: Movement prep", category: .timed),
                WorkoutExercise(name: "Push-Up", sets: 1, reps: 10, notes: "Every minute on the minute", category: .bodyweight),
                WorkoutExercise(name: "Squat", sets: 1, reps: 15, notes: "Alternate minutes", category: .bodyweight),
                WorkoutExercise(name: "Burpee", sets: 1, reps: 5, notes: "Alternate minutes", category: .bodyweight),
                WorkoutExercise(name: "EMOM Duration", sets: 1, durationSeconds: max(600, (minutes - 5) * 60), notes: "Repeat cycle for total duration", category: .timed),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Full sequence", category: .timed),
            ], tag: "tac_emom", tags: ["Tactical", "EMOM"]),

            WorkoutTemplate(title: "Tabata Blitz", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD: Elevate HR gradually", category: .timed),
                WorkoutExercise(name: "Jump Squat", sets: 8, durationSeconds: 20, notes: "10 sec rest between", category: .bodyweight),
                WorkoutExercise(name: "Push-Up", sets: 8, durationSeconds: 20, notes: "10 sec rest between", category: .bodyweight),
                WorkoutExercise(name: "Mountain Climber", sets: 8, durationSeconds: 20, notes: "10 sec rest between", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Burpee", sets: 8, durationSeconds: 20, notes: "10 sec rest between", category: .bodyweight),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 240, notes: "RD: Extended cool-down after high intensity", category: .timed),
            ], tag: "tac_tabata", tags: ["Tactical", "Tabata"]),

            WorkoutTemplate(title: "Field Ready — Mixed Modal", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD + Movement Drill 1", category: .timed),
                WorkoutExercise(name: "Ruck Walk / Fast Walk", sets: 1, durationSeconds: 600, notes: "With load if available", category: .cardio, cardioType: .ruck),
                WorkoutExercise(name: "Bear Crawl", sets: 4, durationSeconds: 30, notes: "25m out and back", category: .timed),
                WorkoutExercise(name: "Sandbag Carry", sets: 4, durationSeconds: 30, notes: "Or heavy pack carry", category: .timed),
                WorkoutExercise(name: "Sprawl", sets: 3, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: 60, category: .timed),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Full sequence", category: .timed),
            ], tag: "tac_field", tags: ["Tactical", "Field"]),

            WorkoutTemplate(title: "AMRAP Challenge", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD: Full sequence", category: .timed),
                WorkoutExercise(name: "Pull-Up / Row", sets: 1, reps: 5, notes: "Part of AMRAP cycle"),
                WorkoutExercise(name: "Push-Up", sets: 1, reps: 10, notes: "Part of AMRAP cycle", category: .bodyweight),
                WorkoutExercise(name: "Squat", sets: 1, reps: 15, notes: "Part of AMRAP cycle", category: .bodyweight),
                WorkoutExercise(name: "AMRAP Duration", sets: 1, durationSeconds: max(600, (minutes - 5) * 60), notes: "As many rounds as possible — track rounds", category: .timed),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Full sequence", category: .timed),
            ], tag: "tac_amrap", tags: ["Tactical", "AMRAP"]),
        ]
    }

    // MARK: - Recovery

    private static func recoveryTemplates(minutes: Int) -> [WorkoutTemplate] {
        return [
            WorkoutTemplate(title: "Mobility Flow", exercises: [
                WorkoutExercise(name: "World's Greatest Stretch", sets: 2, reps: 5, notes: "Each side — slow and deliberate", category: .bodyweight),
                WorkoutExercise(name: "Hip 90/90 Switch", sets: 2, reps: 10, notes: "Each direction — open up hips", category: .bodyweight),
                WorkoutExercise(name: "Cat-Cow", sets: 2, reps: 10, notes: "Sync with breath", category: .bodyweight),
                WorkoutExercise(name: "Light Walk", sets: 1, durationSeconds: max(300, (minutes - 15) * 60), notes: "Easy pace, nasal breathing", category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Deep Breathing", sets: 1, durationSeconds: 180, notes: "Box breathing: 4 in, 4 hold, 4 out, 4 hold", category: .timed),
            ], tag: "rec_mobility", tags: ["Recovery", "Mobility"]),

            WorkoutTemplate(title: "Active Recovery Walk", exercises: [
                WorkoutExercise(name: "Easy Walk", sets: 1, durationSeconds: max(600, (minutes - 10) * 60), notes: "Low intensity — promote blood flow", category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Full Body Stretch", sets: 1, durationSeconds: 480, notes: "Hold each stretch 30 sec", category: .timed),
                WorkoutExercise(name: "Breathing Reset", sets: 1, durationSeconds: 120, notes: "Parasympathetic activation", category: .timed),
            ], tag: "rec_walk", tags: ["Recovery", "Walking"]),

            WorkoutTemplate(title: "Stretch and Reset", exercises: [
                WorkoutExercise(name: "Foam Roll", sets: 1, durationSeconds: 300, notes: "IT band, quads, glutes, thoracic spine, calves", category: .timed),
                WorkoutExercise(name: "Hip Flexor Stretch", sets: 2, durationSeconds: 45, notes: "Each side — half-kneeling", category: .timed),
                WorkoutExercise(name: "Hamstring Stretch", sets: 2, durationSeconds: 45, notes: "Each side — standing or seated", category: .timed),
                WorkoutExercise(name: "Shoulder Cross-Body Stretch", sets: 2, durationSeconds: 30, notes: "Each side", category: .timed),
                WorkoutExercise(name: "Child's Pose", sets: 1, durationSeconds: 120, notes: "Breathe into lower back", category: .timed),
            ], tag: "rec_stretch", tags: ["Recovery", "Flexibility"]),
        ]
    }

    // MARK: - General Army Fitness (Balanced PRT)

    private static func generalArmyTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)
        let useGym = equipment == .gym || equipment == .minimal

        return [
            WorkoutTemplate(title: "Total Body PRT Circuit", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 300, notes: "PD: 10 exercises, 5 reps each", category: .timed),
                WorkoutExercise(name: "Squat", sets: s, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Push-Up", sets: s, reps: level == .beginner ? 8 : 15, category: .bodyweight),
                WorkoutExercise(name: "Lunge", sets: s, reps: 12, notes: "Each leg", category: .bodyweight),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: level == .beginner ? 30 : 45, category: .timed),
                WorkoutExercise(name: "Jumping Jack", sets: 3, durationSeconds: 60, notes: "Steady cadence", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Full sequence", category: .timed),
            ], tag: "gen_total", tags: ["General", "Full Body"]),

            WorkoutTemplate(title: "Calisthenics Drill", exercises: [
                WorkoutExercise(name: "Conditioning Drill 1", sets: 1, durationSeconds: 300, notes: "CD1: Power Jump, V-Up, Mountain Climber, Leg Tuck Twist — 5 reps each", category: .timed),
                WorkoutExercise(name: "Push-Up Pyramid (1-10)", sets: 1, reps: 55, notes: "1, 2, 3...10 with brief rest", category: .bodyweight),
                WorkoutExercise(name: "Squat", sets: 4, reps: 20, category: .bodyweight),
                WorkoutExercise(name: "Flutter Kick", sets: 4, durationSeconds: 30, notes: "4-count cadence", category: .timed),
                WorkoutExercise(name: "Burpee", sets: 3, reps: level == .beginner ? 5 : 10, category: .bodyweight),
                WorkoutExercise(name: "Mountain Climber", sets: 4, durationSeconds: 30, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Full sequence", category: .timed),
            ], tag: "gen_calisthenics", tags: ["General", "Calisthenics"]),

            WorkoutTemplate(title: "Strength Foundations", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD: Movement prep", category: .timed),
                WorkoutExercise(name: "Goblet Squat", sets: s, reps: 12),
                WorkoutExercise(name: "Push-Up Variation", sets: s, reps: 10, category: .bodyweight),
                WorkoutExercise(name: useGym ? "Bent-Over Row" : "Inverted Row", sets: s, reps: 10),
                WorkoutExercise(name: "Glute Bridge", sets: s, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Farmer Carry", sets: 3, durationSeconds: 40, category: .timed),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Full body", category: .timed),
            ], tag: "gen_strength", tags: ["General", "Strength"]),

            WorkoutTemplate(title: "Cardio + Core Conditioning", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD: Elevate HR", category: .timed),
                WorkoutExercise(name: "High Knee", sets: 4, durationSeconds: 30, notes: "Drive knees, pump arms", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Mountain Climber", sets: 4, durationSeconds: 30, notes: "Fast hands, stable hips", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Bicycle Crunch", sets: s, reps: 20, notes: "Controlled rotation", category: .bodyweight),
                WorkoutExercise(name: "Burpee", sets: 3, reps: level == .beginner ? 5 : 10, category: .bodyweight),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: 45, category: .timed),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Core and hip flexors", category: .timed),
            ], tag: "gen_cardio_core", tags: ["General", "Cardio"]),

            WorkoutTemplate(title: "Endurance Run + Sprints", exercises: [
                WorkoutExercise(name: "Warm-Up Jog", sets: 1, durationSeconds: 300, notes: "Easy pace build", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Tempo Run", sets: 1, durationSeconds: minutes >= 45 ? 1200 : 900, notes: "Moderate-hard sustained pace", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Sprint Interval", sets: 6, durationSeconds: 30, notes: "60 sec walk between — push 80% effort", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Walk", sets: 1, durationSeconds: 300, notes: "Easy walk, bring HR down", category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Lower body focus", category: .timed),
            ], tag: "gen_endurance", tags: ["General", "Running"]),

            WorkoutTemplate(title: "Mobility + Light Conditioning", exercises: [
                WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 240, notes: "PD: Slow and controlled", category: .timed),
                WorkoutExercise(name: "World's Greatest Stretch", sets: 2, reps: 5, notes: "Each side", category: .bodyweight),
                WorkoutExercise(name: "Easy Jog / Walk", sets: 1, durationSeconds: minutes >= 30 ? 600 : 300, notes: "Light effort", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Bear Crawl", sets: 3, durationSeconds: 30, notes: "Slow and controlled", category: .timed),
                WorkoutExercise(name: "Side Lunge", sets: 3, reps: 10, notes: "Each side — open up adductors", category: .bodyweight),
                WorkoutExercise(name: "Hip Circle", sets: 2, reps: 10, notes: "Each direction", category: .bodyweight),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 180, notes: "RD: Full sequence", category: .timed),
            ], tag: "gen_mobility", tags: ["General", "Mobility"]),
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
