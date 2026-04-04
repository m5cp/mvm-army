import Foundation

enum ArmyPTExerciseLibrary {
    static let allExercises: [String] = {
        var names = Set<String>()

        for ex in ArmyDrillLibrary.prepDrill { names.insert(ex.name) }
        for ex in ArmyDrillLibrary.fourForCore { names.insert(ex.name) }
        for ex in ArmyDrillLibrary.recoveryDrill { names.insert(ex.name) }
        for ex in ArmyDrillLibrary.pmcs { names.insert(ex.name) }

        for template in ArmyTemplateLibrary.templates {
            for ex in template.warmup { names.insert(ex.name) }
            for ex in template.mainEffort { names.insert(ex.name) }
            for ex in template.cooldown { names.insert(ex.name) }
        }

        return names.sorted()
    }()

    static func search(_ query: String) -> [String] {
        guard !query.isEmpty else { return allExercises }
        let lowered = query.lowercased()
        return allExercises.filter { $0.localizedStandardContains(lowered) }
    }
}
