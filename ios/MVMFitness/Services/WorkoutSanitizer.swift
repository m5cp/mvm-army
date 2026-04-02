import Foundation

enum WorkoutSanitizer {

    private static let prohibitedNames: Set<String> = [
        "murph", "fran", "cindy", "grace", "helen", "dt", "diane", "elizabeth",
        "annie", "barbara", "chelsea", "eva", "isabel", "jackie", "karen", "kelly",
        "linda", "lynne", "mary", "nancy", "nicole", "amanda",
        "jt", "michael", "daniel", "josh", "nate", "randy", "tommy v", "griff",
        "luce", "rj", "loredo", "whitten", "wittman", "the seven", "clovis",
        "jag 28", "helton", "mcghee", "arnie", "murph light",
        "filthy fifty", "fight gone bad", "bear complex"
    ]

    private static let prohibitedSubstrings: [String] = [
        "in honor of", "dedicated to", "in memory of", "tribute to",
        "memorial workout", "hero workout", "hero wod",
        "crossfit", "wod"
    ]

    private static let powerWords: [String] = [
        "Iron", "Relentless", "Apex", "Unbroken", "Tactical",
        "Velocity", "Prime", "Forged", "Endurance", "Elite",
        "Vanguard", "Sentinel", "Resolute", "Titan", "Surge",
        "Fortress", "Valor", "Steadfast", "Catalyst", "Pinnacle"
    ]

    private static let trainingTypes: [String] = [
        "Protocol", "Circuit", "Test", "Grind", "Builder",
        "Session", "Effort", "Challenge", "Complex", "Series"
    ]

    static func isProhibited(_ name: String) -> Bool {
        let lower = name.lowercased().trimmingCharacters(in: .whitespaces)
        if prohibitedNames.contains(lower) { return true }
        for substring in prohibitedSubstrings {
            if lower.contains(substring) { return true }
        }
        return false
    }

    static func sanitizeName(_ name: String) -> String {
        guard isProhibited(name) else { return name }
        return generateEliteName()
    }

    static func sanitizeDescription(_ description: String) -> String {
        var result = description
        for substring in prohibitedSubstrings {
            result = result.replacingOccurrences(of: substring, with: "", options: .caseInsensitive)
        }
        result = result.replacingOccurrences(of: "CrossFit", with: "FunctionFitness", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "WOD", with: "Workout", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "Hero workout", with: "Workout", options: .caseInsensitive)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func sanitizeNotes(_ notes: String?) -> String? {
        guard let notes, !notes.isEmpty else { return notes }
        var result = notes
        for substring in prohibitedSubstrings {
            result = result.replacingOccurrences(of: substring, with: "", options: .caseInsensitive)
        }
        result = result.replacingOccurrences(of: "CrossFit", with: "FunctionFitness", options: .caseInsensitive)
        let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func generateEliteName() -> String {
        let power = powerWords.randomElement() ?? "Elite"
        let type = trainingTypes.randomElement() ?? "Protocol"
        return "The \(power) \(type)"
    }

    static func sanitizeTemplate(_ template: WODTemplate) -> WODTemplate {
        WODTemplate(
            title: sanitizeName(template.title),
            category: template.category,
            format: template.format,
            durationMinutes: template.durationMinutes,
            equipment: template.equipment,
            movements: template.movements,
            workoutDescription: sanitizeDescription(template.workoutDescription),
            notes: sanitizeNotes(template.notes)
        )
    }

    static func sanitizeWorkoutDay(_ day: WorkoutDay) -> WorkoutDay {
        WorkoutDay(
            dayIndex: day.dayIndex,
            date: day.date,
            title: sanitizeName(day.title),
            exercises: day.exercises,
            isCompleted: day.isCompleted,
            isRestDay: day.isRestDay,
            templateTag: day.templateTag,
            tags: day.tags.map { sanitizeTag($0) },
            source: day.source,
            startTime: day.startTime,
            endTime: day.endTime
        )
    }

    static func sanitizeCompletedRecord(_ record: CompletedWorkoutRecord) -> CompletedWorkoutRecord {
        let sanitizedTitle = sanitizeName(record.title)
        guard sanitizedTitle != record.title else { return record }
        return CompletedWorkoutRecord(
            date: record.date,
            title: sanitizedTitle,
            exerciseCount: record.exerciseCount,
            exercises: record.exercises,
            source: record.source
        )
    }

    private static func sanitizeTag(_ tag: String) -> String {
        let lower = tag.lowercased()
        if lower.contains("memorial") || lower.contains("hero") {
            return "FunctionFitness"
        }
        if lower.contains("crossfit") {
            return "FunctionFitness"
        }
        return tag
    }
}
