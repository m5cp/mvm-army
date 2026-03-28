import Foundation

enum ArmyTemplateLibrary {
    static let templates: [ArmyWorkoutTemplate] = [
        // MARK: 1-10 On-Duty Individual
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

        // MARK: 11-20 Off-Duty Individual
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

        // MARK: 21-35 Unit PT
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

        // MARK: 36-50 WOD / Random
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
        )
    ]
}
