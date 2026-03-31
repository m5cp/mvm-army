import Foundation

enum WODTemplateLibrary {

    static let functionalWODs: [WODTemplate] = [
        WODTemplate(
            title: "Murph Light",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "400m"),
                WODMovement(name: "Pull-Ups", reps: "50"),
                WODMovement(name: "Push-Ups", reps: "100"),
                WODMovement(name: "Air Squats", reps: "150"),
                WODMovement(name: "Run", duration: "400m")
            ],
            workoutDescription: "Partition pull-ups, push-ups, and squats as needed. Start and finish with a 400m run.",
            notes: "Scale pull-ups to ring rows if needed"
        ),
        WODTemplate(
            title: "The Grinder",
            category: .crossfit,
            format: .amrap,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Burpees", reps: "10"),
                WODMovement(name: "Air Squats", reps: "15"),
                WODMovement(name: "Push-Ups", reps: "20"),
                WODMovement(name: "Sit-Ups", reps: "25")
            ],
            workoutDescription: "20-minute AMRAP. Move at a sustainable pace. Track total rounds."
        ),
        WODTemplate(
            title: "Devil's Dozen",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 15,
            equipment: .none,
            movements: [
                WODMovement(name: "Burpees", reps: "13"),
                WODMovement(name: "Push-Ups", reps: "13"),
                WODMovement(name: "Lunges (each leg)", reps: "13"),
                WODMovement(name: "Sit-Ups", reps: "13"),
                WODMovement(name: "Air Squats", reps: "13")
            ],
            workoutDescription: "5 rounds for time. 13 reps of each movement per round."
        ),
        WODTemplate(
            title: "Minute Mayhem",
            category: .crossfit,
            format: .emom,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Odd Min: Burpees", reps: "10"),
                WODMovement(name: "Even Min: Air Squats", reps: "15")
            ],
            workoutDescription: "EMOM for 20 minutes. Odd minutes: burpees. Even minutes: squats. Rest the remainder of each minute."
        ),
        WODTemplate(
            title: "Filthy Fifty (Scaled)",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 30,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Box Step-Ups", reps: "50"),
                WODMovement(name: "Push-Ups", reps: "50"),
                WODMovement(name: "Kettlebell Swings", reps: "50"),
                WODMovement(name: "Lunges", reps: "50"),
                WODMovement(name: "Sit-Ups", reps: "50")
            ],
            workoutDescription: "For time: 50 reps of each movement in order."
        ),
        WODTemplate(
            title: "Tabata Tornado",
            category: .crossfit,
            format: .tabata,
            durationMinutes: 16,
            equipment: .none,
            movements: [
                WODMovement(name: "Push-Ups", duration: "20s on / 10s off x 8"),
                WODMovement(name: "Air Squats", duration: "20s on / 10s off x 8"),
                WODMovement(name: "Burpees", duration: "20s on / 10s off x 8"),
                WODMovement(name: "Plank Hold", duration: "20s on / 10s off x 8")
            ],
            workoutDescription: "4 Tabata rounds (8 intervals each). 1 min rest between movements."
        ),
        WODTemplate(
            title: "Death by Push-Ups",
            category: .crossfit,
            format: .emom,
            durationMinutes: 15,
            equipment: .none,
            movements: [
                WODMovement(name: "Push-Ups", reps: "Add 1 each minute"),
                WODMovement(name: "Min 1: 1, Min 2: 2, Min 3: 3...")
            ],
            workoutDescription: "Start with 1 push-up in minute 1, add 1 each minute. Continue until you cannot complete the reps in the minute."
        ),
        WODTemplate(
            title: "Sprint & Swing",
            category: .crossfit,
            format: .interval,
            durationMinutes: 20,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Shuttle Run", duration: "200m"),
                WODMovement(name: "Kettlebell Swings", reps: "15"),
                WODMovement(name: "Push-Ups", reps: "10"),
                WODMovement(name: "Rest", duration: "60 sec")
            ],
            workoutDescription: "5 rounds: 200m shuttle run, 15 KB swings, 10 push-ups. Rest 60 sec between rounds."
        ),
        WODTemplate(
            title: "Cindy",
            category: .crossfit,
            format: .amrap,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Pull-Ups", reps: "5"),
                WODMovement(name: "Push-Ups", reps: "10"),
                WODMovement(name: "Air Squats", reps: "15")
            ],
            workoutDescription: "AMRAP 20 minutes: 5 pull-ups, 10 push-ups, 15 air squats. Scale pull-ups to ring rows.",
            notes: "Classic functional benchmark"
        ),
        WODTemplate(
            title: "Ascending Ladder",
            category: .crossfit,
            format: .ladder,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Burpees", reps: "2-4-6-8-10-8-6-4-2"),
                WODMovement(name: "Air Squats", reps: "4-8-12-16-20-16-12-8-4")
            ],
            workoutDescription: "Ascending then descending ladder. Work through each level, rest as needed between sets."
        ),
        WODTemplate(
            title: "The Chipper",
            category: .crossfit,
            format: .chipper,
            durationMinutes: 25,
            equipment: .none,
            movements: [
                WODMovement(name: "Air Squats", reps: "50"),
                WODMovement(name: "Sit-Ups", reps: "40"),
                WODMovement(name: "Lunges", reps: "30"),
                WODMovement(name: "Push-Ups", reps: "20"),
                WODMovement(name: "Burpees", reps: "10")
            ],
            workoutDescription: "Chip through all reps in order for time. Break up sets as needed."
        ),
        WODTemplate(
            title: "KB Complex",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 20,
            equipment: .minimal,
            movements: [
                WODMovement(name: "KB Swing", reps: "15"),
                WODMovement(name: "Goblet Squat", reps: "10"),
                WODMovement(name: "KB Clean & Press (each)", reps: "8"),
                WODMovement(name: "KB Row (each arm)", reps: "10")
            ],
            workoutDescription: "4 rounds. Rest 90 sec between rounds. Use moderate weight.",
            notes: "Use one kettlebell throughout"
        ),
        WODTemplate(
            title: "Running Clock",
            category: .crossfit,
            format: .emom,
            durationMinutes: 24,
            equipment: .none,
            movements: [
                WODMovement(name: "Min 1: Push-Ups", reps: "12"),
                WODMovement(name: "Min 2: Air Squats", reps: "16"),
                WODMovement(name: "Min 3: Sit-Ups", reps: "12"),
                WODMovement(name: "Min 4: Shuttle Run", duration: "200m")
            ],
            workoutDescription: "6 rounds of the 4-station EMOM. Rotate movements every minute."
        ),
        WODTemplate(
            title: "DB Destroyer",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 18,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Dumbbell Thrusters", reps: "21-15-9"),
                WODMovement(name: "Burpees", reps: "21-15-9"),
                WODMovement(name: "Dumbbell Rows (each)", reps: "21-15-9")
            ],
            workoutDescription: "21-15-9 rep scheme for time. Use moderate dumbbells."
        ),
        WODTemplate(
            title: "Four Corners",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Station 1: Push-Ups", reps: "15"),
                WODMovement(name: "Station 2: Air Squats", reps: "20"),
                WODMovement(name: "Station 3: Plank", duration: "45 sec"),
                WODMovement(name: "Station 4: Shuttle Run", duration: "200m")
            ],
            workoutDescription: "5 rounds through all 4 stations. 30 sec rest between rounds."
        ),
        WODTemplate(
            title: "Fight Gone Bad (Scaled)",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 17,
            equipment: .minimal,
            movements: [
                WODMovement(name: "Box Step-Ups", duration: "1 min"),
                WODMovement(name: "Push Press", duration: "1 min"),
                WODMovement(name: "Kettlebell Swings", duration: "1 min"),
                WODMovement(name: "Sit-Ups", duration: "1 min"),
                WODMovement(name: "Shuttle Run", duration: "1 min")
            ],
            workoutDescription: "3 rounds: 1 min at each station, count total reps. 1 min rest between rounds."
        ),
        WODTemplate(
            title: "The Seven",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 22,
            equipment: .none,
            movements: [
                WODMovement(name: "Burpees", reps: "7"),
                WODMovement(name: "Push-Ups", reps: "7"),
                WODMovement(name: "Lunges (each)", reps: "7"),
                WODMovement(name: "V-Ups", reps: "7"),
                WODMovement(name: "Air Squats", reps: "7"),
                WODMovement(name: "Mountain Climbers (each)", reps: "7"),
                WODMovement(name: "Plank", duration: "30 sec")
            ],
            workoutDescription: "7 rounds for time. 7 reps of each movement per round."
        ),
        WODTemplate(
            title: "Pyramid Push",
            category: .crossfit,
            format: .ladder,
            durationMinutes: 18,
            equipment: .none,
            movements: [
                WODMovement(name: "Push-Ups", reps: "5-10-15-20-15-10-5"),
                WODMovement(name: "Sit-Ups", reps: "10-20-30-40-30-20-10"),
                WODMovement(name: "Air Squats", reps: "10-20-30-40-30-20-10")
            ],
            workoutDescription: "Work up the pyramid then back down. Rest as needed between levels."
        ),
        WODTemplate(
            title: "Partner Pace",
            category: .crossfit,
            format: .amrap,
            durationMinutes: 15,
            equipment: .none,
            movements: [
                WODMovement(name: "Burpees", reps: "8"),
                WODMovement(name: "Air Squats", reps: "12"),
                WODMovement(name: "Push-Ups", reps: "16"),
                WODMovement(name: "Shuttle Run", duration: "100m")
            ],
            workoutDescription: "15-minute AMRAP. Maintain a steady pace. Track rounds completed.",
            notes: "Can be done solo or with a partner (I go, you go)"
        ),
        WODTemplate(
            title: "Heavy Hitter",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Deadlift", reps: "10", notes: "Moderate weight"),
                WODMovement(name: "Box Step-Ups", reps: "15"),
                WODMovement(name: "Push-Ups", reps: "20"),
                WODMovement(name: "Shuttle Run", duration: "200m")
            ],
            workoutDescription: "4 rounds for time. Focus on form over speed."
        ),
        WODTemplate(
            title: "Bear Complex",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Deadlift", reps: "5"),
                WODMovement(name: "Hang Clean", reps: "5"),
                WODMovement(name: "Front Squat", reps: "5"),
                WODMovement(name: "Push Press", reps: "5")
            ],
            workoutDescription: "5 rounds. Use light to moderate barbell or dumbbells. Rest 2 min between rounds.",
            notes: "Focus on smooth transitions between movements"
        ),
        WODTemplate(
            title: "Baseline",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 10,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "500m"),
                WODMovement(name: "Air Squats", reps: "20"),
                WODMovement(name: "Push-Ups", reps: "20"),
                WODMovement(name: "Sit-Ups", reps: "20"),
                WODMovement(name: "Run", duration: "500m")
            ],
            workoutDescription: "For time. Great test workout to track improvement."
        ),
        WODTemplate(
            title: "Triple Threat",
            category: .crossfit,
            format: .interval,
            durationMinutes: 18,
            equipment: .none,
            movements: [
                WODMovement(name: "Round 1: 3 min AMRAP", notes: "10 burpees + 10 squats"),
                WODMovement(name: "Rest", duration: "1 min"),
                WODMovement(name: "Round 2: 3 min AMRAP", notes: "10 push-ups + 10 lunges"),
                WODMovement(name: "Rest", duration: "1 min"),
                WODMovement(name: "Round 3: 3 min AMRAP", notes: "10 sit-ups + 10 mountain climbers")
            ],
            workoutDescription: "Three 3-minute AMRAPs with 1-minute rest between. Then repeat all 3."
        ),
        WODTemplate(
            title: "100s",
            category: .crossfit,
            format: .chipper,
            durationMinutes: 25,
            equipment: .none,
            movements: [
                WODMovement(name: "Air Squats", reps: "100"),
                WODMovement(name: "Push-Ups", reps: "100"),
                WODMovement(name: "Sit-Ups", reps: "100"),
                WODMovement(name: "Lunges", reps: "100")
            ],
            workoutDescription: "For time. 100 reps of each movement in order. Break into sets as needed."
        ),
        WODTemplate(
            title: "The Sprint Session",
            category: .crossfit,
            format: .interval,
            durationMinutes: 15,
            equipment: .none,
            movements: [
                WODMovement(name: "Sprint", duration: "200m"),
                WODMovement(name: "Walk Back Recovery"),
                WODMovement(name: "10 Burpees at the start line")
            ],
            workoutDescription: "8 rounds: Sprint 200m, walk back, do 10 burpees. Go when ready."
        ),
        WODTemplate(
            title: "Dumbbell Blitz",
            category: .crossfit,
            format: .amrap,
            durationMinutes: 15,
            equipment: .minimal,
            movements: [
                WODMovement(name: "DB Thrusters", reps: "10"),
                WODMovement(name: "DB Rows (each arm)", reps: "10"),
                WODMovement(name: "Burpees", reps: "8"),
                WODMovement(name: "DB Lunges (each leg)", reps: "8")
            ],
            workoutDescription: "15-minute AMRAP. Use moderate dumbbells."
        ),
        WODTemplate(
            title: "Run & Gun",
            category: .crossfit,
            format: .interval,
            durationMinutes: 24,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "400m"),
                WODMovement(name: "Push-Ups", reps: "20"),
                WODMovement(name: "Run", duration: "400m"),
                WODMovement(name: "Air Squats", reps: "30"),
                WODMovement(name: "Run", duration: "400m"),
                WODMovement(name: "Burpees", reps: "15")
            ],
            workoutDescription: "3 rounds of the full sequence for time."
        ),
        WODTemplate(
            title: "Core Crusher",
            category: .crossfit,
            format: .emom,
            durationMinutes: 16,
            equipment: .none,
            movements: [
                WODMovement(name: "Min 1: Plank", duration: "45 sec"),
                WODMovement(name: "Min 2: Sit-Ups", reps: "15"),
                WODMovement(name: "Min 3: Flutter Kicks", reps: "20"),
                WODMovement(name: "Min 4: Mountain Climbers", reps: "20")
            ],
            workoutDescription: "4 rounds of the 4-station EMOM. Rest the remainder of each minute."
        ),
        WODTemplate(
            title: "Power Hour",
            category: .crossfit,
            format: .circuit,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Deadlift", reps: "8"),
                WODMovement(name: "Push Press", reps: "8"),
                WODMovement(name: "Front Squat", reps: "8"),
                WODMovement(name: "Bent Over Row", reps: "8"),
                WODMovement(name: "Shuttle Run", duration: "200m")
            ],
            workoutDescription: "4 rounds. 90 sec rest between rounds. Use moderate weight.",
            notes: "Keep form strict throughout all rounds"
        )
    ]

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

    static var allTemplates: [WODTemplate] {
        functionalWODs + aftWODs
    }

    static var regularWODs: [WODTemplate] {
        functionalWODs + aftWODs
    }

    static var heroWODs: [WODTemplate] {
        HeroWODLibrary.heroWODs
    }

    static var allIncludingHero: [WODTemplate] {
        functionalWODs + aftWODs + HeroWODLibrary.heroWODs
    }
}
