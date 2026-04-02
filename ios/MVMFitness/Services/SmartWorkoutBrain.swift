import Foundation

enum MovementPattern: String, CaseIterable {
    case squat
    case hinge
    case push
    case pull
    case carry
    case core
    case conditioning
    case sprint
}

nonisolated enum TrainingGoal: String, Codable, CaseIterable, Sendable {
    case strength = "Strength"
    case hypertrophy = "Hypertrophy"
    case muscularEndurance = "Muscular Endurance"
    case power = "Power"
    case aftReadiness = "AFT Readiness"
    case generalFitness = "General Fitness"
    case conditioning = "Conditioning"
}

nonisolated enum PeriodizationType: String, Codable, CaseIterable, Sendable {
    case linear = "Linear"
    case dailyUndulating = "Daily Undulating"
    case block = "Block"
}

nonisolated enum WorkoutStyle: String, Codable, CaseIterable, Sendable, Identifiable {
    case functional = "Functional Fitness"
    case freeWeight = "Free Weights"
    case hybrid = "Elite Challenge"
    case aftFocused = "AFT Focused"
    case bodyweight = "Bodyweight"

    var id: String { rawValue }
}

nonisolated struct SmartBrainSelection: Sendable {
    var goal: TrainingGoal
    var duration: Int
    var equipment: WODEquipment
    var difficulty: IntensityGrade
    var trainingFrequency: Int
    var focusArea: TrainingSplit
    var workoutStyle: WorkoutStyle
    var level: FitnessLevel

    init(
        goal: TrainingGoal = .generalFitness,
        duration: Int = 45,
        equipment: WODEquipment = .gym,
        difficulty: IntensityGrade = .moderate,
        trainingFrequency: Int = 4,
        focusArea: TrainingSplit = .fullBody,
        workoutStyle: WorkoutStyle = .functional,
        level: FitnessLevel = .intermediate
    ) {
        self.goal = goal
        self.duration = duration
        self.equipment = equipment
        self.difficulty = difficulty
        self.trainingFrequency = trainingFrequency
        self.focusArea = focusArea
        self.workoutStyle = workoutStyle
        self.level = level
    }
}

enum SmartWorkoutBrain {

    private static let recentPatternsKey = "smartBrain_recentPatterns"
    private static let maxHistoryDays = 7

    static func classifyExercise(_ name: String) -> MovementPattern {
        let lower = name.lowercased()

        if lower.contains("squat") || lower.contains("lunge") || lower.contains("step-up") ||
           lower.contains("split squat") || lower.contains("pistol") || lower.contains("box jump") ||
           lower.contains("leg press") || lower.contains("leg extension") || lower.contains("adductor") {
            return .squat
        }

        if lower.contains("deadlift") || lower.contains("rdl") || lower.contains("hip thrust") ||
           lower.contains("hip bridge") || lower.contains("glute bridge") || lower.contains("good morning") ||
           lower.contains("swing") || lower.contains("hinge") || lower.contains("leg curl") ||
           lower.contains("back extension") || lower.contains("hamstring") || lower.contains("nordic") {
            return .hinge
        }

        if lower.contains("push-up") || lower.contains("press") || lower.contains("dip") ||
           lower.contains("pike") || lower.contains("handstand") || lower.contains("push up") ||
           lower.contains("jerk") || lower.contains("fly") || lower.contains("crossover") ||
           lower.contains("skull crusher") || lower.contains("tricep") || lower.contains("pushdown") {
            return .push
        }

        if lower.contains("pull-up") || lower.contains("row") || lower.contains("chin-up") ||
           lower.contains("pull up") || lower.contains("chin up") || lower.contains("muscle-up") ||
           lower.contains("face pull") || lower.contains("rear delt") || lower.contains("inverted") ||
           lower.contains("pulldown") || lower.contains("curl") || lower.contains("lat pull") ||
           lower.contains("t-bar") || lower.contains("straight-arm") {
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
           lower.contains("ab wheel") || lower.contains("core") || lower.contains("superman") ||
           lower.contains("hanging knee") || lower.contains("turkish get") {
            return .core
        }

        if lower.contains("sprint") || lower.contains("shuttle") || lower.contains("lateral shuffle") {
            return .sprint
        }

        if lower.contains("run") || lower.contains("jog") ||
           lower.contains("burpee") || lower.contains("walk") ||
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
        case .conditioning, .sprint: return .endurance
        }
    }

