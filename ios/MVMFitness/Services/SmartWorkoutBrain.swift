import Foundation

enum MovementPattern: String, CaseIterable {
    case squat
    case hinge
    case push
    case pull
    case carry
    case core
    case conditioning
}

enum SmartWorkoutBrain {

    private static let recentPatternsKey = "smartBrain_recentPatterns"
    private static let maxHistoryDays = 7

    static func classifyExercise(_ name: String) -> MovementPattern {
        let lower = name.lowercased()

        if lower.contains("squat") || lower.contains("lunge") || lower.contains("step-up") ||
           lower.contains("split squat") || lower.contains("pistol") || lower.contains("box jump") ||
           lower.contains("leg press") {
            return .squat
        }

        if lower.contains("deadlift") || lower.contains("rdl") || lower.contains("hip thrust") ||
           lower.contains("hip bridge") || lower.contains("glute bridge") || lower.contains("good morning") ||
           lower.contains("swing") || lower.contains("hinge") || lower.contains("leg curl") ||
           lower.contains("back extension") {
            return .hinge
        }

        if lower.contains("push-up") || lower.contains("press") || lower.contains("dip") ||
           lower.contains("pike") || lower.contains("handstand") || lower.contains("push up") ||
           lower.contains("jerk") || lower.contains("fly") {
            return .push
        }

        if lower.contains("pull-up") || lower.contains("row") || lower.contains("chin-up") ||
           lower.contains("pull up") || lower.contains("chin up") || lower.contains("muscle-up") ||
           lower.contains("face pull") || lower.contains("rear delt") || lower.contains("inverted") {
            return .pull
        }

        if lower.contains("carry") || lower.contains("drag") || lower.contains("sled") ||
           lower.contains("farmer") || lower.contains("suitcase") || lower.contains("bear hug") ||
           lower.contains("overhead carry") || lower.contains("sandbag") {
            return .carry
        }

        if lower.contains("plank") || lower.contains("sit-up") || lower.contains("crunch") ||
           lower.contains("flutter") || lower.contains("dead bug") || lower.contains("bird dog") ||
           lower.contains("hollow") || lower.contains("v-up") || lower.contains("mountain climber") ||
           lower.contains("side bridge") || lower.contains("leg raise") || lower.contains("woodchop") ||
           lower.contains("ab wheel") || lower.contains("core") || lower.contains("superman") {
            return .core
        }

        if lower.contains("run") || lower.contains("sprint") || lower.contains("jog") ||
           lower.contains("burpee") || lower.contains("shuttle") || lower.contains("walk") ||
           lower.contains("battle rope") || lower.contains("bike") || lower.contains("row") && lower.contains("erg") ||
           lower.contains("fartlek") || lower.contains("tempo") || lower.contains("interval") ||
           lower.contains("conditioning") || lower.contains("hill") {
            return .conditioning
        }

        return .push
    }

    static func classifyWorkout(_ exercises: [WorkoutExercise]) -> [MovementPattern: Int] {
        var counts: [MovementPattern: Int] = [:]
        for exercise in exercises {
            let pattern = classifyExercise(exercise.name)
            counts[pattern, default: 0] += 1
        }
        return counts
    }

    static func dominantPattern(_ exercises: [WorkoutExercise]) -> MovementPattern? {
        let counts = classifyWorkout(exercises)
        return counts.max(by: { $0.value < $1.value })?.key
    }

    static func recordWorkoutPatterns(_ exercises: [WorkoutExercise]) {
        let patterns = classifyWorkout(exercises)
        let dominant = patterns.max(by: { $0.value < $1.value })?.key ?? .push

        var history = loadPatternHistory()
        let entry = PatternEntry(date: Date(), dominantPattern: dominant.rawValue, patterns: patterns.mapKeys { $0.rawValue })
        history.append(entry)

        let cutoff = Calendar.current.date(byAdding: .day, value: -maxHistoryDays, to: .now) ?? .now
        history = history.filter { $0.date > cutoff }

        savePatternHistory(history)
    }

    static func shouldAvoidPattern(_ pattern: MovementPattern) -> Bool {
        let history = loadPatternHistory()
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now)) ?? .now

        let recentEntries = history.filter { $0.date >= yesterday }
        let recentDominant = recentEntries.compactMap { MovementPattern(rawValue: $0.dominantPattern) }

        return recentDominant.contains(pattern)
    }

    static func recommendedPatterns() -> [MovementPattern] {
        let history = loadPatternHistory()
        let calendar = Calendar.current
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: .now)) ?? .now

        let recentDominant = Set(
            history.filter { $0.date >= twoDaysAgo }
                .compactMap { MovementPattern(rawValue: $0.dominantPattern) }
        )

        let allPatterns: [MovementPattern] = [.squat, .hinge, .push, .pull, .carry, .core, .conditioning]
        let available = allPatterns.filter { !recentDominant.contains($0) }

        return available.isEmpty ? allPatterns : available
    }

    static func isBackToBackOverload(newExercises: [WorkoutExercise]) -> Bool {
        let newDominant = dominantPattern(newExercises)
        guard let pattern = newDominant else { return false }

        let highIntensityPatterns: Set<MovementPattern> = [.squat, .hinge, .push]
        guard highIntensityPatterns.contains(pattern) else { return false }

        return shouldAvoidPattern(pattern)
    }

    static func suggestAlternativeFocus() -> ArmyFocus {
        let recommended = recommendedPatterns()
        let primary = recommended.first ?? .conditioning

        switch primary {
        case .squat, .hinge: return .lowerStrength
        case .push: return .upperEndurance
        case .pull: return .upperEndurance
        case .carry: return .workCapacity
        case .core: return .coreRun
        case .conditioning: return .endurance
        }
    }

    // MARK: - Persistence

    private static func loadPatternHistory() -> [PatternEntry] {
        guard let data = UserDefaults.standard.data(forKey: recentPatternsKey) else { return [] }
        return (try? JSONDecoder().decode([PatternEntry].self, from: data)) ?? []
    }

    private static func savePatternHistory(_ history: [PatternEntry]) {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: recentPatternsKey)
        }
    }
}

private nonisolated struct PatternEntry: Codable, Sendable {
    let date: Date
    let dominantPattern: String
    let patterns: [String: Int]
}

private extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            result[transform(key)] = value
        }
        return result
    }
}
