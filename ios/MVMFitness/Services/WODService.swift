import Foundation

enum WODService {

    private static let lastWODKey = "lastWODTitle"
    private static let lastWODDateKey = "lastWODDate"

    static func generateWOD(
        equipment: EquipmentOption = .bodyweight,
        dutyType: DutyType = .both,
        heroOnly: Bool = false
    ) -> WODTemplate {
        let lastTitle = UserDefaults.standard.string(forKey: lastWODKey)

        let selected: WODTemplate
        if heroOnly {
            let elitePool = HeroWODLibrary.heroWODs.filter { $0.title != lastTitle }
            selected = elitePool.randomElement() ?? HeroWODLibrary.heroWODs.randomElement() ?? HeroWODLibrary.heroWODs[0]
        } else {
            let pool = filteredPool(equipment: equipment, excluding: lastTitle)
            selected = pool.randomElement() ?? WODTemplateLibrary.allTemplates.randomElement() ?? WODTemplateLibrary.functionalWODs[0]
        }

        UserDefaults.standard.set(selected.title, forKey: lastWODKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastWODDateKey)

        return selected
    }

    static func generateHeroWOD() -> WODTemplate {
        let lastTitle = UserDefaults.standard.string(forKey: lastWODKey)
        let pool = HeroWODLibrary.heroWODs.filter { $0.title != lastTitle }
        let selected = pool.randomElement() ?? HeroWODLibrary.heroWODs.randomElement() ?? HeroWODLibrary.heroWODs[0]
        UserDefaults.standard.set(selected.title, forKey: lastWODKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastWODDateKey)
        return selected
    }

    static func convertToWorkoutDay(_ template: WODTemplate) -> WorkoutDay {
        var exercises: [WorkoutExercise] = []

        for movement in template.movements {
            let exercise = convertMovement(movement)
            exercises.append(exercise)
        }

        var tags = [template.category.rawValue, template.format.rawValue]
        if template.equipment != .none {
            tags.append(template.equipment.rawValue)
        }

        return WorkoutDay(
            dayIndex: -1,
            date: Calendar.current.startOfDay(for: .now),
            title: template.title,
            exercises: exercises,
            templateTag: "wod_\(template.title)",
            tags: tags
        )
    }

    private static func filteredPool(equipment: EquipmentOption, excluding lastTitle: String?) -> [WODTemplate] {
        let wodEquipment: Set<WODEquipment>
        switch equipment {
        case .gym:
            wodEquipment = [.none, .minimal, .gym]
        case .minimal, .field:
            wodEquipment = [.none, .minimal]
        default:
            wodEquipment = [.none]
        }

        return WODTemplateLibrary.allTemplates.filter {
            wodEquipment.contains($0.equipment) && $0.title != lastTitle
        }
    }

    private static func convertMovement(_ movement: WODMovement) -> WorkoutExercise {
        let sets = 1
        var reps = 0
        var durationSeconds = 0
        var category: ExerciseCategory = .bodyweight
        var notes = movement.notes ?? ""
        var cardioType: CardioType?

        let nameLower = movement.name.lowercased()

        if nameLower.contains("run") || nameLower.contains("sprint") || nameLower.contains("jog") || nameLower.contains("shuttle") {
            category = .cardio
            cardioType = .run
        } else if nameLower.contains("walk") {
            category = .cardio
            cardioType = .walk
        }

        if let repsStr = movement.reps {
            if repsStr.contains("-") && !repsStr.contains("each") {
                notes = notes.isEmpty ? repsStr : "\(repsStr). \(notes)"
                let parts = repsStr.split(separator: "-")
                reps = Int(parts.first ?? "10") ?? 10
            } else {
                let cleaned = repsStr.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                reps = Int(cleaned) ?? 0
                if reps == 0 {
                    notes = notes.isEmpty ? repsStr : "\(repsStr). \(notes)"
                    reps = 1
                }
            }
        }

        if let durStr = movement.duration {
            if durStr.contains("sec") {
                let cleaned = durStr.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                durationSeconds = Int(cleaned) ?? 30
                reps = 0
                if category != .cardio { category = .timed }
            } else if durStr.contains("min") {
                let cleaned = durStr.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                durationSeconds = (Int(cleaned) ?? 1) * 60
                reps = 0
                if category != .cardio { category = .timed }
            } else if durStr.contains("m") {
                notes = notes.isEmpty ? durStr : "\(durStr). \(notes)"
                if reps == 0 { reps = 1 }
            } else {
                notes = notes.isEmpty ? durStr : "\(durStr). \(notes)"
                if reps == 0 { reps = 1 }
            }
        }

        if reps == 0 && durationSeconds == 0 {
            durationSeconds = 30
            if category != .cardio { category = .timed }
        }

        if nameLower.contains("deadlift") || nameLower.contains("squat") && nameLower.contains("goblet") ||
           nameLower.contains("press") || nameLower.contains("row") || nameLower.contains("clean") ||
           nameLower.contains("thrust") || nameLower.contains("hip bridge") || nameLower.contains("hip thrust") ||
           nameLower.contains("calf raise") || nameLower.contains("good morning") {
            if category != .cardio { category = .strength }
        }

        return WorkoutExercise(
            name: movement.name,
            sets: sets,
            reps: reps,
            durationSeconds: durationSeconds,
            notes: notes,
            category: category,
            cardioType: cardioType
        )
    }
}
