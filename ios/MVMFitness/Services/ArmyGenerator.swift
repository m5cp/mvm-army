import Foundation

enum ArmyGenerator {

    static func templates(
        mode: ArmyWorkoutMode,
        focus: ArmyFocus,
        equipment: ArmyEquipment
    ) -> [ArmyWorkoutTemplate] {
        ArmyTemplateLibrary.templates.filter {
            $0.mode == mode &&
            $0.focus == focus &&
            $0.equipment.contains(equipment)
        }
    }

    static func nextTemplate(
        mode: ArmyWorkoutMode,
        focus: ArmyFocus,
        equipment: ArmyEquipment,
        excluding lastTitle: String?
    ) -> ArmyWorkoutTemplate? {
        let pool = templates(mode: mode, focus: focus, equipment: equipment)
            .filter { $0.title != lastTitle }
        if let result = pool.randomElement() { return result }
        let fallback = ArmyTemplateLibrary.templates.filter {
            $0.mode == mode && $0.equipment.contains(equipment) && $0.title != lastTitle
        }
        if let result = fallback.randomElement() { return result }
        return ArmyTemplateLibrary.templates.filter { $0.mode == mode }.randomElement()
    }

    static func weeklyPlan(
        mode: ArmyWorkoutMode,
        focuses: [ArmyFocus],
        equipment: ArmyEquipment,
        days: Int
    ) -> [ArmyWorkoutTemplate] {
        var output: [ArmyWorkoutTemplate] = []
        var lastTitle: String?

        for index in 0..<days {
            let focus = focuses[index % focuses.count]
            if let next = nextTemplate(mode: mode, focus: focus, equipment: equipment, excluding: lastTitle) {
                output.append(next)
                lastTitle = next.title
            }
        }

        return output
    }

    static func mapArmyEquipment(_ option: EquipmentOption) -> ArmyEquipment {
        switch option {
        case .bodyweight: return .bodyweight
        case .minimal: return .minimal
        case .gym: return .gym
        case .running: return .running
        case .field: return .field
        }
    }

    static func mapArmyFocuses(_ focus: TrainingFocus) -> [ArmyFocus] {
        switch focus {
        case .aftPrep:
            return [.lowerStrength, .upperEndurance, .workCapacity, .coreRun, .aftPrep, .endurance]
        case .strength:
            return [.lowerStrength, .upperEndurance, .lowerStrength, .workCapacity, .coreRun]
        case .endurance:
            return [.endurance, .coreRun, .endurance, .recovery, .endurance]
        case .tacticalConditioning:
            return [.tactical, .workCapacity, .tactical, .endurance, .coreRun]
        case .recovery:
            return [.recovery, .coreRun, .recovery, .endurance, .recovery]
        case .generalArmyFitness:
            return [.aftPrep, .endurance, .tactical, .lowerStrength, .upperEndurance, .coreRun]
        }
    }

    static func mapArmyMode(ptMode: PTMode, dutyType: DutyType) -> ArmyWorkoutMode {
        switch ptMode {
        case .unit:
            return .unitPT
        case .individual, .both:
            switch dutyType {
            case .onDuty: return .onDutyIndividual
            case .offDuty: return .offDutyIndividual
            case .both: return .onDutyIndividual
            }
        }
    }

    static func convertToWorkoutExercises(_ template: ArmyWorkoutTemplate) -> [WorkoutExercise] {
        var exercises: [WorkoutExercise] = []

        let warmupText = template.warmup.map { ex in
            "\(ex.name)\(ex.reps.map { " — \($0)" } ?? "")\(ex.duration.map { " — \($0)" } ?? "")"
        }.joined(separator: ", ")

        exercises.append(WorkoutExercise(
            name: "Preparation Drill",
            sets: 1,
            durationSeconds: 300,
            notes: warmupText.isEmpty ? "PD: 10 exercises, 5 reps each" : String(warmupText.prefix(200)),
            category: .timed
        ))

        for armyEx in template.mainEffort {
            let ex = convertArmyExercise(armyEx)
            exercises.append(ex)
        }

        exercises.append(WorkoutExercise(
            name: "Recovery Drill",
            sets: 1,
            durationSeconds: 240,
            notes: "RD: Overhead Arm Pull, Rear Lunge, Extend and Flex, Thigh Stretch, Single-Leg Over",
            category: .timed
        ))

        return exercises
    }

