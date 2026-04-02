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
        )
    ]
}