    // MARK: - Goal-Based Programming Parameters

    static func programmingParameters(for goal: TrainingGoal) -> (repRange: ClosedRange<Int>, restSeconds: Int, intensityBias: IntensityGrade) {
        switch goal {
        case .strength:
            return (1...6, 180, .high)
        case .hypertrophy:
            return (8...12, 90, .moderate)
        case .muscularEndurance:
            return (15...25, 45, .moderate)
        case .power:
            return (1...5, 180, .high)
        case .aftReadiness:
            return (5...15, 90, .high)
        case .generalFitness:
            return (8...15, 60, .moderate)
        case .conditioning:
            return (10...20, 30, .moderate)
        }
    }

    static func periodizationType(for goal: TrainingGoal, level: FitnessLevel) -> PeriodizationType {
        switch goal {
        case .strength, .power:
            return level == .advanced ? .block : .linear
        case .hypertrophy:
            return level == .advanced ? .dailyUndulating : .linear
        case .aftReadiness:
            return .dailyUndulating
        default:
            return .linear
        }
    }

    static func dailyUndulatingIntensity(dayIndex: Int) -> IntensityGrade {
        let pattern: [IntensityGrade] = [.high, .moderate, .low, .high, .moderate]
        return pattern[dayIndex % pattern.count]
    }

    // MARK: - Enhanced Selection with Smart Brain Selection

    static func selectWithBrain(
        from pool: [WODTemplate],
        selection: SmartBrainSelection,
        weekNumber: Int = 1,
        totalWeeks: Int = 4,
        dayIndex: Int = 0,
        excluding: Set<String> = []
    ) -> WODTemplate? {
        let candidates = pool.filter { !excluding.contains($0.title) }
        guard !candidates.isEmpty else { return pool.randomElement() }

        let recentSplits = recentTrainingSplits()
        let periodType = periodizationType(for: selection.goal, level: selection.level)
        let splits = recommendedSplit(daysPerWeek: selection.trainingFrequency, level: selection.level)
        let targetSplit = dayIndex < splits.count ? splits[dayIndex] : selection.focusArea

        let targetIntensity: IntensityGrade
        switch periodType {
        case .linear:
            targetIntensity = periodizationIntensity(weekNumber: weekNumber, totalWeeks: totalWeeks)
        case .dailyUndulating:
            targetIntensity = dailyUndulatingIntensity(dayIndex: dayIndex)
        case .block:
            let blockWeek = (weekNumber - 1) % 4
            switch blockWeek {
            case 0: targetIntensity = .moderate
            case 1: targetIntensity = .high
            case 2: targetIntensity = .extreme
            default: targetIntensity = .low
            }
        }

        let scored = candidates.map { template in
            let score = scoreTemplateEnhanced(
                template,
                selection: selection,
                targetSplit: targetSplit,
                targetIntensity: targetIntensity,
                recentSplits: recentSplits
            )
            return (template, score)
        }
        .filter { $0.1 > 0 }
        .sorted { $0.1 > $1.1 }

        guard !scored.isEmpty else { return candidates.randomElement() }

        let topCount = min(3, scored.count)
        return Array(scored.prefix(topCount)).randomElement()?.0
    }

