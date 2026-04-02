import Foundation

enum FunctionalFitnessLibrary {

    static let functionalFitnessWorkouts: [WODTemplate] = [

        WODTemplate(
            title: "The Apex Circuit",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 30,
            equipment: .none,
            movements: [
                WODMovement(name: "Air Squat", reps: "4x20"),
                WODMovement(name: "Push-Up", reps: "4x15"),
                WODMovement(name: "Walking Lunge", reps: "4x12/leg"),
                WODMovement(name: "Sit-Up", reps: "4x20"),
                WODMovement(name: "Mountain Climber", reps: "4x30s")
            ],
            workoutDescription: "Bodyweight conditioning circuit built for repeat effort, movement quality, and general work capacity.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Iron Circuit",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .none,
            movements: [
                WODMovement(name: "Burpee", reps: "5x10"),
                WODMovement(name: "Air Squat", reps: "5x20"),
                WODMovement(name: "Push-Up", reps: "5x15"),
                WODMovement(name: "Sit-Up", reps: "5x20"),
                WODMovement(name: "Bear Crawl", reps: "5x20m")
            ],
            workoutDescription: "High-output bodyweight session that blends strength endurance, conditioning, and trunk fatigue resistance.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Tactical Circuit",
            category: .crossfit,
            format: .interval,
            durationMinutes: 32,
            equipment: .none,
            movements: [
                WODMovement(name: "Sprint", reps: "6x40m"),
                WODMovement(name: "Bear Crawl", reps: "6x20m"),
                WODMovement(name: "Push-Up", reps: "6x12"),
                WODMovement(name: "Walking Lunge", reps: "6x12/leg"),
                WODMovement(name: "Plank", reps: "6x30s")
            ],
            workoutDescription: "Tactical-style conditioning session built around speed, crawling, pushing, and core stiffness.",
            intensityGrade: .high,
            trainingSplit: .conditioning
        ),

        WODTemplate(
            title: "The Velocity Builder",
            category: .crossfit,
            format: .interval,
            durationMinutes: 28,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Jump Squat", reps: "5x10"),
                WODMovement(name: "Broad Jump", reps: "5x6"),
                WODMovement(name: "Skater Hop", reps: "5x12/side"),
                WODMovement(name: "High Knee Sprint", reps: "5x20s"),
                WODMovement(name: "Plank Jack", reps: "5x20")
            ],
            workoutDescription: "Explosive lower-body and conditioning session focused on speed, spring, and athletic intent.",
            intensityGrade: .high,
            trainingSplit: .lowerBody
        ),

