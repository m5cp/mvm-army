import Foundation

enum FreeWeightLibrary {

    static let freeWeightWorkouts: [WODTemplate] = [
        // MARK: - Push Day
        WODTemplate(
            title: "The Iron Press Protocol",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 50,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Bench Press", reps: "4x8", notes: "75% 1RM"),
                WODMovement(name: "Incline Dumbbell Press", reps: "3x10"),
                WODMovement(name: "Overhead Press", reps: "4x8", notes: "Strict form"),
                WODMovement(name: "Dumbbell Lateral Raise", reps: "3x12"),
                WODMovement(name: "Tricep Dips", reps: "3x12"),
                WODMovement(name: "Cable Fly", reps: "3x15", notes: "Squeeze at top")
            ],
            workoutDescription: "Push-focused session targeting chest, shoulders, and triceps. Controlled tempo on all presses.",
            intensityGrade: .high,
            trainingSplit: .push
        ),
        WODTemplate(
            title: "The Apex Press Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Dumbbell Bench Press", reps: "4x10"),
                WODMovement(name: "Arnold Press", reps: "3x10"),
                WODMovement(name: "Incline Barbell Press", reps: "3x8", notes: "Moderate weight"),
                WODMovement(name: "Dumbbell Fly", reps: "3x12"),
                WODMovement(name: "Skull Crushers", reps: "3x12"),
                WODMovement(name: "Push-Ups to Failure", reps: "2 sets")
            ],
            workoutDescription: "Hypertrophy-focused push session. Moderate loads with higher rep ranges.",
            intensityGrade: .moderate,
            trainingSplit: .push
        ),

        // MARK: - Pull Day
        WODTemplate(
            title: "The Relentless Pull Builder",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 50,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Bent-Over Row", reps: "4x8", notes: "Overhand grip"),
                WODMovement(name: "Pull-Ups", reps: "4xAMRAP"),
                WODMovement(name: "Dumbbell Single-Arm Row", reps: "3x10 each"),
                WODMovement(name: "Face Pull", reps: "3x15"),
                WODMovement(name: "Barbell Curl", reps: "3x10"),
                WODMovement(name: "Hammer Curl", reps: "3x12")
            ],
            workoutDescription: "Pull day targeting back, rear delts, and biceps. Control the eccentric on all rows.",
            intensityGrade: .high,
            trainingSplit: .pull
        ),
        WODTemplate(
            title: "The Forged Back Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Pendlay Row", reps: "4x6", notes: "Explosive pull"),
                WODMovement(name: "Lat Pulldown", reps: "3x12"),
                WODMovement(name: "Seated Cable Row", reps: "3x10"),
                WODMovement(name: "Dumbbell Reverse Fly", reps: "3x15"),
                WODMovement(name: "EZ Bar Curl", reps: "3x10"),
                WODMovement(name: "Incline Dumbbell Curl", reps: "3x12")
            ],
            workoutDescription: "Back thickness and width builder. Start heavy, finish with isolation.",
            intensityGrade: .moderate,
            trainingSplit: .pull
        ),

        // MARK: - Legs Day
        WODTemplate(
            title: "The Titan Leg Builder",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 55,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Back Squat", reps: "5x5", notes: "75-80% 1RM"),
                WODMovement(name: "Romanian Deadlift", reps: "4x8"),
                WODMovement(name: "Bulgarian Split Squat", reps: "3x10 each"),
                WODMovement(name: "Leg Press", reps: "3x12"),
                WODMovement(name: "Walking Lunges", reps: "3x12 each", notes: "Dumbbells"),
                WODMovement(name: "Calf Raises", reps: "4x15")
            ],
            workoutDescription: "Heavy compound leg session. Build from working sets on squat, then accessory work.",
            intensityGrade: .high,
            trainingSplit: .legs
        ),
        WODTemplate(
            title: "The Velocity Leg Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Front Squat", reps: "4x6", notes: "Clean grip"),
                WODMovement(name: "Dumbbell Step-Ups", reps: "3x10 each"),
                WODMovement(name: "Leg Curl", reps: "3x12"),
                WODMovement(name: "Goblet Squat", reps: "3x15"),
                WODMovement(name: "Hip Thrust", reps: "3x12", notes: "Barbell"),
                WODMovement(name: "Seated Calf Raise", reps: "3x20")
            ],
            workoutDescription: "Quad-dominant session with posterior chain support. Focus on depth and control.",
            intensityGrade: .moderate,
            trainingSplit: .legs
        ),

        // MARK: - Upper Body
        WODTemplate(
            title: "The Prime Upper Builder",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 50,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Overhead Press", reps: "4x6", notes: "Strict press"),
                WODMovement(name: "Weighted Chin-Ups", reps: "4x6"),
                WODMovement(name: "Dumbbell Bench Press", reps: "3x10"),
                WODMovement(name: "Cable Row", reps: "3x10"),
                WODMovement(name: "Lateral Raise", reps: "3x15"),
                WODMovement(name: "Tricep Pushdown", reps: "3x12")
            ],
            workoutDescription: "Balanced upper body session. Alternate push and pull for efficient supersets.",
            intensityGrade: .high,
            trainingSplit: .upperBody
        ),
        WODTemplate(
            title: "The Sentinel Upper Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 40,
            equipment: .gym,
            movements: [
                WODMovement(name: "Incline Dumbbell Press", reps: "3x10"),
                WODMovement(name: "Dumbbell Row", reps: "3x10 each"),
                WODMovement(name: "Push Press", reps: "3x8"),
                WODMovement(name: "Lat Pulldown", reps: "3x12"),
                WODMovement(name: "Dumbbell Curl", reps: "3x12"),
                WODMovement(name: "Overhead Tricep Extension", reps: "3x12")
            ],
            workoutDescription: "Upper body hypertrophy with moderate loads. Focus on mind-muscle connection.",
            intensityGrade: .moderate,
            trainingSplit: .upperBody
        ),

        // MARK: - Lower Body
        WODTemplate(
            title: "The Endurance Leg Grind",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 50,
            equipment: .gym,
            movements: [
                WODMovement(name: "Trap Bar Deadlift", reps: "5x3", notes: "Heavy"),
                WODMovement(name: "Barbell Hip Thrust", reps: "4x8"),
                WODMovement(name: "Single-Leg Romanian Deadlift", reps: "3x10 each"),
                WODMovement(name: "Leg Extension", reps: "3x15"),
                WODMovement(name: "Nordic Hamstring Curl", reps: "3x6"),
                WODMovement(name: "Farmer's Walk", duration: "3x40m")
            ],
            workoutDescription: "Posterior chain emphasis with deadlift as the primary lift. Build from heavy singles to accessories.",
            intensityGrade: .high,
            trainingSplit: .lowerBody
        ),
        WODTemplate(
            title: "The Resolute Lower Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Sumo Deadlift", reps: "4x6"),
                WODMovement(name: "Dumbbell Lunges", reps: "3x10 each"),
                WODMovement(name: "Leg Press", reps: "3x15"),
                WODMovement(name: "Glute Bridge", reps: "3x15", notes: "Banded"),
                WODMovement(name: "Calf Raises", reps: "4x15")
            ],
            workoutDescription: "Lower body strength with volume. Moderate to heavy loads throughout.",
            intensityGrade: .moderate,
            trainingSplit: .lowerBody
        ),

        // MARK: - Full Body
        WODTemplate(
            title: "The Tactical Full Body",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 55,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Back Squat", reps: "4x6"),
                WODMovement(name: "Barbell Bench Press", reps: "4x6"),
                WODMovement(name: "Barbell Bent-Over Row", reps: "4x8"),
                WODMovement(name: "Romanian Deadlift", reps: "3x8"),
                WODMovement(name: "Dumbbell Shoulder Press", reps: "3x10"),
                WODMovement(name: "Plank", duration: "3x45 sec")
            ],
            workoutDescription: "Full body strength using compound barbell lifts. 2-3 min rest between heavy sets.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Forged Full Body",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Goblet Squat", reps: "3x12"),
                WODMovement(name: "Dumbbell Bench Press", reps: "3x10"),
                WODMovement(name: "Dumbbell Row", reps: "3x10 each"),
                WODMovement(name: "Dumbbell Overhead Press", reps: "3x10"),
                WODMovement(name: "Dumbbell Romanian Deadlift", reps: "3x10"),
                WODMovement(name: "Farmer's Walk", duration: "3x30m")
            ],
            workoutDescription: "Dumbbell-only full body session. Great for moderate training days.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        // MARK: - Strength Focus
        WODTemplate(
            title: "The Elite Strength Protocol",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 60,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Deadlift", reps: "5x3", notes: "85% 1RM"),
                WODMovement(name: "Barbell Back Squat", reps: "5x3", notes: "85% 1RM"),
                WODMovement(name: "Barbell Bench Press", reps: "5x3", notes: "85% 1RM"),
                WODMovement(name: "Barbell Row", reps: "4x5"),
                WODMovement(name: "Weighted Pull-Ups", reps: "3x5")
            ],
            workoutDescription: "Max strength session. Focus on heavy compound lifts with full rest between sets (3-5 min).",
            intensityGrade: .extreme,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Pinnacle Strength Test",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 55,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Front Squat", reps: "5x5", notes: "Working weight"),
                WODMovement(name: "Overhead Press", reps: "5x5"),
                WODMovement(name: "Power Clean", reps: "5x3"),
                WODMovement(name: "Barbell Row", reps: "4x6"),
                WODMovement(name: "Weighted Dips", reps: "3x8")
            ],
            workoutDescription: "Strength-power hybrid. Clean, squat, press pattern with moderate to heavy loads.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),

        // MARK: - Hypertrophy
        WODTemplate(
            title: "The Vanguard Hypertrophy Push",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 50,
            equipment: .gym,
            movements: [
                WODMovement(name: "Dumbbell Incline Press", reps: "4x10"),
                WODMovement(name: "Flat Dumbbell Fly", reps: "3x12"),
                WODMovement(name: "Cable Crossover", reps: "3x15"),
                WODMovement(name: "Seated Dumbbell Press", reps: "4x10"),
                WODMovement(name: "Lateral Raise", reps: "4x12"),
                WODMovement(name: "Tricep Rope Pushdown", reps: "3x15"),
                WODMovement(name: "Overhead Dumbbell Extension", reps: "3x12")
            ],
            workoutDescription: "Volume push session for chest, shoulder, and tricep hypertrophy. 60-90 sec rest.",
            intensityGrade: .moderate,
            trainingSplit: .push
        ),
        WODTemplate(
            title: "The Surge Hypertrophy Pull",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 50,
            equipment: .gym,
            movements: [
                WODMovement(name: "Weighted Chin-Ups", reps: "4x8"),
                WODMovement(name: "T-Bar Row", reps: "4x10"),
                WODMovement(name: "Straight-Arm Pulldown", reps: "3x12"),
                WODMovement(name: "Face Pull", reps: "4x15"),
                WODMovement(name: "Barbell Curl", reps: "3x10"),
                WODMovement(name: "Preacher Curl", reps: "3x12"),
                WODMovement(name: "Reverse Curl", reps: "3x12")
            ],
            workoutDescription: "Volume pull session for back and bicep hypertrophy. Focus on stretch and contraction.",
            intensityGrade: .moderate,
            trainingSplit: .pull
        ),
        WODTemplate(
            title: "The Catalyst Leg Volume",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 55,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Back Squat", reps: "4x8"),
                WODMovement(name: "Leg Press", reps: "4x12"),
                WODMovement(name: "Stiff-Leg Deadlift", reps: "3x10"),
                WODMovement(name: "Leg Extension", reps: "3x15"),
                WODMovement(name: "Leg Curl", reps: "3x12"),
                WODMovement(name: "Seated Calf Raise", reps: "4x15"),
                WODMovement(name: "Hip Adductor", reps: "3x12")
            ],
            workoutDescription: "High volume leg session for quad and hamstring hypertrophy. 60-90 sec rest between sets.",
            intensityGrade: .high,
            trainingSplit: .legs
        ),

        // MARK: - Minimal Equipment Free Weights
        WODTemplate(
            title: "The Steadfast Dumbbell Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 40,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Dumbbell Goblet Squat", reps: "4x12"),
                WODMovement(name: "Dumbbell Floor Press", reps: "4x10"),
                WODMovement(name: "Dumbbell Row", reps: "4x10 each"),
                WODMovement(name: "Dumbbell Romanian Deadlift", reps: "3x12"),
                WODMovement(name: "Dumbbell Curl to Press", reps: "3x10"),
                WODMovement(name: "Dumbbell Skull Crusher", reps: "3x12")
            ],
            workoutDescription: "Full body dumbbell-only session. Minimal equipment required.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Unbroken KB Complex",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 35,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Kettlebell Swing", reps: "4x15"),
                WODMovement(name: "Kettlebell Goblet Squat", reps: "4x10"),
                WODMovement(name: "Kettlebell Clean & Press", reps: "3x8 each"),
                WODMovement(name: "Kettlebell Row", reps: "3x10 each"),
                WODMovement(name: "Kettlebell Turkish Get-Up", reps: "3x3 each"),
                WODMovement(name: "Kettlebell Farmer's Carry", duration: "3x40m")
            ],
            workoutDescription: "Kettlebell complex for full body strength and conditioning. Flow between movements.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        // MARK: - AFT-Focused Free Weight
        WODTemplate(
            title: "The Tactical Deadlift Builder",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 50,
            equipment: .gym,
            movements: [
                WODMovement(name: "Hex Bar Deadlift", reps: "5x5", notes: "Build to heavy"),
                WODMovement(name: "Deficit Deadlift", reps: "3x6", notes: "2-inch deficit"),
                WODMovement(name: "Good Morning", reps: "3x10"),
                WODMovement(name: "Weighted Hip Thrust", reps: "3x12"),
                WODMovement(name: "Farmer's Walk", duration: "4x50m", notes: "Heavy"),
                WODMovement(name: "Hanging Knee Raise", reps: "3x15")
            ],
            workoutDescription: "AFT deadlift event preparation. Heavy pulls with posterior chain and grip work.",
            intensityGrade: .high,
            trainingSplit: .lowerBody
        ),
        WODTemplate(
            title: "The Prime Combat Prep",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Power Clean", reps: "5x3"),
                WODMovement(name: "Front Squat", reps: "4x5"),
                WODMovement(name: "Push Press", reps: "4x5"),
                WODMovement(name: "Barbell Row", reps: "3x8"),
                WODMovement(name: "Suitcase Carry", duration: "3x30m each"),
                WODMovement(name: "Dead Bug", reps: "3x12")
            ],
            workoutDescription: "Power and explosiveness for tactical fitness. Moderate to heavy barbell work.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),

        // MARK: - Conditioning + Weights Hybrid
        WODTemplate(
            title: "The Relentless Conditioning Complex",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 35,
            equipment: .gym,
            movements: [
                WODMovement(name: "Dumbbell Thruster", reps: "4x12"),
                WODMovement(name: "Kettlebell Swing", reps: "4x15"),
                WODMovement(name: "Dumbbell Renegade Row", reps: "3x8 each"),
                WODMovement(name: "Goblet Squat", reps: "3x15"),
                WODMovement(name: "Farmer's Walk", duration: "3x40m")
            ],
            workoutDescription: "High-output conditioning with free weights. Minimal rest between sets. Heart rate stays elevated.",
            intensityGrade: .high,
            trainingSplit: .conditioning
        ),
        WODTemplate(
            title: "The Apex Barbell Conditioning",
            category: .freeWeight,
            format: .interval,
            durationMinutes: 30,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Complex: Deadlift", reps: "6"),
                WODMovement(name: "Barbell Complex: Hang Clean", reps: "6"),
                WODMovement(name: "Barbell Complex: Front Squat", reps: "6"),
                WODMovement(name: "Barbell Complex: Push Press", reps: "6"),
                WODMovement(name: "Barbell Complex: Bent-Over Row", reps: "6")
            ],
            workoutDescription: "5 rounds of the barbell complex. 2 min rest between rounds. Light to moderate load, no putting the bar down.",
            intensityGrade: .high,
            trainingSplit: .mixed
        ),

        // MARK: - Deload / Recovery Weight Sessions
        WODTemplate(
            title: "The Resolute Recovery Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 35,
            equipment: .gym,
            movements: [
                WODMovement(name: "Goblet Squat", reps: "3x8", notes: "Light weight, deep stretch"),
                WODMovement(name: "Dumbbell Romanian Deadlift", reps: "3x8", notes: "Light"),
                WODMovement(name: "Dumbbell Bench Press", reps: "3x8", notes: "50% effort"),
                WODMovement(name: "Face Pull", reps: "3x15"),
                WODMovement(name: "Dumbbell Curl", reps: "2x12"),
                WODMovement(name: "Plank", duration: "3x30 sec")
            ],
            workoutDescription: "Deload session. Light weights, perfect form, full range of motion. Focus on recovery.",
            intensityGrade: .low,
            trainingSplit: .fullBody
        ),

        // MARK: - Additional Push
        WODTemplate(
            title: "The Fortress Press Builder",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Close-Grip Bench Press", reps: "4x8"),
                WODMovement(name: "Seated Dumbbell Press", reps: "4x10"),
                WODMovement(name: "Incline Dumbbell Fly", reps: "3x12"),
                WODMovement(name: "Cable Lateral Raise", reps: "3x15"),
                WODMovement(name: "Overhead Tricep Extension", reps: "3x12"),
                WODMovement(name: "Diamond Push-Ups", reps: "2xAMRAP")
            ],
            workoutDescription: "Push session emphasizing lockout strength and shoulder development.",
            intensityGrade: .moderate,
            trainingSplit: .push
        ),

        // MARK: - Additional Pull
        WODTemplate(
            title: "The Valor Pull Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Weighted Pull-Ups", reps: "4x6"),
                WODMovement(name: "Meadows Row", reps: "3x10 each"),
                WODMovement(name: "Cable Pullover", reps: "3x12"),
                WODMovement(name: "Rear Delt Fly", reps: "3x15"),
                WODMovement(name: "Concentration Curl", reps: "3x10 each"),
                WODMovement(name: "Wrist Curl", reps: "3x15")
            ],
            workoutDescription: "Back and bicep session with grip endurance focus. Control tempo on every rep.",
            intensityGrade: .moderate,
            trainingSplit: .pull
        ),

        // MARK: - Additional Legs
        WODTemplate(
            title: "The Endurance Squat Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 50,
            equipment: .gym,
            movements: [
                WODMovement(name: "Paused Back Squat", reps: "4x5", notes: "3 sec pause at bottom"),
                WODMovement(name: "Walking Lunges", reps: "3x12 each", notes: "Barbell"),
                WODMovement(name: "Leg Curl", reps: "3x12"),
                WODMovement(name: "Sissy Squat", reps: "3x12"),
                WODMovement(name: "Standing Calf Raise", reps: "4x15"),
                WODMovement(name: "Plank", duration: "3x45 sec")
            ],
            workoutDescription: "Quad-dominant strength session with paused squats for time under tension.",
            intensityGrade: .high,
            trainingSplit: .legs
        ),

        // MARK: - Additional Upper Body
        WODTemplate(
            title: "The Ironclad Upper Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 50,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Bench Press", reps: "4x8"),
                WODMovement(name: "Barbell Bent-Over Row", reps: "4x8"),
                WODMovement(name: "Dumbbell Shoulder Press", reps: "3x10"),
                WODMovement(name: "Lat Pulldown", reps: "3x12"),
                WODMovement(name: "Dumbbell Lateral Raise", reps: "3x12"),
                WODMovement(name: "EZ Bar Curl + Tricep Pushdown", reps: "3x10 each")
            ],
            workoutDescription: "Balanced upper body push-pull session. Superset push and pull for efficiency.",
            intensityGrade: .moderate,
            trainingSplit: .upperBody
        ),

        // MARK: - Short Duration
        WODTemplate(
            title: "The Velocity Express Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 25,
            equipment: .gym,
            movements: [
                WODMovement(name: "Dumbbell Thruster", reps: "4x10"),
                WODMovement(name: "Dumbbell Row", reps: "4x10 each"),
                WODMovement(name: "Goblet Squat", reps: "3x12"),
                WODMovement(name: "Push-Ups", reps: "3x15")
            ],
            workoutDescription: "Quick full body session. 45 sec rest between sets. Get in, work hard, get out.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        // MARK: - AFT Grip & Carry Focus
        WODTemplate(
            title: "The Tactical Grip Builder",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 40,
            equipment: .gym,
            movements: [
                WODMovement(name: "Hex Bar Deadlift", reps: "4x5"),
                WODMovement(name: "Farmer's Walk", duration: "4x50m", notes: "Heavy"),
                WODMovement(name: "Suitcase Carry", duration: "3x30m each"),
                WODMovement(name: "Dead Hang", duration: "3x max hold"),
                WODMovement(name: "Wrist Roller", reps: "3x2 each direction"),
                WODMovement(name: "Hanging Knee Raise", reps: "3x12")
            ],
            workoutDescription: "Grip and carry focus for AFT Sprint-Drag-Carry and deadlift events.",
            intensityGrade: .high,
            trainingSplit: .mixed
        ),

        // MARK: - Additional Free Weight Library

        WODTemplate(
            title: "The Iron Protocol",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Back Squat", reps: "5x5", notes: "75% 1RM"),
                WODMovement(name: "Romanian Deadlift", reps: "4x8", notes: "Moderate load"),
                WODMovement(name: "Dumbbell Bench Press", reps: "4x10"),
                WODMovement(name: "Walking Lunge", reps: "3x12/leg"),
                WODMovement(name: "Plank", reps: "3x45s")
            ],
            workoutDescription: "Full body strength session focused on squat dominance and posterior chain development.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Apex Builder",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 40,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Bench Press", reps: "5x5"),
                WODMovement(name: "Dumbbell Row", reps: "4x10"),
                WODMovement(name: "Shoulder Press", reps: "4x8"),
                WODMovement(name: "Incline Fly", reps: "3x12"),
                WODMovement(name: "Farmer Carry", reps: "3x40m")
            ],
            workoutDescription: "Upper body strength and hypertrophy session with pressing emphasis and rowing balance.",
            intensityGrade: .high,
            trainingSplit: .upperBody
        ),
        WODTemplate(
            title: "The Tactical Grind",
            category: .freeWeight,
            format: .interval,
            durationMinutes: 35,
            equipment: .gym,
            movements: [
                WODMovement(name: "Trap Bar Deadlift", reps: "5x4"),
                WODMovement(name: "Step-Up", reps: "4x10/leg"),
                WODMovement(name: "Single Arm Row", reps: "4x10/side"),
                WODMovement(name: "Push Press", reps: "4x8"),
                WODMovement(name: "Suitcase Carry", reps: "3x30m")
            ],
            workoutDescription: "Strength and work capacity session combining heavy pulls, unilateral work, and carries.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Velocity Series",
            category: .freeWeight,
            format: .interval,
            durationMinutes: 30,
            equipment: .gym,
            movements: [
                WODMovement(name: "Hang Power Clean", reps: "6x3"),
                WODMovement(name: "Push Press", reps: "5x5"),
                WODMovement(name: "Kettlebell Swing", reps: "4x12"),
                WODMovement(name: "Jump Squat", reps: "4x8"),
                WODMovement(name: "Medicine Ball Slam", reps: "4x10")
            ],
            workoutDescription: "Explosive power session designed to improve speed, coordination, and athletic output.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Relentless Builder",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Front Squat", reps: "4x6"),
                WODMovement(name: "Romanian Deadlift", reps: "4x10"),
                WODMovement(name: "Walking Lunge", reps: "3x12/leg"),
                WODMovement(name: "Calf Raise", reps: "4x15"),
                WODMovement(name: "Sit-Up", reps: "3x15")
            ],
            workoutDescription: "Lower body builder session targeting quads, glutes, and trunk stability.",
            intensityGrade: .moderate,
            trainingSplit: .lowerBody
        ),
        WODTemplate(
            title: "The Prime Complex",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 50,
            equipment: .gym,
            movements: [
                WODMovement(name: "Deadlift", reps: "5x3"),
                WODMovement(name: "Barbell Row", reps: "4x8"),
                WODMovement(name: "Incline Bench Press", reps: "4x10"),
                WODMovement(name: "Split Squat", reps: "3x10/leg"),
                WODMovement(name: "Hanging Knee Raise", reps: "3x15")
            ],
            workoutDescription: "Full body strength complex with heavy hinge work and accessory hypertrophy.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Endurance Protocol",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Light Deadlift", reps: "3x15"),
                WODMovement(name: "Dumbbell Press", reps: "3x15"),
                WODMovement(name: "Step-Up", reps: "3x15/leg"),
                WODMovement(name: "Row", reps: "3x15"),
                WODMovement(name: "Russian Twist", reps: "3x20")
            ],
            workoutDescription: "Muscular endurance session designed to build fatigue resistance across the full body.",
            intensityGrade: .low,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Apex Grind",
            category: .freeWeight,
            format: .forTime,
            durationMinutes: 30,
            equipment: .gym,
            movements: [
                WODMovement(name: "Thruster", reps: "5x8"),
                WODMovement(name: "Pull-Up", reps: "5x10"),
                WODMovement(name: "Romanian Deadlift", reps: "5x12"),
                WODMovement(name: "Burpee", reps: "5x10"),
                WODMovement(name: "Sit-Up", reps: "5x20")
            ],
            workoutDescription: "High-output mixed session combining strength, conditioning, and core endurance.",
            intensityGrade: .extreme,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Forged Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 35,
            equipment: .gym,
            movements: [
                WODMovement(name: "Dumbbell Thruster", reps: "4x12"),
                WODMovement(name: "Kettlebell Swing", reps: "4x15"),
                WODMovement(name: "Goblet Squat", reps: "4x15"),
                WODMovement(name: "Renegade Row", reps: "4x10/side"),
                WODMovement(name: "Dumbbell Push Press", reps: "4x10")
            ],
            workoutDescription: "Fast-paced free weight session built to raise heart rate while maintaining strong movement quality.",
            intensityGrade: .high,
            trainingSplit: .conditioning
        ),
        WODTemplate(
            title: "The Iron Series",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 40,
            equipment: .gym,
            movements: [
                WODMovement(name: "Flat Dumbbell Bench Press", reps: "4x10"),
                WODMovement(name: "Incline Barbell Bench Press", reps: "4x8"),
                WODMovement(name: "Cable Chest Fly", reps: "3x12"),
                WODMovement(name: "Dumbbell Lateral Raise", reps: "3x15"),
                WODMovement(name: "Close Grip Push-Up", reps: "3xAMRAP")
            ],
            workoutDescription: "Chest-dominant upper session with layered pressing work and shoulder accessory volume.",
            intensityGrade: .moderate,
            trainingSplit: .push
        ),
        WODTemplate(
            title: "The Apex Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Weighted Pull-Up", reps: "5x5", notes: "Scale as needed"),
                WODMovement(name: "Barbell Bent Over Row", reps: "4x8"),
                WODMovement(name: "Single Arm Lat Pulldown", reps: "3x12/side"),
                WODMovement(name: "Face Pull", reps: "3x15"),
                WODMovement(name: "Hammer Curl", reps: "3x12")
            ],
            workoutDescription: "Back-focused session built around pulling strength, upper back density, and arm accessory work.",
            intensityGrade: .high,
            trainingSplit: .pull
        ),
        WODTemplate(
            title: "The Forged Builder",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 35,
            equipment: .gym,
            movements: [
                WODMovement(name: "Seated Dumbbell Shoulder Press", reps: "4x8"),
                WODMovement(name: "Arnold Press", reps: "3x10"),
                WODMovement(name: "Dumbbell Lateral Raise", reps: "3x15"),
                WODMovement(name: "Rear Delt Fly", reps: "3x15"),
                WODMovement(name: "Plate Front Raise", reps: "3x12")
            ],
            workoutDescription: "Shoulder-focused hypertrophy session emphasizing overhead pressing and delt balance.",
            intensityGrade: .moderate,
            trainingSplit: .push
        ),
        WODTemplate(
            title: "The Tactical Builder",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 40,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Curl", reps: "4x10"),
                WODMovement(name: "EZ Bar Skull Crusher", reps: "4x10"),
                WODMovement(name: "Incline Dumbbell Curl", reps: "3x12"),
                WODMovement(name: "Rope Triceps Pressdown", reps: "3x12"),
                WODMovement(name: "Hammer Curl", reps: "3x12")
            ],
            workoutDescription: "Arm-focused session with balanced biceps and triceps work for size and control.",
            intensityGrade: .moderate,
            trainingSplit: .upperBody
        ),
        WODTemplate(
            title: "The Prime Grind",
            category: .freeWeight,
            format: .forTime,
            durationMinutes: 25,
            equipment: .gym,
            movements: [
                WODMovement(name: "Dumbbell Snatch", reps: "5x8/side"),
                WODMovement(name: "Goblet Squat", reps: "5x12"),
                WODMovement(name: "Alternating Dumbbell Bench Press", reps: "5x10/side"),
                WODMovement(name: "Kettlebell Swing", reps: "5x15"),
                WODMovement(name: "Farmer Carry", reps: "5x30m")
            ],
            workoutDescription: "Condensed mixed-modal session blending explosiveness, pressing, lower body work, and carries.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Velocity Builder",
            category: .freeWeight,
            format: .ladder,
            durationMinutes: 30,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Push Press", reps: "2-4-6-8-10"),
                WODMovement(name: "Barbell Front Squat", reps: "2-4-6-8-10"),
                WODMovement(name: "Pull-Up", reps: "2-4-6-8-10"),
                WODMovement(name: "Dumbbell Reverse Lunge", reps: "2-4-6-8-10/leg")
            ],
            workoutDescription: "Ladder session that builds fatigue through power, squatting, pulling, and unilateral leg work.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Relentless Complex",
            category: .freeWeight,
            format: .interval,
            durationMinutes: 40,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Complex", reps: "6 rounds", notes: "6 RDL + 6 Row + 6 Hang Clean + 6 Front Squat"),
                WODMovement(name: "Dumbbell Push Press", reps: "4x10"),
                WODMovement(name: "Walking Lunge", reps: "4x12/leg"),
                WODMovement(name: "Plank Drag", reps: "3x12/side")
            ],
            workoutDescription: "Integrated barbell and dumbbell complex built for coordination, strength endurance, and total-body output.",
            intensityGrade: .extreme,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Forged Protocol",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 50,
            equipment: .gym,
            movements: [
                WODMovement(name: "Trap Bar Deadlift", reps: "5x5"),
                WODMovement(name: "Barbell Hip Thrust", reps: "4x8"),
                WODMovement(name: "Rear Foot Elevated Split Squat", reps: "3x10/leg"),
                WODMovement(name: "Glute Ham Raise", reps: "3x10"),
                WODMovement(name: "Weighted Carry", reps: "3x40m")
            ],
            workoutDescription: "Posterior chain dominant lower session emphasizing heavy pulling, glute strength, and loaded movement.",
            intensityGrade: .high,
            trainingSplit: .lowerBody
        ),
        WODTemplate(
            title: "The Prime Builder",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Incline Dumbbell Bench Press", reps: "4x10"),
                WODMovement(name: "Single Arm Dumbbell Row", reps: "4x10/side"),
                WODMovement(name: "Goblet Squat", reps: "4x12"),
                WODMovement(name: "Seated Dumbbell Curl", reps: "3x12"),
                WODMovement(name: "Overhead Triceps Extension", reps: "3x12")
            ],
            workoutDescription: "Balanced free weight hypertrophy session with upper body emphasis and enough lower body work to stay athletic.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Tactical Series",
            category: .freeWeight,
            format: .interval,
            durationMinutes: 30,
            equipment: .gym,
            movements: [
                WODMovement(name: "Farmer Carry", reps: "6x40m"),
                WODMovement(name: "Sled Push", reps: "6x20m"),
                WODMovement(name: "Sandbag Front Carry", reps: "4x30m"),
                WODMovement(name: "Dumbbell Step-Up", reps: "4x12/leg"),
                WODMovement(name: "Hanging Knee Raise", reps: "4x12")
            ],
            workoutDescription: "Grip, carry, trunk, and work-capacity session built around loaded movement and tactical-style output.",
            intensityGrade: .high,
            trainingSplit: .conditioning
        ),
        WODTemplate(
            title: "The Iron Builder",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 45,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Back Squat", reps: "4x8"),
                WODMovement(name: "Flat Barbell Bench Press", reps: "4x8"),
                WODMovement(name: "Barbell Bent Over Row", reps: "4x8"),
                WODMovement(name: "Romanian Deadlift", reps: "3x10"),
                WODMovement(name: "Farmer Carry", reps: "3x30m")
            ],
            workoutDescription: "Classic full body barbell builder with squat, press, row, hinge, and carry patterns.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Elite Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 42,
            equipment: .gym,
            movements: [
                WODMovement(name: "Incline Barbell Bench Press", reps: "4x6"),
                WODMovement(name: "Chest Supported Row", reps: "4x10"),
                WODMovement(name: "Dumbbell Lateral Raise", reps: "3x15"),
                WODMovement(name: "Cable Fly", reps: "3x12"),
                WODMovement(name: "Face Pull", reps: "3x15")
            ],
            workoutDescription: "Upper body session focused on controlled pressing, upper back support, and shoulder balance.",
            intensityGrade: .moderate,
            trainingSplit: .upperBody
        ),
        WODTemplate(
            title: "The Unbroken Protocol",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 48,
            equipment: .gym,
            movements: [
                WODMovement(name: "Back Squat", reps: "5x4"),
                WODMovement(name: "Barbell Split Squat", reps: "3x8/leg"),
                WODMovement(name: "Romanian Deadlift", reps: "4x8"),
                WODMovement(name: "Leg Press", reps: "3x12"),
                WODMovement(name: "Standing Calf Raise", reps: "4x15")
            ],
            workoutDescription: "Lower body strength session with squat priority and accessory volume for complete leg development.",
            intensityGrade: .high,
            trainingSplit: .legs
        ),
        WODTemplate(
            title: "The Endurance Builder",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 38,
            equipment: .gym,
            movements: [
                WODMovement(name: "Dumbbell Floor Press", reps: "3x15"),
                WODMovement(name: "Dumbbell Row", reps: "3x15/side"),
                WODMovement(name: "Goblet Squat", reps: "3x20"),
                WODMovement(name: "Walking Lunge", reps: "3x16/leg"),
                WODMovement(name: "Weighted Sit-Up", reps: "3x20")
            ],
            workoutDescription: "Muscular endurance session built around sustained work and repeated full-body effort.",
            intensityGrade: .low,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Velocity Protocol",
            category: .freeWeight,
            format: .interval,
            durationMinutes: 32,
            equipment: .gym,
            movements: [
                WODMovement(name: "Push Jerk", reps: "6x3"),
                WODMovement(name: "Hang Clean Pull", reps: "5x3"),
                WODMovement(name: "Medicine Ball Chest Pass", reps: "5x5"),
                WODMovement(name: "Jump Lunge", reps: "4x8/leg"),
                WODMovement(name: "Kettlebell Swing", reps: "4x15")
            ],
            workoutDescription: "Explosive training session aimed at speed, force production, and athletic intent.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Tactical Protocol",
            category: .freeWeight,
            format: .forTime,
            durationMinutes: 28,
            equipment: .gym,
            movements: [
                WODMovement(name: "Sandbag Carry", reps: "4x40m"),
                WODMovement(name: "Farmer Carry", reps: "4x40m"),
                WODMovement(name: "Trap Bar Deadlift", reps: "4x6"),
                WODMovement(name: "Box Step-Up", reps: "4x12/leg"),
                WODMovement(name: "Hanging Knee Raise", reps: "4x12")
            ],
            workoutDescription: "Carry and trunk-focused session that supports loaded movement, work capacity, and tactical durability.",
            intensityGrade: .high,
            trainingSplit: .mixed
        ),
        WODTemplate(
            title: "The Prime Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 36,
            equipment: .gym,
            movements: [
                WODMovement(name: "Overhead Press", reps: "5x5"),
                WODMovement(name: "Arnold Press", reps: "3x10"),
                WODMovement(name: "Rear Delt Fly", reps: "3x15"),
                WODMovement(name: "Cable Upright Row", reps: "3x12"),
                WODMovement(name: "Plate Front Raise", reps: "3x12")
            ],
            workoutDescription: "Shoulder-focused pressing and hypertrophy session with balanced front, side, and rear delt work.",
            intensityGrade: .moderate,
            trainingSplit: .push
        ),
        WODTemplate(
            title: "The Iron Complex",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 44,
            equipment: .gym,
            movements: [
                WODMovement(name: "Bench Press", reps: "4x8"),
                WODMovement(name: "Incline Dumbbell Bench Press", reps: "3x10"),
                WODMovement(name: "Weighted Dip", reps: "3x8"),
                WODMovement(name: "Cable Fly", reps: "3x12"),
                WODMovement(name: "Push-Up", reps: "2xAMRAP")
            ],
            workoutDescription: "Chest-focused session built around pressing volume and clean accessory finishing work.",
            intensityGrade: .moderate,
            trainingSplit: .push
        ),
        WODTemplate(
            title: "The Forged Grind",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 43,
            equipment: .gym,
            movements: [
                WODMovement(name: "Weighted Pull-Up", reps: "4x6"),
                WODMovement(name: "Barbell Row", reps: "4x8"),
                WODMovement(name: "Lat Pulldown", reps: "3x12"),
                WODMovement(name: "Face Pull", reps: "3x15"),
                WODMovement(name: "Incline Curl", reps: "3x12")
            ],
            workoutDescription: "Back-dominant pulling session designed to build upper back strength and arm support.",
            intensityGrade: .high,
            trainingSplit: .pull
        ),
        WODTemplate(
            title: "The Apex Protocol",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 46,
            equipment: .gym,
            movements: [
                WODMovement(name: "Hack Squat", reps: "4x10"),
                WODMovement(name: "Dumbbell Romanian Deadlift", reps: "4x10"),
                WODMovement(name: "Walking Lunge", reps: "3x14/leg"),
                WODMovement(name: "Leg Curl", reps: "3x12"),
                WODMovement(name: "Seated Calf Raise", reps: "4x15")
            ],
            workoutDescription: "Leg-focused hypertrophy session combining quad volume, posterior chain work, and accessory control.",
            intensityGrade: .moderate,
            trainingSplit: .legs
        ),
        WODTemplate(
            title: "The Relentless Session",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 34,
            equipment: .gym,
            movements: [
                WODMovement(name: "EZ Bar Curl", reps: "4x10"),
                WODMovement(name: "Close Grip Bench Press", reps: "4x8"),
                WODMovement(name: "Hammer Curl", reps: "3x12"),
                WODMovement(name: "Cable Triceps Extension", reps: "3x12"),
                WODMovement(name: "Reverse Curl", reps: "3x12")
            ],
            workoutDescription: "Arms session built for controlled tension, balanced biceps and triceps loading, and accessory volume.",
            intensityGrade: .moderate,
            trainingSplit: .upperBody
        ),
        WODTemplate(
            title: "The Tactical Complex",
            category: .freeWeight,
            format: .forTime,
            durationMinutes: 33,
            equipment: .gym,
            movements: [
                WODMovement(name: "Dumbbell Clean and Press", reps: "5x8"),
                WODMovement(name: "Front Rack Carry", reps: "5x25m"),
                WODMovement(name: "Goblet Squat", reps: "5x12"),
                WODMovement(name: "Renegade Row", reps: "5x8/side"),
                WODMovement(name: "Sit-Up", reps: "5x15")
            ],
            workoutDescription: "Mixed free weight session with full-body coordination, loaded movement, and trunk control.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Elite Builder",
            category: .freeWeight,
            format: .ladder,
            durationMinutes: 27,
            equipment: .gym,
            movements: [
                WODMovement(name: "Dumbbell Bench Press", reps: "5-10-15-10-5"),
                WODMovement(name: "Single Arm Row", reps: "5-10-15-10-5/side"),
                WODMovement(name: "Goblet Squat", reps: "5-10-15-10-5"),
                WODMovement(name: "Push Press", reps: "5-10-15-10-5")
            ],
            workoutDescription: "Ladder session that rises and falls through pressing, pulling, squatting, and shoulder drive.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Unbroken Builder",
            category: .freeWeight,
            format: .interval,
            durationMinutes: 37,
            equipment: .gym,
            movements: [
                WODMovement(name: "Deadlift", reps: "EMOM 8x3", notes: "Moderately heavy"),
                WODMovement(name: "Bench Press", reps: "4x6"),
                WODMovement(name: "Barbell Row", reps: "4x8"),
                WODMovement(name: "Reverse Lunge", reps: "3x10/leg"),
                WODMovement(name: "Farmer Carry", reps: "3x40m")
            ],
            workoutDescription: "Structured full-body strength session pairing barbell staples with loaded movement and unilateral support.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Velocity Session",
            category: .freeWeight,
            format: .interval,
            durationMinutes: 29,
            equipment: .gym,
            movements: [
                WODMovement(name: "Kettlebell Swing", reps: "6x15"),
                WODMovement(name: "Dumbbell Push Press", reps: "5x8"),
                WODMovement(name: "Jump Squat", reps: "5x8"),
                WODMovement(name: "Medicine Ball Slam", reps: "5x10"),
                WODMovement(name: "Farmer Carry", reps: "4x30m")
            ],
            workoutDescription: "Power-endurance session designed to keep force output high without losing movement quality.",
            intensityGrade: .high,
            trainingSplit: .conditioning
        ),
        WODTemplate(
            title: "The Endurance Session",
            category: .freeWeight,
            format: .forTime,
            durationMinutes: 31,
            equipment: .gym,
            movements: [
                WODMovement(name: "Goblet Squat", reps: "4x20"),
                WODMovement(name: "Dumbbell Floor Press", reps: "4x15"),
                WODMovement(name: "Single Arm Row", reps: "4x15/side"),
                WODMovement(name: "Walking Lunge", reps: "4x20/leg"),
                WODMovement(name: "Russian Twist", reps: "4x25")
            ],
            workoutDescription: "High-rep endurance session built to challenge repeat effort and movement control under fatigue.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Prime Protocol",
            category: .freeWeight,
            format: .circuit,
            durationMinutes: 41,
            equipment: .gym,
            movements: [
                WODMovement(name: "Barbell Overhead Press", reps: "4x6"),
                WODMovement(name: "Weighted Pull-Up", reps: "4x5"),
                WODMovement(name: "Front Squat", reps: "4x6"),
                WODMovement(name: "Romanian Deadlift", reps: "3x8"),
                WODMovement(name: "Hanging Knee Raise", reps: "3x15")
            ],
            workoutDescription: "Balanced full-body strength session with emphasis on press, pull, squat, hinge, and trunk control.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "The Iron Grind",
            category: .freeWeight,
            format: .forTime,
            durationMinutes: 26,
            equipment: .gym,
            movements: [
                WODMovement(name: "Dumbbell Thruster", reps: "4x10"),
                WODMovement(name: "Pull-Up", reps: "4x8"),
                WODMovement(name: "Kettlebell Swing", reps: "4x15"),
                WODMovement(name: "Farmer Carry", reps: "4x30m"),
                WODMovement(name: "Sit-Up", reps: "4x20")
            ],
            workoutDescription: "Short hard session pairing full-body free weight work with carries and trunk endurance.",
            intensityGrade: .high,
            trainingSplit: .conditioning
        )
    ]
}
