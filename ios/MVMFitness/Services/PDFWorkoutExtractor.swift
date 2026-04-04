import Foundation
import PDFKit

enum PDFWorkoutExtractor {

    struct ExtractedWorkout: Sendable {
        let title: String
        let exercises: [WorkoutExercise]
        let rawText: String
        let tags: [String]
    }

    nonisolated static func extractText(from url: URL) -> String? {
        guard let document = PDFDocument(url: url) else { return nil }
        var fullText = ""
        for i in 0..<document.pageCount {
            guard let page = document.page(at: i) else { continue }
            if let pageText = page.string {
                fullText += pageText + "\n"
            }
        }
        return fullText.isEmpty ? nil : fullText
    }

    static func parseWorkout(from text: String) -> ExtractedWorkout {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let title = extractTitle(from: lines)
        let exercises = extractExercises(from: lines)
        let tags = extractTags(from: text)

        return ExtractedWorkout(
            title: title,
            exercises: exercises,
            rawText: text,
            tags: tags
        )
    }

    private static func extractTitle(from lines: [String]) -> String {
        let titleKeywords = ["workout", "routine", "program", "plan", "training", "session", "wod", "pt"]

        for line in lines.prefix(10) {
            let lower = line.lowercased()
            if titleKeywords.contains(where: { lower.contains($0) }) && line.count < 80 {
                return cleanTitle(line)
            }
        }

        if let first = lines.first, first.count < 60 {
            return cleanTitle(first)
        }

        return "Imported Workout"
    }

    private static func cleanTitle(_ raw: String) -> String {
        var title = raw
            .replacingOccurrences(of: ":", with: "")
            .trimmingCharacters(in: .punctuationCharacters)
            .trimmingCharacters(in: .whitespaces)
        if title.count > 50 {
            title = String(title.prefix(50)) + "…"
        }
        return title.isEmpty ? "Imported Workout" : title
    }

    private static func extractExercises(from lines: [String]) -> [WorkoutExercise] {
        var exercises: [WorkoutExercise] = []
        let skipPrefixes = ["note", "rest", "warm", "cool", "tip", "equipment", "objective", "formation"]

        for line in lines {
            let lower = line.lowercased()
            if skipPrefixes.contains(where: { lower.hasPrefix($0) }) { continue }
            if line.count < 3 { continue }

            if let exercise = parseExerciseLine(line) {
                exercises.append(exercise)
            }
        }

        if exercises.isEmpty {
            for line in lines {
                if line.count >= 4 && line.count <= 100 && !line.contains("http") {
                    let lower = line.lowercased()
                    let hasExerciseHint = exerciseHints.contains(where: { lower.contains($0) })
                    if hasExerciseHint {
                        exercises.append(WorkoutExercise(
                            name: cleanExerciseName(line),
                            sets: 3,
                            reps: 10,
                            category: guessCategory(line)
                        ))
                    }
                }
            }
        }

        return exercises
    }

    private static let exerciseHints = [
        "squat", "press", "push", "pull", "curl", "row", "deadlift", "lunge",
        "plank", "crunch", "sit-up", "burpee", "jump", "run", "sprint",
        "dip", "fly", "raise", "extension", "swing", "clean", "snatch",
        "thruster", "muscle-up", "box", "wall ball", "rope", "carry",
        "hip", "bridge", "leg", "step", "bike", "rower", "shuttle",
        "farmer", "sled", "drag", "slam", "toss", "throw",
        "bench", "overhead", "military", "lateral", "front",
        "rdl", "sdc", "ruck", "flutter", "mountain climber",
        "pistol", "turkish", "kb", "db", "bb"
    ]