        WODTemplate(
            title: "The Prime Session",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 35,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Pull-Up", reps: "5x6"),
                WODMovement(name: "Push-Up", reps: "5x15"),
                WODMovement(name: "Air Squat", reps: "5x20"),
                WODMovement(name: "Hanging Knee Raise", reps: "5x12"),
                WODMovement(name: "Farmer Carry", reps: "5x30m")
            ],
            workoutDescription: "Mixed upper-body pulling, pressing, lower-body endurance, and trunk strength with simple functional flow.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Relentless Protocol",
            category: .crossfit,
            format: .ladder,
            durationMinutes: 24,
            equipment: .none,
            movements: [
                WODMovement(name: "Push-Up", reps: "2-4-6-8-10-8-6-4-2"),
                WODMovement(name: "Sit-Up", reps: "2-4-6-8-10-8-6-4-2"),
                WODMovement(name: "Air Squat", reps: "4-8-12-16-20-16-12-8-4"),
                WODMovement(name: "Jumping Jack", reps: "10-20-30-40-50-40-30-20-10")
            ],
            workoutDescription: "Simple ladder session that builds fatigue gradually and then tapers down through repeat-effort bodyweight work.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Forged Session",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 27,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Kettlebell Swing", reps: "5x15"),
                WODMovement(name: "Goblet Squat", reps: "5x12"),
                WODMovement(name: "Push-Up", reps: "5x12"),
                WODMovement(name: "Reverse Lunge", reps: "5x10/leg"),
                WODMovement(name: "Sit-Up", reps: "5x15")
            ],
            workoutDescription: "Minimal-equipment conditioning session with full-body free movement and repeatable work capacity demands.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Endurance Grind",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 40,
            equipment: .none,
            movements: [
                WODMovement(name: "Walking Lunge", reps: "4x20/leg"),
                WODMovement(name: "Push-Up", reps: "4x20"),
                WODMovement(name: "Air Squat", reps: "4x25"),
                WODMovement(name: "Sit-Up", reps: "4x25"),
                WODMovement(name: "Plank Shoulder Tap", reps: "4x20/side")
            ],
            workoutDescription: "Longer muscular endurance session built to challenge posture, trunk control, and sustainable bodyweight output.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Elite Protocol",
            category: .crossfit,
            format: .interval,
            durationMinutes: 30,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Sled Push", reps: "6x20m"),
                WODMovement(name: "Farmer Carry", reps: "6x30m"),
                WODMovement(name: "Burpee", reps: "6x10"),
                WODMovement(name: "Walking Lunge", reps: "6x12/leg"),
                WODMovement(name: "Hollow Hold", reps: "6x25s")
            ],
            workoutDescription: "Hard functional session with carries, sled work, bodyweight output, and trunk stiffness under fatigue.",
            intensityGrade: .extreme,
            trainingSplit: .conditioning
        ),

        WODTemplate(
            title: "The Tactical Builder",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 34,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Sandbag Carry", reps: "5x30m"),
                WODMovement(name: "Push-Up", reps: "5x15"),
                WODMovement(name: "Step-Up", reps: "5x12/leg"),
                WODMovement(name: "Bear Crawl", reps: "5x20m"),
                WODMovement(name: "Hanging Knee Raise", reps: "5x12")
            ],
            workoutDescription: "Tactical-style builder session using carries, step work, crawling, and upper-body endurance.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Iron Effort",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 22,
            equipment: .none,
            movements: [
                WODMovement(name: "Burpee", reps: "4x12"),
                WODMovement(name: "Push-Up", reps: "4x15"),
                WODMovement(name: "Jump Squat", reps: "4x15"),
                WODMovement(name: "Sit-Up", reps: "4x20"),
                WODMovement(name: "Broad Jump", reps: "4x8")
            ],
            workoutDescription: "Short, hard bodyweight session combining explosive lower-body work with upper-body and trunk endurance.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Prime Circuit",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 33,
            equipment: .none,
            movements: [
                WODMovement(name: "Pull-Up", reps: "4x8"),
                WODMovement(name: "Dip", reps: "4x10"),
                WODMovement(name: "Air Squat", reps: "4x20"),
                WODMovement(name: "Hanging Leg Raise", reps: "4x10"),
                WODMovement(name: "Plank", reps: "4x40s")
            ],
            workoutDescription: "Simple upper-body and trunk-driven bodyweight session supported by lower-body endurance volume.",
            intensityGrade: .moderate,
            trainingSplit: .upperBody
        ),

        WODTemplate(
            title: "The Velocity Grind",
            category: .crossfit,
            format: .interval,
            durationMinutes: 26,
            equipment: .none,
            movements: [
                WODMovement(name: "Sprint", reps: "8x30m"),
                WODMovement(name: "Jumping Lunge", reps: "6x10/leg"),
                WODMovement(name: "Burpee", reps: "6x8"),
                WODMovement(name: "Mountain Climber", reps: "6x30s"),
                WODMovement(name: "Plank Up-Down", reps: "6x12")
            ],
            workoutDescription: "Fast interval-based bodyweight session aimed at speed, transition control, and repeated explosive effort.",
            intensityGrade: .high,
            trainingSplit: .conditioning
        ),

        WODTemplate(
            title: "The Unbroken Session",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 36,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Kettlebell Swing", reps: "4x20"),
                WODMovement(name: "Push-Up", reps: "4x15"),
                WODMovement(name: "Step-Up", reps: "4x15/leg"),
                WODMovement(name: "Farmer Carry", reps: "4x40m"),
                WODMovement(name: "Russian Twist", reps: "4x20")
            ],
            workoutDescription: "Repeatable mixed-modal session designed for steady effort and clean movement under fatigue.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Apex Protocol",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 29,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Dumbbell Snatch", reps: "5x10/side"),
                WODMovement(name: "Goblet Squat", reps: "5x15"),
                WODMovement(name: "Push-Up", reps: "5x15"),
                WODMovement(name: "Walking Lunge", reps: "5x12/leg"),
                WODMovement(name: "Sit-Up", reps: "5x20")
            ],
            workoutDescription: "Full-body functional conditioning session combining unilateral power, squatting, and trunk endurance.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Endurance Builder",
            category: .crossfit,
            format: .ladder,
            durationMinutes: 30,
            equipment: .none,
            movements: [
                WODMovement(name: "Air Squat", reps: "10-20-30-20-10"),
                WODMovement(name: "Push-Up", reps: "5-10-15-10-5"),
                WODMovement(name: "Sit-Up", reps: "10-20-30-20-10"),
                WODMovement(name: "Mountain Climber", reps: "20-30-40-30-20")
            ],
            workoutDescription: "Ladder-based muscular endurance session with rising and falling bodyweight volume.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Tactical Session",
            category: .crossfit,
            format: .interval,
            durationMinutes: 31,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Farmer Carry", reps: "5x40m"),
                WODMovement(name: "Sled Drag", reps: "5x20m"),
                WODMovement(name: "Push-Up", reps: "5x12"),
                WODMovement(name: "Lateral Shuffle", reps: "5x20m"),
                WODMovement(name: "Dead Bug", reps: "5x12/side")
            ],
            workoutDescription: "Carry, drag, and movement-control session supporting tactical fitness and work capacity.",
            intensityGrade: .high,
            trainingSplit: .conditioning
        ),

        WODTemplate(
            title: "The Forged Circuit",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 32,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Box Step-Up", reps: "4x15/leg"),
                WODMovement(name: "Push-Up", reps: "4x15"),
                WODMovement(name: "Kettlebell Swing", reps: "4x15"),
                WODMovement(name: "Bear Crawl", reps: "4x20m"),
                WODMovement(name: "Hollow Hold", reps: "4x30s")
            ],
            workoutDescription: "Functional circuit that builds lower-body stamina, pushing endurance, and trunk control.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Relentless Circuit",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 23,
            equipment: .none,
            movements: [
                WODMovement(name: "Air Squat", reps: "5x25"),
                WODMovement(name: "Push-Up", reps: "5x12"),
                WODMovement(name: "Sit-Up", reps: "5x20"),
                WODMovement(name: "Walking Lunge", reps: "5x12/leg"),
                WODMovement(name: "Plank", reps: "5x30s")
            ],
            workoutDescription: "Simple bodyweight grind built around repeated lower-body and trunk effort with steady upper-body endurance.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Elite Builder",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 37,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Sandbag Front Carry", reps: "4x30m"),
                WODMovement(name: "Step-Up", reps: "4x12/leg"),
                WODMovement(name: "Pull-Up", reps: "4x6"),
                WODMovement(name: "Push-Up", reps: "4x15"),
                WODMovement(name: "Sit-Up", reps: "4x20")
            ],
            workoutDescription: "Balanced tactical-style session with carries, vertical pulling, pressing endurance, and trunk work.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Prime Builder",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 34,
            equipment: .none,
            movements: [
                WODMovement(name: "Dip", reps: "4x10"),
                WODMovement(name: "Pull-Up", reps: "4x6"),
                WODMovement(name: "Push-Up", reps: "4x12"),
                WODMovement(name: "Hanging Knee Raise", reps: "4x12"),
                WODMovement(name: "Air Squat", reps: "4x20")
            ],
            workoutDescription: "Upper-body dominant bodyweight builder with enough lower-body volume to keep the session complete.",
            intensityGrade: .moderate,
            trainingSplit: .upperBody
        ),

        WODTemplate(
            title: "The Iron Session",
            category: .crossfit,
            format: .interval,
            durationMinutes: 27,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Farmer Carry", reps: "6x30m"),
                WODMovement(name: "Burpee", reps: "6x8"),
                WODMovement(name: "Goblet Squat", reps: "6x12"),
                WODMovement(name: "Push-Up", reps: "6x12"),
                WODMovement(name: "Dead Bug", reps: "6x12/side")
            ],
            workoutDescription: "Interval-based mixed session pairing carries, bodyweight output, and lower-body volume.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Velocity Protocol",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 21,
            equipment: .none,
            movements: [
                WODMovement(name: "Sprint", reps: "6x50m"),
                WODMovement(name: "Jump Squat", reps: "6x12"),
                WODMovement(name: "Burpee", reps: "6x8"),
                WODMovement(name: "Mountain Climber", reps: "6x20s"),
                WODMovement(name: "Sit-Up", reps: "6x15")
            ],
            workoutDescription: "Short sharp speed-conditioning session with repeated explosive lower-body effort and core volume.",
            intensityGrade: .high,
            trainingSplit: .conditioning
        ),

        WODTemplate(
            title: "The Unbroken Protocol",
            category: .crossfit,
            format: .ladder,
            durationMinutes: 26,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Kettlebell Swing", reps: "5-10-15-10-5"),
                WODMovement(name: "Push-Up", reps: "5-10-15-10-5"),
                WODMovement(name: "Goblet Squat", reps: "5-10-15-10-5"),
                WODMovement(name: "Sit-Up", reps: "10-20-30-20-10")
            ],
            workoutDescription: "Minimal-equipment ladder session that builds controlled fatigue through repeatable patterns.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Tactical Grind",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 30,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Sandbag Carry", reps: "5x40m"),
                WODMovement(name: "Bear Crawl", reps: "5x20m"),
                WODMovement(name: "Push-Up", reps: "5x15"),
                WODMovement(name: "Walking Lunge", reps: "5x15/leg"),
                WODMovement(name: "Plank Shoulder Tap", reps: "5x20/side")
            ],
            workoutDescription: "Loaded movement and bodyweight conditioning session built for tactical-style durability.",
            intensityGrade: .high,
            trainingSplit: .conditioning
        ),

        WODTemplate(
            title: "The Endurance Session",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 42,
            equipment: .none,
            movements: [
                WODMovement(name: "Air Squat", reps: "5x25"),
                WODMovement(name: "Push-Up", reps: "5x18"),
                WODMovement(name: "Walking Lunge", reps: "5x16/leg"),
                WODMovement(name: "Sit-Up", reps: "5x25"),
                WODMovement(name: "Plank", reps: "5x40s")
            ],
            workoutDescription: "Longer bodyweight endurance session designed to improve fatigue resistance and consistency.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Forged Builder",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 33,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Step-Up", reps: "4x15/leg"),
                WODMovement(name: "Push-Up", reps: "4x15"),
                WODMovement(name: "Farmer Carry", reps: "4x35m"),
                WODMovement(name: "Hanging Knee Raise", reps: "4x10"),
                WODMovement(name: "Skater Hop", reps: "4x12/side")
            ],
            workoutDescription: "Athletic mixed-modal session blending step work, pressing, loaded movement, and trunk control.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Apex Effort",
            category: .crossfit,
            format: .interval,
            durationMinutes: 29,
            equipment: .none,
            movements: [
                WODMovement(name: "Burpee", reps: "8x8"),
                WODMovement(name: "Air Squat", reps: "8x15"),
                WODMovement(name: "Push-Up", reps: "8x10"),
                WODMovement(name: "Mountain Climber", reps: "8x20s"),
                WODMovement(name: "Hollow Hold", reps: "8x20s")
            ],
            workoutDescription: "Hard interval bodyweight session built to keep intensity high while movements stay simple and repeatable.",
            intensityGrade: .extreme,
            trainingSplit: .conditioning
        ),

        WODTemplate(
            title: "The Prime Protocol",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 35,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Pull-Up", reps: "5x5"),
                WODMovement(name: "Push-Up", reps: "5x12"),
                WODMovement(name: "Goblet Squat", reps: "5x15"),
                WODMovement(name: "Farmer Carry", reps: "5x30m"),
                WODMovement(name: "Dead Bug", reps: "5x12/side")
            ],
            workoutDescription: "Balanced functional session with pulling, pressing, squatting, carrying, and trunk control.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),

        WODTemplate(
            title: "The Elite Circuit",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 24,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Kettlebell Swing", reps: "4x20"),
                WODMovement(name: "Goblet Squat", reps: "4x15"),
                WODMovement(name: "Push-Up", reps: "4x15"),
                WODMovement(name: "Farmer Carry", reps: "4x30m"),
                WODMovement(name: "Sit-Up", reps: "4x20")
            ],
            workoutDescription: "Compact mixed-modal session that blends free movement, simple loading, and sustained work capacity.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        )
    ]
}