    static func scoreTemplateEnhanced(
        _ template: WODTemplate,
        selection: SmartBrainSelection,
        targetSplit: TrainingSplit,
        targetIntensity: IntensityGrade,
        recentSplits: [TrainingSplit]
    ) -> Double {
        var score: Double = 50.0

        if WorkoutSanitizer.isProhibited(template.title) { return 0 }

        switch selection.equipment {
        case .gym: break
        case .minimal:
            if template.equipment == .gym { return 0 }
        case .none:
            if template.equipment == .gym || template.equipment == .minimal { return 0 }
        }

        let goalParams = programmingParameters(for: selection.goal)
        switch selection.goal {
        case .strength, .power:
            if template.category == .freeWeight { score += 20 }
            if template.intensityGrade == .high || template.intensityGrade == .extreme { score += 10 }
        case .hypertrophy:
            if template.category == .freeWeight { score += 15 }
            if template.intensityGrade == .moderate { score += 10 }
        case .muscularEndurance:
            if template.category == .bodyweight || template.category == .crossfit { score += 15 }
        case .aftReadiness:
            if template.category == .aftStyle { score += 25 }
            if template.category == .freeWeight && template.trainingSplit == .lowerBody { score += 10 }
        case .conditioning:
            if template.category == .crossfit || template.category == .bodyweight { score += 15 }
        case .generalFitness:
            score += 5
        }

        let durationDiff = abs(template.durationMinutes - selection.duration)
        if durationDiff <= 5 { score += 20 }
        else if durationDiff <= 15 { score += 10 }
        else if durationDiff > 30 { score -= 15 }

        if template.trainingSplit == targetSplit { score += 25 }

        if template.intensityGrade == targetIntensity {
            score += 15
        } else if let tIdx = IntensityGrade.allCases.firstIndex(of: template.intensityGrade),
                  let iIdx = IntensityGrade.allCases.firstIndex(of: targetIntensity),
                  abs(tIdx - iIdx) == 1 {
            score += 5
        }

        if template.intensityGrade == selection.difficulty { score += 10 }

        if template.trainingSplit == selection.focusArea { score += 10 }

        if recentSplits.contains(template.trainingSplit) { score -= 20 }

        let dominantMovements = template.movements.map { classifyMovement($0.name) }
        let dominantPattern = dominantMovements.reduce(into: [MovementPattern: Int]()) { $0[$1, default: 0] += 1 }
            .max(by: { $0.value < $1.value })?.key
        if let dominant = dominantPattern, shouldAvoidPattern(dominant) {
            score -= 25
        }

        let history = loadPatternHistory()
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now)) ?? .now
        let consecutiveHighDays = history.filter { $0.date >= yesterday }.count
        if consecutiveHighDays >= 2 && (template.intensityGrade == .high || template.intensityGrade == .extreme) {
            score -= 15
        }

        return max(score, 0)
    }

    static func selectWeekPlanWithBrain(
        pool: [WODTemplate],
        selection: SmartBrainSelection,
        weekNumber: Int = 1,
        totalWeeks: Int = 4
    ) -> [WODTemplate] {
        let daysPerWeek = selection.trainingFrequency
        var selected: [WODTemplate] = []
        var usedTitles: Set<String> = []

        for dayIndex in 0..<daysPerWeek {
            if let template = selectWithBrain(
                from: pool,
                selection: selection,
                weekNumber: weekNumber,
                totalWeeks: totalWeeks,
                dayIndex: dayIndex,
                excluding: usedTitles
            ) {
                selected.append(template)
                usedTitles.insert(template.title)
            } else if let fallback = pool.filter({ !usedTitles.contains($0.title) }).randomElement() {
                selected.append(fallback)
                usedTitles.insert(fallback.title)
            }
        }

        return selected
    }

    // MARK: - AFT-Focused Selection

    static func selectAFTWorkout(
        from pool: [WODTemplate],
        weakEvents: [String] = [],
        equipment: WODEquipment = .gym,
        excluding: Set<String> = []
    ) -> WODTemplate? {
        let aftPool = pool.filter { $0.category == .aftStyle || $0.category == .freeWeight }
        let candidates = aftPool.filter { !excluding.contains($0.title) }
        guard !candidates.isEmpty else { return pool.randomElement() }

        let scored = candidates.map { template -> (WODTemplate, Double) in
            var score: Double = 50.0

            if template.category == .aftStyle { score += 20 }

            switch equipment {
            case .gym: break
            case .minimal:
                if template.equipment == .gym { return (template, 0) }
            case .none:
                if template.equipment != .none { return (template, 0) }
            }

            for event in weakEvents {
                let eventLower = event.lowercased()
                if eventLower.contains("deadlift") && template.trainingSplit == .lowerBody { score += 15 }
                if eventLower.contains("push") && (template.trainingSplit == .push || template.trainingSplit == .upperBody) { score += 15 }
                if eventLower.contains("sprint") || eventLower.contains("sdc") {
                    if template.trainingSplit == .conditioning || template.trainingSplit == .mixed { score += 15 }
                }
                if eventLower.contains("plank") || eventLower.contains("core") {
                    let hasCoreWork = template.movements.contains { classifyMovement($0.name) == .core }
                    if hasCoreWork { score += 15 }
                }
                if eventLower.contains("run") || eventLower.contains("2mr") {
                    let hasRunning = template.movements.contains { classifyMovement($0.name) == .conditioning }
                    if hasRunning { score += 15 }
                }
            }

            let recentSplits = recentTrainingSplits()
            if recentSplits.contains(template.trainingSplit) { score -= 15 }

            if WorkoutSanitizer.isProhibited(template.title) { return (template, 0) }

            return (template, max(score, 0))
        }
        .filter { $0.1 > 0 }
        .sorted { $0.1 > $1.1 }

        guard !scored.isEmpty else { return candidates.randomElement() }
        let topCount = min(3, scored.count)
        return Array(scored.prefix(topCount)).randomElement()?.0
    }

    // MARK: - Consecutive Intensity Check

    static func consecutiveHighIntensityDays() -> Int {
        let history = loadPatternHistory()
        let calendar = Calendar.current
        var count = 0
        var checkDate = calendar.startOfDay(for: .now)

        for _ in 0..<7 {
            guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            let dayEntries = history.filter { calendar.isDate($0.date, inSameDayAs: previous) }
            if dayEntries.isEmpty { break }
            count += 1
            checkDate = previous
        }

        return count
    }

    static func shouldReduceIntensity() -> Bool {
        consecutiveHighIntensityDays() >= 3
    }

    // MARK: - Split Logic

    static func recommendedSplit(daysPerWeek: Int, level: FitnessLevel = .intermediate) -> [TrainingSplit] {
        switch daysPerWeek {
        case 1...2:
            return Array(repeating: TrainingSplit.fullBody, count: daysPerWeek)
        case 3:
            return [.fullBody, .fullBody, .fullBody]
        case 4:
            return [.upperBody, .lowerBody, .upperBody, .lowerBody]
        case 5:
            if level == .advanced {
                return [.push, .pull, .legs, .upperBody, .conditioning]
            }
            return [.upperBody, .lowerBody, .fullBody, .upperBody, .lowerBody]
        case 6:
            if level == .advanced {
                return [.push, .pull, .legs, .push, .pull, .legs]
            }
            return [.upperBody, .lowerBody, .push, .pull, .legs, .conditioning]
        default:
            return [.fullBody, .upperBody, .lowerBody]
        }
    }

    // MARK: - Periodization

    static func periodizationIntensity(weekNumber: Int, totalWeeks: Int) -> IntensityGrade {
        guard totalWeeks > 1 else { return .moderate }
        let progress = Double(weekNumber - 1) / Double(totalWeeks - 1)

        let isDeloadWeek = weekNumber > 1 && weekNumber % 4 == 0
        if isDeloadWeek { return .low }

        if progress < 0.33 { return .moderate }
        if progress < 0.66 { return .high }
        return .extreme
    }

    static func shouldDeload(weekNumber: Int) -> Bool {
        weekNumber > 1 && weekNumber % 4 == 0
    }

    // MARK: - WOD Template Scoring & Selection (Legacy compatible)

    static func scoreTemplate(
        _ template: WODTemplate,
        equipment: WODEquipment,
        targetDuration: Int?,
        targetSplit: TrainingSplit?,
        targetIntensity: IntensityGrade?,
        recentSplits: [TrainingSplit]
    ) -> Double {
        var score: Double = 50.0

        switch equipment {
        case .gym:
            break
        case .minimal:
            if template.equipment == .gym { return 0 }
        case .none:
            if template.equipment == .gym || template.equipment == .minimal { return 0 }
        }

        if let dur = targetDuration {
            let diff = abs(template.durationMinutes - dur)
            if diff <= 5 { score += 20 }
            else if diff <= 15 { score += 10 }
            else if diff > 30 { score -= 15 }
        }

        if let split = targetSplit, template.trainingSplit == split {
            score += 25
        }

        if let intensity = targetIntensity {
            if template.intensityGrade == intensity {
                score += 15
            } else if let tIdx = IntensityGrade.allCases.firstIndex(of: template.intensityGrade),
                      let iIdx = IntensityGrade.allCases.firstIndex(of: intensity),
                      abs(tIdx - iIdx) == 1 {
                score += 5
            }
        }

        if recentSplits.contains(template.trainingSplit) {
            score -= 20
        }

        let dominantMovements = template.movements.map { classifyMovement($0.name) }
        let dominantPattern = dominantMovements.reduce(into: [MovementPattern: Int]()) { $0[$1, default: 0] += 1 }
            .max(by: { $0.value < $1.value })?.key
        if let dominant = dominantPattern, shouldAvoidPattern(dominant) {
            score -= 25
        }

        if WorkoutSanitizer.isProhibited(template.title) {
            return 0
        }

        return max(score, 0)
    }

    static func classifyMovement(_ name: String) -> MovementPattern {
        classifyExercise(name)
    }

    static func selectBestTemplate(
        from pool: [WODTemplate],
        equipment: WODEquipment,
        targetDuration: Int? = nil,
        targetSplit: TrainingSplit? = nil,
        targetIntensity: IntensityGrade? = nil,
        recentSplits: [TrainingSplit] = [],
        excluding: Set<String> = []
    ) -> WODTemplate? {
        let candidates = pool.filter { !excluding.contains($0.title) }
        guard !candidates.isEmpty else { return pool.randomElement() }

        let scored = candidates.map { template in
            (template, scoreTemplate(
                template,
                equipment: equipment,
                targetDuration: targetDuration,
                targetSplit: targetSplit,
                targetIntensity: targetIntensity,
                recentSplits: recentSplits
            ))
        }
        .filter { $0.1 > 0 }
        .sorted { $0.1 > $1.1 }

        guard !scored.isEmpty else { return candidates.randomElement() }

        let topCount = min(3, scored.count)
        let topCandidates = Array(scored.prefix(topCount))
        return topCandidates.randomElement()?.0
    }

    static func selectWeekPlan(
        pool: [WODTemplate],
        daysPerWeek: Int,
        equipment: WODEquipment,
        level: FitnessLevel = .intermediate,
        weekNumber: Int = 1,
        totalWeeks: Int = 4
    ) -> [WODTemplate] {
        let splits = recommendedSplit(daysPerWeek: daysPerWeek, level: level)
        let intensity = periodizationIntensity(weekNumber: weekNumber, totalWeeks: totalWeeks)
        var selected: [WODTemplate] = []
        var usedTitles: Set<String> = []
        var recentSplits: [TrainingSplit] = []

        for split in splits {
            if let template = selectBestTemplate(
                from: pool,
                equipment: equipment,
                targetSplit: split,
                targetIntensity: intensity,
                recentSplits: recentSplits,
                excluding: usedTitles
            ) {
                selected.append(template)
                usedTitles.insert(template.title)
                recentSplits.append(template.trainingSplit)
            } else if let fallback = pool.filter({ !usedTitles.contains($0.title) }).randomElement() {
                selected.append(fallback)
                usedTitles.insert(fallback.title)
                recentSplits.append(fallback.trainingSplit)
            }
        }

        return selected
    }

    // MARK: - Record WOD Split History

    private static let recentSplitsKey = "smartBrain_recentSplits"

    static func recordWODSplit(_ split: TrainingSplit) {
        var splits = loadRecentSplits()
        splits.append(split.rawValue)
        if splits.count > 14 { splits = Array(splits.suffix(14)) }
        UserDefaults.standard.set(splits, forKey: recentSplitsKey)
    }

    static func loadRecentSplits() -> [String] {
        UserDefaults.standard.stringArray(forKey: recentSplitsKey) ?? []
    }

    static func recentTrainingSplits(last count: Int = 3) -> [TrainingSplit] {
        loadRecentSplits().suffix(count).compactMap { TrainingSplit(rawValue: $0) }
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
