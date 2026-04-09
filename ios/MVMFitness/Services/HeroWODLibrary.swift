import Foundation

enum HeroWODLibrary {

    static let heroWODs: [WODTemplate] = [
        WODTemplate(
            title: "Blackout Protocol",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .none,
            movements: [
                WODMovement(name: "Burpees", reps: "15"),
                WODMovement(name: "Air Squats", reps: "30"),
                WODMovement(name: "Push-Ups", reps: "20"),
                WODMovement(name: "Sit-Ups", reps: "25"),
                WODMovement(name: "Lunges (alternating)", reps: "20")
            ],
            workoutDescription: "5 rounds for time. No rest between movements. Rest 60 sec between rounds.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "Smoke Check",
            category: .crossfit,
            format: .amrap,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Push-Ups", reps: "10"),
                WODMovement(name: "Jump Squats", reps: "12"),
                WODMovement(name: "Mountain Climbers", reps: "16"),
                WODMovement(name: "Plank Up-Downs", reps: "8")
            ],
            workoutDescription: "As many rounds as possible in 20 minutes. Keep transitions tight.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "Iron Mile",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 30,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "400m"),
                WODMovement(name: "Push-Ups", reps: "20"),
                WODMovement(name: "Air Squats", reps: "30"),
                WODMovement(name: "Burpees", reps: "10")
            ],
            workoutDescription: "4 rounds for time. Each round starts with a 400m run.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "Redline",
            category: .crossfit,
            format: .emom,
            durationMinutes: 24,
            equipment: .none,
            movements: [
                WODMovement(name: "Min 1: Burpees", reps: "8"),
                WODMovement(name: "Min 2: Air Squats", reps: "15"),
                WODMovement(name: "Min 3: Push-Ups", reps: "12"),
                WODMovement(name: "Min 4: Sit-Ups", reps: "15")
            ],
            workoutDescription: "6 rounds of the 4-station EMOM. Use remaining time each minute as rest.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "Ground Zero",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Kettlebell Swings", reps: "15", notes: "53 lbs"),
                WODMovement(name: "Box Jump", reps: "12", notes: "24 in"),
                WODMovement(name: "Push-Ups", reps: "15"),
                WODMovement(name: "Goblet Squat", reps: "12", notes: "35 lbs")
            ],
            workoutDescription: "5 rounds for time. Aim for sub-20 minutes.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "Foxhole Grind",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 30,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Push-Ups", reps: "25"),
                WODMovement(name: "Flutter Kicks", reps: "30"),
                WODMovement(name: "Pull-Ups", reps: "10")
            ],
            workoutDescription: "3 rounds for time. Scale pull-ups to inverted rows if needed.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "Sandstorm",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Bear Crawl", duration: "25m"),
                WODMovement(name: "Burpees", reps: "10"),
                WODMovement(name: "Broad Jumps", reps: "10"),
                WODMovement(name: "Plank Hold", duration: "45 sec"),
                WODMovement(name: "Sprint", duration: "100m")
            ],
            workoutDescription: "4 rounds for time. Minimal rest between movements.",
            intensityGrade: .extreme,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "Steel Curtain",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 35,
            equipment: .gym,
            movements: [
                WODMovement(name: "Deadlift", reps: "8", notes: "135/95 lbs"),
                WODMovement(name: "Box Jump", reps: "10", notes: "24 in"),
                WODMovement(name: "Wall Ball", reps: "12", notes: "20/14 lbs"),
                WODMovement(name: "Burpees", reps: "8")
            ],
            workoutDescription: "6 rounds for time. Rest 90 sec between rounds.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "Outpost",
            category: .crossfit,
            format: .amrap,
            durationMinutes: 16,
            equipment: .none,
            movements: [
                WODMovement(name: "Tuck Jumps", reps: "8"),
                WODMovement(name: "Diamond Push-Ups", reps: "10"),
                WODMovement(name: "Pistol Squats (alternating)", reps: "6"),
                WODMovement(name: "V-Ups", reps: "12")
            ],
            workoutDescription: "As many rounds as possible in 16 minutes. Bodyweight only.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "Rolling Thunder",
            category: .crossfit,
            format: .interval,
            durationMinutes: 25,
            equipment: .none,
            movements: [
                WODMovement(name: "Sprint", duration: "200m"),
                WODMovement(name: "Burpees", reps: "12"),
                WODMovement(name: "Sprint", duration: "200m"),
                WODMovement(name: "Push-Ups", reps: "20"),
                WODMovement(name: "Sprint", duration: "200m"),
                WODMovement(name: "Air Squats", reps: "30")
            ],
            workoutDescription: "3 rounds for time. Sprint between each bodyweight station.",
            intensityGrade: .extreme,
            trainingSplit: .conditioning
        ),
        WODTemplate(
            title: "Devil Dog",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Dumbbell Thrusters", reps: "10", notes: "35/25 lbs"),
                WODMovement(name: "Pull-Ups", reps: "10"),
                WODMovement(name: "Kettlebell Swings", reps: "15", notes: "53 lbs"),
                WODMovement(name: "Box Jump", reps: "10", notes: "24 in")
            ],
            workoutDescription: "4 rounds for time. Keep a steady pace.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "Ruck Standard",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 30,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "400m"),
                WODMovement(name: "Lunges (alternating)", reps: "20"),
                WODMovement(name: "Push-Ups", reps: "15"),
                WODMovement(name: "Plank", duration: "60 sec"),
                WODMovement(name: "Mountain Climbers", reps: "20")
            ],
            workoutDescription: "5 rounds. 60 sec rest between rounds. Focus on form under fatigue.",
            intensityGrade: .moderate,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "No Slack",
            category: .crossfit,
            format: .ladder,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Burpees", reps: "2-4-6-8-10-8-6-4-2"),
                WODMovement(name: "Push-Ups", reps: "4-8-12-16-20-16-12-8-4"),
                WODMovement(name: "Air Squats", reps: "6-12-18-24-30-24-18-12-6")
            ],
            workoutDescription: "Ascending/descending ladder. Complete all 3 movements at each step before advancing.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "Trench Warfare",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 35,
            equipment: .gym,
            movements: [
                WODMovement(name: "Farmer's Carry", duration: "50m", notes: "Heavy"),
                WODMovement(name: "Burpees", reps: "10"),
                WODMovement(name: "Goblet Squat", reps: "15", notes: "44 lbs"),
                WODMovement(name: "Push Press", reps: "12", notes: "65/45 lbs")
            ],
            workoutDescription: "5 rounds for time. Build grip and pressing endurance under load.",
            intensityGrade: .high,
            trainingSplit: .fullBody
        ),
        WODTemplate(
            title: "Midnight Run",
            category: .crossfit,
            format: .interval,
            durationMinutes: 30,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Burpees", reps: "15"),
                WODMovement(name: "Sit-Ups", reps: "25"),
                WODMovement(name: "Plank", duration: "45 sec")
            ],
            workoutDescription: "4 rounds. Focus on maintaining run pace across all rounds.",
            intensityGrade: .high,
            trainingSplit: .conditioning
        ),
        WODTemplate(
            title: "Bunker Buster",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .gym,
            movements: [
                WODMovement(name: "Wall Ball", reps: "20", notes: "20/14 lbs"),
                WODMovement(name: "Kettlebell Swings", reps: "15", notes: "53 lbs"),
                WODMovement(name: "Burpees", reps: "10"),
                WODMovement(name: "Run", duration: "200m")
            ],
            workoutDescription: "5 rounds for time. Fast transitions, no rest.",
            intensityGrade: .extreme,
            trainingSplit: .fullBody
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
