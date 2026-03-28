import Foundation

enum ArmyTemplateLibrary {
    static let templates: [ArmyWorkoutTemplate] = onDutyIndividual + offDutyIndividual + unitPT + wodTemplates + randomTemplates

    // MARK: - On-Duty Individual (30 total: 10 original + 20 new)
    static let onDutyIndividual: [ArmyWorkoutTemplate] = [
        ArmyWorkoutTemplate(
            title: "On-Duty AFT Lower Strength 1",
            mode: .onDutyIndividual,
            focus: .lowerStrength,
            equipment: [.minimal, .gym, .field],
            objective: "Build lower-body strength for deadlift and sprint-carry demands.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Hex Bar Deadlift", sets: 4, reps: "5"),
                ArmyExercise(name: "Forward Lunge", sets: 3, reps: "8 each"),
                ArmyExercise(name: "Farmer Carry", sets: 4, duration: "40 m"),
                ArmyExercise(name: "Plank", sets: 3, duration: "45 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Keep transitions tight and reinforce safe lift mechanics."
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty AFT Upper Endurance 1",
            mode: .onDutyIndividual,
            focus: .upperEndurance,
            equipment: [.bodyweight, .minimal],
            objective: "Improve hand-release push-up endurance and trunk stability.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Hand-Release Push-Up", sets: 5, reps: "AMRAP - 2 reps in reserve"),
                ArmyExercise(name: "8-Count T Push-Up", sets: 3, reps: "8"),
                ArmyExercise(name: "Supine Chest Press", sets: 3, reps: "12"),
                ArmyExercise(name: "Quadraplex", sets: 3, reps: "10")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Work Capacity 1",
            mode: .onDutyIndividual,
            focus: .workCapacity,
            equipment: [.field, .minimal],
            objective: "Build sprint-drag-carry style work capacity.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Sprint", sets: 5, duration: "50 m"),
                ArmyExercise(name: "Backward Drag", sets: 5, duration: "25 m"),
                ArmyExercise(name: "Lateral Shuffle", sets: 4, duration: "25 m each"),
                ArmyExercise(name: "Kettlebell Carry", sets: 4, duration: "40 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Core + Run 1",
            mode: .onDutyIndividual,
            focus: .coreRun,
            equipment: [.running, .field],
            objective: "Develop core endurance and running economy.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Plank", sets: 4, duration: "60 sec"),
                ArmyExercise(name: "Side Bridge", sets: 3, duration: "30 sec each"),
                ArmyExercise(name: "400 m Run", sets: 4, duration: "Moderate pace"),
                ArmyExercise(name: "Walk Recovery", sets: 4, duration: "90 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Running Intervals 1",
            mode: .onDutyIndividual,
            focus: .endurance,
            equipment: [.running, .field],
            objective: "Improve 2-mile pace and aerobic power.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Running Drill 1", sets: 1, duration: "as directed"),
                ArmyExercise(name: "Running Drill 2", sets: 1, duration: "as directed"),
                ArmyExercise(name: "800 m Repeats", sets: 3, duration: "Hard, controlled"),
                ArmyExercise(name: "Walk/Jog Recovery", sets: 3, duration: "2 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Tactical Circuit 1",
            mode: .onDutyIndividual,
            focus: .tactical,
            equipment: [.field, .bodyweight],
            objective: "Build tactical conditioning with simple field-friendly movements.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Push-Up", sets: 4, reps: "15"),
                ArmyExercise(name: "Air Squat", sets: 4, reps: "20"),
                ArmyExercise(name: "Burpee", sets: 4, reps: "10"),
                ArmyExercise(name: "Shuttle Run", sets: 4, duration: "30 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Recovery / PMCS 1",
            mode: .onDutyIndividual,
            focus: .recovery,
            equipment: [.bodyweight, .field],
            objective: "Promote recovery and joint maintenance.",
            warmup: ArmyDrillLibrary.pmcs,
            mainEffort: [
                ArmyExercise(name: "Hip Stability Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Shoulder Stability Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Four for the Core", sets: 1, duration: "through sequence")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty AFT Hybrid 1",
            mode: .onDutyIndividual,
            focus: .aftPrep,
            equipment: [.minimal, .field],
            objective: "Touch all major AFT domains in one short session.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Deadlift", sets: 3, reps: "5"),
                ArmyExercise(name: "Hand-Release Push-Up", sets: 3, reps: "12"),
                ArmyExercise(name: "Sprint-Drag-Carry Simulation", sets: 3, duration: "1 round"),
                ArmyExercise(name: "Plank", sets: 3, duration: "45 sec"),
                ArmyExercise(name: "400 m Run", sets: 3, duration: "moderate-hard")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Military Movement 1",
            mode: .onDutyIndividual,
            focus: .tactical,
            equipment: [.field],
            objective: "Use military movement and shuttle patterns for movement quality and intensity.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Military Movement Drill 1", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Military Movement Drill 2", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Sprint", sets: 6, duration: "40 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Conditioning Drill 1 Session",
            mode: .onDutyIndividual,
            focus: .tactical,
            equipment: [.bodyweight, .field],
            objective: "Use Army conditioning drill structure for a short sharp PT block.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Conditioning Drill 1", sets: 2, duration: "through sequence"),
                ArmyExercise(name: "Conditioning Drill 2", sets: 1, duration: "through sequence")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),

        // NEW On-Duty Individual (20 new)
        ArmyWorkoutTemplate(
            title: "On-Duty AFT Lower Strength 2",
            mode: .onDutyIndividual,
            focus: .lowerStrength,
            equipment: [.minimal, .field],
            objective: "Develop posterior chain strength and loaded movement under field conditions.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Sumo Deadlift", sets: 4, reps: "6"),
                ArmyExercise(name: "Reverse Lunge", sets: 3, reps: "10 each"),
                ArmyExercise(name: "Suitcase Carry", sets: 4, duration: "30 m each hand"),
                ArmyExercise(name: "Glute Bridge", sets: 3, reps: "12")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Emphasize hip hinge mechanics and bracing."
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty AFT Lower Strength 3",
            mode: .onDutyIndividual,
            focus: .lowerStrength,
            equipment: [.gym, .minimal],
            objective: "Build deadlift-specific strength with accessory lower work.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Trap Bar Deadlift", sets: 5, reps: "3"),
                ArmyExercise(name: "Bulgarian Split Squat", sets: 3, reps: "8 each"),
                ArmyExercise(name: "Kettlebell Swing", sets: 4, reps: "12"),
                ArmyExercise(name: "Single-Leg RDL", sets: 3, reps: "8 each")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty AFT Upper Endurance 2",
            mode: .onDutyIndividual,
            focus: .upperEndurance,
            equipment: [.bodyweight, .field],
            objective: "Build push-up volume and pressing endurance for AFT demands.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Hand-Release Push-Up", sets: 4, reps: "15"),
                ArmyExercise(name: "Diamond Push-Up", sets: 3, reps: "10"),
                ArmyExercise(name: "Wide Push-Up", sets: 3, reps: "12"),
                ArmyExercise(name: "Prone Row", sets: 3, reps: "10"),
                ArmyExercise(name: "Front Lean and Rest", sets: 3, duration: "20 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty AFT Upper Endurance 3",
            mode: .onDutyIndividual,
            focus: .upperEndurance,
            equipment: [.bodyweight, .minimal],
            objective: "Ladder push-up session to build muscular endurance under fatigue.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Push-Up Ladder 2-4-6-8-10", sets: 3, reps: "ladder"),
                ArmyExercise(name: "Hand-Release Push-Up", sets: 3, reps: "AMRAP 30 sec"),
                ArmyExercise(name: "Plank to Push-Up", sets: 3, reps: "8"),
                ArmyExercise(name: "Quadraplex", sets: 2, reps: "10")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Work Capacity 2",
            mode: .onDutyIndividual,
            focus: .workCapacity,
            equipment: [.field, .bodyweight],
            objective: "Simulate sprint-drag-carry demands with field-ready circuits.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Bear Crawl", sets: 4, duration: "20 m"),
                ArmyExercise(name: "Sprint", sets: 4, duration: "50 m"),
                ArmyExercise(name: "Broad Jump", sets: 4, reps: "5"),
                ArmyExercise(name: "Overhead Carry", sets: 4, duration: "30 m"),
                ArmyExercise(name: "Burpee", sets: 3, reps: "8")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Work Capacity 3",
            mode: .onDutyIndividual,
            focus: .workCapacity,
            equipment: [.field, .minimal],
            objective: "High-effort anaerobic intervals mimicking SDC movement patterns.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Sled Push / Heavy Push", sets: 5, duration: "25 m"),
                ArmyExercise(name: "Backward Drag", sets: 5, duration: "25 m"),
                ArmyExercise(name: "Lateral Shuffle", sets: 5, duration: "25 m each"),
                ArmyExercise(name: "Farmer Carry Sprint", sets: 5, duration: "25 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Core + Run 2",
            mode: .onDutyIndividual,
            focus: .coreRun,
            equipment: [.running, .bodyweight],
            objective: "Alternate between trunk stability and short running efforts.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Plank", sets: 3, duration: "60 sec"),
                ArmyExercise(name: "200 m Run", sets: 3, duration: "moderate-hard"),
                ArmyExercise(name: "Side Bridge", sets: 3, duration: "30 sec each"),
                ArmyExercise(name: "200 m Run", sets: 3, duration: "hard"),
                ArmyExercise(name: "Back Bridge", sets: 3, duration: "30 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Core + Run 3",
            mode: .onDutyIndividual,
            focus: .coreRun,
            equipment: [.running, .field],
            objective: "Fartlek-style running with integrated core holds.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Fartlek Run", sets: 1, duration: "15 min alternating easy/hard"),
                ArmyExercise(name: "Plank", sets: 4, duration: "45 sec"),
                ArmyExercise(name: "Bent-Leg Raise", sets: 3, reps: "12"),
                ArmyExercise(name: "Superman Hold", sets: 3, duration: "20 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Running Intervals 2",
            mode: .onDutyIndividual,
            focus: .endurance,
            equipment: [.running],
            objective: "Build aerobic threshold with progressive interval distances.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "200 m Run", sets: 2, duration: "hard"),
                ArmyExercise(name: "400 m Run", sets: 2, duration: "moderate-hard"),
                ArmyExercise(name: "800 m Run", sets: 1, duration: "steady-hard"),
                ArmyExercise(name: "Walk Recovery", sets: 5, duration: "90 sec between efforts")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Running Tempo 1",
            mode: .onDutyIndividual,
            focus: .endurance,
            equipment: [.running, .field],
            objective: "Sustain a controlled hard pace to improve 2-mile economy.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Tempo Run", sets: 1, duration: "15 min at controlled hard pace"),
                ArmyExercise(name: "Stride-Out", sets: 4, duration: "80 m at 90% effort"),
                ArmyExercise(name: "Walk Recovery", sets: 4, duration: "60 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Tactical Circuit 2",
            mode: .onDutyIndividual,
            focus: .tactical,
            equipment: [.field, .bodyweight],
            objective: "EMOM-style tactical conditioning for sustained output.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Push-Up", sets: 1, reps: "10 every minute on the minute x 10 min"),
                ArmyExercise(name: "Air Squat", sets: 1, reps: "15 every minute on the minute x 10 min"),
                ArmyExercise(name: "Mountain Climber", sets: 3, duration: "30 sec"),
                ArmyExercise(name: "Sprint", sets: 4, duration: "30 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Tactical Circuit 3",
            mode: .onDutyIndividual,
            focus: .tactical,
            equipment: [.bodyweight, .field],
            objective: "Partner-based field circuit for competitive conditioning.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Buddy Carry", sets: 4, duration: "25 m"),
                ArmyExercise(name: "Burpee", sets: 4, reps: "10"),
                ArmyExercise(name: "Flutter Kick", sets: 4, duration: "30 sec"),
                ArmyExercise(name: "Shuttle Sprint", sets: 4, duration: "25 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Recovery / PMCS 2",
            mode: .onDutyIndividual,
            focus: .recovery,
            equipment: [.bodyweight],
            objective: "Active recovery with emphasis on hip and ankle mobility.",
            warmup: ArmyDrillLibrary.pmcs,
            mainEffort: [
                ArmyExercise(name: "90/90 Hip Switch", sets: 2, reps: "10 each"),
                ArmyExercise(name: "World's Greatest Stretch", sets: 2, reps: "5 each"),
                ArmyExercise(name: "Ankle Circle", sets: 2, reps: "10 each direction"),
                ArmyExercise(name: "Cat-Cow", sets: 2, reps: "10"),
                ArmyExercise(name: "Easy Walk", sets: 1, duration: "10 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty AFT Hybrid 2",
            mode: .onDutyIndividual,
            focus: .aftPrep,
            equipment: [.field, .minimal],
            objective: "Compressed AFT domain practice with quick transitions.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Deadlift", sets: 3, reps: "3"),
                ArmyExercise(name: "Hand-Release Push-Up", sets: 3, reps: "15"),
                ArmyExercise(name: "Lateral Shuffle + Sprint", sets: 3, duration: "down and back"),
                ArmyExercise(name: "Plank", sets: 3, duration: "60 sec"),
                ArmyExercise(name: "800 m Run", sets: 1, duration: "hard")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty AFT Hybrid 3",
            mode: .onDutyIndividual,
            focus: .aftPrep,
            equipment: [.minimal, .field],
            objective: "Cycle through AFT event patterns in timed rounds.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Deadlift", sets: 2, reps: "5"),
                ArmyExercise(name: "Push-Up", sets: 2, reps: "20"),
                ArmyExercise(name: "Sprint-Drag-Carry Simulation", sets: 2, duration: "1 round"),
                ArmyExercise(name: "Plank Hold", sets: 2, duration: "75 sec"),
                ArmyExercise(name: "400 m Run", sets: 2, duration: "hard")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Military Movement 2",
            mode: .onDutyIndividual,
            focus: .tactical,
            equipment: [.field],
            objective: "Agility and lateral quickness using Army movement drills.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Lateral Shuffle", sets: 6, duration: "25 m each"),
                ArmyExercise(name: "Crossover Run", sets: 4, duration: "25 m each"),
                ArmyExercise(name: "High Knee Run", sets: 4, duration: "25 m"),
                ArmyExercise(name: "Sprint", sets: 4, duration: "50 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Conditioning Drill 2 Session",
            mode: .onDutyIndividual,
            focus: .tactical,
            equipment: [.bodyweight, .field],
            objective: "Higher-intensity conditioning drill session with sprint finisher.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Conditioning Drill 2", sets: 2, duration: "through sequence"),
                ArmyExercise(name: "Conditioning Drill 3", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Sprint", sets: 4, duration: "40 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Lower + Carry Emphasis",
            mode: .onDutyIndividual,
            focus: .lowerStrength,
            equipment: [.field, .minimal],
            objective: "Loaded carries and squat patterns for leg drive and grip strength.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Goblet Squat", sets: 4, reps: "10"),
                ArmyExercise(name: "Farmer Carry", sets: 5, duration: "40 m"),
                ArmyExercise(name: "Reverse Lunge", sets: 3, reps: "8 each"),
                ArmyExercise(name: "Overhead Carry", sets: 4, duration: "30 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Push + Pull Field Day",
            mode: .onDutyIndividual,
            focus: .upperEndurance,
            equipment: [.field, .minimal],
            objective: "Balanced upper-body session alternating push and pull patterns.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Hand-Release Push-Up", sets: 4, reps: "12"),
                ArmyExercise(name: "Inverted Row / Towel Row", sets: 4, reps: "10"),
                ArmyExercise(name: "Pike Push-Up", sets: 3, reps: "8"),
                ArmyExercise(name: "Prone Row", sets: 3, reps: "10"),
                ArmyExercise(name: "Plank", sets: 2, duration: "45 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "On-Duty Sprint Repeats",
            mode: .onDutyIndividual,
            focus: .endurance,
            equipment: [.running, .field],
            objective: "Short sprint repeats to build speed and anaerobic capacity.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "100 m Sprint", sets: 8, duration: "near max effort"),
                ArmyExercise(name: "Walk Recovery", sets: 8, duration: "60-90 sec"),
                ArmyExercise(name: "Stride-Out", sets: 4, duration: "80 m at 85%")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
    ]

    // MARK: - Off-Duty Individual (40 total: 10 original + 30 new)
    static let offDutyIndividual: [ArmyWorkoutTemplate] = [
        ArmyWorkoutTemplate(
            title: "Off-Duty Free Weight Strength 1",
            mode: .offDutyIndividual,
            focus: .lowerStrength,
            equipment: [.gym],
            objective: "Build total-body strength with free weights.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Barbell Deadlift", sets: 5, reps: "5"),
                ArmyExercise(name: "Bench Press", sets: 4, reps: "8"),
                ArmyExercise(name: "Bent-Over Row", sets: 4, reps: "8"),
                ArmyExercise(name: "Plank", sets: 3, duration: "60 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Lower Strength 2",
            mode: .offDutyIndividual,
            focus: .lowerStrength,
            equipment: [.gym, .minimal],
            objective: "Increase posterior-chain strength and carry capacity.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Romanian Deadlift", sets: 4, reps: "8"),
                ArmyExercise(name: "Goblet Squat", sets: 4, reps: "10"),
                ArmyExercise(name: "Walking Lunge", sets: 3, reps: "10 each"),
                ArmyExercise(name: "Farmer Carry", sets: 5, duration: "30 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Upper Endurance 2",
            mode: .offDutyIndividual,
            focus: .upperEndurance,
            equipment: [.bodyweight, .gym],
            objective: "Increase pressing endurance and upper-body durability.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Hand-Release Push-Up", sets: 6, reps: "10"),
                ArmyExercise(name: "Incline Bench Press", sets: 4, reps: "10"),
                ArmyExercise(name: "Pull-Up", sets: 4, reps: "6-10"),
                ArmyExercise(name: "Shoulder Stability Drill", sets: 1, duration: "through sequence")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Core + Run 2",
            mode: .offDutyIndividual,
            focus: .coreRun,
            equipment: [.running],
            objective: "Blend plank-focused trunk endurance with tempo running.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Plank", sets: 4, duration: "75 sec"),
                ArmyExercise(name: "Bent-Leg Raise", sets: 3, reps: "12"),
                ArmyExercise(name: "Tempo Run", sets: 1, duration: "20 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Long Run 1",
            mode: .offDutyIndividual,
            focus: .endurance,
            equipment: [.running],
            objective: "Build aerobic endurance for the 2-mile run and recovery capacity.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Easy Run", sets: 1, duration: "35-45 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Speed Session 1",
            mode: .offDutyIndividual,
            focus: .endurance,
            equipment: [.running, .field],
            objective: "Improve pace and turnover.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Running Drill 3", sets: 1, duration: "as directed"),
                ArmyExercise(name: "Running Drill 4", sets: 1, duration: "as directed"),
                ArmyExercise(name: "200 m Intervals", sets: 8, duration: "hard"),
                ArmyExercise(name: "Walk Recovery", sets: 8, duration: "60 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Strength Circuit 1",
            mode: .offDutyIndividual,
            focus: .aftPrep,
            equipment: [.gym, .minimal],
            objective: "Use circuit sequencing for all-around Army readiness.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Strength Training Circuit Station 1", sets: 1, duration: "work through"),
                ArmyExercise(name: "Strength Training Circuit Station 2", sets: 1, duration: "work through"),
                ArmyExercise(name: "Strength Training Circuit Station 3", sets: 1, duration: "work through")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Tactical Carry Day",
            mode: .offDutyIndividual,
            focus: .tactical,
            equipment: [.field, .minimal],
            objective: "Build grip, trunk, and locomotion under load.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Farmer Carry", sets: 6, duration: "40 m"),
                ArmyExercise(name: "Backward Drag", sets: 4, duration: "25 m"),
                ArmyExercise(name: "Step-Up", sets: 4, reps: "10 each"),
                ArmyExercise(name: "Plank", sets: 3, duration: "60 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Recovery / Mobility 2",
            mode: .offDutyIndividual,
            focus: .recovery,
            equipment: [.bodyweight],
            objective: "Restore movement and unload fatigue.",
            warmup: ArmyDrillLibrary.pmcs,
            mainEffort: [
                ArmyExercise(name: "Recovery Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Hip Stability Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Shoulder Stability Drill", sets: 1, duration: "through sequence")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty AFT Hybrid 2",
            mode: .offDutyIndividual,
            focus: .aftPrep,
            equipment: [.gym, .running],
            objective: "Blend strength, push endurance, carries, core, and running in one session.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Trap Bar Deadlift", sets: 4, reps: "4"),
                ArmyExercise(name: "Hand-Release Push-Up", sets: 4, reps: "12"),
                ArmyExercise(name: "Farmer Carry", sets: 4, duration: "30 m"),
                ArmyExercise(name: "Plank", sets: 3, duration: "60 sec"),
                ArmyExercise(name: "800 m Run", sets: 2, duration: "hard, controlled")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),

        // NEW Off-Duty Individual (30 new)
        ArmyWorkoutTemplate(
            title: "Off-Duty Lower Strength 3",
            mode: .offDutyIndividual,
            focus: .lowerStrength,
            equipment: [.gym],
            objective: "Heavy posterior chain emphasis for max deadlift improvement.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Conventional Deadlift", sets: 5, reps: "3"),
                ArmyExercise(name: "Front Squat", sets: 4, reps: "6"),
                ArmyExercise(name: "Barbell Hip Thrust", sets: 4, reps: "8"),
                ArmyExercise(name: "Weighted Plank", sets: 3, duration: "45 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Lower Strength 4",
            mode: .offDutyIndividual,
            focus: .lowerStrength,
            equipment: [.gym, .minimal],
            objective: "Unilateral lower-body work for balanced strength development.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Single-Leg RDL", sets: 4, reps: "8 each"),
                ArmyExercise(name: "Bulgarian Split Squat", sets: 4, reps: "8 each"),
                ArmyExercise(name: "Step-Up with Weight", sets: 3, reps: "10 each"),
                ArmyExercise(name: "Calf Raise", sets: 3, reps: "15")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Lower Strength 5",
            mode: .offDutyIndividual,
            focus: .lowerStrength,
            equipment: [.gym],
            objective: "Squat-dominant session for quad and trunk strength.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Back Squat", sets: 5, reps: "5"),
                ArmyExercise(name: "Leg Press", sets: 4, reps: "10"),
                ArmyExercise(name: "Walking Lunge", sets: 3, reps: "12 each"),
                ArmyExercise(name: "Leg Curl", sets: 3, reps: "10")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Upper Endurance 3",
            mode: .offDutyIndividual,
            focus: .upperEndurance,
            equipment: [.gym],
            objective: "Volume pressing day for push-up carryover.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Flat Dumbbell Press", sets: 4, reps: "12"),
                ArmyExercise(name: "Hand-Release Push-Up", sets: 4, reps: "15"),
                ArmyExercise(name: "Cable Fly", sets: 3, reps: "12"),
                ArmyExercise(name: "Tricep Dip", sets: 3, reps: "10"),
                ArmyExercise(name: "Face Pull", sets: 3, reps: "15")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Upper Endurance 4",
            mode: .offDutyIndividual,
            focus: .upperEndurance,
            equipment: [.bodyweight, .gym],
            objective: "Pull-heavy session to balance pushing volume.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Pull-Up", sets: 5, reps: "6-8"),
                ArmyExercise(name: "Barbell Row", sets: 4, reps: "8"),
                ArmyExercise(name: "Push-Up", sets: 4, reps: "15"),
                ArmyExercise(name: "Rear Delt Fly", sets: 3, reps: "12")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Upper Endurance 5",
            mode: .offDutyIndividual,
            focus: .upperEndurance,
            equipment: [.bodyweight, .minimal],
            objective: "Bodyweight push-pull superset for sustained endurance.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Hand-Release Push-Up", sets: 5, reps: "12"),
                ArmyExercise(name: "Inverted Row", sets: 5, reps: "10"),
                ArmyExercise(name: "Diamond Push-Up", sets: 3, reps: "10"),
                ArmyExercise(name: "Chin-Up", sets: 3, reps: "6-8"),
                ArmyExercise(name: "Front Lean and Rest", sets: 3, duration: "30 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Work Capacity 1",
            mode: .offDutyIndividual,
            focus: .workCapacity,
            equipment: [.gym, .minimal],
            objective: "Gym-based circuit mimicking SDC energy demands.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Kettlebell Swing", sets: 5, reps: "15"),
                ArmyExercise(name: "Farmer Carry", sets: 5, duration: "40 m"),
                ArmyExercise(name: "Box Jump", sets: 4, reps: "8"),
                ArmyExercise(name: "Battle Rope", sets: 4, duration: "30 sec"),
                ArmyExercise(name: "Sled Push", sets: 4, duration: "25 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Work Capacity 2",
            mode: .offDutyIndividual,
            focus: .workCapacity,
            equipment: [.field, .minimal],
            objective: "Field-based interval circuit for anaerobic conditioning.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Sprint", sets: 6, duration: "40 m"),
                ArmyExercise(name: "Sandbag Carry", sets: 4, duration: "30 m"),
                ArmyExercise(name: "Backward Drag", sets: 4, duration: "25 m"),
                ArmyExercise(name: "Broad Jump", sets: 4, reps: "5"),
                ArmyExercise(name: "Bear Crawl", sets: 3, duration: "20 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Core + Run 3",
            mode: .offDutyIndividual,
            focus: .coreRun,
            equipment: [.running, .bodyweight],
            objective: "Alternating run and core blocks for trunk endurance under fatigue.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "800 m Run", sets: 1, duration: "moderate"),
                ArmyExercise(name: "Plank", sets: 1, duration: "90 sec"),
                ArmyExercise(name: "800 m Run", sets: 1, duration: "moderate-hard"),
                ArmyExercise(name: "Side Bridge", sets: 2, duration: "30 sec each"),
                ArmyExercise(name: "400 m Run", sets: 2, duration: "hard"),
                ArmyExercise(name: "Bent-Leg Raise", sets: 3, reps: "12")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Core + Run 4",
            mode: .offDutyIndividual,
            focus: .coreRun,
            equipment: [.running, .gym],
            objective: "Weighted core work followed by threshold running.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Weighted Plank", sets: 4, duration: "45 sec"),
                ArmyExercise(name: "Cable Woodchop", sets: 3, reps: "10 each"),
                ArmyExercise(name: "Ab Wheel Rollout", sets: 3, reps: "8"),
                ArmyExercise(name: "Tempo Run", sets: 1, duration: "15 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Long Run 2",
            mode: .offDutyIndividual,
            focus: .endurance,
            equipment: [.running],
            objective: "Extended aerobic base building at conversational pace.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Easy Run", sets: 1, duration: "45-55 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Speed Session 2",
            mode: .offDutyIndividual,
            focus: .endurance,
            equipment: [.running],
            objective: "Short hill repeats for power and running economy.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Hill Sprint", sets: 8, duration: "15-20 sec uphill"),
                ArmyExercise(name: "Walk Down Recovery", sets: 8, duration: "60 sec"),
                ArmyExercise(name: "Stride-Out on Flat", sets: 4, duration: "80 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Interval Run 1",
            mode: .offDutyIndividual,
            focus: .endurance,
            equipment: [.running],
            objective: "Classic 400 m interval session to lower 2-mile time.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "400 m Run", sets: 8, duration: "hard"),
                ArmyExercise(name: "Walk/Jog Recovery", sets: 8, duration: "90 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Fartlek Run 1",
            mode: .offDutyIndividual,
            focus: .endurance,
            equipment: [.running],
            objective: "Unstructured speed play for aerobic and anaerobic development.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Fartlek Run", sets: 1, duration: "25 min alternating 1 min hard / 2 min easy")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty AFT Hybrid 3",
            mode: .offDutyIndividual,
            focus: .aftPrep,
            equipment: [.gym, .running],
            objective: "Heavy strength paired with push endurance and a timed run effort.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Barbell Deadlift", sets: 4, reps: "3"),
                ArmyExercise(name: "Hand-Release Push-Up", sets: 5, reps: "12"),
                ArmyExercise(name: "Kettlebell Carry", sets: 4, duration: "40 m"),
                ArmyExercise(name: "Plank", sets: 3, duration: "75 sec"),
                ArmyExercise(name: "1-Mile Time Trial", sets: 1, duration: "best effort")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty AFT Hybrid 4",
            mode: .offDutyIndividual,
            focus: .aftPrep,
            equipment: [.gym, .field],
            objective: "Full-spectrum AFT session with gym and field components.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Trap Bar Deadlift", sets: 3, reps: "5"),
                ArmyExercise(name: "Push-Up", sets: 4, reps: "20"),
                ArmyExercise(name: "Sprint-Drag-Carry Simulation", sets: 3, duration: "1 round"),
                ArmyExercise(name: "Plank", sets: 3, duration: "90 sec"),
                ArmyExercise(name: "800 m Run", sets: 2, duration: "hard")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Strength Circuit 2",
            mode: .offDutyIndividual,
            focus: .aftPrep,
            equipment: [.gym],
            objective: "Rotate through strength stations for total-body conditioning.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Deadlift", sets: 3, reps: "5"),
                ArmyExercise(name: "Bench Press", sets: 3, reps: "8"),
                ArmyExercise(name: "Pull-Up", sets: 3, reps: "8"),
                ArmyExercise(name: "Overhead Press", sets: 3, reps: "8"),
                ArmyExercise(name: "Farmer Carry", sets: 3, duration: "30 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Tactical Carry Day 2",
            mode: .offDutyIndividual,
            focus: .tactical,
            equipment: [.field, .minimal],
            objective: "Loaded carry variations for grip, trunk, and locomotion.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Farmer Carry", sets: 4, duration: "40 m"),
                ArmyExercise(name: "Overhead Carry", sets: 4, duration: "30 m"),
                ArmyExercise(name: "Suitcase Carry", sets: 4, duration: "30 m each"),
                ArmyExercise(name: "Sandbag Carry", sets: 4, duration: "30 m"),
                ArmyExercise(name: "Bear Hug Carry", sets: 3, duration: "25 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Tactical Circuit 1",
            mode: .offDutyIndividual,
            focus: .tactical,
            equipment: [.gym, .field],
            objective: "High-effort conditioning circuit blending gym and field movements.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Kettlebell Swing", sets: 4, reps: "15"),
                ArmyExercise(name: "Box Jump", sets: 4, reps: "8"),
                ArmyExercise(name: "Push-Up", sets: 4, reps: "15"),
                ArmyExercise(name: "Sprint", sets: 4, duration: "30 m"),
                ArmyExercise(name: "Plank", sets: 3, duration: "45 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Push Day 1",
            mode: .offDutyIndividual,
            focus: .upperEndurance,
            equipment: [.gym],
            objective: "Dedicated pressing session for chest, shoulders, and triceps.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Bench Press", sets: 4, reps: "8"),
                ArmyExercise(name: "Overhead Press", sets: 4, reps: "8"),
                ArmyExercise(name: "Incline Dumbbell Press", sets: 3, reps: "10"),
                ArmyExercise(name: "Tricep Pushdown", sets: 3, reps: "12"),
                ArmyExercise(name: "Hand-Release Push-Up", sets: 3, reps: "AMRAP")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Pull Day 1",
            mode: .offDutyIndividual,
            focus: .upperEndurance,
            equipment: [.gym],
            objective: "Back and bicep focused session for pulling strength and posture.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Pull-Up", sets: 4, reps: "6-8"),
                ArmyExercise(name: "Barbell Row", sets: 4, reps: "8"),
                ArmyExercise(name: "Seated Cable Row", sets: 3, reps: "10"),
                ArmyExercise(name: "Face Pull", sets: 3, reps: "15"),
                ArmyExercise(name: "Barbell Curl", sets: 3, reps: "10")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Full Body 1",
            mode: .offDutyIndividual,
            focus: .aftPrep,
            equipment: [.gym],
            objective: "Efficient full-body session hitting all major patterns.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Trap Bar Deadlift", sets: 4, reps: "5"),
                ArmyExercise(name: "Dumbbell Bench Press", sets: 4, reps: "10"),
                ArmyExercise(name: "Pull-Up", sets: 4, reps: "8"),
                ArmyExercise(name: "Goblet Squat", sets: 3, reps: "10"),
                ArmyExercise(name: "Plank", sets: 3, duration: "60 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Full Body 2",
            mode: .offDutyIndividual,
            focus: .aftPrep,
            equipment: [.gym, .minimal],
            objective: "Balanced full-body training with dumbbell emphasis.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Dumbbell Deadlift", sets: 4, reps: "8"),
                ArmyExercise(name: "Dumbbell Overhead Press", sets: 4, reps: "8"),
                ArmyExercise(name: "Dumbbell Row", sets: 4, reps: "10 each"),
                ArmyExercise(name: "Dumbbell Lunge", sets: 3, reps: "10 each"),
                ArmyExercise(name: "Push-Up", sets: 3, reps: "15")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Work Capacity 3",
            mode: .offDutyIndividual,
            focus: .workCapacity,
            equipment: [.gym],
            objective: "Gym-based AMRAP for sustained high output.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Kettlebell Goblet Squat", sets: 1, reps: "15 per round, 4 rounds"),
                ArmyExercise(name: "Push-Up", sets: 1, reps: "12 per round, 4 rounds"),
                ArmyExercise(name: "Kettlebell Swing", sets: 1, reps: "15 per round, 4 rounds"),
                ArmyExercise(name: "Row (machine)", sets: 1, duration: "250 m per round, 4 rounds")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Recovery / Mobility 3",
            mode: .offDutyIndividual,
            focus: .recovery,
            equipment: [.bodyweight],
            objective: "Gentle full-body mobility and breathing reset.",
            warmup: ArmyDrillLibrary.pmcs,
            mainEffort: [
                ArmyExercise(name: "World's Greatest Stretch", sets: 2, reps: "5 each"),
                ArmyExercise(name: "Pigeon Stretch", sets: 2, duration: "45 sec each"),
                ArmyExercise(name: "Thoracic Rotation", sets: 2, reps: "8 each"),
                ArmyExercise(name: "Cat-Cow", sets: 2, reps: "10"),
                ArmyExercise(name: "Easy Walk", sets: 1, duration: "10 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Recovery / Mobility 4",
            mode: .offDutyIndividual,
            focus: .recovery,
            equipment: [.bodyweight],
            objective: "Foam rolling emphasis with light movement.",
            warmup: ArmyDrillLibrary.pmcs,
            mainEffort: [
                ArmyExercise(name: "Foam Roll Quads", sets: 1, duration: "2 min"),
                ArmyExercise(name: "Foam Roll Hamstrings", sets: 1, duration: "2 min"),
                ArmyExercise(name: "Foam Roll Upper Back", sets: 1, duration: "2 min"),
                ArmyExercise(name: "Hip Stability Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Easy Walk", sets: 1, duration: "15 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Leg + Sprint Day",
            mode: .offDutyIndividual,
            focus: .lowerStrength,
            equipment: [.gym, .running],
            objective: "Combine heavy legs with short sprint work for power transfer.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Back Squat", sets: 4, reps: "5"),
                ArmyExercise(name: "Romanian Deadlift", sets: 3, reps: "8"),
                ArmyExercise(name: "100 m Sprint", sets: 4, duration: "90% effort"),
                ArmyExercise(name: "Walk Recovery", sets: 4, duration: "90 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Off-Duty Kettlebell Session",
            mode: .offDutyIndividual,
            focus: .tactical,
            equipment: [.minimal],
            objective: "Full-body kettlebell session for functional strength and conditioning.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Kettlebell Swing", sets: 5, reps: "15"),
                ArmyExercise(name: "Goblet Squat", sets: 4, reps: "10"),
                ArmyExercise(name: "Kettlebell Press", sets: 4, reps: "8 each"),
                ArmyExercise(name: "Kettlebell Row", sets: 4, reps: "10 each"),
                ArmyExercise(name: "Turkish Get-Up", sets: 3, reps: "3 each")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
    ]

    // MARK: - Unit PT (35 total: 15 original + 20 new)
    static let unitPT: [ArmyWorkoutTemplate] = [
        ArmyWorkoutTemplate(
            title: "Unit PT AFT Prep 1",
            mode: .unitPT,
            focus: .aftPrep,
            equipment: [.field, .minimal],
            objective: "Prepare the formation for major AFT movement patterns.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Sprint Relay", sets: 4, duration: "50 m"),
                ArmyExercise(name: "Push-Up", sets: 4, reps: "15"),
                ArmyExercise(name: "Partner Carry / Carry Variation", sets: 4, duration: "30 m"),
                ArmyExercise(name: "Plank", sets: 3, duration: "45 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Platoon and below. Use lane discipline and rotate squads by station."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Endurance 1",
            mode: .unitPT,
            focus: .endurance,
            equipment: [.running, .field],
            objective: "Improve unit aerobic endurance and pacing discipline.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Formation Run", sets: 1, duration: "15-20 min"),
                ArmyExercise(name: "Stride Intervals", sets: 6, duration: "20 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Control pace. Keep cadence and accountability."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Conditioning 1",
            mode: .unitPT,
            focus: .tactical,
            equipment: [.field, .bodyweight],
            objective: "Build general work capacity in formation.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Conditioning Drill 1", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Conditioning Drill 2", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Shuttle Run", sets: 4, duration: "30 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Demo first, then execute by count."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Core and Mobility 1",
            mode: .unitPT,
            focus: .recovery,
            equipment: [.bodyweight],
            objective: "Emphasize trunk endurance and recovery.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: ArmyDrillLibrary.fourForCore + ArmyDrillLibrary.pmcs,
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Use for lower intensity or post-event recovery."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Military Movement 1",
            mode: .unitPT,
            focus: .tactical,
            equipment: [.field],
            objective: "Improve movement skill and short-burst effort.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Military Movement Drill 1", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Military Movement Drill 2", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Sprint", sets: 6, duration: "40 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Ensure spacing and lane control."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Running Drills Day",
            mode: .unitPT,
            focus: .endurance,
            equipment: [.running],
            objective: "Sharpen running mechanics and turnover.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Running Drill 1", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Running Drill 2", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Running Drill 3", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Running Drill 4", sets: 1, duration: "through sequence")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Focus on quality movement over fatigue."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Push-Up Focus",
            mode: .unitPT,
            focus: .upperEndurance,
            equipment: [.bodyweight],
            objective: "Build upper-body endurance in a simple formation session.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Push-Up", sets: 5, reps: "15"),
                ArmyExercise(name: "8-Count T Push-Up", sets: 3, reps: "8"),
                ArmyExercise(name: "Front Lean and Rest", sets: 3, duration: "30 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Watch form and trunk alignment."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Lower Body Strength",
            mode: .unitPT,
            focus: .lowerStrength,
            equipment: [.field, .minimal],
            objective: "Use simple movements to build leg and trunk strength.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Squat Bender", sets: 3, reps: "10"),
                ArmyExercise(name: "Forward Lunge", sets: 3, reps: "10 each"),
                ArmyExercise(name: "Step-Up", sets: 3, reps: "10 each"),
                ArmyExercise(name: "Farmer Carry", sets: 4, duration: "30 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Great on-duty field option."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Sprint Carry Circuit",
            mode: .unitPT,
            focus: .workCapacity,
            equipment: [.field, .minimal],
            objective: "Train short-duration moderate-to-high intensity effort.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Sprint", sets: 5, duration: "50 m"),
                ArmyExercise(name: "Backward Drag", sets: 5, duration: "25 m"),
                ArmyExercise(name: "Carry", sets: 5, duration: "25 m"),
                ArmyExercise(name: "Lateral Shuffle", sets: 5, duration: "25 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Mirror AFT work-capacity demands."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Recovery Formation",
            mode: .unitPT,
            focus: .recovery,
            equipment: [.bodyweight],
            objective: "Light formation recovery and maintenance.",
            warmup: ArmyDrillLibrary.pmcs,
            mainEffort: [
                ArmyExercise(name: "Hip Stability Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Shoulder Stability Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Recovery Drill", sets: 1, duration: "through sequence")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Use after harder field weeks or test events."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT AFT Hybrid 2",
            mode: .unitPT,
            focus: .aftPrep,
            equipment: [.field, .minimal],
            objective: "Simple platoon-ready hybrid PT session.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Partner Deadlift Variation", sets: 3, reps: "6"),
                ArmyExercise(name: "Push-Up", sets: 4, reps: "15"),
                ArmyExercise(name: "Shuttle Run", sets: 4, duration: "40 sec"),
                ArmyExercise(name: "Plank", sets: 3, duration: "45 sec"),
                ArmyExercise(name: "400 m Run", sets: 2, duration: "moderate")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Use cones and lane setup for clean execution."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Conditioning 2",
            mode: .unitPT,
            focus: .tactical,
            equipment: [.field],
            objective: "Use drill-based conditioning to keep execution simple.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Conditioning Drill 3", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Shuttle Sprint", sets: 6, duration: "20 sec"),
                ArmyExercise(name: "Push-Up", sets: 3, reps: "12")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Keep the session brief and high quality."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Core + Endurance 2",
            mode: .unitPT,
            focus: .coreRun,
            equipment: [.running, .bodyweight],
            objective: "Combine trunk work and easy endurance.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Four for the Core", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Easy Formation Run", sets: 1, duration: "15 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Ideal for lower-intensity midweek PT."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Strength Circuit 2",
            mode: .unitPT,
            focus: .lowerStrength,
            equipment: [.minimal, .field],
            objective: "Use station-based strength work for simple team rotation.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Carry Station", sets: 3, duration: "45 sec"),
                ArmyExercise(name: "Lunge Station", sets: 3, reps: "10 each"),
                ArmyExercise(name: "Push-Up Station", sets: 3, reps: "15"),
                ArmyExercise(name: "Core Station", sets: 3, duration: "45 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Assign squad leaders to stations."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Work Capacity 2",
            mode: .unitPT,
            focus: .workCapacity,
            equipment: [.field, .bodyweight],
            objective: "Build anaerobic capacity through short high-effort intervals.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Burpee", sets: 4, reps: "10"),
                ArmyExercise(name: "Sprint", sets: 6, duration: "40 m"),
                ArmyExercise(name: "Push-Up", sets: 4, reps: "12"),
                ArmyExercise(name: "Bear Crawl", sets: 4, duration: "20 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Use as a competition-style lane workout between squads."
        ),

        // NEW Unit PT (20 new)
        ArmyWorkoutTemplate(
            title: "Unit PT AFT Prep 2",
            mode: .unitPT,
            focus: .aftPrep,
            equipment: [.field, .minimal],
            objective: "Rotate through AFT domains in a formation-friendly circuit.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Deadlift Station", sets: 3, reps: "5"),
                ArmyExercise(name: "Push-Up Station", sets: 3, reps: "15"),
                ArmyExercise(name: "Carry Station", sets: 3, duration: "30 m"),
                ArmyExercise(name: "Plank Station", sets: 3, duration: "45 sec"),
                ArmyExercise(name: "200 m Run", sets: 3, duration: "moderate-hard")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Set 5 lanes. Squads rotate every 3 min. Track accountability."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT AFT Prep 3",
            mode: .unitPT,
            focus: .aftPrep,
            equipment: [.field],
            objective: "Partner-based AFT event practice with competitive element.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Partner Deadlift Variation", sets: 4, reps: "5"),
                ArmyExercise(name: "Hand-Release Push-Up", sets: 4, reps: "12"),
                ArmyExercise(name: "Partner Drag Race", sets: 4, duration: "25 m"),
                ArmyExercise(name: "Plank Hold Challenge", sets: 3, duration: "60 sec"),
                ArmyExercise(name: "300 m Shuttle", sets: 2, duration: "timed")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Pair Soldiers by similar fitness level for competitive element."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Endurance 2",
            mode: .unitPT,
            focus: .endurance,
            equipment: [.running],
            objective: "Interval running with formation accountability.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "400 m Run", sets: 6, duration: "moderate-hard"),
                ArmyExercise(name: "Walk/Jog Recovery", sets: 6, duration: "90 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Use a track or marked course. Call out split times."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Endurance 3",
            mode: .unitPT,
            focus: .endurance,
            equipment: [.running, .field],
            objective: "Progressive run building from easy to hard effort.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Easy Formation Run", sets: 1, duration: "5 min"),
                ArmyExercise(name: "Moderate Pace Run", sets: 1, duration: "5 min"),
                ArmyExercise(name: "Hard Effort Run", sets: 1, duration: "5 min"),
                ArmyExercise(name: "Cool-Down Jog", sets: 1, duration: "5 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Build progressively. No sprinting. Control the formation."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Conditioning 3",
            mode: .unitPT,
            focus: .tactical,
            equipment: [.field, .bodyweight],
            objective: "AMRAP-style conditioning in formation with simple movements.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Push-Up", sets: 1, reps: "10 per round"),
                ArmyExercise(name: "Air Squat", sets: 1, reps: "15 per round"),
                ArmyExercise(name: "Burpee", sets: 1, reps: "5 per round"),
                ArmyExercise(name: "Mountain Climber", sets: 1, reps: "20 per round"),
                ArmyExercise(name: "AMRAP", sets: 1, duration: "15 min total")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Count rounds per squad. Brief the standard before execution."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Conditioning 4",
            mode: .unitPT,
            focus: .tactical,
            equipment: [.field],
            objective: "Tabata-style intervals for maximum output in minimal time.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Push-Up", sets: 8, duration: "20 sec on / 10 sec off"),
                ArmyExercise(name: "Air Squat", sets: 8, duration: "20 sec on / 10 sec off"),
                ArmyExercise(name: "Flutter Kick", sets: 8, duration: "20 sec on / 10 sec off")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Use a timer. Keep the formation tight and loud."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Military Movement 2",
            mode: .unitPT,
            focus: .tactical,
            equipment: [.field],
            objective: "Extended movement drill session with agility emphasis.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "High Knee Run", sets: 4, duration: "25 m"),
                ArmyExercise(name: "Lateral Shuffle", sets: 4, duration: "25 m each"),
                ArmyExercise(name: "Crossover Run", sets: 4, duration: "25 m each"),
                ArmyExercise(name: "Backward Run", sets: 4, duration: "25 m"),
                ArmyExercise(name: "Sprint", sets: 4, duration: "50 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Use cones at 25 m intervals. Execute by squad."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Push-Up Focus 2",
            mode: .unitPT,
            focus: .upperEndurance,
            equipment: [.bodyweight],
            objective: "Push-up pyramid for volume and endurance development.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Push-Up Pyramid 2-4-6-8-10-8-6-4-2", sets: 1, reps: "pyramid"),
                ArmyExercise(name: "Hand-Release Push-Up", sets: 3, reps: "AMRAP 30 sec"),
                ArmyExercise(name: "Plank", sets: 3, duration: "45 sec"),
                ArmyExercise(name: "Prone Row", sets: 3, reps: "10")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Call the count. Enforce full lockout and chest-to-ground standard."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Upper + Core 1",
            mode: .unitPT,
            focus: .upperEndurance,
            equipment: [.bodyweight, .field],
            objective: "Combined upper-body and core session for trunk endurance.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Push-Up", sets: 4, reps: "15"),
                ArmyExercise(name: "8-Count T Push-Up", sets: 3, reps: "8"),
                ArmyExercise(name: "Plank", sets: 3, duration: "60 sec"),
                ArmyExercise(name: "Side Bridge", sets: 3, duration: "30 sec each"),
                ArmyExercise(name: "Flutter Kick", sets: 3, duration: "30 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Alternate between push and core exercises to manage fatigue."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Lower Body 2",
            mode: .unitPT,
            focus: .lowerStrength,
            equipment: [.field, .bodyweight],
            objective: "Bodyweight lower-body circuit for leg strength and stability.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Air Squat", sets: 4, reps: "20"),
                ArmyExercise(name: "Reverse Lunge", sets: 3, reps: "10 each"),
                ArmyExercise(name: "Lateral Lunge", sets: 3, reps: "8 each"),
                ArmyExercise(name: "Wall Sit", sets: 3, duration: "45 sec"),
                ArmyExercise(name: "Calf Raise", sets: 3, reps: "20")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "No equipment needed. Execute in extended rectangular formation."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Sprint Relay Day",
            mode: .unitPT,
            focus: .workCapacity,
            equipment: [.field],
            objective: "Sprint relay competition for team building and anaerobic capacity.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "50 m Sprint Relay", sets: 6, duration: "by squad"),
                ArmyExercise(name: "100 m Relay", sets: 4, duration: "by squad"),
                ArmyExercise(name: "Indian Run", sets: 1, duration: "10 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Competition between squads builds morale. Keep it safe and controlled."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Work Capacity 3",
            mode: .unitPT,
            focus: .workCapacity,
            equipment: [.field, .minimal],
            objective: "Lane-based circuit with carry, crawl, and sprint elements.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Sprint", sets: 4, duration: "50 m"),
                ArmyExercise(name: "Bear Crawl", sets: 4, duration: "25 m"),
                ArmyExercise(name: "Kettlebell Carry", sets: 4, duration: "50 m"),
                ArmyExercise(name: "Burpee", sets: 4, reps: "8"),
                ArmyExercise(name: "Lateral Shuffle", sets: 4, duration: "25 m each")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Set up 5-station lane. Rotate every 2 min."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Core + Endurance 3",
            mode: .unitPT,
            focus: .coreRun,
            equipment: [.running, .bodyweight],
            objective: "Run-core-run sandwich for trunk endurance under cardiovascular load.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Formation Run", sets: 1, duration: "8 min easy"),
                ArmyExercise(name: "Four for the Core", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Formation Run", sets: 1, duration: "8 min moderate"),
                ArmyExercise(name: "Plank", sets: 2, duration: "60 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Transition quickly between run and ground work."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Recovery Formation 2",
            mode: .unitPT,
            focus: .recovery,
            equipment: [.bodyweight],
            objective: "Extended recovery session for post-field or post-test weeks.",
            warmup: ArmyDrillLibrary.pmcs,
            mainEffort: [
                ArmyExercise(name: "Recovery Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Hip Stability Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Shoulder Stability Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Easy Walk", sets: 1, duration: "10 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Low intensity. Focus on accountability and joint health."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Running Intervals 1",
            mode: .unitPT,
            focus: .endurance,
            equipment: [.running],
            objective: "Formation interval run for aerobic power.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "800 m Run", sets: 4, duration: "moderate-hard"),
                ArmyExercise(name: "Walk Recovery", sets: 4, duration: "2 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Call target pace. Keep formation together on recovery."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Buddy Workout 1",
            mode: .unitPT,
            focus: .tactical,
            equipment: [.field, .bodyweight],
            objective: "Partner-based workout for teamwork and accountability.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Buddy Carry", sets: 4, duration: "25 m, then switch"),
                ArmyExercise(name: "Wheelbarrow Walk", sets: 3, duration: "15 m, then switch"),
                ArmyExercise(name: "Partner Push-Up Clap", sets: 3, reps: "10"),
                ArmyExercise(name: "Partner Sit-Up with Pass", sets: 3, reps: "12"),
                ArmyExercise(name: "Sprint", sets: 4, duration: "50 m together")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Pair by similar size and weight. Enforce safety on carries."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Strength Circuit 3",
            mode: .unitPT,
            focus: .lowerStrength,
            equipment: [.field, .minimal],
            objective: "Multi-station strength circuit for team rotation.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Goblet Squat Station", sets: 3, reps: "10"),
                ArmyExercise(name: "Push-Up Station", sets: 3, reps: "15"),
                ArmyExercise(name: "Kettlebell Swing Station", sets: 3, reps: "12"),
                ArmyExercise(name: "Plank Station", sets: 3, duration: "45 sec"),
                ArmyExercise(name: "Farmer Carry Station", sets: 3, duration: "30 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "5 stations, rotate every 90 sec. Brief all stations before start."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Running Drills + Sprint 1",
            mode: .unitPT,
            focus: .endurance,
            equipment: [.running, .field],
            objective: "Running drill technique followed by sprint application.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Running Drill 1", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Running Drill 2", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "100 m Sprint", sets: 6, duration: "controlled effort"),
                ArmyExercise(name: "Walk Recovery", sets: 6, duration: "60 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Drills teach mechanics. Sprints apply them. Keep quality high."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Plank + Carry Day",
            mode: .unitPT,
            focus: .coreRun,
            equipment: [.field, .minimal],
            objective: "Trunk and grip endurance for AFT plank and carry demands.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Plank", sets: 4, duration: "60 sec"),
                ArmyExercise(name: "Side Bridge", sets: 3, duration: "30 sec each"),
                ArmyExercise(name: "Farmer Carry", sets: 4, duration: "40 m"),
                ArmyExercise(name: "Overhead Carry", sets: 3, duration: "30 m"),
                ArmyExercise(name: "Back Bridge", sets: 3, duration: "30 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Alternate between static holds and loaded carries for recovery."
        ),
        ArmyWorkoutTemplate(
            title: "Unit PT Full Formation Circuit",
            mode: .unitPT,
            focus: .aftPrep,
            equipment: [.field, .bodyweight],
            objective: "Large-group circuit suitable for company-level PT.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Push-Up", sets: 3, reps: "15"),
                ArmyExercise(name: "Air Squat", sets: 3, reps: "20"),
                ArmyExercise(name: "Plank", sets: 3, duration: "45 sec"),
                ArmyExercise(name: "Sprint", sets: 3, duration: "50 m"),
                ArmyExercise(name: "Burpee", sets: 3, reps: "8"),
                ArmyExercise(name: "Mountain Climber", sets: 3, duration: "30 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill,
            leaderNotes: "Works for large formations. Keep it simple, loud, and disciplined."
        ),
    ]

    // MARK: - WOD (27 total: 7 original + 20 new)
    static let wodTemplates: [ArmyWorkoutTemplate] = [
        ArmyWorkoutTemplate(
            title: "WOD AFT Quick Hit 1",
            mode: .workoutOfDay,
            focus: .aftPrep,
            equipment: [.minimal, .field],
            objective: "Quick daily AFT touchpoint.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Deadlift", sets: 3, reps: "5"),
                ArmyExercise(name: "Push-Up", sets: 3, reps: "15"),
                ArmyExercise(name: "Plank", sets: 3, duration: "45 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Run Intervals 1",
            mode: .workoutOfDay,
            focus: .endurance,
            equipment: [.running],
            objective: "Fast run-focused session.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "200 m Run", sets: 6, duration: "hard"),
                ArmyExercise(name: "Walk Recovery", sets: 6, duration: "60 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Recovery Reset 1",
            mode: .workoutOfDay,
            focus: .recovery,
            equipment: [.bodyweight],
            objective: "Simple restoration day.",
            warmup: ArmyDrillLibrary.pmcs,
            mainEffort: [
                ArmyExercise(name: "Recovery Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Plank", sets: 2, duration: "30 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Tactical Circuit 1",
            mode: .workoutOfDay,
            focus: .tactical,
            equipment: [.field, .bodyweight],
            objective: "Short work-capacity effort.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Push-Up", sets: 4, reps: "12"),
                ArmyExercise(name: "Burpee", sets: 4, reps: "8"),
                ArmyExercise(name: "Shuttle Run", sets: 4, duration: "20 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Core + Carry 1",
            mode: .workoutOfDay,
            focus: .coreRun,
            equipment: [.minimal],
            objective: "Brief core and carry session.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Plank", sets: 4, duration: "45 sec"),
                ArmyExercise(name: "Farmer Carry", sets: 4, duration: "25 m"),
                ArmyExercise(name: "Bent-Leg Raise", sets: 3, reps: "10")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD AFT Quick Hit 2",
            mode: .workoutOfDay,
            focus: .aftPrep,
            equipment: [.field, .minimal],
            objective: "Short AFT prep variation.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Deadlift", sets: 3, reps: "3"),
                ArmyExercise(name: "Sprint-Drag-Carry Simulation", sets: 2, duration: "full round"),
                ArmyExercise(name: "Plank", sets: 3, duration: "60 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Run + Push 1",
            mode: .workoutOfDay,
            focus: .upperEndurance,
            equipment: [.running, .bodyweight],
            objective: "Simple run and push-up blend.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "800 m Run", sets: 2, duration: "steady"),
                ArmyExercise(name: "Hand-Release Push-Up", sets: 4, reps: "10")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),

        // NEW WOD (20 new)
        ArmyWorkoutTemplate(
            title: "WOD AFT Quick Hit 3",
            mode: .workoutOfDay,
            focus: .aftPrep,
            equipment: [.minimal, .field],
            objective: "Touch deadlift, push, and run in under 20 minutes.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Deadlift", sets: 3, reps: "5"),
                ArmyExercise(name: "Hand-Release Push-Up", sets: 3, reps: "12"),
                ArmyExercise(name: "400 m Run", sets: 2, duration: "moderate-hard")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD AFT Quick Hit 4",
            mode: .workoutOfDay,
            focus: .aftPrep,
            equipment: [.field, .minimal],
            objective: "Carry and core emphasis for AFT maintenance.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Farmer Carry", sets: 4, duration: "40 m"),
                ArmyExercise(name: "Plank", sets: 4, duration: "60 sec"),
                ArmyExercise(name: "Sprint", sets: 4, duration: "30 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Lower Quick Hit",
            mode: .workoutOfDay,
            focus: .lowerStrength,
            equipment: [.minimal, .gym],
            objective: "Quick lower-body session for deadlift maintenance.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Goblet Squat", sets: 3, reps: "10"),
                ArmyExercise(name: "Romanian Deadlift", sets: 3, reps: "8"),
                ArmyExercise(name: "Glute Bridge", sets: 3, reps: "12")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Upper Quick Hit",
            mode: .workoutOfDay,
            focus: .upperEndurance,
            equipment: [.bodyweight],
            objective: "Fast push-up endurance session.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Hand-Release Push-Up", sets: 5, reps: "10"),
                ArmyExercise(name: "Plank to Push-Up", sets: 3, reps: "8"),
                ArmyExercise(name: "Prone Row", sets: 3, reps: "10")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Run Intervals 2",
            mode: .workoutOfDay,
            focus: .endurance,
            equipment: [.running],
            objective: "Short sharp intervals for pace improvement.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "400 m Run", sets: 4, duration: "hard"),
                ArmyExercise(name: "Walk Recovery", sets: 4, duration: "90 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Easy Endurance",
            mode: .workoutOfDay,
            focus: .endurance,
            equipment: [.running],
            objective: "Low-intensity steady-state for aerobic base.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Easy Run", sets: 1, duration: "20-25 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Tactical Circuit 2",
            mode: .workoutOfDay,
            focus: .tactical,
            equipment: [.field, .bodyweight],
            objective: "Bodyweight circuit for sustained effort.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Air Squat", sets: 4, reps: "20"),
                ArmyExercise(name: "Push-Up", sets: 4, reps: "15"),
                ArmyExercise(name: "Mountain Climber", sets: 4, duration: "30 sec"),
                ArmyExercise(name: "Sprint", sets: 4, duration: "30 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Tactical Circuit 3",
            mode: .workoutOfDay,
            focus: .tactical,
            equipment: [.bodyweight],
            objective: "Minimal-space bodyweight conditioning.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Burpee", sets: 5, reps: "8"),
                ArmyExercise(name: "Push-Up", sets: 5, reps: "12"),
                ArmyExercise(name: "Plank", sets: 3, duration: "45 sec"),
                ArmyExercise(name: "Flutter Kick", sets: 3, duration: "30 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Core + Carry 2",
            mode: .workoutOfDay,
            focus: .coreRun,
            equipment: [.minimal, .field],
            objective: "Core holds paired with loaded carries.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Plank", sets: 3, duration: "60 sec"),
                ArmyExercise(name: "Suitcase Carry", sets: 3, duration: "30 m each"),
                ArmyExercise(name: "Side Bridge", sets: 3, duration: "30 sec each"),
                ArmyExercise(name: "Overhead Carry", sets: 3, duration: "25 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Work Capacity 1",
            mode: .workoutOfDay,
            focus: .workCapacity,
            equipment: [.field, .bodyweight],
            objective: "Quick anaerobic burst session.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Sprint", sets: 6, duration: "40 m"),
                ArmyExercise(name: "Bear Crawl", sets: 3, duration: "15 m"),
                ArmyExercise(name: "Burpee", sets: 3, reps: "8")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Work Capacity 2",
            mode: .workoutOfDay,
            focus: .workCapacity,
            equipment: [.field, .minimal],
            objective: "Carry-heavy work capacity session.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Farmer Carry", sets: 5, duration: "30 m"),
                ArmyExercise(name: "Sprint", sets: 5, duration: "30 m"),
                ArmyExercise(name: "Backward Drag", sets: 4, duration: "20 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Recovery Reset 2",
            mode: .workoutOfDay,
            focus: .recovery,
            equipment: [.bodyweight],
            objective: "Light mobility and stability focus.",
            warmup: ArmyDrillLibrary.pmcs,
            mainEffort: [
                ArmyExercise(name: "Hip Stability Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Shoulder Stability Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Easy Walk", sets: 1, duration: "10 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Run + Core 1",
            mode: .workoutOfDay,
            focus: .coreRun,
            equipment: [.running, .bodyweight],
            objective: "Quick run and core combination.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "400 m Run", sets: 3, duration: "moderate-hard"),
                ArmyExercise(name: "Plank", sets: 3, duration: "45 sec"),
                ArmyExercise(name: "Bent-Leg Raise", sets: 3, reps: "10")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Conditioning Drill Day",
            mode: .workoutOfDay,
            focus: .tactical,
            equipment: [.bodyweight, .field],
            objective: "Army conditioning drills as the main effort.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Conditioning Drill 1", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Conditioning Drill 2", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Sprint", sets: 4, duration: "30 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Push + Sprint 1",
            mode: .workoutOfDay,
            focus: .upperEndurance,
            equipment: [.bodyweight, .field],
            objective: "Alternate pushing and sprinting for conditioning.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Push-Up", sets: 5, reps: "12"),
                ArmyExercise(name: "Sprint", sets: 5, duration: "40 m"),
                ArmyExercise(name: "Plank", sets: 3, duration: "30 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Squat + Run 1",
            mode: .workoutOfDay,
            focus: .lowerStrength,
            equipment: [.bodyweight, .running],
            objective: "Lower-body and running combo for quick training effect.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Air Squat", sets: 4, reps: "20"),
                ArmyExercise(name: "200 m Run", sets: 4, duration: "moderate-hard"),
                ArmyExercise(name: "Lunge", sets: 3, reps: "10 each")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Movement Quality",
            mode: .workoutOfDay,
            focus: .tactical,
            equipment: [.field],
            objective: "Focus on clean movement patterns at moderate intensity.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Military Movement Drill 1", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "High Knee Run", sets: 4, duration: "25 m"),
                ArmyExercise(name: "Lateral Shuffle", sets: 4, duration: "25 m each"),
                ArmyExercise(name: "Sprint", sets: 4, duration: "40 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Plank Challenge",
            mode: .workoutOfDay,
            focus: .coreRun,
            equipment: [.bodyweight],
            objective: "Max plank endurance session with accessory core work.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Plank", sets: 1, duration: "max hold"),
                ArmyExercise(name: "Side Bridge", sets: 3, duration: "30 sec each"),
                ArmyExercise(name: "Back Bridge", sets: 3, duration: "30 sec"),
                ArmyExercise(name: "Plank", sets: 2, duration: "45 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "WOD Full Body Blast",
            mode: .workoutOfDay,
            focus: .aftPrep,
            equipment: [.bodyweight, .field],
            objective: "Hit every major pattern in one fast session.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Air Squat", sets: 3, reps: "15"),
                ArmyExercise(name: "Push-Up", sets: 3, reps: "15"),
                ArmyExercise(name: "Plank", sets: 3, duration: "45 sec"),
                ArmyExercise(name: "Sprint", sets: 3, duration: "40 m"),
                ArmyExercise(name: "Burpee", sets: 3, reps: "8")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
    ]

    // MARK: - Random (18 total: 8 original + 10 new)
    static let randomTemplates: [ArmyWorkoutTemplate] = [
        ArmyWorkoutTemplate(
            title: "Random Session Lower 1",
            mode: .randomSession,
            focus: .lowerStrength,
            equipment: [.minimal, .gym],
            objective: "Random lower-body strength day.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Goblet Squat", sets: 4, reps: "8"),
                ArmyExercise(name: "Romanian Deadlift", sets: 4, reps: "8"),
                ArmyExercise(name: "Lunge", sets: 3, reps: "10 each")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Upper 1",
            mode: .randomSession,
            focus: .upperEndurance,
            equipment: [.bodyweight, .gym],
            objective: "Random upper-body endurance day.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Hand-Release Push-Up", sets: 4, reps: "12"),
                ArmyExercise(name: "Pull-Up", sets: 4, reps: "6-8"),
                ArmyExercise(name: "Shoulder Stability Drill", sets: 1, duration: "through sequence")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Work Capacity 1",
            mode: .randomSession,
            focus: .workCapacity,
            equipment: [.field, .minimal],
            objective: "Random work-capacity session.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Sprint", sets: 5, duration: "40 m"),
                ArmyExercise(name: "Drag", sets: 4, duration: "20 m"),
                ArmyExercise(name: "Carry", sets: 4, duration: "20 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Core Run 1",
            mode: .randomSession,
            focus: .coreRun,
            equipment: [.running, .bodyweight],
            objective: "Random core and run day.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Plank", sets: 4, duration: "60 sec"),
                ArmyExercise(name: "400 m Run", sets: 4, duration: "steady-hard")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Recovery 1",
            mode: .randomSession,
            focus: .recovery,
            equipment: [.bodyweight],
            objective: "Random recovery session.",
            warmup: ArmyDrillLibrary.pmcs,
            mainEffort: [
                ArmyExercise(name: "Hip Stability Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Recovery Drill", sets: 1, duration: "through sequence")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Tactical 2",
            mode: .randomSession,
            focus: .tactical,
            equipment: [.field],
            objective: "Field-friendly random tactical day.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Military Movement Drill 1", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Conditioning Drill 1", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Shuttle Run", sets: 5, duration: "20 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Endurance 2",
            mode: .randomSession,
            focus: .endurance,
            equipment: [.running],
            objective: "Another endurance variation.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Tempo Run", sets: 1, duration: "15-20 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Strength 2",
            mode: .randomSession,
            focus: .lowerStrength,
            equipment: [.gym, .minimal],
            objective: "Another strength variation.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Trap Bar Deadlift", sets: 5, reps: "3"),
                ArmyExercise(name: "Step-Up", sets: 3, reps: "10 each"),
                ArmyExercise(name: "Farmer Carry", sets: 4, duration: "30 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),

        // NEW Random (10 new)
        ArmyWorkoutTemplate(
            title: "Random Session Lower 2",
            mode: .randomSession,
            focus: .lowerStrength,
            equipment: [.gym],
            objective: "Barbell-focused lower session for max strength development.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Back Squat", sets: 4, reps: "5"),
                ArmyExercise(name: "Barbell Hip Thrust", sets: 3, reps: "8"),
                ArmyExercise(name: "Walking Lunge", sets: 3, reps: "10 each"),
                ArmyExercise(name: "Calf Raise", sets: 3, reps: "15")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Upper 2",
            mode: .randomSession,
            focus: .upperEndurance,
            equipment: [.gym, .bodyweight],
            objective: "Push and pull superset for balanced upper-body development.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Bench Press", sets: 4, reps: "8"),
                ArmyExercise(name: "Barbell Row", sets: 4, reps: "8"),
                ArmyExercise(name: "Push-Up", sets: 3, reps: "15"),
                ArmyExercise(name: "Face Pull", sets: 3, reps: "15")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Work Capacity 2",
            mode: .randomSession,
            focus: .workCapacity,
            equipment: [.field, .bodyweight],
            objective: "Bodyweight AMRAP for work capacity and mental toughness.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Burpee", sets: 1, reps: "8 per round"),
                ArmyExercise(name: "Air Squat", sets: 1, reps: "15 per round"),
                ArmyExercise(name: "Push-Up", sets: 1, reps: "12 per round"),
                ArmyExercise(name: "AMRAP", sets: 1, duration: "12 min total")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Core Run 2",
            mode: .randomSession,
            focus: .coreRun,
            equipment: [.running, .bodyweight],
            objective: "Run-core alternating blocks.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "800 m Run", sets: 2, duration: "moderate"),
                ArmyExercise(name: "Plank", sets: 2, duration: "75 sec"),
                ArmyExercise(name: "Side Bridge", sets: 2, duration: "30 sec each"),
                ArmyExercise(name: "400 m Run", sets: 2, duration: "hard")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Recovery 2",
            mode: .randomSession,
            focus: .recovery,
            equipment: [.bodyweight],
            objective: "Full-body mobility and reset session.",
            warmup: ArmyDrillLibrary.pmcs,
            mainEffort: [
                ArmyExercise(name: "World's Greatest Stretch", sets: 2, reps: "5 each"),
                ArmyExercise(name: "Cat-Cow", sets: 2, reps: "10"),
                ArmyExercise(name: "Hip Stability Drill", sets: 1, duration: "through sequence"),
                ArmyExercise(name: "Easy Walk", sets: 1, duration: "10 min")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Tactical 3",
            mode: .randomSession,
            focus: .tactical,
            equipment: [.field, .bodyweight],
            objective: "Mixed conditioning with crawls and carries.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Bear Crawl", sets: 4, duration: "20 m"),
                ArmyExercise(name: "Sprint", sets: 4, duration: "40 m"),
                ArmyExercise(name: "Buddy Carry", sets: 3, duration: "25 m"),
                ArmyExercise(name: "Push-Up", sets: 3, reps: "15")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Endurance 3",
            mode: .randomSession,
            focus: .endurance,
            equipment: [.running],
            objective: "Progressive run with descending intervals.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "800 m Run", sets: 1, duration: "moderate"),
                ArmyExercise(name: "600 m Run", sets: 1, duration: "moderate-hard"),
                ArmyExercise(name: "400 m Run", sets: 1, duration: "hard"),
                ArmyExercise(name: "200 m Run", sets: 1, duration: "near max"),
                ArmyExercise(name: "Walk Recovery", sets: 4, duration: "90 sec between efforts")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session AFT Prep 1",
            mode: .randomSession,
            focus: .aftPrep,
            equipment: [.field, .minimal],
            objective: "Random AFT-focused session across all domains.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Deadlift", sets: 3, reps: "5"),
                ArmyExercise(name: "Push-Up", sets: 3, reps: "15"),
                ArmyExercise(name: "Carry", sets: 3, duration: "30 m"),
                ArmyExercise(name: "Plank", sets: 3, duration: "45 sec"),
                ArmyExercise(name: "200 m Run", sets: 3, duration: "hard")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Kettlebell 1",
            mode: .randomSession,
            focus: .tactical,
            equipment: [.minimal],
            objective: "Kettlebell-only session for functional conditioning.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Kettlebell Swing", sets: 5, reps: "15"),
                ArmyExercise(name: "Goblet Squat", sets: 4, reps: "10"),
                ArmyExercise(name: "Kettlebell Press", sets: 3, reps: "8 each"),
                ArmyExercise(name: "Farmer Carry", sets: 4, duration: "30 m")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
        ArmyWorkoutTemplate(
            title: "Random Session Strength 3",
            mode: .randomSession,
            focus: .lowerStrength,
            equipment: [.gym],
            objective: "Deadlift emphasis with accessory pulling.",
            warmup: ArmyDrillLibrary.prepDrill,
            mainEffort: [
                ArmyExercise(name: "Conventional Deadlift", sets: 5, reps: "3"),
                ArmyExercise(name: "Pull-Up", sets: 4, reps: "6-8"),
                ArmyExercise(name: "Single-Leg RDL", sets: 3, reps: "8 each"),
                ArmyExercise(name: "Plank", sets: 3, duration: "60 sec")
            ],
            cooldown: ArmyDrillLibrary.recoveryDrill
        ),
    ]
}
