import Foundation

enum WorkoutGenerator {

    static func generateWeeklyPlan(
        goal: TrainingGoal,
        level: FitnessLevel,
        equipment: EquipmentOption,
        daysPerWeek: Int,
        minutesPerWorkout: Int
    ) -> WeeklyPlan {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today) ?? today

        let templates = workoutTemplates(goal: goal, level: level, equipment: equipment, minutes: minutesPerWorkout)
        let selectedDays = distributeDays(count: daysPerWeek)

        var days: [WorkoutDay] = []
        var templateIndex = 0

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
                    templateTag: template.tag
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
            goal: goal.rawValue,
            level: level.rawValue,
            equipment: equipment.rawValue,
            minutesPerWorkout: minutesPerWorkout,
            days: days
        )
    }

    static func generateWorkoutOfDay(
        goal: TrainingGoal,
        level: FitnessLevel,
        equipment: EquipmentOption,
        minutes: Int,
        lastWorkoutTag: String
    ) -> WorkoutDay {
        let templates = workoutTemplates(goal: goal, level: level, equipment: equipment, minutes: minutes)
        let filtered = templates.filter { $0.tag != lastWorkoutTag }
        let chosen = filtered.randomElement() ?? templates.first!
        let calendar = Calendar.current

        return WorkoutDay(
            dayIndex: 0,
            date: calendar.startOfDay(for: .now),
            title: chosen.title,
            exercises: chosen.exercises,
            templateTag: chosen.tag
        )
    }

    static func generateRandomWorkout(
        goal: TrainingGoal,
        level: FitnessLevel,
        equipment: EquipmentOption,
        minutes: Int,
        lastWorkoutTag: String
    ) -> WorkoutDay {
        let all = allRandomTemplates(level: level, equipment: equipment, minutes: minutes)
        let filtered = all.filter { $0.tag != lastWorkoutTag }
        let chosen = filtered.randomElement() ?? all.randomElement()!
        let calendar = Calendar.current

        return WorkoutDay(
            dayIndex: 0,
            date: calendar.startOfDay(for: .now),
            title: chosen.title,
            exercises: chosen.exercises,
            templateTag: chosen.tag
        )
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

    struct WorkoutTemplate {
        let title: String
        let exercises: [WorkoutExercise]
        let tag: String
    }

    private static func workoutTemplates(
        goal: TrainingGoal,
        level: FitnessLevel,
        equipment: EquipmentOption,
        minutes: Int
    ) -> [WorkoutTemplate] {
        switch goal {
        case .muscleBuilding:
            return muscleTemplates(level: level, equipment: equipment, minutes: minutes)
        case .generalFitness:
            return generalFitnessTemplates(level: level, equipment: equipment, minutes: minutes)
        case .sportsTraining:
            return sportsTemplates(level: level, equipment: equipment, minutes: minutes)
        case .militaryFitness:
            return militaryTemplates(level: level, equipment: equipment, minutes: minutes)
        case .policeFitness:
            return policeTemplates(level: level, equipment: equipment, minutes: minutes)
        case .fireRescue:
            return fireRescueTemplates(level: level, equipment: equipment, minutes: minutes)
        case .distanceRunning:
            return runningTemplates(level: level, minutes: minutes)
        case .conditioning:
            return conditioningTemplates(level: level, equipment: equipment, minutes: minutes)
        }
    }

    // MARK: - Muscle Building

    private static func muscleTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)
        let useGym = equipment == .gym || equipment == .dumbbells

        return [
            WorkoutTemplate(title: "Push Day", exercises: [
                WorkoutExercise(name: useGym ? "Bench Press" : "Push-Ups", sets: s, reps: useGym ? 8 : 15, weight: useGym ? "Working weight" : ""),
                WorkoutExercise(name: useGym ? "Overhead Press" : "Pike Push-Ups", sets: s, reps: useGym ? 8 : 12),
                WorkoutExercise(name: useGym ? "Incline Dumbbell Press" : "Diamond Push-Ups", sets: s, reps: 10),
                WorkoutExercise(name: useGym ? "Cable Flyes" : "Wide Push-Ups", sets: s - 1, reps: 12),
                WorkoutExercise(name: useGym ? "Lateral Raises" : "Arm Circles", sets: s - 1, reps: 15),
            ], tag: "muscle_push"),

            WorkoutTemplate(title: "Pull Day", exercises: [
                WorkoutExercise(name: useGym ? "Barbell Rows" : "Inverted Rows", sets: s, reps: 8),
                WorkoutExercise(name: useGym ? "Pull-Ups" : "Door Pull-Ups", sets: s, reps: level == .beginner ? 5 : 10),
                WorkoutExercise(name: useGym ? "Face Pulls" : "Band Pull-Aparts", sets: s, reps: 15),
                WorkoutExercise(name: useGym ? "Dumbbell Curls" : "Towel Curls", sets: s - 1, reps: 12),
                WorkoutExercise(name: useGym ? "Hammer Curls" : "Chin-Up Holds", sets: s - 1, reps: useGym ? 12 : 0, durationSeconds: useGym ? 0 : 30, category: useGym ? .strength : .timed),
            ], tag: "muscle_pull"),

            WorkoutTemplate(title: "Leg Day", exercises: [
                WorkoutExercise(name: useGym ? "Barbell Squats" : "Bodyweight Squats", sets: s, reps: useGym ? 8 : 20),
                WorkoutExercise(name: useGym ? "Romanian Deadlifts" : "Single-Leg Deadlifts", sets: s, reps: 10),
                WorkoutExercise(name: "Walking Lunges", sets: s, reps: 12, notes: "Each leg"),
                WorkoutExercise(name: useGym ? "Leg Press" : "Bulgarian Split Squats", sets: s - 1, reps: 10),
                WorkoutExercise(name: "Calf Raises", sets: s, reps: 15),
            ], tag: "muscle_legs"),

            WorkoutTemplate(title: "Upper Hypertrophy", exercises: [
                WorkoutExercise(name: useGym ? "Dumbbell Bench Press" : "Decline Push-Ups", sets: s, reps: 10),
                WorkoutExercise(name: useGym ? "Seated Rows" : "Towel Rows", sets: s, reps: 10),
                WorkoutExercise(name: useGym ? "Arnold Press" : "Handstand Hold", sets: s, reps: useGym ? 10 : 0, durationSeconds: useGym ? 0 : 30, category: useGym ? .strength : .timed),
                WorkoutExercise(name: useGym ? "Tricep Pushdowns" : "Bench Dips", sets: s - 1, reps: 12),
                WorkoutExercise(name: useGym ? "Preacher Curls" : "Isometric Curl Holds", sets: s - 1, reps: useGym ? 12 : 0, durationSeconds: useGym ? 0 : 30, category: useGym ? .strength : .timed),
            ], tag: "muscle_upper_hyp"),

            WorkoutTemplate(title: "Lower Power", exercises: [
                WorkoutExercise(name: useGym ? "Front Squats" : "Jump Squats", sets: s, reps: useGym ? 6 : 12),
                WorkoutExercise(name: useGym ? "Deadlifts" : "Hip Thrusts", sets: s, reps: useGym ? 5 : 15),
                WorkoutExercise(name: "Step-Ups", sets: s, reps: 10, notes: "Each leg"),
                WorkoutExercise(name: useGym ? "Leg Curls" : "Nordic Curl Negatives", sets: s - 1, reps: useGym ? 10 : 5),
                WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: level == .beginner ? 30 : 60, category: .timed),
            ], tag: "muscle_lower_power"),

            WorkoutTemplate(title: "Full Body Strength", exercises: [
                WorkoutExercise(name: useGym ? "Deadlifts" : "Single-Leg Deadlifts", sets: s, reps: useGym ? 5 : 10),
                WorkoutExercise(name: useGym ? "Overhead Press" : "Pike Push-Ups", sets: s, reps: 8),
                WorkoutExercise(name: useGym ? "Pull-Ups" : "Inverted Rows", sets: s, reps: level == .beginner ? 5 : 8),
                WorkoutExercise(name: "Goblet Squats", sets: s, reps: 10),
                WorkoutExercise(name: "Farmer Carry", sets: 3, durationSeconds: 45, category: .timed),
            ], tag: "muscle_full"),
        ]
    }

    // MARK: - General Fitness

    private static func generalFitnessTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)

        return [
            WorkoutTemplate(title: "Total Body Circuit", exercises: [
                WorkoutExercise(name: "Squats", sets: s, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Push-Ups", sets: s, reps: level == .beginner ? 8 : 15, category: .bodyweight),
                WorkoutExercise(name: "Lunges", sets: s, reps: 12, notes: "Each leg", category: .bodyweight),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: level == .beginner ? 30 : 45, category: .timed),
                WorkoutExercise(name: "Jumping Jacks", sets: 3, durationSeconds: 60, category: .cardio, cardioType: .walk),
            ], tag: "gen_total"),

            WorkoutTemplate(title: "Cardio + Core", exercises: [
                WorkoutExercise(name: "High Knees", sets: 4, durationSeconds: 30, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Mountain Climbers", sets: 4, durationSeconds: 30, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Bicycle Crunches", sets: s, reps: 20, category: .bodyweight),
                WorkoutExercise(name: "Burpees", sets: 3, reps: level == .beginner ? 5 : 10, category: .bodyweight),
                WorkoutExercise(name: "Dead Bug", sets: 3, reps: 10, notes: "Each side", category: .bodyweight),
            ], tag: "gen_cardio_core"),

            WorkoutTemplate(title: "Strength Foundations", exercises: [
                WorkoutExercise(name: "Goblet Squats", sets: s, reps: 12),
                WorkoutExercise(name: "Push-Up Variation", sets: s, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "Bent-Over Rows", sets: s, reps: 10),
                WorkoutExercise(name: "Glute Bridges", sets: s, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Farmer Carry", sets: 3, durationSeconds: 40, category: .timed),
            ], tag: "gen_strength"),

            WorkoutTemplate(title: "Mobility + Endurance", exercises: [
                WorkoutExercise(name: "World's Greatest Stretch", sets: 2, reps: 5, notes: "Each side", category: .bodyweight),
                WorkoutExercise(name: "Easy Jog / Walk", sets: 1, durationSeconds: minutes >= 30 ? 600 : 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Bear Crawl", sets: 3, durationSeconds: 30, category: .timed),
                WorkoutExercise(name: "Side Lunges", sets: 3, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "Hip Circles", sets: 2, reps: 10, notes: "Each direction", category: .bodyweight),
            ], tag: "gen_mobility"),

            WorkoutTemplate(title: "Upper Body Focus", exercises: [
                WorkoutExercise(name: "Push-Ups", sets: s, reps: 12, category: .bodyweight),
                WorkoutExercise(name: "Inverted Rows", sets: s, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "Shoulder Taps", sets: s, reps: 16, category: .bodyweight),
                WorkoutExercise(name: "Tricep Dips", sets: s, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "Arm Circles", sets: 2, durationSeconds: 30, category: .timed),
            ], tag: "gen_upper"),

            WorkoutTemplate(title: "Lower Body Focus", exercises: [
                WorkoutExercise(name: "Squats", sets: s, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Romanian Deadlifts", sets: s, reps: 10),
                WorkoutExercise(name: "Lateral Lunges", sets: s, reps: 10, notes: "Each side", category: .bodyweight),
                WorkoutExercise(name: "Wall Sit", sets: 3, durationSeconds: level == .beginner ? 30 : 45, category: .timed),
                WorkoutExercise(name: "Calf Raises", sets: 3, reps: 20, category: .bodyweight),
            ], tag: "gen_lower"),
        ]
    }

    // MARK: - Sports Training

    private static func sportsTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)

        return [
            WorkoutTemplate(title: "Speed & Agility", exercises: [
                WorkoutExercise(name: "Sprint Intervals", sets: 6, durationSeconds: 20, notes: "Walk back recovery", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Lateral Shuffles", sets: 4, durationSeconds: 30, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Box Jumps / Squat Jumps", sets: s, reps: 8, category: .bodyweight),
                WorkoutExercise(name: "Backpedal Sprints", sets: 4, durationSeconds: 15, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "High Knees", sets: 4, durationSeconds: 20, category: .cardio, cardioType: .run),
            ], tag: "sport_speed"),

            WorkoutTemplate(title: "Power & Explosiveness", exercises: [
                WorkoutExercise(name: "Broad Jumps", sets: s, reps: 5, category: .bodyweight),
                WorkoutExercise(name: "Medicine Ball Slams", sets: s, reps: 8),
                WorkoutExercise(name: "Squat Jumps", sets: s, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "Clap Push-Ups", sets: s, reps: level == .beginner ? 5 : 8, category: .bodyweight),
                WorkoutExercise(name: "Sprint Starts", sets: 4, durationSeconds: 10, category: .cardio, cardioType: .run),
            ], tag: "sport_power"),

            WorkoutTemplate(title: "Sport Conditioning", exercises: [
                WorkoutExercise(name: "Shuttle Runs", sets: 6, durationSeconds: 30, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Burpees", sets: 4, reps: 8, category: .bodyweight),
                WorkoutExercise(name: "Bear Crawl", sets: 4, durationSeconds: 30, category: .timed),
                WorkoutExercise(name: "Mountain Climbers", sets: 4, durationSeconds: 30, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: 45, category: .timed),
            ], tag: "sport_conditioning"),

            WorkoutTemplate(title: "Recovery & Mobility", exercises: [
                WorkoutExercise(name: "Foam Roll / Self-Massage", sets: 1, durationSeconds: 300, category: .timed),
                WorkoutExercise(name: "Hip Flexor Stretch", sets: 2, durationSeconds: 45, notes: "Each side", category: .timed),
                WorkoutExercise(name: "Light Jog", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Leg Swings", sets: 2, reps: 10, notes: "Each direction", category: .bodyweight),
                WorkoutExercise(name: "Deep Breathing", sets: 1, durationSeconds: 120, category: .timed),
            ], tag: "sport_recovery"),

            WorkoutTemplate(title: "Strength for Sport", exercises: [
                WorkoutExercise(name: "Squats", sets: s, reps: 8),
                WorkoutExercise(name: "Push-Ups", sets: s, reps: 12, category: .bodyweight),
                WorkoutExercise(name: "Single-Leg Deadlifts", sets: s, reps: 8, notes: "Each leg"),
                WorkoutExercise(name: "Pull-Ups / Rows", sets: s, reps: level == .beginner ? 5 : 8),
                WorkoutExercise(name: "Core Rotation", sets: 3, reps: 10, notes: "Each side", category: .bodyweight),
            ], tag: "sport_strength"),

            WorkoutTemplate(title: "Agility Circuits", exercises: [
                WorkoutExercise(name: "Cone Drills / Zigzag Run", sets: 5, durationSeconds: 20, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Pro Agility Shuttle", sets: 5, durationSeconds: 15, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Lateral Bounds", sets: 4, reps: 8, category: .bodyweight),
                WorkoutExercise(name: "Karaoke / Carioca", sets: 4, durationSeconds: 20, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Reaction Sprints", sets: 4, durationSeconds: 10, category: .cardio, cardioType: .run),
            ], tag: "sport_agility"),
        ]
    }

    // MARK: - Military Fitness

    private static func militaryTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)

        return [
            WorkoutTemplate(title: "ACFT Prep", exercises: [
                WorkoutExercise(name: "Deadlift Pattern", sets: s, reps: 5, notes: "Focus on form"),
                WorkoutExercise(name: "Hand-Release Push-Ups", sets: s, reps: level == .beginner ? 10 : 20, category: .bodyweight),
                WorkoutExercise(name: "Sprint-Drag-Carry Sim", sets: 4, durationSeconds: 60, notes: "Shuttle format", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: level == .beginner ? 45 : 90, category: .timed),
                WorkoutExercise(name: "400m Run Intervals", sets: 4, durationSeconds: 120, notes: "90 sec rest between", category: .cardio, cardioType: .run),
            ], tag: "mil_acft"),

            WorkoutTemplate(title: "Calisthenics Circuit", exercises: [
                WorkoutExercise(name: "Push-Up Ladder (1–10)", sets: 1, reps: 55, notes: "Pyramid: 1,2,3...10", category: .bodyweight),
                WorkoutExercise(name: "Squats", sets: 4, reps: 20, category: .bodyweight),
                WorkoutExercise(name: "Flutter Kicks", sets: 4, durationSeconds: 30, category: .timed),
                WorkoutExercise(name: "Burpees", sets: 3, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "Mountain Climbers", sets: 4, durationSeconds: 30, category: .cardio, cardioType: .run),
            ], tag: "mil_calisthenics"),

            WorkoutTemplate(title: "Endurance Run", exercises: [
                WorkoutExercise(name: "Warm-Up Jog", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Tempo Run", sets: 1, durationSeconds: minutes >= 45 ? 1200 : 900, notes: "Moderate hard pace", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Sprint Intervals", sets: 6, durationSeconds: 30, notes: "60 sec walk between", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Walk", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .walk),
            ], tag: "mil_endurance"),

            WorkoutTemplate(title: "Strength Circuit", exercises: [
                WorkoutExercise(name: "Deadlifts / Hip Hinge", sets: s, reps: 8),
                WorkoutExercise(name: "Overhead Press", sets: s, reps: 8),
                WorkoutExercise(name: "Pull-Ups", sets: s, reps: level == .beginner ? 5 : 10, category: .bodyweight),
                WorkoutExercise(name: "Farmer Carry", sets: 3, durationSeconds: 45, category: .timed),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: 60, category: .timed),
            ], tag: "mil_strength"),

            WorkoutTemplate(title: "Field Ready", exercises: [
                WorkoutExercise(name: "Ruck March / Fast Walk", sets: 1, durationSeconds: 600, notes: "With weight if available", category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Bear Crawl", sets: 4, durationSeconds: 30, category: .timed),
                WorkoutExercise(name: "Sandbag Carry", sets: 4, durationSeconds: 30, category: .timed),
                WorkoutExercise(name: "Sprawls", sets: 3, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "Buddy Drag Sim", sets: 4, durationSeconds: 20, category: .timed),
            ], tag: "mil_field"),

            WorkoutTemplate(title: "Recovery PT", exercises: [
                WorkoutExercise(name: "Mobility Flow", sets: 1, durationSeconds: 480, category: .timed),
                WorkoutExercise(name: "Light Walk", sets: 1, durationSeconds: 600, category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Stretch Reset", sets: 1, durationSeconds: 300, category: .timed),
            ], tag: "mil_recovery"),
        ]
    }

    // MARK: - Police Fitness

    private static func policeTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)

        return [
            WorkoutTemplate(title: "Pursuit Conditioning", exercises: [
                WorkoutExercise(name: "Sprint Intervals", sets: 8, durationSeconds: 20, notes: "40 sec rest", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Fence Vault Sim (Box Jump)", sets: s, reps: 8, category: .bodyweight),
                WorkoutExercise(name: "Bear Crawl", sets: 4, durationSeconds: 30, category: .timed),
                WorkoutExercise(name: "Lateral Shuffles", sets: 4, durationSeconds: 20, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Burpees", sets: 3, reps: 8, category: .bodyweight),
            ], tag: "police_pursuit"),

            WorkoutTemplate(title: "Defensive Tactics Strength", exercises: [
                WorkoutExercise(name: "Push-Ups", sets: s, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Squats", sets: s, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Pull-Ups / Rows", sets: s, reps: level == .beginner ? 5 : 10),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: 60, category: .timed),
                WorkoutExercise(name: "Farmer Carry", sets: 3, durationSeconds: 40, category: .timed),
            ], tag: "police_strength"),

            WorkoutTemplate(title: "Endurance Run", exercises: [
                WorkoutExercise(name: "Warm-Up", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "1.5 Mile Pace Run", sets: 1, durationSeconds: 900, notes: "Target test pace", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Walk", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .walk),
            ], tag: "police_endurance"),

            WorkoutTemplate(title: "Circuit Training", exercises: [
                WorkoutExercise(name: "Push-Ups", sets: 3, reps: 12, category: .bodyweight),
                WorkoutExercise(name: "Squats", sets: 3, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Mountain Climbers", sets: 3, durationSeconds: 30, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Lunges", sets: 3, reps: 10, notes: "Each leg", category: .bodyweight),
                WorkoutExercise(name: "Jumping Jacks", sets: 3, durationSeconds: 45, category: .cardio, cardioType: .walk),
            ], tag: "police_circuit"),

            WorkoutTemplate(title: "Recovery", exercises: [
                WorkoutExercise(name: "Light Walk", sets: 1, durationSeconds: 600, category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Full Body Stretch", sets: 1, durationSeconds: 480, category: .timed),
                WorkoutExercise(name: "Deep Breathing", sets: 1, durationSeconds: 180, category: .timed),
            ], tag: "police_recovery"),

            WorkoutTemplate(title: "Agility & Reaction", exercises: [
                WorkoutExercise(name: "Cone Drills", sets: 6, durationSeconds: 15, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Pro Shuttle", sets: 5, durationSeconds: 15, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Lateral Bounds", sets: 4, reps: 8, category: .bodyweight),
                WorkoutExercise(name: "Backpedal Sprints", sets: 4, durationSeconds: 15, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Quick Feet Ladder", sets: 4, durationSeconds: 15, category: .cardio, cardioType: .run),
            ], tag: "police_agility"),
        ]
    }

    // MARK: - Fire / Rescue

    private static func fireRescueTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)

        return [
            WorkoutTemplate(title: "CPAT Prep", exercises: [
                WorkoutExercise(name: "Stair Climb (Step-Ups)", sets: 1, durationSeconds: 180, notes: "Steady pace", category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Hose Drag Sim (Sled/Carry)", sets: 4, durationSeconds: 30, category: .timed),
                WorkoutExercise(name: "Ceiling Breach (Overhead Press)", sets: s, reps: 10),
                WorkoutExercise(name: "Ladder Raise Sim (Rows)", sets: s, reps: 10),
                WorkoutExercise(name: "Victim Drag (Farmer Carry)", sets: 4, durationSeconds: 30, category: .timed),
            ], tag: "fire_cpat"),

            WorkoutTemplate(title: "Strength & Carry", exercises: [
                WorkoutExercise(name: "Deadlifts", sets: s, reps: 8),
                WorkoutExercise(name: "Overhead Press", sets: s, reps: 8),
                WorkoutExercise(name: "Farmer Carry", sets: 4, durationSeconds: 45, category: .timed),
                WorkoutExercise(name: "Squats", sets: s, reps: 10),
                WorkoutExercise(name: "Pull-Ups", sets: s, reps: level == .beginner ? 5 : 8),
            ], tag: "fire_strength"),

            WorkoutTemplate(title: "Endurance Circuit", exercises: [
                WorkoutExercise(name: "Step-Ups", sets: 4, durationSeconds: 60, category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Push-Ups", sets: 4, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Squats", sets: 4, reps: 20, category: .bodyweight),
                WorkoutExercise(name: "Burpees", sets: 3, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "Bear Crawl", sets: 3, durationSeconds: 30, category: .timed),
            ], tag: "fire_endurance"),

            WorkoutTemplate(title: "Cardio Focus", exercises: [
                WorkoutExercise(name: "Warm-Up Jog", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Interval Run", sets: 6, durationSeconds: 60, notes: "60 sec walk rest", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Walk", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .walk),
            ], tag: "fire_cardio"),

            WorkoutTemplate(title: "Recovery", exercises: [
                WorkoutExercise(name: "Mobility Flow", sets: 1, durationSeconds: 480, category: .timed),
                WorkoutExercise(name: "Light Walk", sets: 1, durationSeconds: 600, category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Stretch", sets: 1, durationSeconds: 300, category: .timed),
            ], tag: "fire_recovery"),

            WorkoutTemplate(title: "Full Body Power", exercises: [
                WorkoutExercise(name: "Clean & Press", sets: s, reps: 6),
                WorkoutExercise(name: "Box Jumps", sets: s, reps: 8, category: .bodyweight),
                WorkoutExercise(name: "Sled Push / Sprint", sets: 4, durationSeconds: 20, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Sandbag Carry", sets: 4, durationSeconds: 30, category: .timed),
                WorkoutExercise(name: "Plank", sets: 3, durationSeconds: 60, category: .timed),
            ], tag: "fire_power"),
        ]
    }

    // MARK: - Distance Running

    private static func runningTemplates(level: FitnessLevel, minutes: Int) -> [WorkoutTemplate] {
        return [
            WorkoutTemplate(title: "Easy Run", exercises: [
                WorkoutExercise(name: "Warm-Up Walk", sets: 1, durationSeconds: 180, category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Easy Pace Run", sets: 1, durationSeconds: max(600, (minutes - 8) * 60), notes: "Conversational pace", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Walk", sets: 1, durationSeconds: 180, category: .cardio, cardioType: .walk),
            ], tag: "run_easy"),

            WorkoutTemplate(title: "Interval Training", exercises: [
                WorkoutExercise(name: "Warm-Up Jog", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Hard Intervals", sets: level == .beginner ? 4 : 8, durationSeconds: 60, notes: "90 sec jog between", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Jog", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
            ], tag: "run_intervals"),

            WorkoutTemplate(title: "Long Steady Run", exercises: [
                WorkoutExercise(name: "Warm-Up Walk", sets: 1, durationSeconds: 180, category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Steady Run", sets: 1, durationSeconds: max(900, (minutes - 6) * 60), notes: "Maintain even effort", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Walk", sets: 1, durationSeconds: 180, category: .cardio, cardioType: .walk),
            ], tag: "run_long"),

            WorkoutTemplate(title: "Tempo Run", exercises: [
                WorkoutExercise(name: "Easy Warm-Up", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Tempo Effort", sets: 1, durationSeconds: max(600, (minutes - 15) * 60), notes: "Comfortably hard", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Easy Cool-Down", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
            ], tag: "run_tempo"),

            WorkoutTemplate(title: "Recovery Run", exercises: [
                WorkoutExercise(name: "Very Easy Jog", sets: 1, durationSeconds: max(600, (minutes - 5) * 60), notes: "Slow and relaxed", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Stretch", sets: 1, durationSeconds: 300, category: .timed),
            ], tag: "run_recovery"),

            WorkoutTemplate(title: "Hill Repeats", exercises: [
                WorkoutExercise(name: "Warm-Up Jog", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Hill Sprints", sets: level == .beginner ? 4 : 8, durationSeconds: 30, notes: "Walk down recovery", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Easy Jog", sets: 1, durationSeconds: 300, category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool-Down Walk", sets: 1, durationSeconds: 180, category: .cardio, cardioType: .walk),
            ], tag: "run_hills"),
        ]
    }

    // MARK: - Conditioning

    private static func conditioningTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        let s = setsFor(level)

        return [
            WorkoutTemplate(title: "EMOM Circuit", exercises: [
                WorkoutExercise(name: "Push-Ups", sets: 1, reps: 10, notes: "Every minute on the minute", category: .bodyweight),
                WorkoutExercise(name: "Squats", sets: 1, reps: 15, notes: "Alternate minutes", category: .bodyweight),
                WorkoutExercise(name: "Burpees", sets: 1, reps: 5, notes: "Alternate minutes", category: .bodyweight),
                WorkoutExercise(name: "Total Duration", sets: 1, durationSeconds: max(600, (minutes - 5) * 60), category: .timed),
            ], tag: "cond_emom"),

            WorkoutTemplate(title: "Tabata Blitz", exercises: [
                WorkoutExercise(name: "Jump Squats", sets: 8, durationSeconds: 20, notes: "10 sec rest", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Push-Ups", sets: 8, durationSeconds: 20, notes: "10 sec rest", category: .timed),
                WorkoutExercise(name: "Mountain Climbers", sets: 8, durationSeconds: 20, notes: "10 sec rest", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Burpees", sets: 8, durationSeconds: 20, notes: "10 sec rest", category: .bodyweight),
            ], tag: "cond_tabata"),

            WorkoutTemplate(title: "AMRAP Challenge", exercises: [
                WorkoutExercise(name: "5 Pull-Ups / Rows", sets: 1, reps: 5),
                WorkoutExercise(name: "10 Push-Ups", sets: 1, reps: 10, category: .bodyweight),
                WorkoutExercise(name: "15 Squats", sets: 1, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Repeat for Time", sets: 1, durationSeconds: max(600, (minutes - 5) * 60), notes: "As many rounds as possible", category: .timed),
            ], tag: "cond_amrap"),

            WorkoutTemplate(title: "Chipper", exercises: [
                WorkoutExercise(name: "50 Squats", sets: 1, reps: 50, category: .bodyweight),
                WorkoutExercise(name: "40 Sit-Ups", sets: 1, reps: 40, category: .bodyweight),
                WorkoutExercise(name: "30 Push-Ups", sets: 1, reps: 30, category: .bodyweight),
                WorkoutExercise(name: "20 Lunges", sets: 1, reps: 20, notes: "Each leg", category: .bodyweight),
                WorkoutExercise(name: "10 Burpees", sets: 1, reps: 10, category: .bodyweight),
            ], tag: "cond_chipper"),

            WorkoutTemplate(title: "Interval Blast", exercises: [
                WorkoutExercise(name: "Sprint", sets: 8, durationSeconds: 30, notes: "30 sec rest", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Plank Hold", sets: 4, durationSeconds: 45, category: .timed),
                WorkoutExercise(name: "Jumping Lunges", sets: 4, reps: 12, category: .bodyweight),
            ], tag: "cond_intervals"),

            WorkoutTemplate(title: "Active Recovery", exercises: [
                WorkoutExercise(name: "Light Walk / Jog", sets: 1, durationSeconds: 600, category: .cardio, cardioType: .walk),
                WorkoutExercise(name: "Mobility Flow", sets: 1, durationSeconds: 480, category: .timed),
                WorkoutExercise(name: "Breathing Exercise", sets: 1, durationSeconds: 120, category: .timed),
            ], tag: "cond_recovery"),
        ]
    }

    // MARK: - Random Pool (all goals mixed)

    private static func allRandomTemplates(level: FitnessLevel, equipment: EquipmentOption, minutes: Int) -> [WorkoutTemplate] {
        var all: [WorkoutTemplate] = []
        all.append(contentsOf: generalFitnessTemplates(level: level, equipment: equipment, minutes: minutes))
        all.append(contentsOf: conditioningTemplates(level: level, equipment: equipment, minutes: minutes))
        all.append(contentsOf: sportsTemplates(level: level, equipment: equipment, minutes: minutes))
        return all
    }

    private static func setsFor(_ level: FitnessLevel) -> Int {
        switch level {
        case .beginner: return 3
        case .intermediate: return 4
        case .advanced: return 5
        }
    }
}
