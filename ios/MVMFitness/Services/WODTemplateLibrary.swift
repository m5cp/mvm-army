import Foundation

enum WODTemplateLibrary {

    static var functionalWODs: [WODTemplate] {
        FunctionalFitnessLibrary.functionalFitnessWorkouts
    }

    static let aftWODs: [WODTemplate] = [
        WODTemplate(
            title: "MDL Builder",
            category: .aftStyle,
            format: .circuit,
            durationMinutes: 25,
            equipment: .gym,
            movements: [
                WODMovement(name: "Hex Bar Deadlift", reps: "5", notes: "Build to working weight"),
                WODMovement(name: "Romanian Deadlift", reps: "8"),
                WODMovement(name: "Goblet Squat", reps: "10"),
                WODMovement(name: "Hip Bridge", reps: "12"),
                WODMovement(name: "Farmer's Carry", duration: "40m")
            ],
            workoutDescription: "4 rounds. Rest 90 sec between rounds. Focus on hip hinge form."
        ),
        WODTemplate(
            title: "HRP Endurance",
            category: .aftStyle,
            format: .interval,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Hand-Release Push-Ups", reps: "15"),
                WODMovement(name: "Plank", duration: "30 sec"),
                WODMovement(name: "Diamond Push-Ups", reps: "8"),
                WODMovement(name: "Shoulder Taps", reps: "20")
            ],
            workoutDescription: "5 rounds. Rest 60 sec between rounds. Build push endurance."
        ),
        WODTemplate(
            title: "SDC Simulator",
            category: .aftStyle,
            format: .interval,
            durationMinutes: 25,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Sprint", duration: "25m down and back"),
                WODMovement(name: "Sled Drag (or Bear Crawl)", duration: "25m down and back"),
                WODMovement(name: "Lateral Shuffle", duration: "25m down and back"),
                WODMovement(name: "Farmer's Carry", duration: "25m down and back"),
                WODMovement(name: "Sprint Finish", duration: "25m down and back")
            ],
            workoutDescription: "Practice the full SDC sequence. 4 rounds with 2 min rest between.",
            notes: "Simulate actual SDC lane setup"
        ),
        WODTemplate(
            title: "Plank Fortress",
            category: .aftStyle,
            format: .circuit,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Forearm Plank", duration: "45 sec"),
                WODMovement(name: "Side Plank (L)", duration: "30 sec"),
                WODMovement(name: "Side Plank (R)", duration: "30 sec"),
                WODMovement(name: "Dead Bug", reps: "12"),
                WODMovement(name: "Bird Dog", reps: "10 each"),
                WODMovement(name: "Hollow Hold", duration: "30 sec")
            ],
            workoutDescription: "4 rounds. 45 sec rest between rounds. Build core endurance for the plank event."
        ),
        WODTemplate(
            title: "2MR Intervals",
            category: .aftStyle,
            format: .interval,
            durationMinutes: 25,
            equipment: .none,
            movements: [
                WODMovement(name: "800m Run", notes: "Target pace"),
                WODMovement(name: "Rest", duration: "90 sec"),
                WODMovement(name: "400m Run", notes: "Faster than target pace"),
                WODMovement(name: "Rest", duration: "60 sec")
            ],
            workoutDescription: "2x (800m + 400m). Build aerobic capacity and pace awareness for the 2-mile run."
        ),
        WODTemplate(
            title: "AFT Full Send",
            category: .aftStyle,
            format: .circuit,
            durationMinutes: 30,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Deadlift (moderate)", reps: "5"),
                WODMovement(name: "Hand-Release Push-Ups", reps: "15"),
                WODMovement(name: "Farmer's Carry + Sprint", duration: "50m"),
                WODMovement(name: "Plank", duration: "60 sec"),
                WODMovement(name: "Run", duration: "400m")
            ],
            workoutDescription: "3 rounds. Simulates all 5 AFT events in one circuit. 2 min rest between rounds."
        ),
        WODTemplate(
            title: "Lower Body Power",
            category: .aftStyle,
            format: .circuit,
            durationMinutes: 25,
            equipment: .gym,
            movements: [
                WODMovement(name: "Trap Bar Deadlift", reps: "5x3", notes: "Heavy"),
                WODMovement(name: "Bulgarian Split Squat", reps: "8 each"),
                WODMovement(name: "Box Jump", reps: "8"),
                WODMovement(name: "Hip Thrust", reps: "10")
            ],
            workoutDescription: "4 rounds. 2 min rest between rounds. Build max deadlift strength."
        ),
        WODTemplate(
            title: "Push-Up Pyramid",
            category: .aftStyle,
            format: .ladder,
            durationMinutes: 15,
            equipment: .none,
            movements: [
                WODMovement(name: "Hand-Release Push-Ups", reps: "5-10-15-20-15-10-5"),
                WODMovement(name: "Plank Hold between sets", duration: "20 sec")
            ],
            workoutDescription: "Ascending then descending pyramid. Hold a plank for 20 sec between each set."
        ),
        WODTemplate(
            title: "Work Capacity Builder",
            category: .aftStyle,
            format: .interval,
            durationMinutes: 20,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Kettlebell Swing", reps: "15"),
                WODMovement(name: "Suitcase Carry", duration: "40m"),
                WODMovement(name: "Lateral Shuffle", duration: "25m down and back"),
                WODMovement(name: "Sprint", duration: "50m")
            ],
            workoutDescription: "5 rounds. 60 sec rest between rounds. Build SDC-specific capacity."
        ),
        WODTemplate(
            title: "Core + Run Combo",
            category: .aftStyle,
            format: .interval,
            durationMinutes: 25,
            equipment: .none,
            movements: [
                WODMovement(name: "Plank", duration: "60 sec"),
                WODMovement(name: "Flutter Kicks", reps: "20"),
                WODMovement(name: "Run", duration: "400m"),
                WODMovement(name: "Dead Bug", reps: "12"),
                WODMovement(name: "Run", duration: "400m")
            ],
            workoutDescription: "3 rounds. Combines plank endurance with running intervals."
        ),
        WODTemplate(
            title: "Deadlift Day",
            category: .aftStyle,
            format: .circuit,
            durationMinutes: 30,
            equipment: .gym,
            movements: [
                WODMovement(name: "Hex Bar Deadlift", reps: "3", notes: "Work up to heavy triple"),
                WODMovement(name: "Sumo Deadlift", reps: "8", notes: "Moderate"),
                WODMovement(name: "Good Mornings", reps: "10"),
                WODMovement(name: "Weighted Hip Bridge", reps: "12"),
                WODMovement(name: "Calf Raises", reps: "15")
            ],
            workoutDescription: "5 sets of deadlift, then 3 rounds of accessories. Rest 2 min between DL sets."
        ),
        WODTemplate(
            title: "Tempo Run",
            category: .aftStyle,
            format: .interval,
            durationMinutes: 30,
            equipment: .none,
            movements: [
                WODMovement(name: "Easy Jog", duration: "5 min"),
                WODMovement(name: "Tempo Run", duration: "20 min", notes: "Comfortably hard pace"),
                WODMovement(name: "Cool Down Jog", duration: "5 min")
            ],
            workoutDescription: "Sustained tempo effort. Find a pace you can hold for 20 min. Builds 2-mile run time."
        ),
        WODTemplate(
            title: "Upper Push Stamina",
            category: .aftStyle,
            format: .emom,
            durationMinutes: 16,
            equipment: .none,
            movements: [
                WODMovement(name: "Min 1: Hand-Release Push-Ups", reps: "10"),
                WODMovement(name: "Min 2: Wide Push-Ups", reps: "8"),
                WODMovement(name: "Min 3: Close-Grip Push-Ups", reps: "8"),
                WODMovement(name: "Min 4: Shoulder Taps", reps: "16")
            ],
            workoutDescription: "4 rounds of the 4-station EMOM. Build push endurance without equipment."
        ),
        WODTemplate(
            title: "Sprint Intervals",
            category: .aftStyle,
            format: .interval,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Sprint", duration: "200m"),
                WODMovement(name: "Walk Recovery", duration: "200m"),
                WODMovement(name: "Sprint", duration: "400m"),
                WODMovement(name: "Jog Recovery", duration: "400m")
            ],
            workoutDescription: "3 sets of the 200/400 combo. Builds speed and recovery for the 2-mile run."
        )
    ]

    static var freeWeightWODs: [WODTemplate] {
        FreeWeightLibrary.freeWeightWorkouts
    }

    static var allTemplates: [WODTemplate] {
        functionalWODs + aftWODs
    }

    static var regularWODs: [WODTemplate] {
        functionalWODs + aftWODs
    }

    static var challengeWODs: [WODTemplate] {
        HeroWODLibrary.heroWODs
    }

    static var allIncludingChallenge: [WODTemplate] {
        functionalWODs + aftWODs + HeroWODLibrary.heroWODs
    }

    static var allIncludingFreeWeights: [WODTemplate] {
        functionalWODs + aftWODs + FreeWeightLibrary.freeWeightWorkouts
    }

    static func poolForPreference(_ preference: WODHeroPreference) -> [WODTemplate] {
        switch preference {
        case .regular:
            return functionalWODs + aftWODs
        case .mixed:
            return FreeWeightLibrary.freeWeightWorkouts
        case .heroOnly:
            return functionalWODs + aftWODs + FreeWeightLibrary.freeWeightWorkouts
        }
    }
}
