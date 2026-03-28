import Foundation

nonisolated struct StepDay: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var date: Date
    var steps: Int

    init(date: Date, steps: Int) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.steps = steps
    }
}