    private static func parseExerciseLine(_ line: String) -> WorkoutExercise? {
        let setsRepsPatterns: [(pattern: String, setsIdx: Int, repsIdx: Int)] = [
            (#"(\d+)\s*[xX×]\s*(\d+)"#, 1, 2),
            (#"(\d+)\s*sets?\s*[xX×of]*\s*(\d+)\s*reps?"#, 1, 2),
            (#"(\d+)\s*sets?\s*(\d+)\s*reps?"#, 1, 2),
        ]

        for (pattern, sI, rI) in setsRepsPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(line.startIndex..., in: line)
                if let match = regex.firstMatch(in: line, range: range) {
                    let setsStr = (line as NSString).substring(with: match.range(at: sI))
                    let repsStr = (line as NSString).substring(with: match.range(at: rI))
                    let sets = Int(setsStr) ?? 3
                    let reps = Int(repsStr) ?? 10

                    let matchRange = Range(match.range, in: line)!
                    var name = line
                    name.removeSubrange(matchRange)
                    name = cleanExerciseName(name)

                    if name.count < 2 { return nil }

                    let weight = extractWeight(from: line)

                    return WorkoutExercise(
                        name: name,
                        sets: min(max(sets, 1), 20),
                        reps: min(max(reps, 1), 200),
                        weight: weight,
                        category: guessCategory(name)
                    )
                }
            }
        }

        let durationPattern = #"(\d+)\s*(min|minute|sec|second|s)\b"#
        if let regex = try? NSRegularExpression(pattern: durationPattern, options: .caseInsensitive) {
            let range = NSRange(line.startIndex..., in: line)
            if let match = regex.firstMatch(in: line, range: range) {
                let valueStr = (line as NSString).substring(with: match.range(at: 1))
                let unitStr = (line as NSString).substring(with: match.range(at: 2)).lowercased()
                let value = Int(valueStr) ?? 0

                let seconds: Int
                if unitStr.hasPrefix("min") {
                    seconds = value * 60
                } else {
                    seconds = value
                }

                let matchRange = Range(match.range, in: line)!
                var name = line
                name.removeSubrange(matchRange)
                name = cleanExerciseName(name)

                if name.count < 2 { return nil }

                return WorkoutExercise(
                    name: name,
                    sets: 1,
                    durationSeconds: max(seconds, 10),
                    category: .timed
                )
            }
        }

        let repsOnlyPattern = #"(\d+)\s*reps?\b"#
        if let regex = try? NSRegularExpression(pattern: repsOnlyPattern, options: .caseInsensitive) {
            let range = NSRange(line.startIndex..., in: line)
            if let match = regex.firstMatch(in: line, range: range) {
                let repsStr = (line as NSString).substring(with: match.range(at: 1))
                let reps = Int(repsStr) ?? 10

                let matchRange = Range(match.range, in: line)!
                var name = line
                name.removeSubrange(matchRange)
                name = cleanExerciseName(name)

                if name.count < 2 { return nil }

                return WorkoutExercise(
                    name: name,
                    sets: 3,
                    reps: min(max(reps, 1), 200),
                    category: guessCategory(name)
                )
            }
        }

        return nil
    }

    private static func cleanExerciseName(_ raw: String) -> String {
        var name = raw
            .replacingOccurrences(of: #"^\d+[\.\)\-\s]*"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: "[•\\-–—\\*#]", with: "", options: .regularExpression)
            .replacingOccurrences(of: #"@\s*\d+.*$"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .punctuationCharacters)
            .trimmingCharacters(in: .whitespaces)

        if name.count > 45 {
            name = String(name.prefix(45))
        }

        return name
    }

    private static func extractWeight(from line: String) -> String {
        let weightPattern = #"@?\s*(\d+)\s*(lbs?|kg|pounds?|kilograms?)\b"#
        if let regex = try? NSRegularExpression(pattern: weightPattern, options: .caseInsensitive) {
            let range = NSRange(line.startIndex..., in: line)
            if let match = regex.firstMatch(in: line, range: range) {
                let value = (line as NSString).substring(with: match.range(at: 1))
                let unit = (line as NSString).substring(with: match.range(at: 2)).lowercased()
                let normalizedUnit = unit.hasPrefix("kg") || unit.hasPrefix("kilo") ? "kg" : "lbs"
                return "\(value) \(normalizedUnit)"
            }
        }
        return ""
    }

    private static func guessCategory(_ name: String) -> ExerciseCategory {
        let lower = name.lowercased()
        if lower.contains("run") || lower.contains("bike") || lower.contains("row") ||
           lower.contains("swim") || lower.contains("walk") || lower.contains("sprint") ||
           lower.contains("jog") || lower.contains("ruck") {
            return .cardio
        }
        if lower.contains("plank") || lower.contains("hold") || lower.contains("hang") {
            return .timed
        }
        if lower.contains("push-up") || lower.contains("push up") || lower.contains("pull-up") ||
           lower.contains("pull up") || lower.contains("burpee") || lower.contains("squat") && !lower.contains("bar") ||
           lower.contains("sit-up") || lower.contains("sit up") || lower.contains("crunch") ||
           lower.contains("lunge") && !lower.contains("bar") || lower.contains("dip") ||
           lower.contains("mountain climber") || lower.contains("flutter") {
            return .bodyweight
        }
        return .strength
    }

    private static func extractTags(from text: String) -> [String] {
        var tags: [String] = ["Imported"]
        let lower = text.lowercased()

        if lower.contains("crossfit") || lower.contains("wod") || lower.contains("amrap") || lower.contains("emom") {
            tags.append("FunctionFitness")
        }
        if lower.contains("strength") || lower.contains("powerlifting") || lower.contains("hypertrophy") {
            tags.append("Strength")
        }
        if lower.contains("cardio") || lower.contains("running") || lower.contains("endurance") {
            tags.append("Cardio")
        }
        if lower.contains("army") || lower.contains("military") || lower.contains("acft") || lower.contains("aft") || lower.contains("prt") {
            tags.append("Military PT")
        }
        if lower.contains("bodyweight") || lower.contains("calisthenics") {
            tags.append("Bodyweight")
        }

        return tags
    }
}