    static func convertArmyExercise(_ armyEx: ArmyExercise) -> WorkoutExercise {
        let sets = armyEx.sets ?? 1
        var reps = 0
        var durationSeconds = 0
        var category: ExerciseCategory = .strength
        var notes = armyEx.notes ?? ""
        var cardioType: CardioType?

        if let repsStr = armyEx.reps {
            let cleaned = repsStr.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            reps = Int(cleaned) ?? 0
            if reps == 0 {
                notes = notes.isEmpty ? repsStr : "\(repsStr). \(notes)"
                reps = 1
            }
        }

        if let durStr = armyEx.duration {
            let name = armyEx.name.lowercased()
            if name.contains("run") || name.contains("sprint") || name.contains("jog") ||
               name.contains("shuffle") || name.contains("shuttle") {
                category = .cardio
                cardioType = .run
            } else if name.contains("walk") {
                category = .cardio
                cardioType = .walk
            } else {
                category = .timed
            }

            if durStr.contains("sec") {
                let cleaned = durStr.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                durationSeconds = Int(cleaned) ?? 30
            } else if durStr.contains("min") {
                let cleaned = durStr.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                durationSeconds = (Int(cleaned) ?? 1) * 60
            } else if durStr.contains("m") && !durStr.contains("min") {
                notes = notes.isEmpty ? durStr : "\(durStr). \(notes)"
                durationSeconds = 30
            } else {
                notes = notes.isEmpty ? durStr : "\(durStr). \(notes)"
                durationSeconds = 30
            }

            reps = 0
        }

        if reps == 0 && durationSeconds == 0 {
            if let durStr = armyEx.duration {
                notes = notes.isEmpty ? durStr : "\(durStr). \(notes)"
            }
            durationSeconds = 30
            category = .timed
        }

        let name = armyEx.name.lowercased()
        if category == .strength {
            if name.contains("push-up") || name.contains("plank") || name.contains("burpee") ||
               name.contains("squat") && !name.contains("goblet") || name.contains("lunge") && !name.contains("walking") ||
               name.contains("body twist") || name.contains("stability") || name.contains("bridge") ||
               name.contains("raise") || name.contains("quadraplex") || name.contains("dead bug") ||
               name.contains("bird dog") || name.contains("flutter") || name.contains("hollow") {
                category = .bodyweight
            }
        }

        return WorkoutExercise(
            name: armyEx.name,
            sets: sets,
            reps: reps,
            durationSeconds: durationSeconds,
            notes: notes,
            category: category,
            cardioType: cardioType
        )
    }

    static func convertToUnitPTPlan(_ template: ArmyWorkoutTemplate) -> UnitPTPlan {
        let warmupText = template.warmup.map { ex in
            "\(ex.name)\(ex.reps.map { " — \($0)" } ?? "")\(ex.duration.map { " — \($0)" } ?? "")"
        }.joined(separator: "\n")

        let cooldownText = template.cooldown.map { ex in
            "\(ex.name)\(ex.duration.map { " — \($0)" } ?? "")"
        }.joined(separator: "\n")

        let blocks = template.mainEffort.map { ex in
            var desc = ex.name
            if let sets = ex.sets { desc += " — \(sets) sets" }
            if let reps = ex.reps { desc += " x \(reps)" }
            if let dur = ex.duration { desc += " (\(dur))" }
            if let notes = ex.notes, !notes.isEmpty { desc += ". \(notes)" }
            return UnitPTBlock(desc)
        }

        let equipmentText = template.equipment.map(\.rawValue).joined(separator: ", ")

        return UnitPTPlan(
            title: template.title,
            objective: template.objective,
            formationNotes: "Form up by squad in extended rectangular formation. Conduct accountability, safety brief, and session overview. Designate lane NCOs for station-based work.",
            equipment: equipmentText.isEmpty ? "Cones, timer, water source" : "Cones, timer, water source. \(equipmentText) as available.",
            warmup: warmupText.isEmpty ? "Preparation Drill (PD): 10 exercises, 5 reps each" : warmupText,
            mainEffort: blocks,
            cooldown: cooldownText.isEmpty ? "Recovery Drill (RD): Full sequence" : cooldownText,
            leaderNotes: template.leaderNotes ?? "Maintain lane assignments and keep transitions tight. Monitor form on all lifts. Adjust intensity for ability groups as needed."
        )
    }
}
