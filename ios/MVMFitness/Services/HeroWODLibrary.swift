import Foundation

enum HeroWODLibrary {

    static let heroWODs: [WODTemplate] = [
        WODTemplate(
            title: "The Iron Test",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 45,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "1 mile"),
                WODMovement(name: "Pull-Ups", reps: "100"),
                WODMovement(name: "Push-Ups", reps: "200"),
                WODMovement(name: "Air Squats", reps: "300"),
                WODMovement(name: "Run", duration: "1 mile")
            ],
            workoutDescription: "For time. Partition the pull-ups, push-ups, and squats as needed. Start and finish with a 1-mile run."
        ),
        WODTemplate(
            title: "The Relentless Grind",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Handstand Push-Ups", reps: "21"),
                WODMovement(name: "Ring Dips", reps: "21"),
                WODMovement(name: "Push-Ups", reps: "21"),
                WODMovement(name: "Handstand Push-Ups", reps: "15"),
                WODMovement(name: "Ring Dips", reps: "15"),
                WODMovement(name: "Push-Ups", reps: "15"),
                WODMovement(name: "Handstand Push-Ups", reps: "9"),
                WODMovement(name: "Ring Dips", reps: "9"),
                WODMovement(name: "Push-Ups", reps: "9")
            ],
            workoutDescription: "21-15-9 reps for time of handstand push-ups, ring dips, and push-ups."
        ),
        WODTemplate(
            title: "The Apex Protocol",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 30,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Back Extensions", reps: "50"),
                WODMovement(name: "Sit-Ups", reps: "50")
            ],
            workoutDescription: "3 rounds for time of 800m run, 50 back extensions, and 50 sit-ups."
        ),
        WODTemplate(
            title: "The Vanguard Effort",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .gym,
            movements: [
                WODMovement(name: "Pull-Ups", reps: "50"),
                WODMovement(name: "Run", duration: "400m"),
                WODMovement(name: "Thrusters", reps: "21", notes: "95/65 lbs"),
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Thrusters", reps: "21", notes: "95/65 lbs"),
                WODMovement(name: "Run", duration: "400m"),
                WODMovement(name: "Pull-Ups", reps: "50")
            ],
            workoutDescription: "For time: 50 pull-ups, 400m run, 21 thrusters, 800m run, 21 thrusters, 400m run, 50 pull-ups."
        ),
        WODTemplate(
            title: "The Sentinel Challenge",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Overhead Squats", reps: "21", notes: "95/65 lbs"),
                WODMovement(name: "Pull-Ups", reps: "42"),
                WODMovement(name: "Overhead Squats", reps: "15", notes: "95/65 lbs"),
                WODMovement(name: "Pull-Ups", reps: "30"),
                WODMovement(name: "Overhead Squats", reps: "9", notes: "95/65 lbs"),
                WODMovement(name: "Pull-Ups", reps: "18")
            ],
            workoutDescription: "For time: 21 OHS, 42 pull-ups, 15 OHS, 30 pull-ups, 9 OHS, 18 pull-ups."
        ),
        WODTemplate(
            title: "The Forged Circuit",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 15,
            equipment: .gym,
            movements: [
                WODMovement(name: "Deadlift", reps: "12", notes: "155/105 lbs"),
                WODMovement(name: "Hang Power Clean", reps: "9", notes: "155/105 lbs"),
                WODMovement(name: "Push Jerk", reps: "6", notes: "155/105 lbs")
            ],
            workoutDescription: "5 rounds for time: 12 deadlifts, 9 hang power cleans, 6 push jerks."
        ),
        WODTemplate(
            title: "The Titan Builder",
            category: .crossfit,
            format: .amrap,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Muscle-Ups", reps: "2"),
                WODMovement(name: "Handstand Push-Ups", reps: "4"),
                WODMovement(name: "Pistols (alternating)", reps: "8")
            ],
            workoutDescription: "As many rounds as possible in 20 minutes: 2 muscle-ups, 4 handstand push-ups, 8 pistols."
        ),
        WODTemplate(
            title: "The Surge Session",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 10,
            equipment: .gym,
            movements: [
                WODMovement(name: "Power Snatch", reps: "75", notes: "75/55 lbs")
            ],
            workoutDescription: "For time: 75 power snatches at 75/55 lbs."
        ),
        WODTemplate(
            title: "The Resolute Complex",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Thrusters", reps: "21", notes: "115/75 lbs"),
                WODMovement(name: "Rope Climb (15 ft)", reps: "12"),
                WODMovement(name: "Thrusters", reps: "15", notes: "115/75 lbs"),
                WODMovement(name: "Rope Climb (15 ft)", reps: "9"),
                WODMovement(name: "Thrusters", reps: "9", notes: "115/75 lbs"),
                WODMovement(name: "Rope Climb (15 ft)", reps: "6")
            ],
            workoutDescription: "For time: 21 thrusters + 12 rope climbs, 15 thrusters + 9 rope climbs, 9 thrusters + 6 rope climbs."
        ),
        WODTemplate(
            title: "The Velocity Test",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Run Backwards", duration: "400m"),
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Run Backwards", duration: "400m")
            ],
            workoutDescription: "For time: 800m run, 400m run backwards, 800m run, 400m run backwards."
        ),
        WODTemplate(
            title: "The Endurance Protocol",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 35,
            equipment: .gym,
            movements: [
                WODMovement(name: "Run", duration: "1 mile"),
                WODMovement(name: "Clean & Jerk", reps: "10", notes: "135/95 lbs"),
                WODMovement(name: "Run", duration: "1 mile"),
                WODMovement(name: "Clean & Jerk", reps: "10", notes: "135/95 lbs"),
                WODMovement(name: "Run", duration: "1 mile"),
                WODMovement(name: "Clean & Jerk", reps: "10", notes: "135/95 lbs")
            ],
            workoutDescription: "3 rounds for time: 1-mile run + 10 clean & jerks at 135/95 lbs."
        ),
        WODTemplate(
            title: "The Fortress Grind",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 30,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Pull-Ups", reps: "5"),
                WODMovement(name: "Push-Ups", reps: "10"),
                WODMovement(name: "Air Squats", reps: "15")
            ],
            workoutDescription: "5 rounds for time: 800m run, 5 pull-ups, 10 push-ups, 15 air squats."
        ),
        WODTemplate(
            title: "The Pinnacle Effort",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "200m"),
                WODMovement(name: "Air Squats", reps: "24"),
                WODMovement(name: "Push-Ups", reps: "24"),
                WODMovement(name: "Lunges", reps: "24"),
                WODMovement(name: "Pull-Ups", reps: "24")
            ],
            workoutDescription: "6 rounds for time: 200m run, 24 air squats, 24 push-ups, 24 lunges, 24 pull-ups."
        ),
        WODTemplate(
            title: "The Catalyst Series",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 35,
            equipment: .gym,
            movements: [
                WODMovement(name: "Burpees", reps: "22"),
                WODMovement(name: "Kettlebell Swings", reps: "22", notes: "70 lbs"),
                WODMovement(name: "Box Jump", reps: "22", notes: "24 in"),
                WODMovement(name: "Wall Ball", reps: "22", notes: "20/14 lbs"),
                WODMovement(name: "Double-Unders", reps: "22")
            ],
            workoutDescription: "5 rounds for time: 22 burpees, 22 KB swings, 22 box jumps, 22 wall balls, 22 double-unders."
        ),
        WODTemplate(
            title: "The Steadfast Builder",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .gym,
            movements: [
                WODMovement(name: "Kettlebell Swings", reps: "15", notes: "53 lbs"),
                WODMovement(name: "Power Clean", reps: "15", notes: "95/65 lbs"),
                WODMovement(name: "Box Jump", reps: "15", notes: "24 in")
            ],
            workoutDescription: "7 rounds for time: 15 KB swings, 15 power cleans, 15 box jumps."
        ),
        WODTemplate(
            title: "The Elite Seven",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 30,
            equipment: .gym,
            movements: [
                WODMovement(name: "Handstand Push-Ups", reps: "7"),
                WODMovement(name: "Thrusters", reps: "7", notes: "135/95 lbs"),
                WODMovement(name: "Knees-to-Elbows", reps: "7"),
                WODMovement(name: "Deadlift", reps: "7", notes: "245/165 lbs"),
                WODMovement(name: "Burpees", reps: "7"),
                WODMovement(name: "Kettlebell Swings", reps: "7", notes: "70 lbs"),
                WODMovement(name: "Pull-Ups", reps: "7")
            ],
            workoutDescription: "7 rounds for time: 7 reps of each movement per round."
        ),
        WODTemplate(
            title: "The Unbroken Challenge",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 60,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "10 miles"),
                WODMovement(name: "Burpees", reps: "150")
            ],
            workoutDescription: "For time: 10-mile run, then 150 burpees. Partition as needed during the run."
        ),
        WODTemplate(
            title: "The Valor Session",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 30,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Push-Ups", reps: "28"),
                WODMovement(name: "Pull-Ups", reps: "28"),
                WODMovement(name: "Air Squats", reps: "28"),
                WODMovement(name: "Sit-Ups", reps: "28")
            ],
            workoutDescription: "8 rounds for time: 800m run, 28 push-ups, 28 pull-ups, 28 air squats, 28 sit-ups."
        ),
        WODTemplate(
            title: "The Prime Effort",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Dumbbell Squat Clean", reps: "30", notes: "50/35 lbs"),
                WODMovement(name: "Burpees", reps: "30")
            ],
            workoutDescription: "3 rounds for time: 800m run, 30 DB squat cleans, 30 burpees."
        ),
        WODTemplate(
            title: "The Tactical Grind",
            category: .crossfit,
            format: .amrap,
            durationMinutes: 30,
            equipment: .gym,
            movements: [
                WODMovement(name: "Deadlift", reps: "5", notes: "275/185 lbs"),
                WODMovement(name: "Push-Ups", reps: "13"),
                WODMovement(name: "Box Jump", reps: "9", notes: "24 in")
            ],
            workoutDescription: "As many rounds as possible in 30 minutes: 5 deadlifts, 13 push-ups, 9 box jumps."
        ),
        WODTemplate(
            title: "The Forge Complex",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Turkish Get-Up (R)", reps: "1", notes: "70 lbs"),
                WODMovement(name: "Turkish Get-Up (L)", reps: "1", notes: "70 lbs"),
                WODMovement(name: "Kettlebell Swings", reps: "6", notes: "70 lbs"),
                WODMovement(name: "Kettlebell Clean & Jerk (R)", reps: "7"),
                WODMovement(name: "Kettlebell Clean & Jerk (L)", reps: "7")
            ],
            workoutDescription: "With a single kettlebell, flow: 1 TGU each side, 6 KB swings, 7 C&J each side. Repeat."
        )
    ]

    static func isHeroWorkout(_ template: WODTemplate) -> Bool {
        false
    }

    static func isMemorialWorkout(_ template: WODTemplate) -> Bool {
        false
    }

    static func tributeFor(_ templateTitle: String) -> HeroWODInfo? {
        nil
    }
}

nonisolated struct HeroWODInfo: Codable, Hashable, Sendable {
    let honoreeFullName: String
    let rankOrRole: String
    let serviceBranch: String
    let dateOfDeath: String
    let location: String
    let shortTribute: String

    var displayName: String { "" }
    var formattedTribute: String { "" }
    var isValid: Bool { false }
}
